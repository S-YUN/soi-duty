import 'dart:async';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/core/providers/clock_provider.dart';
import 'package:soi_duty/core/providers/database_providers.dart';
import 'package:soi_duty/core/providers/notification_providers.dart';
import 'package:soi_duty/data/database/app_database.dart';
import 'package:soi_duty/data/repository/drift_notification_state_repository.dart';
import 'package:soi_duty/data/repository/drift_work_record_repository.dart';
import 'package:soi_duty/domain/model/work_record.dart';
import 'package:soi_duty/domain/model/work_type.dart';
import 'package:soi_duty/domain/notification/clock_out_notice.dart';
import 'package:soi_duty/domain/repository/notification_scheduler.dart';
import 'package:soi_duty/presentation/notification/clock_out_notification_sync.dart';
import 'package:soi_duty/presentation/notification/notification_texts.dart';
import 'package:soi_duty/presentation/settings/settings_controller.dart';
import 'package:soi_duty/presentation/today/today_controller.dart';
import 'package:soi_duty/presentation/today/today_state.dart';

import '../helpers/fake_notification_scheduler.dart';
import '../helpers/records.dart';

/// 퇴근 알림 예약을 "한 곳에서 다시 맞추는" 동기화. OS 대신 Fake가 무엇이 언제 예약·발송·취소됐는지 적는다.
/// 2026-09-14(월)~18(금) 주, 오늘은 16(수). 월·화는 9–18시(8h)로 채워 둔다 → 일반 출근 08:30이면 17:30.
void main() {
  late AppDatabase db;
  late FakeNotificationScheduler os;
  late DateTime now;
  late StreamController<DateTime> ticks;
  final containers = <ProviderContainer>[];

  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    os = FakeNotificationScheduler();
    now = d(16, 8, 30);
    ticks = StreamController<DateTime>.broadcast();
    final repo = DriftWorkRecordRepository(db);
    await repo.save(rec(14, inH: 9, outH: 18));
    await repo.save(rec(15, inH: 9, outH: 18));
  });

  tearDown(() async {
    for (final c in containers) {
      c.dispose();
    }
    containers.clear();
    await ticks.close();
    await db.close();
  });

  /// 앱 프로세스 하나. 같은 DB·같은 OS(Fake)로 다시 만들면 "앱을 껐다 켠" 것이다.
  ProviderContainer launch({bool startSync = true}) {
    final c = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(() => now),
        nowProvider.overrideWith((ref) async* {
          yield now;
          yield* ticks.stream;
        }),
        notificationSchedulerProvider.overrideWithValue(os),
      ],
    );
    containers.add(c);
    c.listen(todayControllerProvider, (_, _) {});
    c.listen(allRecordsProvider, (_, _) {});
    c.listen(appSettingsProvider, (_, _) {});
    if (startSync) c.listen(clockOutNotificationSyncProvider, (_, _) {});
    return c;
  }

  /// 스트림 방출 → 계획 재계산 → 동기화가 가라앉을 때까지 기다렸다가 조건을 본다.
  Future<void> settle(ProviderContainer c, [bool Function()? until]) async {
    for (var i = 0; i < 100; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await c.read(clockOutNotificationSyncProvider.notifier).sync();
      if (until != null && until()) return;
      if (until == null && i >= 6) return;
    }
    if (until != null) fail('조건에 도달하지 못함. log: ${os.log}');
  }

  Future<void> enable(ProviderContainer c) async {
    await c.read(settingsControllerProvider.notifier).setClockOutNotification(true);
    await settle(c);
  }

  TodayController today(ProviderContainer c) => c.read(todayControllerProvider.notifier);

  /// 오늘 화면 상태가 조건에 닿을 때까지 — 화면이 다음 버튼을 그릴 때까지 사용자는 누를 수 없다.
  Future<void> waitToday(ProviderContainer c, bool Function(TodayState) test) async {
    for (var i = 0; i < 100; i++) {
      final s = c.read(todayControllerProvider).value;
      if (s != null && test(s)) return;
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    fail('오늘 상태가 기대대로 바뀌지 않음');
  }
  Future<ClockOutNotice?> stored() => DriftNotificationStateRepository(db).lastNotice();
  ClockOutNotice daily(int h, [int m = 0]) => ClockOutNotice(ClockOutNoticeKind.daily, d(16, h, m));

  group('켜고 끄기 · 권한', () {
    test('꺼져 있으면(기본) 출근해도 예약하지 않는다', () async {
      final c = launch();
      await today(c).clockIn();
      await settle(c);
      expect(os.count('schedule'), 0);
      expect(os.scheduledAt, isNull);
      expect(await stored(), isNull);
    });

    test('켜짐 + 허용: 출근(08:30) → 17:30에 일일 알림 하나, 저장된다', () async {
      final c = launch();
      await enable(c);
      await today(c).clockIn();
      await settle(c, () => os.scheduledAt != null);
      expect(os.scheduledAt, d(16, 17, 30));
      expect(os.scheduledTitle, NotificationTexts.dailyTitle);
      expect(os.scheduledBody, NotificationTexts.dailyBody);
      expect(os.count('schedule'), 1);
      expect(os.shown, isEmpty);
      expect(await stored(), daily(17, 30));
    });

    test('근무 중에 알림을 켜면 그때 예약된다, 끄면 취소된다', () async {
      final c = launch();
      await today(c).clockIn();
      await settle(c);
      expect(os.scheduledAt, isNull);
      await enable(c);
      expect(os.scheduledAt, d(16, 17, 30));
      await c.read(settingsControllerProvider.notifier).setClockOutNotification(false);
      await settle(c, () => os.scheduledAt == null);
      expect(await stored(), isNull);
    });

    test('켜짐 + OS 미허용 → 예약 없음. OS에서 허용하고 돌아오면(sync) 예약된다', () async {
      os.osStatus = OsNotificationStatus.notGranted;
      final c = launch();
      await enable(c);
      await today(c).clockIn();
      await settle(c);
      expect(os.count('schedule'), 0);
      os.osStatus = OsNotificationStatus.granted;
      await settle(c, () => os.scheduledAt != null);
      expect(os.scheduledAt, d(16, 17, 30));
    });

    test('예약해 둔 뒤 OS에서 알림을 끄고 돌아오면 취소하고 저장을 지운다', () async {
      final c = launch();
      await enable(c);
      await today(c).clockIn();
      await settle(c, () => os.scheduledAt != null);
      os.osStatus = OsNotificationStatus.notGranted;
      await settle(c, () => os.scheduledAt == null);
      expect(await stored(), isNull);
    });
  });

  group('오늘 상태가 바뀌면 다시 맞춘다', () {
    late ProviderContainer c;
    setUp(() async {
      c = launch();
      await enable(c);
      await today(c).clockIn();
      await settle(c, () => os.scheduledAt == d(16, 17, 30));
    });

    test('퇴근 → 취소 (기준 전에 퇴근하면 알림이 가지 않는다)', () async {
      now = d(16, 15);
      await today(c).clockOut();
      await settle(c, () => os.scheduledAt == null);
      expect(os.shown, isEmpty);
      expect(await stored(), isNull);
    });

    test('공제하고 퇴근 → 취소', () async {
      now = d(16, 15);
      await today(c).clockOut(deductRemaining: true);
      await settle(c, () => os.scheduledAt == null);
      expect(os.shown, isEmpty);
    });

    test('출근 취소 → 취소', () async {
      await today(c).cancelClockIn();
      await settle(c, () => os.scheduledAt == null);
      expect(await stored(), isNull);
    });

    test('출근 변경(08:00) → 17:00으로 대체', () async {
      await today(c).setClockIn(d(16, 8));
      await settle(c, () => os.scheduledAt == d(16, 17));
      expect(await stored(), daily(17));
    });

    test('반차 체크 → 12:30, 해제 → 17:30', () async {
      await today(c).setHalfDay(true);
      await settle(c, () => os.scheduledAt == d(16, 12, 30));
      await today(c).setHalfDay(false);
      await settle(c, () => os.scheduledAt == d(16, 17, 30));
    });

    test('시간 출장을 남겨도 예약은 그대로 — 다시 걸지도 않는다', () async {
      final before = os.count('schedule');
      await today(c).setTrip(d(16, 8, 30), d(16, 11, 30));
      await settle(c);
      expect(os.scheduledAt, d(16, 17, 30));
      expect(os.count('schedule'), before);
    });

    test('지난 날 기록을 고쳐도 계획이 같으면 다시 걸지 않는다 (수요일은 주간 잔여와 무관)', () async {
      final before = os.count('schedule');
      await DriftWorkRecordRepository(db).save(rec(15, inH: 9, outH: 19));
      await settle(c);
      expect(os.count('schedule'), before);
      expect(os.scheduledAt, d(16, 17, 30));
    });

    test('연속 변경: 반차 → 출근 변경을 동기화가 가라앉기 전에 이어 불러도 마지막 상태로 맞는다', () async {
      await today(c).setHalfDay(true);
      // 화면이 반차를 그린 직후 바로 다음 조작 — 동기화는 아직 앞의 변경을 처리하는 중일 수 있다.
      await waitToday(c, (s) => s.isHalfDay);
      await today(c).setClockIn(d(16, 8));
      await settle(c, () => os.scheduledAt == d(16, 12));
      expect(await stored(), ClockOutNotice(ClockOutNoticeKind.daily, d(16, 12)));
    });

    test('날짜가 바뀌면(자정) 어제 예약을 치운다', () async {
      now = d(17, 0, 0);
      ticks.add(now);
      await settle(c, () => os.scheduledAt == null);
      expect(await stored(), isNull);
    });
  });

  group('마지막 근무일 — 주간 알림', () {
    test('금요일: 지난 날 기록을 고치면 주간 알림 시각이 바뀌어 다시 건다', () async {
      final repo = DriftWorkRecordRepository(db);
      await repo.save(rec(16, inH: 9, outH: 18));
      await repo.save(rec(17, inH: 9, outH: 18));
      now = d(18, 9);
      final c = launch();
      await enable(c);
      await today(c).clockIn();
      await settle(c, () => os.scheduledAt == d(18, 18));
      expect(os.scheduledTitle, NotificationTexts.weeklyTitle);
      expect(os.scheduledBody, NotificationTexts.weeklyBody);
      await repo.save(rec(17, inH: 9, outH: 20)); // 어제 +2h
      await settle(c, () => os.scheduledAt == d(18, 16));
      expect(await stored(), ClockOutNotice(ClockOutNoticeKind.weekly, d(18, 16)));
    });

    test('목요일에 이번 주가 먼저 끝나면 N2′ 문구', () async {
      final repo = DriftWorkRecordRepository(db);
      await repo.save(rec(14, inH: 9, outH: 22));
      await repo.save(rec(15, inH: 9, outH: 22));
      await repo.save(rec(16, inH: 9, outH: 23));
      now = d(17, 9);
      final c = launch();
      await enable(c);
      await today(c).clockIn();
      await settle(c, () => os.scheduledAt == d(17, 12));
      expect(os.scheduledTitle, NotificationTexts.weeklyTitle);
      expect(os.scheduledBody, NotificationTexts.weeklyEarlyBody);
    });
  });

  group('이미 지난 시각 (N3) — 한 번만', () {
    test('출근 시각을 앞으로 고쳐 퇴근 시각이 지나 있으면 지금 띄운다 — 다시 맞춰도 또 띄우지 않는다', () async {
      final c = launch();
      await enable(c);
      await today(c).clockIn();
      await settle(c, () => os.scheduledAt == d(16, 17, 30));
      now = d(16, 17, 10);
      await today(c).setClockIn(d(16, 8)); // → 17:00, 이미 지남
      await settle(c, () => os.shown.isNotEmpty);
      expect(os.shown, [(NotificationTexts.dailyTitle, NotificationTexts.dailyBody)]);
      expect(os.scheduledAt, isNull, reason: '미래 예약은 치운다');
      for (var i = 0; i < 3; i++) {
        await c.read(clockOutNotificationSyncProvider.notifier).sync();
      }
      await settle(c);
      expect(os.shown, hasLength(1));
      expect(os.count('schedule'), 1); // 처음 건 17:30 하나뿐
    });

    test('예약 시각이 지난 뒤 앱을 다시 켜도 또 울리지 않는다', () async {
      var c = launch();
      await enable(c);
      await today(c).clockIn();
      await settle(c, () => os.scheduledAt == d(16, 17, 30));
      c.dispose();
      containers.remove(c);
      // 17:30에 OS가 띄웠다. 18:00에 앱을 켠다.
      os.scheduledAt = null;
      os.log.clear();
      now = d(16, 18);
      c = launch();
      await settle(c);
      expect(os.shown, isEmpty);
      expect(os.count('schedule'), 0);
      expect(await stored(), daily(17, 30), reason: '오늘 전달된 기록은 남긴다');
    });

    test('울린 뒤 지난 날 기록을 고치거나 시간 출장을 남겨도 또 울리지 않는다', () async {
      final c = launch();
      await enable(c);
      await today(c).clockIn();
      await settle(c, () => os.scheduledAt == d(16, 17, 30));
      now = d(16, 18);
      os.scheduledAt = null;
      await DriftWorkRecordRepository(db).save(rec(15, inH: 9, outH: 19));
      await today(c).setTrip(d(16, 9), d(16, 12));
      await settle(c);
      expect(os.shown, isEmpty);
      expect(os.count('schedule'), 1);
    });

    test('울린 뒤 퇴근 → 퇴근 취소: 저장이 지워졌으므로 한 번 더 띄운다 (N3와 같은 동작)', () async {
      final c = launch();
      await enable(c);
      await today(c).clockIn();
      await settle(c, () => os.scheduledAt == d(16, 17, 30));
      now = d(16, 18);
      os.scheduledAt = null;
      await today(c).clockOut();
      await settle(c, () => c.read(todayControllerProvider).value?.clockOut != null);
      await settle(c);
      expect(await stored(), isNull);
      await today(c).cancelClockOut();
      await settle(c, () => os.shown.isNotEmpty);
      expect(os.shown, hasLength(1));
      await settle(c);
      expect(os.shown, hasLength(1));
    });

    test('울린 뒤 계획이 미래로 옮겨가면(반차 해제) 새 시각에 다시 예약한다', () async {
      final c = launch();
      await enable(c);
      await today(c).clockIn();
      await waitToday(c, (s) => s.clockIn != null);
      await today(c).setHalfDay(true);
      await settle(c, () => os.scheduledAt == d(16, 12, 30));
      now = d(16, 13);
      os.scheduledAt = null; // 12:30에 울렸다
      await today(c).setHalfDay(false);
      await settle(c, () => os.scheduledAt == d(16, 17, 30));
      expect(os.shown, isEmpty);
    });

    test('퇴근 시각이 지난 뒤에 알림을 켜면 지금 한 번 띄운다', () async {
      final c = launch();
      await today(c).clockIn();
      await settle(c);
      now = d(16, 19);
      await enable(c);
      expect(os.shown, hasLength(1));
      await settle(c);
      expect(os.shown, hasLength(1));
    });
  });

  group('앱을 켤 때', () {
    test('기록이 오기 전에 예약을 지우지 않는다 — 걸려 있던 예약은 그대로 다시 확인된다', () async {
      var c = launch();
      await enable(c);
      await today(c).clockIn();
      await settle(c, () => os.scheduledAt == d(16, 17, 30));
      c.dispose();
      containers.remove(c);
      os.log.clear();
      now = d(16, 10);
      c = launch();
      await settle(c);
      expect(os.count('cancel'), 0, reason: '시작할 때 취소하면 그 사이 앱이 죽었을 때 알림이 사라진다');
      expect(os.scheduledAt, d(16, 17, 30));
      // 앱을 막 켰을 땐 OS에 무엇이 걸려 있는지 모르니 한 번은 다시 건다(같은 시각, 대체)
      expect(os.count('schedule'), 1);
    });

    test('OS 예약이 사라져 있었어도(강제 종료 등) 켜면 다시 건다', () async {
      var c = launch();
      await enable(c);
      await today(c).clockIn();
      await settle(c, () => os.scheduledAt == d(16, 17, 30));
      c.dispose();
      containers.remove(c);
      os.scheduledAt = null; // OS가 잃어버림
      now = d(16, 10);
      c = launch();
      await settle(c, () => os.scheduledAt == d(16, 17, 30));
    });

    test('알림을 안 쓰는 사람: 켤 때 한 번만 정리하고, 그 뒤 기록이 바뀌어도 OS를 부르지 않는다', () async {
      final c = launch();
      await settle(c);
      final cancels = os.count('cancel');
      expect(cancels, lessThanOrEqualTo(1));
      await today(c).clockIn();
      await settle(c);
      await today(c).setHalfDay(true);
      await settle(c);
      expect(os.count('cancel'), cancels);
      expect(os.count('schedule'), 0);
    });

    test('어제 걸어두고 퇴근을 안 찍은 채 다음 날 켜면: 어제 기록은 치우고 오늘은 출근 전이라 예약 없음', () async {
      var c = launch();
      await enable(c);
      await today(c).clockIn();
      await settle(c, () => os.scheduledAt == d(16, 17, 30));
      c.dispose();
      containers.remove(c);
      os.scheduledAt = null; // 어제 17:30에 울렸다
      now = d(17, 8, 50);
      c = launch();
      await settle(c);
      expect(os.shown, isEmpty);
      expect(await stored(), isNull);
      await today(c).clockIn();
      await settle(c, () => os.scheduledAt == d(17, 17, 50));
    });
  });

  group('견고함', () {
    test('디버그 시계를 옮겼으면 OS에는 실제 시각으로 건다 (앱 시각 − 오프셋)', () async {
      final c = launch();
      await enable(c);
      final real = DateTime.now();
      c.read(debugClockOffsetProvider.notifier).moveTo(real.add(const Duration(hours: 3)));
      final offset = c.read(debugClockOffsetProvider);
      await today(c).clockIn();
      await settle(c, () => os.scheduledAt != null);
      expect(os.scheduledAt, d(16, 17, 30).subtract(offset));
      // 저장은 앱 시각 그대로 — 계획과 비교하는 값이다
      expect(await stored(), daily(17, 30));
    });

    test('예약이 실패해도 동기화가 죽지 않고, 다음 번에 다시 건다', () async {
      final c = launch();
      await enable(c);
      os.failNextSchedule = true;
      await today(c).clockIn();
      await settle(c);
      await settle(c, () => os.scheduledAt == d(16, 17, 30));
      expect(await stored(), daily(17, 30));
    });

    test('주말·공휴일 근무는 예약하지 않는다', () async {
      now = d(19, 10);
      final c = launch();
      await enable(c);
      await today(c).clockIn();
      await settle(c);
      expect(os.count('schedule'), 0);
    });

    test('종일 출장·연차로 바꾸면(출근 전) 예약이 없다', () async {
      final c = launch();
      await enable(c);
      await today(c).setDayType(WorkType.businessTrip);
      await settle(c);
      expect(os.count('schedule'), 0);
    });
  });

  test('저장된 알림 인코딩 왕복 · 손상된 값은 null', () {
    final n = ClockOutNotice(ClockOutNoticeKind.weeklyEarly, d(17, 12));
    expect(DriftNotificationStateRepository.decodeNotice(DriftNotificationStateRepository.encodeNotice(n)), n);
    for (final bad in [null, '', 'x', '2026-09-16T17:30:00.000', '2026-09-16T17:30:00.000|nope', 'nope|daily', 'a|b|c']) {
      expect(DriftNotificationStateRepository.decodeNotice(bad), isNull, reason: '$bad');
    }
  });

  test('기록 저장소는 건드리지 않는다 — 알림 상태 키는 Settings에만', () async {
    final c = launch();
    await enable(c);
    await today(c).clockIn();
    await settle(c, () => os.scheduledAt != null);
    final keys = (await db.select(db.settings).get()).map((r) => r.key).toSet();
    expect(keys, containsAll(['clock_out_notice', 'clock_out_notification', 'first_record_date']));
    final records = await db.select(db.workRecords).get();
    expect(records, hasLength(3));
    expect(records.whereType<WorkRecord>(), isEmpty);
  });
}

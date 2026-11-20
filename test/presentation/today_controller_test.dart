import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/core/providers/clock_provider.dart';
import 'package:soi_duty/core/providers/database_providers.dart';
import 'package:soi_duty/data/database/app_database.dart';
import 'package:soi_duty/domain/model/work_record.dart';
import 'package:soi_duty/domain/model/work_type.dart';
import 'package:soi_duty/presentation/today/today_controller.dart';
import 'package:soi_duty/presentation/today/today_state.dart';

import '../helpers/records.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  final now = d(16, 9, 12);

  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer.test(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(() => now),
        nowProvider.overrideWith((ref) => Stream.value(now)),
      ],
    );
    // autoDispose 프로바이더가 테스트 중 사라지지 않게 구독을 유지한다.
    container.listen(todayControllerProvider, (_, _) {});
  });

  tearDown(() => db.close());

  Future<TodayState> waitFor(bool Function(TodayState) test) async {
    for (var i = 0; i < 50; i++) {
      final s = await container.read(todayControllerProvider.future);
      if (test(s)) return s;
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    fail('상태가 기대대로 바뀌지 않음');
  }

  TodayController notifier() => container.read(todayControllerProvider.notifier);

  test('초기 상태는 출근 전', () async {
    final s = await container.read(todayControllerProvider.future);
    expect(s.phase, TodayPhase.before);
  });

  test('clockIn → 근무 중, 출근 시각은 clock 값', () async {
    await notifier().clockIn();
    final s = await waitFor((s) => s.phase == TodayPhase.working);
    expect(s.clockIn, now);
  });

  test('setClockIn → 출근 시각만 바뀌고 반차·날짜는 유지', () async {
    await notifier().clockIn();
    await waitFor((s) => s.phase == TodayPhase.working);
    await notifier().setHalfDay(true);
    await waitFor((s) => s.isHalfDay);
    await notifier().setClockIn(DateTime(2000, 1, 1, 8, 50)); // 날짜는 무시, 시분만
    final s = await waitFor((s) => s.clockIn == d(16, 8, 50));
    expect(s.phase, TodayPhase.working);
    expect(s.isHalfDay, isTrue);
    expect(s.record!.date, d(16));
  });

  test('clockOut → 퇴근 완료', () async {
    await notifier().clockIn();
    await waitFor((s) => s.phase == TodayPhase.working);
    await notifier().clockOut();
    final s = await waitFor((s) => s.phase == TodayPhase.done);
    expect(s.clockOut, now);
  });

  test('setHalfDay는 출근 기록을 유지한 채 유형만 바꾼다', () async {
    await notifier().clockIn();
    await waitFor((s) => s.phase == TodayPhase.working);
    await notifier().setHalfDay(true);
    final s = await waitFor((s) => s.isHalfDay);
    expect(s.clockIn, now);
    await notifier().setHalfDay(false);
    await waitFor((s) => !s.isHalfDay);
  });

  test('setDayType(dayOff) → dayType 화면, revert → 출근 전', () async {
    await notifier().setDayType(WorkType.dayOff);
    await waitFor((s) => s.screenState == TodayScreenState.dayType);
    await notifier().revert();
    final s = await waitFor((s) => s.screenState == TodayScreenState.beforeWork);
    expect(s.record?.type, WorkType.normal);
  });

  test('첫 기록이 첫 기록일을 만든다', () async {
    await notifier().clockIn();
    final s = await waitFor((s) => s.firstRecordDate != null);
    expect(s.firstRecordDate, d(16));
  });

  test('연차인 날 clockIn하면 type이 normal로 정규화된다', () async {
    await notifier().setDayType(WorkType.dayOff);
    await waitFor((s) => s.screenState == TodayScreenState.dayType);
    await notifier().clockIn();
    final s = await waitFor((s) => s.phase == TodayPhase.working);
    expect(s.record?.type, WorkType.normal);
  });

  test('cancelClockIn → 기록이 지워지고 출근 전, 반차도 풀린다', () async {
    await notifier().clockIn();
    await waitFor((s) => s.phase == TodayPhase.working);
    await notifier().setHalfDay(true);
    await waitFor((s) => s.isHalfDay);
    await notifier().cancelClockIn();
    final s = await waitFor((s) => s.phase == TodayPhase.before);
    expect(s.record, isNull);
    expect(s.isHalfDay, isFalse);
  });

  test('cancelClockOut → 근무 중으로 돌아가고 type은 유지', () async {
    await notifier().clockIn();
    await waitFor((s) => s.phase == TodayPhase.working);
    await notifier().setHalfDay(true);
    await waitFor((s) => s.isHalfDay);
    await notifier().clockOut();
    await waitFor((s) => s.phase == TodayPhase.done);
    await notifier().cancelClockOut();
    final s = await waitFor((s) => s.phase == TodayPhase.working);
    expect(s.clockOut, isNull);
    expect(s.isHalfDay, isTrue);
  });

  group('공휴일 근무 · 출장 · 시간공제', () {
    Future<List<WorkRecord>> records() => container.read(allRecordsProvider.future);

    /// 퇴근이 저장될 때까지 기다린다 — 스트림의 첫 값은 저장 전일 수 있다.
    Future<WorkRecord> clockedOut(ProviderContainer c) async {
      for (var i = 0; i < 50; i++) {
        final all = await c.read(allRecordsProvider.future);
        final done = all.where((r) => r.clockOut != null);
        if (done.isNotEmpty) return done.single;
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      fail('퇴근이 저장되지 않음');
    }

    ProviderContainer at(DateTime t) {
      final c = ProviderContainer.test(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(() => t),
          nowProvider.overrideWith((ref) => Stream.value(t)),
        ],
      );
      c.listen(todayControllerProvider, (_, _) {});
      c.listen(allRecordsProvider, (_, _) {});
      return c;
    }

    test('공휴일 출근은 공휴일을 유지한다', () async {
      await notifier().setDayType(WorkType.holiday);
      await waitFor((s) => s.dayType == WorkType.holiday);
      await notifier().clockIn();
      final s = await waitFor((s) => s.phase == TodayPhase.working);
      expect(s.record!.type, WorkType.holiday);
    });

    test('공휴일 출근 취소는 시각만 비우고 공휴일을 남긴다', () async {
      await notifier().setDayType(WorkType.holiday);
      await waitFor((s) => s.dayType == WorkType.holiday);
      await notifier().clockIn();
      await waitFor((s) => s.phase == TodayPhase.working);
      await notifier().cancelClockIn();
      final s = await waitFor((s) => s.phase == TodayPhase.before);
      expect(s.record?.type, WorkType.holiday);
      expect(s.dayType, WorkType.holiday);
    });

    test('출장 상태에서 clockIn은 일반으로 바꾼다', () async {
      await notifier().setDayType(WorkType.businessTrip);
      await waitFor((s) => s.dayType == WorkType.businessTrip);
      await notifier().clockIn();
      final s = await waitFor((s) => s.phase == TodayPhase.working);
      expect(s.record!.type, WorkType.normal);
    });

    test('공제하고 퇴근: 기본 − 실근무가 공제로 저장된다', () async {
      await db.into(db.workRecords).insert(
            WorkRecordsCompanion.insert(date: '2026-09-16', clockIn: Value(d(16, 9)), type: WorkType.normal),
          );
      final c = at(d(16, 15));
      await c.read(todayControllerProvider.future);
      await c.read(todayControllerProvider.notifier).clockOut(deductRemaining: true);
      final r = await clockedOut(c);
      expect(r.deductionMinutes, 180);
    });

    test('반차 날 이미 4h 넘겼으면 공제 0', () async {
      await db.into(db.workRecords).insert(
            WorkRecordsCompanion.insert(date: '2026-09-16', clockIn: Value(d(16, 9)), type: WorkType.halfDay),
          );
      final c = at(d(16, 14));
      await c.read(todayControllerProvider.future);
      await c.read(todayControllerProvider.notifier).clockOut(deductRemaining: true);
      final r = await clockedOut(c);
      expect(r.deductionMinutes, 0);
    });

    test('공제 체크 없이 퇴근하면 기존 공제 유지', () async {
      await db.into(db.workRecords).insert(
            WorkRecordsCompanion.insert(
              date: '2026-09-16',
              clockIn: Value(d(16, 9)),
              type: WorkType.normal,
              deductionMinutes: const Value(60),
            ),
          );
      final c = at(d(16, 17));
      await c.read(todayControllerProvider.future);
      await c.read(todayControllerProvider.notifier).clockOut();
      final r = await clockedOut(c);
      expect(r.deductionMinutes, 60);
    });

    test('공제가 있던 오늘을 연차로 바꾸면 공제가 지워진다', () async {
      await db.into(db.workRecords).insert(
            WorkRecordsCompanion.insert(date: '2026-09-16', type: WorkType.normal, deductionMinutes: const Value(60)),
          );
      await container.read(todayControllerProvider.future);
      await notifier().setDayType(WorkType.dayOff);
      await waitFor((s) => s.dayType == WorkType.dayOff);
      expect((await records()).single.deductionMinutes, 0);
    });
  });

  test('미리 넣은 공제는 출근 취소해도 남는다', () async {
    await db.into(db.workRecords).insert(
          WorkRecordsCompanion.insert(
            date: '2026-09-16',
            type: WorkType.normal,
            deductionMinutes: const Value(120),
          ),
        );
    await container.read(todayControllerProvider.future);
    await notifier().clockIn();
    await waitFor((s) => s.phase == TodayPhase.working);
    await notifier().cancelClockIn();
    final s = await waitFor((s) => s.phase == TodayPhase.before);
    expect(s.record?.deductionMinutes, 120);
    expect(s.record?.clockIn, isNull);
  });

  group('시간 출장', () {
    Future<List<WorkRecord>> waitRecords(bool Function(List<WorkRecord>) test) async {
      for (var i = 0; i < 50; i++) {
        final all = await container.read(allRecordsProvider.future);
        if (test(all)) return all;
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      fail('기록이 기대대로 바뀌지 않음');
    }

    test('출근 전 setTrip → 범위만 있는 오늘 기록(출근 전 그대로), clearTrip → 기록 삭제', () async {
      await notifier().setTrip(DateTime(2000, 1, 1, 9), DateTime(2000, 1, 1, 12)); // 날짜는 무시
      final s = await waitFor((s) => s.record != null);
      expect(s.phase, TodayPhase.before);
      expect(s.dayType, isNull);
      expect((s.record!.tripStart, s.record!.tripEnd), (d(16, 9), d(16, 12)));
      await notifier().clearTrip();
      await waitFor((s) => s.record == null);
      expect(await waitRecords((all) => all.isEmpty), isEmpty);
    });

    test('근무 중 setTrip → 출근 시각·반차 유지, clearTrip → 기록은 남는다', () async {
      await notifier().clockIn();
      await waitFor((s) => s.phase == TodayPhase.working);
      await notifier().setHalfDay(true);
      await waitFor((s) => s.isHalfDay);
      await notifier().setTrip(d(16, 9, 12), d(16, 12, 12));
      var s = await waitFor((s) => s.record?.tripStart != null);
      expect(s.clockIn, now);
      expect(s.isHalfDay, isTrue);
      expect((s.record!.tripStart, s.record!.tripEnd), (d(16, 9, 12), d(16, 12, 12)));
      await notifier().clearTrip();
      s = await waitFor((s) => s.record?.tripStart == null);
      expect(s.phase, TodayPhase.working);
      expect(s.clockIn, now);
    });

    test('시간 출장은 오늘 계산을 바꾸지 않는다 — 잔여·오늘 몫·기준이 같다', () async {
      await notifier().clockIn();
      final before = await waitFor((s) => s.phase == TodayPhase.working);
      await notifier().setTrip(d(16, 9, 12), d(16, 12, 12));
      final after = await waitFor((s) => s.record?.tripStart != null);
      expect(after.week.copyWith(businessTripCount: 0), before.week.copyWith(businessTripCount: 0));
      expect(after.todayShareMinutes, before.todayShareMinutes);
      expect(after.todayStandardMinutes, before.todayStandardMinutes);
      expect(after.elapsedMinutes, before.elapsedMinutes);
      expect(after.expectedClockOut, before.expectedClockOut);
    });

    test('근무 중 + 출장 → 출근 취소: 기록이 남고 범위는 유지, 시각만 비운다', () async {
      await notifier().clockIn();
      await waitFor((s) => s.phase == TodayPhase.working);
      await notifier().setTrip(d(16, 9, 12), d(16, 12, 12));
      await waitFor((s) => s.record?.tripStart != null);
      await notifier().cancelClockIn();
      final s = await waitFor((s) => s.phase == TodayPhase.before);
      expect(s.record, isNotNull);
      expect(s.record!.clockIn, isNull);
      expect((s.record!.tripStart, s.record!.tripEnd), (d(16, 9, 12), d(16, 12, 12)));
    });

    test('종일 출장 상태에서 setTrip → 유형이 일반으로 풀리고 범위가 붙는다', () async {
      await notifier().setDayType(WorkType.businessTrip);
      await waitFor((s) => s.dayType == WorkType.businessTrip);
      await notifier().setTrip(d(16, 9), d(16, 12));
      final s = await waitFor((s) => s.record?.tripStart != null);
      expect(s.record!.type, WorkType.normal);
      expect(s.dayType, isNull);
    });

    test('범위가 있는 날을 종일 출장·연차로 바꾸면 범위가 지워진다', () async {
      await notifier().setTrip(d(16, 9), d(16, 12));
      await waitFor((s) => s.record?.tripStart != null);
      await notifier().setDayType(WorkType.businessTrip);
      final s = await waitFor((s) => s.dayType == WorkType.businessTrip);
      expect((s.record!.tripStart, s.record!.tripEnd), (null, null));
    });

    test('범위가 있는 날 출근 → 범위 유지', () async {
      await notifier().setTrip(d(16, 9), d(16, 12));
      await waitFor((s) => s.record?.tripStart != null);
      await notifier().clockIn();
      final s = await waitFor((s) => s.phase == TodayPhase.working);
      expect((s.record!.tripStart, s.record!.tripEnd), (d(16, 9), d(16, 12)));
    });
  });
}

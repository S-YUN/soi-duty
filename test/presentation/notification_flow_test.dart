import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/core/presentation/size_config.dart';
import 'package:soi_duty/core/providers/app_info_provider.dart';
import 'package:soi_duty/core/providers/clock_provider.dart';
import 'package:soi_duty/core/providers/database_providers.dart';
import 'package:soi_duty/core/providers/notification_providers.dart';
import 'package:soi_duty/data/database/app_database.dart';
import 'package:soi_duty/data/repository/drift_app_settings_repository.dart';
import 'package:soi_duty/data/repository/drift_notification_state_repository.dart';
import 'package:soi_duty/domain/model/app_settings.dart';
import 'package:soi_duty/domain/model/work_type.dart';
import 'package:soi_duty/domain/repository/notification_scheduler.dart';
import 'package:soi_duty/presentation/notification/clock_out_notification_host.dart';
import 'package:soi_duty/presentation/notification/widgets/notification_preview_card.dart';
import 'package:soi_duty/presentation/settings/settings_screen.dart';
import 'package:soi_duty/presentation/settings/widgets/soi_switch.dart';
import 'package:soi_duty/presentation/today/today_screen.dart';
import 'package:soi_duty/ui/app_sizes.dart';
import 'package:soi_duty/ui/app_theme.dart';

import '../helpers/fake_notification_scheduler.dart';
import '../helpers/fonts.dart';
import '../helpers/records.dart';

/// 퇴근 알림의 화면 흐름 — 첫 평일 출근 때 묻기(P1·P2·P5)와 설정 토글(P3·P4). OS는 Fake.
void main() {
  late AppDatabase db;
  late FakeNotificationScheduler os;
  late DateTime now;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    await loadPretendard();
  });
  setUp(() {
    SizeConfig.init(402);
    db = AppDatabase(NativeDatabase.memory());
    os = FakeNotificationScheduler(osStatus: OsNotificationStatus.notGranted);
    now = d(16, 9, 12); // 수요일
  });
  tearDown(() => db.close());

  Future<void> pump(WidgetTester tester, Widget home) async {
    tester.view.physicalSize = const Size(402 * 3, 874 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(() => now),
        nowProvider.overrideWith((ref) => Stream.value(now)),
        appVersionProvider.overrideWith((ref) async => '1.0.3'),
        notificationSchedulerProvider.overrideWithValue(os),
      ],
      child: MaterialApp(theme: AppTheme.light, home: ClockOutNotificationHost(child: home)),
    ));
    await tester.pumpAndSettle();
  }

  /// 저장 → 스트림 → 동기화로 이어지는 비동기 사슬은 프레임을 예약하지 않아 pumpAndSettle만으로는 다 흐르지 않는다.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 5));
    }
    await tester.pumpAndSettle();
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pump(AppDurations.toast);
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  }

  Future<AppSettings> settings() => DriftAppSettingsRepository(db).read();
  Future<bool> osAsked() => DriftNotificationStateRepository(db).osAsked();
  const today = Scaffold(body: TodayScreen());

  group('첫 평일 출근 때 묻기', () {
    testWidgets('출근이 먼저 저장되고 그 위에 다이얼로그 — 제목·설명·미리보기·두 버튼', (tester) async {
      await pump(tester, today);
      await tester.tap(find.text('출근하기'));
      await tester.pumpAndSettle();
      expect((await db.select(db.workRecords).get()).single.clockIn, now);
      expect(find.text('퇴근하기'), findsOneWidget);
      expect(find.text('퇴근할 때 알려드릴까요?'), findsOneWidget);
      expect(find.text('오늘 채울 시간을 다 채우면 퇴근 알림을 보내드려요.'), findsOneWidget);
      expect(find.byType(NotificationPreviewCard), findsOneWidget);
      expect(find.text('소이듀티'), findsOneWidget);
      expect(find.text('퇴근할 시간이에요'), findsOneWidget);
      expect(find.text('안 받을래요'), findsOneWidget);
      expect(find.text('알림 받기'), findsOneWidget);
      expect(os.requestCount, 0, reason: 'OS 창은 수락한 뒤에만');
      await tester.tap(find.text('안 받을래요'));
      await tester.pumpAndSettle();
      await finish(tester);
    });

    testWidgets('"알림 받기" + OS 허용 → 켜짐, 예약됨, 토스트 없음', (tester) async {
      await pump(tester, today);
      await tester.tap(find.text('출근하기'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('알림 받기'));
      await settle(tester);
      final s = await settings();
      expect((s.clockOutNotificationEnabled, s.notificationPrompted), (true, true));
      expect(os.requestCount, 1);
      expect(await osAsked(), isTrue);
      expect(os.scheduledAt, d(16, 18, 12));
      expect(find.text('기기 설정에서 알림을 허용해야 받을 수 있어요'), findsNothing);
      expect(find.text('알림은 설정에서 언제든 켤 수 있어요'), findsNothing);
      await finish(tester);
    });

    testWidgets('"알림 받기" + OS 거절 → 켜짐은 남고 P5 토스트, 예약 없음', (tester) async {
      os.requestResult = false;
      await pump(tester, today);
      await tester.tap(find.text('출근하기'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('알림 받기'));
      await settle(tester);
      final s = await settings();
      expect((s.clockOutNotificationEnabled, s.notificationPrompted), (true, true));
      expect(find.text('기기 설정에서 알림을 허용해야 받을 수 있어요'), findsOneWidget);
      expect(os.scheduledAt, isNull);
      expect(os.count('schedule'), 0);
      await finish(tester);
    });

    testWidgets('"안 받을래요" → 꺼짐, P2 토스트, OS 창 없음', (tester) async {
      await pump(tester, today);
      await tester.tap(find.text('출근하기'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('안 받을래요'));
      await tester.pumpAndSettle();
      final s = await settings();
      expect((s.clockOutNotificationEnabled, s.notificationPrompted), (false, true));
      expect(find.text('알림은 설정에서 언제든 켤 수 있어요'), findsOneWidget);
      expect(os.requestCount, 0);
      expect(await osAsked(), isFalse);
      await finish(tester);
    });

    testWidgets('바깥을 탭해 넘겨도 거절과 같다 — 다시 묻지 않는다', (tester) async {
      await pump(tester, today);
      await tester.tap(find.text('출근하기'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect((await settings()).notificationPrompted, isTrue);
      expect(find.text('알림은 설정에서 언제든 켤 수 있어요'), findsOneWidget);
      await finish(tester);
    });

    testWidgets('한 번 물었으면 출근 취소 뒤 다시 출근해도 묻지 않는다', (tester) async {
      await pump(tester, today);
      await tester.tap(find.text('출근하기'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('안 받을래요'));
      await tester.pumpAndSettle();
      await tester.pump(AppDurations.toast);
      await tester.tap(find.text('출근 취소'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('출근하기'));
      await tester.pumpAndSettle();
      expect(find.text('퇴근할 때 알려드릴까요?'), findsNothing);
      expect(find.text('퇴근하기'), findsOneWidget);
      await finish(tester);
    });

    testWidgets('토요일 출근은 묻지 않고 "물어봤다"로 남기지도 않는다 — 다음 평일 출근 때 묻는다', (tester) async {
      now = d(19, 10);
      await pump(tester, today);
      await tester.tap(find.text('출근하기'));
      await tester.pumpAndSettle();
      expect(find.text('퇴근할 때 알려드릴까요?'), findsNothing);
      expect((await settings()).notificationPrompted, isFalse);
      await finish(tester);
    });

    testWidgets('평일 공휴일 근무 출근도 묻지 않는다', (tester) async {
      await db.into(db.workRecords).insert(WorkRecordsCompanion.insert(date: '2026-09-16', type: WorkType.holiday));
      await pump(tester, today);
      await tester.tap(find.text('출근하기'));
      await tester.pumpAndSettle();
      expect(find.text('퇴근할 때 알려드릴까요?'), findsNothing);
      expect((await settings()).notificationPrompted, isFalse);
      await finish(tester);
    });

    testWidgets('미리보기 카드는 접근성에서 숨는다', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester, today);
      await tester.tap(find.text('출근하기'));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel(RegExp('소이듀티')), findsNothing);
      expect(find.bySemanticsLabel(RegExp('퇴근할 시간이에요')), findsNothing);
      expect(
        find.ancestor(of: find.text('소이듀티'), matching: find.byType(ExcludeSemantics)),
        findsWidgets,
      );
      await tester.tap(find.text('안 받을래요'));
      await tester.pumpAndSettle();
      handle.dispose();
      await finish(tester);
    });
  });

  group('설정 화면 토글', () {
    const settingsScreen = SettingsScreen();
    Future<void> tapRow(WidgetTester tester) async {
      await tester.ensureVisible(find.text('퇴근 알림'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('퇴근 알림'));
      await settle(tester);
    }

    testWidgets('꺼짐 → 토글 → OS 창 허용 → 켜짐', (tester) async {
      await pump(tester, settingsScreen);
      expect(tester.widget<SoiSwitch>(find.byType(SoiSwitch)).value, isFalse);
      await tapRow(tester);
      expect(os.requestCount, 1);
      expect((await settings()).clockOutNotificationEnabled, isTrue);
      expect(tester.widget<SoiSwitch>(find.byType(SoiSwitch)).value, isTrue);
      expect(find.text('그날 채울 시간을 다 채우면 알려드려요'), findsOneWidget);
      await finish(tester);
    });

    testWidgets('꺼짐 → 토글 → OS 창 거절 → P5 토스트, 행이 "설정 열기"로 바뀐다', (tester) async {
      os.requestResult = false;
      await pump(tester, settingsScreen);
      await tapRow(tester);
      expect(find.text('기기 설정에서 알림을 허용해야 받을 수 있어요'), findsOneWidget);
      expect(find.byType(SoiSwitch), findsNothing);
      expect(find.text('설정 열기'), findsOneWidget);
      expect(find.text('기기 설정에서 알림이 꺼져 있어요'), findsOneWidget);
      await finish(tester);
    });

    testWidgets('"설정 열기" 행 → 안내 다이얼로그 → 설정 열기 → OS 설정을 연다. 취소하면 안 연다', (tester) async {
      await DriftNotificationStateRepository(db).markOsAsked();
      await pump(tester, settingsScreen);
      await tapRow(tester);
      expect(find.text('알림이 꺼져 있어요'), findsOneWidget);
      expect(find.text('기기 설정에서 소이듀티 알림을 허용하면 퇴근할 시간에 알려드려요.'), findsOneWidget);
      await tester.tap(find.text('취소'));
      await tester.pumpAndSettle();
      expect(os.openSettingsCount, 0);
      await tapRow(tester);
      await tester.tap(find.text('설정 열기').last);
      await tester.pumpAndSettle();
      expect(os.openSettingsCount, 1);
      await finish(tester);
    });

    testWidgets('OS 설정에서 허용하고 돌아오면(resume) 토글 행으로 바뀌고, 켜 둔 상태였으면 바로 예약된다', (tester) async {
      await DriftNotificationStateRepository(db).markOsAsked();
      await DriftAppSettingsRepository(db).save(const AppSettings(clockOutNotificationEnabled: true, notificationPrompted: true));
      await db.into(db.workRecords).insert(
            WorkRecordsCompanion.insert(date: '2026-09-16', clockIn: Value(d(16, 9)), type: WorkType.normal),
          );
      await pump(tester, settingsScreen);
      expect(find.text('설정 열기'), findsOneWidget);
      expect(os.scheduledAt, isNull);
      os.osStatus = OsNotificationStatus.granted;
      // 앱을 떠났다 돌아온다 (OS 설정 화면에 다녀옴)
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await settle(tester);
      expect(tester.widget<SoiSwitch>(find.byType(SoiSwitch)).value, isTrue);
      expect(os.scheduledAt, d(16, 18));
      await finish(tester);
    });

    testWidgets('켜짐 → 토글 → 꺼짐, 걸어둔 예약이 취소된다', (tester) async {
      os.osStatus = OsNotificationStatus.granted;
      await DriftAppSettingsRepository(db).save(const AppSettings(clockOutNotificationEnabled: true, notificationPrompted: true));
      await db.into(db.workRecords).insert(
            WorkRecordsCompanion.insert(date: '2026-09-16', clockIn: Value(d(16, 9)), type: WorkType.normal),
          );
      await pump(tester, settingsScreen);
      expect(os.scheduledAt, d(16, 18));
      await tapRow(tester);
      expect((await settings()).clockOutNotificationEnabled, isFalse);
      expect(os.scheduledAt, isNull);
      expect(os.requestCount, 0);
      await finish(tester);
    });

    testWidgets('OS는 허용인데 앱에서 꺼 둔 상태 → 토글만 켜면 OS 창 없이 켜진다', (tester) async {
      os.osStatus = OsNotificationStatus.granted;
      await pump(tester, settingsScreen);
      await tapRow(tester);
      expect(os.requestCount, 0);
      expect((await settings()).clockOutNotificationEnabled, isTrue);
      expect(find.text('기기 설정에서 알림을 허용해야 받을 수 있어요'), findsNothing);
      await finish(tester);
    });
  });
}

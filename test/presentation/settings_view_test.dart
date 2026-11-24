import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/core/presentation/size_config.dart';
import 'package:soi_duty/core/providers/notification_providers.dart';
import 'package:soi_duty/domain/model/app_settings.dart';
import 'package:soi_duty/domain/model/leave_balance.dart';
import 'package:soi_duty/presentation/settings/settings_screen.dart';
import 'package:soi_duty/presentation/settings/settings_texts.dart';
import 'package:soi_duty/presentation/settings/widgets/soi_switch.dart';
import 'package:soi_duty/ui/app_colors.dart';
import 'package:soi_duty/presentation/shared/stroke_icons.dart';
import 'package:soi_duty/ui/app_sizes.dart';
import 'package:soi_duty/ui/app_theme.dart';

import '../helpers/fonts.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadPretendard();
  });

  WeekStart? pickedWeekStart;
  var taps = <String>[];

  Future<void> pump(
    WidgetTester tester,
    AppSettings settings, {
    double width = 402,
    NotificationPermission permission = NotificationPermission.notDetermined,
    bool exactAllowed = true,
  }) async {
    pickedWeekStart = null;
    taps = [];
    SizeConfig.init(width);
    tester.view.physicalSize = Size(width * 3, 874 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: SettingsView(
        settings: settings,
        notificationPermission: permission,
        exactAlarmAllowed: exactAllowed,
        year: 2026,
        version: '1.0.1',
        callbacks: SettingsCallbacks(
          onBack: () => taps.add('back'),
          onWeekStart: (w) => pickedWeekStart = w,
          onTapDefaultTimes: () => taps.add('default-times'),
          onTapAnnual: () => taps.add('annual'),
          onTapWage: () => taps.add('wage'),
          onExport: () => taps.add('export'),
          onImport: () => taps.add('import'),
          onPrivacy: () => taps.add('privacy'),
          onNotificationToggle: (on) => taps.add('notify:$on'),
          onOpenNotificationSettings: () => taps.add('notify-settings'),
          onExactAlarm: () => taps.add('exact'),
        ),
      ),
    ));
    await tester.pump();
  }

  testWidgets('빈 상태 — 두 보조 설명과 "사용 안 함" 둘, "아직 내보낸 적 없어요", 버전', (tester) async {
    await pump(tester, const AppSettings());
    expect(find.text('설정'), findsOneWidget);
    expect(find.text('남은 연차'), findsOneWidget);
    expect(find.text('알려주시면 월간 탭에서 잔여 연차를 볼 수 있어요'), findsOneWidget);
    expect(find.text('알려주시면 주말·공휴일 근무 예상 금액을 볼 수 있어요'), findsOneWidget);
    expect(find.text('사용 안 함'), findsNWidgets(2));
    expect(find.textContaining('기준'), findsNothing);
    expect(find.text('아직 내보낸 적 없어요'), findsOneWidget);
    expect(find.text('주간 탭과 주 40시간 계산은 월~일 그대로예요'), findsOneWidget);
    expect(find.text('주말·공휴일 근무 × 1.5배로 계산해요'), findsOneWidget);
    expect(find.text('1.0.1'), findsOneWidget);
    expect(find.text('개인정보 처리방침'), findsOneWidget);
  });

  testWidgets('채운 상태 — "8.5일" + 보조 "10월 26일 기준" · "12,500원" · "마지막 내보내기 2026년 10월 24일"', (tester) async {
    await pump(
      tester,
      AppSettings(
        weekStart: WeekStart.sunday,
        leaveBalanceByYear: {2026: LeaveBalance(remainingMinutes: 4080, baseDate: DateTime(2026, 10, 26))},
        hourlyWage: 12500,
        lastExportDate: DateTime(2026, 10, 24),
      ),
    );
    expect(find.text('8.5일'), findsOneWidget);
    expect(find.text('10월 26일 기준'), findsOneWidget);
    expect(find.text('12,500원'), findsOneWidget);
    expect(find.text('마지막 내보내기 2026년 10월 24일'), findsOneWidget);
    expect(find.text('사용 안 함'), findsNothing);
    expect(find.text('알려주시면 월간 탭에서 잔여 연차를 볼 수 있어요'), findsNothing);
  });

  testWidgets('기록 묶음 — 값이 없어도 "08:00–17:00", 정하면 그 값, 행을 누르면 콜백 (핸드오프 7)', (tester) async {
    await pump(tester, const AppSettings());
    expect(find.text('기록'), findsOneWidget);
    expect(find.text('기본 출퇴근 시각'), findsOneWidget);
    expect(find.text('08:00–17:00'), findsOneWidget);
    expect(find.text('기록이 없는 날에 시각을 넣을 때 처음 보이는 값이에요'), findsOneWidget);
    // 묶음 순서: 캘린더 → 알림 → 기록 → 연차
    final y = [for (final t in ['캘린더', '알림', '기록', '연차']) tester.getTopLeft(find.text(t)).dy];
    expect(y, orderedEquals([...y]..sort()));
    await tester.tap(find.text('기본 출퇴근 시각'));
    expect(taps, ['default-times']);

    await pump(tester, const AppSettings(defaultClockInMinutes: 9 * 60 + 30, defaultClockOutMinutes: 18 * 60 + 30));
    expect(find.text('09:30–18:30'), findsOneWidget);
    expect(tester.widget<Text>(find.text('09:30–18:30')).style?.color, AppColors.brand);
  });

  testWidgets('행 탭 → 콜백, 세그먼트 "일" 탭 → onWeekStart(sunday)', (tester) async {
    await pump(tester, const AppSettings());
    await tester.tap(find.text('일'));
    expect(pickedWeekStart, WeekStart.sunday);
    await tester.tap(find.text('남은 연차'));
    await tester.tap(find.text('시급'));
    await tester.tap(find.text('내보내기'));
    // 기록 묶음이 생긴 뒤로 874 높이에서 "가져오기"가 화면 아래로 내려간다 — 스크롤해서 누른다.
    await tester.ensureVisible(find.text('가져오기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('가져오기'));
    await tester.ensureVisible(find.text('개인정보 처리방침'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('개인정보 처리방침'));
    await tester.tap(find.bySemanticsLabel('뒤로'));
    expect(taps, ['annual', 'wage', 'export', 'import', 'privacy', 'back']);
  });

  testWidgets('폭 320·600에서 overflow 없음', (tester) async {
    for (final w in [320.0, 600.0]) {
      await pump(tester, AppSettings(leaveBalanceByYear: {2026: LeaveBalance(remainingMinutes: 99 * 480 + 240, baseDate: DateTime(2026, 12, 31))}, hourlyWage: 9999999, lastExportDate: DateTime(2026, 10, 24)), width: w);
      expect(tester.takeException(), isNull, reason: 'width $w');
      await pump(tester, const AppSettings(), width: w);
      expect(tester.takeException(), isNull, reason: 'width $w empty');
    }
  });

  testWidgets('뒤로가기 화살표가 화면 왼쪽(8 + 16)에 그려지고 제목은 화면 가운데', (tester) async {
    await pump(tester, const AppSettings());
    final arrow = tester.getRect(find.byType(BackArrowIcon));
    expect(arrow.width, AppSizes.backArrow.width);
    expect(arrow.left, closeTo(AppSizes.settingsBackLeft + (AppSizes.gearSize - AppSizes.backArrow.width) / 2, 0.5));
    expect(tester.getCenter(find.text('설정')).dx, closeTo(201, 0.5));
    expect(tester.getCenter(find.text('설정')).dy, closeTo(tester.getCenter(find.byType(BackArrowIcon)).dy, 0.5));
  });

  test('연차 시트 헤드라인 — 올해면 해 없이, 다른 해(12월에 1월 카드)면 해를 붙인다', () {
    expect(SettingsTexts.annualHeadline(DateTime(2026, 10, 26), 2026), '오늘(10월 26일) 기준 남은 연차');
    expect(SettingsTexts.annualHeadline(DateTime(2026, 12, 20), 2027), '오늘(12월 20일) 기준 2027년 남은 연차');
  });

  group('알림 섹션 (핸드오프 6 §9)', () {
    testWidgets('섹션 순서: 캘린더 · 알림 · 연차 · 수당 · 데이터 · 앱 정보', (tester) async {
      await pump(tester, const AppSettings());
      final labels = ['캘린더', '알림', '연차', '수당', '데이터', '앱 정보'];
      final ys = [for (final l in labels) tester.getTopLeft(find.text(l)).dy];
      expect(ys, [...ys]..sort(), reason: '$ys');
    });

    testWidgets('꺼짐: 토글 off + "알림을 켜면 퇴근 시간에 알려드려요", 행 어디를 눌러도 켜기 요청', (tester) async {
      await pump(tester, const AppSettings());
      expect(tester.widget<SoiSwitch>(find.byType(SoiSwitch)).value, isFalse);
      expect(find.text('알림을 켜면 퇴근 시간에 알려드려요'), findsOneWidget);
      expect(find.text('설정 열기'), findsNothing);
      await tester.tap(find.text('퇴근 알림'));
      expect(taps, ['notify:true']);
      await tester.tap(find.byType(SoiSwitch));
      expect(taps, ['notify:true', 'notify:true']);
    });

    testWidgets('켜짐: 토글 on + 보조 설명 없이 한 줄, 누르면 끄기 요청', (tester) async {
      await pump(tester, const AppSettings(clockOutNotificationEnabled: true), permission: NotificationPermission.granted);
      expect(tester.widget<SoiSwitch>(find.byType(SoiSwitch)).value, isTrue);
      expect(find.text('그날 채울 시간을 다 채우면 알려드려요'), findsNothing);
      expect(find.text('알림을 켜면 퇴근 시간에 알려드려요'), findsNothing);
      await tester.tap(find.text('퇴근 알림'));
      expect(taps, ['notify:false']);
    });

    testWidgets('토글은 접근성에 켜짐/꺼짐을 알린다', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester, const AppSettings(clockOutNotificationEnabled: true), permission: NotificationPermission.granted);
      expect(tester.getSemantics(find.byType(SoiSwitch)).flagsCollection.isToggled.toString(), contains('isTrue'));
      handle.dispose();
    });

    for (final enabled in [true, false]) {
      testWidgets('OS 권한 꺼짐(켜짐 여부 $enabled): 토글 대신 "설정 열기", 보조 설명은 경고색', (tester) async {
        await pump(tester, AppSettings(clockOutNotificationEnabled: enabled), permission: NotificationPermission.denied);
        expect(find.byType(SoiSwitch), findsNothing);
        expect(tester.widget<Text>(find.text('설정 열기')).style?.color, AppColors.brand);
        expect(tester.widget<Text>(find.text('기기 설정에서 알림이 꺼져 있어요')).style?.color, AppColors.minus);
        await tester.tap(find.text('퇴근 알림'));
        expect(taps, ['notify-settings']);
      });
    }

    testWidgets('폭 320에서 세 상태 모두 넘치지 않는다', (tester) async {
      await pump(tester, const AppSettings(), width: 320);
      expect(tester.takeException(), isNull);
      await pump(tester, const AppSettings(clockOutNotificationEnabled: true), width: 320, permission: NotificationPermission.granted);
      expect(tester.takeException(), isNull);
      await pump(tester, const AppSettings(), width: 320, permission: NotificationPermission.denied);
      expect(tester.takeException(), isNull);
    });
  });

  group('Android "알람 및 리마인더" 행', () {
    testWidgets('알림이 켜져 있고 허용인데 정시 권한이 없으면 행이 보인다 — 누르면 안내 요청', (tester) async {
      await pump(
        tester,
        const AppSettings(clockOutNotificationEnabled: true),
        permission: NotificationPermission.granted,
        exactAllowed: false,
      );
      expect(find.text('알람 및 리마인더'), findsOneWidget);
      expect(
        tester.widget<Text>(find.text('허용해야 퇴근 알림이 와요')).style?.color,
        AppColors.minus,
      );
      expect(find.byType(SoiSwitch), findsOneWidget); // 토글은 그대로
      await tester.tap(find.text('알람 및 리마인더'));
      expect(taps, ['exact']);
    });

    testWidgets('정시 권한이 있거나 · 알림이 꺼져 있거나 · OS 알림이 꺼져 있으면 행이 없다', (tester) async {
      await pump(tester, const AppSettings(clockOutNotificationEnabled: true), permission: NotificationPermission.granted);
      expect(find.text('알람 및 리마인더'), findsNothing);
      await pump(tester, const AppSettings(), permission: NotificationPermission.granted, exactAllowed: false);
      expect(find.text('알람 및 리마인더'), findsNothing);
      await pump(
        tester,
        const AppSettings(clockOutNotificationEnabled: true),
        permission: NotificationPermission.denied,
        exactAllowed: false,
      );
      expect(find.text('알람 및 리마인더'), findsNothing);
    });

    testWidgets('폭 320에서 넘치지 않는다', (tester) async {
      await pump(
        tester,
        const AppSettings(clockOutNotificationEnabled: true),
        width: 320,
        permission: NotificationPermission.granted,
        exactAllowed: false,
      );
      expect(tester.takeException(), isNull);
    });
  });
}

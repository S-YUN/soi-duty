import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/core/presentation/size_config.dart';
import 'package:soi_duty/domain/model/app_settings.dart';
import 'package:soi_duty/presentation/settings/settings_screen.dart';
import 'package:soi_duty/ui/app_theme.dart';

import '../helpers/fonts.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadPretendard();
  });

  WeekStart? pickedWeekStart;
  var taps = <String>[];

  Future<void> pump(WidgetTester tester, AppSettings settings, {double width = 402}) async {
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
        year: 2026,
        version: '1.0.1',
        callbacks: SettingsCallbacks(
          onBack: () => taps.add('back'),
          onWeekStart: (w) => pickedWeekStart = w,
          onTapAnnual: () => taps.add('annual'),
          onTapWage: () => taps.add('wage'),
          onExport: () => taps.add('export'),
          onImport: () => taps.add('import'),
          onPrivacy: () => taps.add('privacy'),
        ),
      ),
    ));
    await tester.pump();
  }

  testWidgets('빈 상태 — 두 보조 설명과 "사용 안 함" 둘, "아직 내보낸 적 없어요", 버전', (tester) async {
    await pump(tester, const AppSettings());
    expect(find.text('설정'), findsOneWidget);
    expect(find.text('알려주시면 월간 탭에서 남은 연차를 볼 수 있어요'), findsOneWidget);
    expect(find.text('알려주시면 주말·공휴일 근무 예상 금액을 볼 수 있어요'), findsOneWidget);
    expect(find.text('사용 안 함'), findsNWidgets(2));
    expect(find.text('아직 내보낸 적 없어요'), findsOneWidget);
    expect(find.text('주간 탭과 주 40시간 계산은 월~일 그대로예요'), findsOneWidget);
    expect(find.text('주말·공휴일 근무 × 1.5배로 계산해요'), findsOneWidget);
    expect(find.text('1.0.1'), findsOneWidget);
    expect(find.text('개인정보 처리방침'), findsOneWidget);
  });

  testWidgets('채운 상태 — "15일" · "12,500원" · "마지막 내보내기 10월 24일", 보조 설명 없음', (tester) async {
    await pump(
      tester,
      AppSettings(
        weekStart: WeekStart.sunday,
        annualLeaveDaysByYear: const {2026: 15},
        hourlyWage: 12500,
        lastExportDate: DateTime(2026, 10, 24),
      ),
    );
    expect(find.text('15일'), findsOneWidget);
    expect(find.text('12,500원'), findsOneWidget);
    expect(find.text('마지막 내보내기 10월 24일'), findsOneWidget);
    expect(find.text('사용 안 함'), findsNothing);
    expect(find.text('알려주시면 월간 탭에서 남은 연차를 볼 수 있어요'), findsNothing);
  });

  testWidgets('행 탭 → 콜백, 세그먼트 "일" 탭 → onWeekStart(sunday)', (tester) async {
    await pump(tester, const AppSettings());
    await tester.tap(find.text('일'));
    expect(pickedWeekStart, WeekStart.sunday);
    await tester.tap(find.text('올해 총 연차'));
    await tester.tap(find.text('시급'));
    await tester.tap(find.text('내보내기'));
    await tester.tap(find.text('가져오기'));
    await tester.ensureVisible(find.text('개인정보 처리방침'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('개인정보 처리방침'));
    await tester.tap(find.byTooltip('뒤로'));
    expect(taps, ['annual', 'wage', 'export', 'import', 'privacy', 'back']);
  });

  testWidgets('폭 320·600에서 overflow 없음', (tester) async {
    for (final w in [320.0, 600.0]) {
      await pump(tester, AppSettings(annualLeaveDaysByYear: const {2026: 15}, hourlyWage: 9999999, lastExportDate: DateTime(2026, 10, 24)), width: w);
      expect(tester.takeException(), isNull, reason: 'width $w');
      await pump(tester, const AppSettings(), width: w);
      expect(tester.takeException(), isNull, reason: 'width $w empty');
    }
  });
}

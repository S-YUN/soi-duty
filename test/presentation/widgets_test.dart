import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/core/presentation/size_config.dart';
import 'package:soi_duty/domain/model/work_type.dart';
import 'package:soi_duty/domain/model/app_settings.dart';
import 'package:soi_duty/presentation/settings/widgets/segment_toggle.dart';
import 'package:soi_duty/presentation/shell/gear_button.dart';
import 'package:soi_duty/presentation/shell/shell_tab_bar.dart';
import 'package:soi_duty/presentation/today/widgets/pill_tabs.dart';
import 'package:soi_duty/presentation/today/widgets/primary_button.dart';
import 'package:soi_duty/presentation/today/widgets/soi_checkbox.dart';
import 'package:soi_duty/presentation/today/widgets/summary_row.dart';
import 'package:soi_duty/presentation/today/widgets/type_badge.dart';
import 'package:soi_duty/ui/app_colors.dart';
import 'package:soi_duty/ui/app_sizes.dart';

Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  setUp(() => SizeConfig.init(402));

  testWidgets('PrimaryButton 높이 56, 비활성이면 탭 무반응', (tester) async {
    var taps = 0;
    await tester.pumpWidget(wrap(PrimaryButton(label: '출근하기', onPressed: () => taps++)));
    expect(tester.getSize(find.byType(PrimaryButton)).height, AppSizes.primaryButton);
    await tester.tap(find.text('출근하기'));
    expect(taps, 1);

    await tester.pumpWidget(wrap(const PrimaryButton(label: '오늘 퇴근 완료')));
    await tester.tap(find.text('오늘 퇴근 완료'));
    expect(taps, 1);
  });

  testWidgets('SoiCheckbox 탭하면 반전값 콜백, 히트 영역 44 이상', (tester) async {
    bool? received;
    await tester.pumpWidget(wrap(SoiCheckbox(
      label: '오늘 반차',
      checked: false,
      onChanged: (v) => received = v,
      shape: SoiCheckShape.square,
    )));
    expect(tester.getSize(find.byType(SoiCheckbox)).height, greaterThanOrEqualTo(AppSizes.minTapHeight));
    await tester.tap(find.text('오늘 반차'));
    expect(received, isTrue);
  });

  testWidgets('PillTabs 선택 콜백', (tester) async {
    int? selected;
    await tester.pumpWidget(wrap(PillTabs(labels: const ['오늘', '주간'], selectedIndex: 0, onSelected: (i) => selected = i)));
    await tester.tap(find.text('주간'));
    expect(selected, 1);
  });

  testWidgets('ShellTabBar — 톱니가 있고 PillTabs 중심 x는 화면 중심', (tester) async {
    tester.view.physicalSize = const Size(402 * 3, 874 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    var opened = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ShellTabBar(labels: const ['오늘', '주간', '월간'], selectedIndex: 0, onSelected: (_) {}, onSettings: () => opened++),
      ),
    ));
    expect(tester.getCenter(find.byType(PillTabs)).dx, closeTo(201, 0.5));
    final gear = find.byType(GearButton);
    expect(tester.getSize(gear), Size(AppSizes.gearSize, AppSizes.gearSize));
    expect(tester.getTopRight(gear).dx, closeTo(402 - AppSizes.gearRight, 0.5));
    await tester.tap(gear);
    expect(opened, 1);
  });

  testWidgets('ShellTabBar — 폭 320에서도 톱니가 알약과 겹치지 않는다', (tester) async {
    SizeConfig.init(320);
    tester.view.physicalSize = const Size(320 * 3, 874 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ShellTabBar(labels: const ['오늘', '주간', '월간'], selectedIndex: 0, onSelected: (_) {}, onSettings: () {}),
      ),
    ));
    expect(tester.getTopRight(find.byType(PillTabs)).dx, lessThan(tester.getTopLeft(find.byType(GearButton)).dx));
  });

  testWidgets('SegmentToggle — 선택 배경이 토글처럼 미끄러져 이동한다', (tester) async {
    Widget build(WeekStart value) => wrap(SegmentToggle<WeekStart>(
          options: const [(WeekStart.monday, '월'), (WeekStart.sunday, '일')],
          value: value,
          onChanged: (_) {},
        ));
    Finder thumb() => find.byWidgetPredicate(
        (w) => w is DecoratedBox && (w.decoration as BoxDecoration).color == AppColors.brand);
    await tester.pumpWidget(build(WeekStart.monday));
    await tester.pumpAndSettle();
    expect(thumb(), findsOneWidget);
    final monX = tester.getCenter(find.text('월')).dx;
    final sunX = tester.getCenter(find.text('일')).dx;
    expect(tester.getCenter(thumb()).dx, closeTo(monX, 1));

    await tester.pumpWidget(build(WeekStart.sunday));
    await tester.pump(AppDurations.buttonColor ~/ 2);
    final midX = tester.getCenter(thumb()).dx;
    expect(midX, greaterThan(monX + 2));
    expect(midX, lessThan(sunX - 2));
    await tester.pumpAndSettle();
    expect(tester.getCenter(thumb()).dx, closeTo(sunX, 1));
  });

  testWidgets('TypeBadge 라벨', (tester) async {
    await tester.pumpWidget(wrap(const TypeBadge(type: WorkType.holiday)));
    expect(find.text('공휴일'), findsOneWidget);
  });

  testWidgets('SummaryRow 4칸과 값 색', (tester) async {
    await tester.pumpWidget(wrap(SummaryRow(
      labels: const ['출근', '퇴근', '근무', '기준 대비'],
      values: const ['09:12', '18:05', '7h 53m', '−7m'],
      valueColor: (i) => i == 3 ? AppColors.minus : null,
    )));
    expect(find.text('−7m'), findsOneWidget);
    final text = tester.widget<Text>(find.text('−7m'));
    expect(text.style?.color, AppColors.minus);
  });
}

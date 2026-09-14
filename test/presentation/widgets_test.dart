import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/core/presentation/size_config.dart';
import 'package:soi_duty/domain/model/work_type.dart';
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
      label: '오늘은 반차',
      checked: false,
      onChanged: (v) => received = v,
      shape: SoiCheckShape.square,
    )));
    expect(tester.getSize(find.byType(SoiCheckbox)).height, greaterThanOrEqualTo(AppSizes.minTapHeight));
    await tester.tap(find.text('오늘은 반차'));
    expect(received, isTrue);
  });

  testWidgets('PillTabs 선택 콜백', (tester) async {
    int? selected;
    await tester.pumpWidget(wrap(PillTabs(labels: const ['오늘', '주간'], selectedIndex: 0, onSelected: (i) => selected = i)));
    await tester.tap(find.text('주간'));
    expect(selected, 1);
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

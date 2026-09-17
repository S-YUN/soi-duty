import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/core/presentation/size_config.dart';
import 'package:soi_duty/domain/model/work_type.dart';
import 'package:soi_duty/domain/rules/work_rules.dart';
import 'package:soi_duty/presentation/month/month_screen.dart';
import 'package:soi_duty/presentation/month/month_state_builder.dart';
import 'package:soi_duty/ui/app_colors.dart';
import 'package:soi_duty/ui/app_theme.dart';

import '../helpers/fonts.dart';
import '../helpers/records.dart';

void main() {
  const rules = WorkRules();
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadPretendard();
  });
  setUp(() => SizeConfig.init(402));

  testWidgets('배지와 값이 그려지고, 셀을 탭하면 날짜가 올라온다', (tester) async {
    tester.view.physicalSize = const Size(402 * 3, 874 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final state = buildMonthState(
      records: [
        rec(14, inH: 9, inM: 5, outH: 18, outM: 36),
        rec(15, type: WorkType.holiday),
        rec(16, inH: 9, outH: 13, outM: 10, type: WorkType.halfDay),
      ],
      firstRecordDate: DateTime(2026, 8, 20),
      now: d(16, 12),
      rules: rules,
      month: DateTime(2026, 9),
    );
    DateTime? tapped;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: MonthView(
          state: state,
          canGoPrev: true,
          canGoNext: true,
          onCellTap: (d) => tapped = d,
          onPrev: () {},
          onNext: () {},
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('2026년 9월'), findsOneWidget);
    expect(find.text('+31m'), findsOneWidget);
    expect(find.text('공휴일'), findsOneWidget); // 범례만 — 셀은 원 색으로 구분
    expect(find.text('+10m'), findsOneWidget); // 반차도 값은 그대로
    BoxDecoration circleOf(String day) => tester
        .widget<Container>(find.ancestor(of: find.text(day), matching: find.byType(Container)).first)
        .decoration! as BoxDecoration;
    expect(circleOf('15').color, AppColors.typeColors(WorkType.holiday).$1);
    expect(circleOf('16').color, AppColors.typeColors(WorkType.halfDay).$1);
    expect(circleOf('14').color, AppColors.calendarWorked);
    expect(circleOf('18').color, isNull); // 미래 — 원 없음
    expect(circleOf('16').border, isNull); // 오늘 표시는 따로 없다
    await tester.tap(find.text('+31m'));
    expect(tapped, d(14));
  });
}

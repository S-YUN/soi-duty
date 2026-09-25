import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/core/presentation/format/time_format.dart';
import 'package:soi_duty/core/presentation/size_config.dart';
import 'package:soi_duty/domain/model/work_type.dart';
import 'package:soi_duty/domain/rules/work_rules.dart';
import 'package:soi_duty/presentation/month/month_screen.dart';
import 'package:soi_duty/presentation/month/month_state_builder.dart';
import 'package:soi_duty/presentation/month/widgets/calendar_card.dart';
import 'package:soi_duty/ui/app_colors.dart';
import 'package:soi_duty/ui/app_sizes.dart';
import 'package:soi_duty/ui/app_text_styles.dart';
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

  // 폰마다 폭이 다르다 — SizeConfig가 칸과 글자를 같은 배율로 키우므로 비율은 유지되지만,
  // 상한(480) 위에서는 칸만 넓어진다. 대표 폭에서 잘림·축소가 없는지 고정한다.
  for (final width in [320.0, 360.0, 375.0, 393.0, 402.0, 430.0, 480.0, 600.0]) {
    testWidgets('폭 ${width.toInt()}에서도 긴 값이 온전히 들어간다', (tester) async {
      tester.view.physicalSize = Size(width * 3, 900 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      SizeConfig.init(width);

      final state = buildMonthState(
        records: [rec(14, inH: 9, outH: 21, outM: 52)], // 12h − 1h 점심 − 8h = +3h 52m
        firstRecordDate: DateTime(2026, 8, 20),
        now: d(16, 12),
        rules: rules,
        month: DateTime(2026, 9),
      );
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.screenHPadding),
            child: CalendarCard(state: state, onCellTap: (_) {}),
          ),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 500));

      final label = '+3h${narrowSpace}52m';
      final value = find.text(label);
      expect(value, findsOneWidget);
      // 그려진 폭이 자연 폭과 같아야 한다 — 잘리거나 FittedBox로 줄어들지 않았다는 뜻.
      final painted = tester.getRect(value).width;
      final natural = (TextPainter(
        text: TextSpan(text: label, style: AppTextStyles.calendarValue(AppColors.brand)),
        textDirection: TextDirection.ltr,
      )..layout())
          .width;
      expect(painted, closeTo(natural, 0.5), reason: '폭 $width: 그려진 $painted / 자연 $natural');
    });
  }
}

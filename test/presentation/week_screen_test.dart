import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/core/presentation/size_config.dart';
import 'package:soi_duty/domain/model/work_type.dart';
import 'package:soi_duty/domain/rules/work_rules.dart';
import 'package:soi_duty/presentation/week/week_screen.dart';
import 'package:soi_duty/presentation/week/week_state_builder.dart';
import 'package:soi_duty/presentation/week/widgets/week_day_row.dart';
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

  testWidgets('7행 높이가 모두 같고, 행을 탭하면 날짜가 올라온다', (tester) async {
    tester.view.physicalSize = const Size(402 * 3, 874 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final state = buildWeekState(
      records: [
        rec(14, inH: 9, inM: 5, outH: 18, outM: 36),
        rec(15, type: WorkType.holiday),
        rec(16, inH: 9, inM: 12),
        rec(19, inH: 10, outH: 14, outM: 30),
      ],
      firstRecordDate: d(7),
      now: d(16, 12),
      rules: rules,
      monday: d(14),
    );
    DateTime? tapped;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: WeekView(state: state, rules: rules, onDayTap: (d) => tapped = d, onPrev: () {}, onNext: () {}),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 500));

    final heights = tester.widgetList(find.byType(WeekDayRow)).map((w) => tester.getSize(find.byWidget(w)).height).toSet();
    expect(heights.length, 1, reason: '행 높이: $heights');
    expect(find.text('9월 3째주'), findsOneWidget);

    await tester.tap(find.text('근무 중'));
    expect(tapped, d(16));
  });
}

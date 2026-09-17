import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/core/presentation/size_config.dart';
import 'package:soi_duty/domain/model/work_type.dart';
import 'package:soi_duty/domain/rules/work_rules.dart';
import 'package:soi_duty/presentation/month/month_screen.dart';
import 'package:soi_duty/presentation/month/month_state_builder.dart';
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
      records: [rec(14, inH: 9, inM: 5, outH: 18, outM: 36), rec(15, type: WorkType.holiday)],
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
          month: DateTime(2026, 9),
          earliest: DateTime(2026, 8),
          latest: DateTime(2026, 12),
          onPrev: () {},
          onNext: () {},
          onSelected: (_) {},
          pageBuilder: (_) => MonthBody(state: state, onCellTap: (d) => tapped = d),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('2026년 9월'), findsOneWidget);
    expect(find.text('+31m'), findsOneWidget);
    expect(find.text('공휴일'), findsNWidgets(2)); // 셀 배지 + 범례
    await tester.tap(find.text('+31m'));
    expect(tapped, d(14));
  });

  _pagerTests();
}

void _pagerTests() {
  const rules = WorkRules();
  Widget page(DateTime month) => MonthBody(
        state: buildMonthState(records: [], firstRecordDate: d(1), now: d(16, 12), rules: rules, month: month),
        onCellTap: (_) {},
      );

  testWidgets('스와이프하면 다음 달이 선택되고, 선택이 바뀌면 페이지가 따라간다', (tester) async {
    tester.view.physicalSize = const Size(402 * 3, 874 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    var month = DateTime(2026, 9);
    late StateSetter setMonth;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: StatefulBuilder(builder: (_, setState) {
          setMonth = setState;
          return MonthView(
            month: month,
            earliest: DateTime(2026, 9),
            latest: DateTime(2026, 12),
            onPrev: () {},
            onNext: () {},
            onSelected: (m) => setState(() => month = m),
            pageBuilder: page,
          );
        }),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('2026년 9월'), findsOneWidget);

    await tester.fling(find.byType(MonthBody).first, const Offset(-300, 0), 1000);
    await tester.pumpAndSettle();
    expect(month, DateTime(2026, 10));
    expect(find.text('2026년 10월'), findsOneWidget);

    setMonth(() => month = DateTime(2026, 12));
    await tester.pumpAndSettle();
    expect(find.text('2026년 12월'), findsOneWidget);
    expect(find.text('31'), findsWidgets); // 12월 페이지가 보인다

    // 마지막 달에서는 더 못 간다.
    await tester.fling(find.byType(MonthBody).last, const Offset(-300, 0), 1000);
    await tester.pumpAndSettle();
    expect(month, DateTime(2026, 12));
  });
}

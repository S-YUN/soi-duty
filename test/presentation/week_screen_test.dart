import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/core/presentation/size_config.dart';
import 'package:soi_duty/domain/model/work_type.dart';
import 'package:soi_duty/domain/rules/work_rules.dart';
import 'package:soi_duty/presentation/week/week_screen.dart';
import 'package:soi_duty/presentation/week/week_state_builder.dart';
import 'package:soi_duty/presentation/week/widgets/week_day_row.dart';
import 'package:soi_duty/ui/app_colors.dart';
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

  testWidgets('7행 높이가 모두 같고, 행을 탭하면 날짜가 올라온다', (tester) async {
    tester.view.physicalSize = const Size(402 * 3, 874 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final state = buildWeekState(
      records: [
        rec(14, inH: 9, inM: 5, outH: 21, outM: 1), // +2h 56m — 한 줄에 들어가야 한다
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
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: WeekView(state: state, rules: rules, onDayTap: (d) => tapped = d, onPrev: () {}, onNext: () {}),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    final heights = tester
        .widgetList(find.byType(WeekDayRow))
        .map((w) => tester.getSize(find.byWidget(w)).height)
        .toSet();
    expect(heights.length, 1, reason: '행 높이: $heights');
    final valueLine = AppTextStyles.rowValue(AppColors.ink).fontSize! * 1.6;
    expect(tester.getSize(find.text('+2h 56m')).height, lessThan(valueLine), reason: '± 값이 한 줄에 들어가야 한다');
    expect(find.text('9월 3째주'), findsOneWidget);

    await tester.tap(find.text('근무 중'));
    expect(tapped, d(16));
  });

  for (final width in [320.0, 360.0, 600.0]) {
    testWidgets('배지 둘이 있어도 7행 높이가 같고 폭 $width에서 넘치지 않는다', (tester) async {
      SizeConfig.init(width);
      tester.view.physicalSize = Size(width * 3, 900 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      final state = buildWeekState(
        records: [
          rec(
            14,
            inH: 9,
            inM: 5,
            outH: 21,
            outM: 1,
            type: WorkType.halfDay,
            ded: 150,
          ),
          rec(15, inH: 10, outH: 15, type: WorkType.holiday),
          rec(16, inH: 9, inM: 12),
          rec(17, type: WorkType.businessTrip),
        ],
        firstRecordDate: d(7),
        now: d(16, 12),
        rules: rules,
        monday: d(14),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: WeekView(state: state, rules: rules, onDayTap: (_) {}, onPrev: () {}, onNext: () {}),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
      final heights = tester
          .widgetList(find.byType(WeekDayRow))
          .map((w) => tester.getSize(find.byWidget(w)).height)
          .toSet();
      expect(heights.length, 1, reason: '행 높이: $heights');
      expect(find.text('2h 30m 공제'), findsOneWidget);
      expect(find.text('출장'), findsOneWidget);
    });
  }

  for (final width in [320.0, 360.0, 600.0]) {
    testWidgets('배지 셋(반차 + 출장 + 공제)이어도 7행 높이가 같고 폭 $width에서 넘치지 않는다 — 셋째는 둘째 줄', (tester) async {
      SizeConfig.init(width);
      tester.view.physicalSize = Size(width * 3, 900 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      final state = buildWeekState(
        records: [
          rec(14, inH: 13, inM: 5, outH: 21, outM: 1, type: WorkType.halfDay, ded: 150, tripInH: 13, tripInM: 40, tripOutH: 16, tripOutM: 50),
          rec(15, inH: 10, outH: 15, type: WorkType.holiday, tripInH: 10, tripOutH: 13),
          rec(16, inH: 9, inM: 12, tripInH: 9, tripInM: 12, tripOutH: 12, tripOutM: 12),
          rec(17, type: WorkType.businessTrip),
          rec(19, inH: 10, outH: 14, tripInH: 10, tripOutH: 12),
        ],
        firstRecordDate: d(7),
        now: d(16, 12),
        rules: rules,
        monday: d(14),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: WeekView(state: state, rules: rules, onDayTap: (_) {}, onPrev: () {}, onNext: () {}),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
      final heights = tester
          .widgetList(find.byType(WeekDayRow))
          .map((w) => tester.getSize(find.byWidget(w)).height)
          .toSet();
      expect(heights.length, 1, reason: '행 높이: $heights');
      // 첫 줄: 반차 · 출장 3h 10m, 둘째 줄 맨 앞: 공제
      final half = tester.getRect(find.text('반차'));
      final trip = tester.getRect(find.text('출장 3h 10m'));
      final deduction = tester.getRect(find.text('2h 30m 공제'));
      expect((trip.center.dy - half.center.dy).abs(), lessThan(1));
      expect(deduction.top, greaterThan(half.bottom));
      expect(deduction.left, lessThan(trip.left));
      // 메모(출퇴근 범위)는 공제 배지 오른쪽에서 한 줄
      final note = tester.getRect(find.text('13:05 – 21:01'));
      expect(note.left, greaterThan(deduction.right));
      expect((note.center.dy - deduction.center.dy).abs(), lessThan(2));
      // 배지가 값 칸을 침범하지 않는다
      expect(trip.right, lessThanOrEqualTo(tester.getRect(find.text('+6h 26m')).left));
      expect(find.text('출장 3h'), findsNWidgets(2)); // 공휴일 근무 + 오늘
      expect(find.text('출장 2h'), findsOneWidget); // 토요일
    });
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/core/presentation/format/time_format.dart';
import 'package:soi_duty/core/presentation/size_config.dart';
import 'package:soi_duty/domain/model/app_settings.dart';
import 'package:soi_duty/domain/model/leave_balance.dart';
import 'package:soi_duty/domain/model/work_type.dart';
import 'package:soi_duty/domain/rules/work_rules.dart';
import 'package:soi_duty/presentation/month/month_screen.dart';
import 'package:soi_duty/presentation/month/month_state.dart';
import 'package:soi_duty/presentation/month/month_state_builder.dart';
import 'package:soi_duty/presentation/month/widgets/calendar_card.dart';
import 'package:soi_duty/presentation/month/widgets/extra_work_card.dart';
import 'package:soi_duty/presentation/month/widgets/leave_card.dart';
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
      settings: const AppSettings(),
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
          onOpenWage: () {},
          onOpenAnnual: () {},
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('2026년 9월'), findsOneWidget);
    expect(find.text('+31m'), findsOneWidget);
    expect(find.text('공휴일'), findsNWidgets(2)); // 범례 + 수당 카드 행 — 셀은 원 색으로 구분
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

  testWidgets('주말 근무를 찍어도 날짜 숫자는 적갈색 그대로, 평일은 원 위에서 잉크', (tester) async {
    tester.view.physicalSize = const Size(402 * 3, 874 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final state = buildMonthState(
      records: [rec(19, inH: 10, outH: 14), rec(14, inH: 9, outH: 18)],
      firstRecordDate: DateTime(2026, 8, 20),
      now: d(16, 12),
      rules: rules,
      month: DateTime(2026, 9),
      settings: const AppSettings(),
    );
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: CalendarCard(state: state, onCellTap: (_) {})),
    ));
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.widget<Text>(find.text('19')).style?.color, AppColors.calendarWeekendNum); // 토요일, 근무 원 있음
    expect(tester.widget<Text>(find.text('20')).style?.color, AppColors.calendarWeekendNum); // 일요일, 원 없음
    expect(tester.widget<Text>(find.text('14')).style?.color, AppColors.ink); // 평일 근무
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
        settings: const AppSettings(),
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

  testWidgets('범례 4개가 폭 320에서 넘치지 않는다', (tester) async {
    SizeConfig.init(320);
    tester.view.physicalSize = const Size(320 * 3, 900 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final state = buildMonthState(
      records: [rec(11, type: WorkType.businessTrip)],
      firstRecordDate: DateTime(2026, 8, 20),
      now: d(16, 12),
      rules: rules,
      month: DateTime(2026, 9),
      settings: const AppSettings(),
    );
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: MonthView(state: state, canGoPrev: true, canGoNext: true, onCellTap: (_) {}, onPrev: () {}, onNext: () {}, onOpenWage: () {}, onOpenAnnual: () {}),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);
    expect(find.text('출장'), findsOneWidget);
    final circle = tester
        .widget<Container>(find.ancestor(of: find.text('11'), matching: find.byType(Container)).first)
        .decoration! as BoxDecoration;
    expect(circle.color, AppColors.typeColors(WorkType.businessTrip).$1);
  });

  testWidgets('요일 헤더 — 기본은 월…일, 일요일 시작이면 일…토 (주말 색 유지)', (tester) async {
    tester.view.physicalSize = const Size(402 * 3, 874 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    Future<void> pump(AppSettings settings) => tester.pumpWidget(MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: MonthView(
              state: buildMonthState(
                records: [],
                firstRecordDate: DateTime(2026, 8, 20),
                now: d(16, 12),
                rules: rules,
                month: DateTime(2026, 9),
                settings: settings,
              ),
              canGoPrev: true,
              canGoNext: true,
              onCellTap: (_) {},
              onPrev: () {},
              onNext: () {},
              onOpenWage: () {},
              onOpenAnnual: () {},
            ),
          ),
        ));
    await pump(const AppSettings());
    expect(tester.getCenter(find.text('월')).dx, lessThan(tester.getCenter(find.text('일')).dx));
    await pump(const AppSettings(weekStart: WeekStart.sunday));
    expect(tester.getCenter(find.text('일')).dx, lessThan(tester.getCenter(find.text('월')).dx));
    expect(tester.getCenter(find.text('토')).dx, greaterThan(tester.getCenter(find.text('금')).dx));
    expect(tester.widget<Text>(find.text('일')).style?.color, AppColors.calendarWeekendNum);
    expect(tester.widget<Text>(find.text('월')).style?.color, AppColors.subtle);
  });

  group('월간 카드', () {
    var wageTaps = 0, annualTaps = 0;
    MonthState base() => buildMonthState(
          records: [],
          firstRecordDate: DateTime(2026, 8, 20),
          now: d(16, 12),
          rules: rules,
          month: DateTime(2026, 9),
          settings: const AppSettings(),
        );
    Future<void> pump(WidgetTester tester, MonthState state, {double width = 402}) async {
      wageTaps = 0;
      annualTaps = 0;
      SizeConfig.init(width);
      tester.view.physicalSize = Size(width * 3, 1400 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: MonthView(
            state: state,
            canGoPrev: true,
            canGoNext: true,
            onCellTap: (_) {},
            onPrev: () {},
            onNext: () {},
            onOpenWage: () => wageTaps++,
            onOpenAnnual: () => annualTaps++,
          ),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 500));
    }

    testWidgets('값 없음 + 기록 없음 — 두 카드가 항상 보이고 "기록 없음"·"—"·"미입력"·"0일"로 구분된다', (tester) async {
      await pump(tester, base());
      expect(find.text('9월 주말·공휴일 근무'), findsOneWidget);
      expect(find.text('기록 없음'), findsNWidgets(2)); // 주말 · 공휴일 행
      expect(tester.widget<Text>(find.text('기록 없음').first).style?.color, AppColors.subtle);
      expect(find.text('예상 금액'), findsOneWidget);
      final amountNone = find.descendant(of: find.byType(ExtraWorkCard), matching: find.text('—'));
      expect(amountNone, findsOneWidget);
      expect(tester.widget<Text>(amountNone).style?.color, AppColors.subtle);
      expect(tester.widget<Text>(amountNone).style?.fontSize, AppTextStyles.extraRowLabel.fontSize! / 13.5 * 15);
      expect(find.text('시급을 알려주시면 예상 금액을 보여드려요'), findsOneWidget);
      expect(find.text('2026년 연차'), findsOneWidget);
      expect(find.text('미입력'), findsOneWidget);
      expect(tester.widget<Text>(find.text('미입력')).style?.color, AppColors.subtle);
      expect(find.text('0일'), findsOneWidget); // 기록으로 나온 0은 숫자
      final remainNone = find.descendant(of: find.byType(LeaveCard), matching: find.text('—'));
      expect(remainNone, findsOneWidget);
      expect(tester.widget<Text>(remainNone).style?.color, AppColors.subtle);
      expect(tester.widget<Text>(remainNone).style?.fontWeight, FontWeight.w400);
      // 작은 글자(15)라 위 여백을 2 더 줘 "미입력"과 같은 선에 — 두 칸의 글자 밑선이 같다
      expect(tester.getBottomLeft(remainNone).dy, closeTo(tester.getBottomLeft(find.text('미입력')).dy, 0.5));
      expect(find.text('올해 사용'), findsOneWidget);
      expect(find.text('지금 남은 연차를 알려주시면 잔여를 보여드려요'), findsOneWidget);
    });

    testWidgets('수당 카드 — 주말 7h, 공휴일 0이면 "기록 없음", payWon 206250 → "206,250원"', (tester) async {
      await pump(tester, base().copyWith(extraWork: const MonthExtraWork(weekendMinutes: 420, holidayMinutes: 0, payWon: 206250)));
      expect(find.text('9월 주말·공휴일 근무'), findsOneWidget);
      expect(find.text('주말'), findsOneWidget);
      expect(find.text('7h'), findsOneWidget);
      expect(find.text('공휴일'), findsNWidgets(2)); // 범례 + 행
      expect(find.text('기록 없음'), findsOneWidget);
      expect(find.text('예상 금액'), findsOneWidget);
      expect(find.text('206,250원'), findsOneWidget);
      expect(find.text('시급을 알려주시면 예상 금액을 보여드려요'), findsNothing);
    });

    testWidgets('수당 카드 — payWon null이면 금액 "—" + 유도 줄, 탭 → onOpenWage', (tester) async {
      await pump(tester, base().copyWith(extraWork: const MonthExtraWork(weekendMinutes: 60, holidayMinutes: 240)));
      expect(find.text('1h'), findsOneWidget);
      expect(find.text('4h'), findsOneWidget);
      expect(find.text('예상 금액'), findsOneWidget);
      expect(find.descendant(of: find.byType(ExtraWorkCard), matching: find.text('—')), findsOneWidget);
      final nudge = find.text('시급을 알려주시면 예상 금액을 보여드려요');
      await tester.ensureVisible(nudge);
      await tester.pumpAndSettle();
      await tester.tap(nudge);
      expect(wageTaps, 1);
    });

    testWidgets('연차 카드 — 값 있음: 기준일 줄 · "남은 연차" "이후 사용" "지금 잔여"; 초과면 "초과" 붉은색', (tester) async {
      final b = LeaveBalance(remainingMinutes: 4080, baseDate: DateTime(2026, 10, 26));
      await pump(tester, base().copyWith(leave: MonthLeave(year: 2026, balance: b, usedMinutes: 480, plannedMinutes: 0, remainingMinutes: 3600, dayMinutes: 480)));
      expect(find.text('2026년 연차'), findsOneWidget);
      expect(find.text('10월 26일 기준'), findsOneWidget);
      expect(find.text('남은 연차'), findsOneWidget);
      expect(find.text('이후 사용'), findsOneWidget);
      expect(find.text('올해 사용'), findsNothing);
      expect(find.text('지금 잔여'), findsOneWidget);
      expect(find.text('8.5일'), findsOneWidget);
      expect(find.text('1일'), findsOneWidget);
      expect(find.text('7.5일'), findsOneWidget);
      expect(tester.widget<Text>(find.text('7.5일')).style?.color, AppColors.brand);
      expect(find.text('지금 남은 연차를 알려주시면 잔여를 보여드려요'), findsNothing);

      await pump(tester, base().copyWith(leave: MonthLeave(year: 2026, balance: b, usedMinutes: 4800, plannedMinutes: 0, remainingMinutes: -720, dayMinutes: 480)));
      expect(find.text('지금 잔여'), findsNothing);
      expect(find.text('초과'), findsOneWidget);
      expect(find.text('1.5일'), findsOneWidget);
      expect(tester.widget<Text>(find.text('1.5일')).style?.color, AppColors.minus);
    });

    testWidgets('연차 카드 — 1월 1일 기준이어도 라벨은 "남은 연차", 줄은 "1월 1일 기준"', (tester) async {
      final b = LeaveBalance(remainingMinutes: 7200, baseDate: DateTime(2026, 1, 1));
      await pump(tester, base().copyWith(leave: MonthLeave(year: 2026, balance: b, usedMinutes: 0, plannedMinutes: 0, remainingMinutes: 7200, dayMinutes: 480)));
      expect(find.text('1월 1일 기준'), findsOneWidget);
      expect(find.text('남은 연차'), findsOneWidget);
      expect(find.text('15일'), findsNWidgets(2));
      expect(find.text('0일'), findsOneWidget);
    });

    testWidgets('연차 카드 — plannedMinutes 720 → "예정 1.5일 포함", 0이면 없음. 세 칸 값의 y가 같다', (tester) async {
      final b = LeaveBalance(remainingMinutes: 7200, baseDate: DateTime(2026, 1, 1));
      await pump(tester, base().copyWith(leave: MonthLeave(year: 2026, balance: b, usedMinutes: 1680, plannedMinutes: 720, remainingMinutes: 5520, dayMinutes: 480)));
      expect(find.text('예정 1.5일 포함'), findsOneWidget);
      final y = tester.getTopLeft(find.text('15일')).dy;
      expect(tester.getTopLeft(find.text('3.5일')).dy, closeTo(y, 0.5));
      expect(tester.getTopLeft(find.text('11.5일')).dy, closeTo(y, 0.5));

      await pump(tester, base().copyWith(leave: MonthLeave(year: 2026, balance: b, usedMinutes: 1680, plannedMinutes: 0, remainingMinutes: 5520, dayMinutes: 480)));
      expect(find.textContaining('예정'), findsNothing);
    });

    testWidgets('연차 카드 — balance null → "미입력" · "올해 사용" · "—" + 유도 줄, 탭 → onOpenAnnual', (tester) async {
      await pump(tester, base().copyWith(leave: const MonthLeave(year: 2026, usedMinutes: 480, plannedMinutes: 0, dayMinutes: 480)));
      expect(find.text('미입력'), findsOneWidget);
      expect(find.textContaining('기준'), findsNothing);
      expect(find.descendant(of: find.byType(LeaveCard), matching: find.text('—')), findsOneWidget);
      expect(find.text('올해 사용'), findsOneWidget);
      expect(find.text('1일'), findsOneWidget);
      final nudge = find.text('지금 남은 연차를 알려주시면 잔여를 보여드려요');
      await tester.ensureVisible(nudge);
      await tester.pumpAndSettle();
      await tester.tap(nudge);
      expect(annualTaps, 1);
    });

    for (final width in [320.0, 360.0, 375.0, 393.0, 402.0, 430.0, 480.0, 600.0]) {
      testWidgets('폭 ${width.toInt()}에서 두 카드가 넘치지 않는다', (tester) async {
        await pump(
          tester,
          base().copyWith(
            extraWork: const MonthExtraWork(weekendMinutes: 1234, holidayMinutes: 999, payWon: 99999999),
            leave: MonthLeave(year: 2026, balance: LeaveBalance(remainingMinutes: 99 * 480, baseDate: DateTime(2026, 12, 31)), usedMinutes: 199 * 240, plannedMinutes: 101 * 240, remainingMinutes: -240, dayMinutes: 480),
          ),
          width: width,
        );
        expect(tester.takeException(), isNull, reason: 'width $width');
        await pump(tester, base().copyWith(extraWork: const MonthExtraWork(weekendMinutes: 1234, holidayMinutes: 999), leave: const MonthLeave(year: 2026, usedMinutes: 199 * 240, plannedMinutes: 101 * 240, dayMinutes: 480)), width: width);
        expect(tester.takeException(), isNull, reason: 'width $width nudges');
      });
    }
  });
}

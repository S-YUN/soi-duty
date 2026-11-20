import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/core/presentation/size_config.dart';
import 'package:soi_duty/domain/model/work_record.dart';
import 'package:soi_duty/domain/model/work_type.dart';
import 'package:soi_duty/domain/rules/work_rules.dart';
import 'package:soi_duty/presentation/today/today_state.dart';
import 'package:soi_duty/presentation/today/today_state_builder.dart';
import 'package:soi_duty/presentation/today/today_view.dart';
import 'package:soi_duty/presentation/today/widgets/first_week_card.dart';
import 'package:soi_duty/presentation/today/widgets/primary_button.dart';
import 'package:soi_duty/presentation/today/widgets/soi_checkbox.dart';
import 'package:soi_duty/presentation/today/widgets/summary_row.dart';
import 'package:soi_duty/presentation/today/widgets/today_trip_sheet.dart';
import 'package:soi_duty/presentation/today/widgets/trip_chip.dart';
import 'package:soi_duty/ui/app_colors.dart';
import 'package:soi_duty/presentation/today/widgets/unrecorded_card.dart';
import 'package:soi_duty/ui/app_sizes.dart';
import 'package:soi_duty/ui/app_theme.dart';

import '../helpers/fonts.dart';
import '../helpers/records.dart';

const rules = WorkRules();

TodayCallbacks noop() => TodayCallbacks(
  onClockIn: () {},
  onClockOut: (_) {},
  onHalfDayChanged: (_) {},
  onDayTypeChanged: (_) {},
  onRevert: () {},
  onEditTime: () {},
  onEditClockIn: () {},
  onCancelClockIn: () {},
  onCancelClockOut: () {},
  onUnrecordedTap: (_) {},
  onTripTap: () {},
  onTripRadioTap: () {},
  onDateLongPress: null,
);

// 기본 firstRecordDate는 `past`의 첫 기록일(14, 월)과 맞춘다. d(7)(전주 월요일)을 쓰면
// 7~11일이 기록 없는 평일로 잡혀 기록 누락 카드가 의도치 않게 뜬다 — 그 시나리오는
// 아래 '기록 누락' 테스트에서 별도로 first를 넘겨 명시적으로 검증한다.
TodayState stateOf(
  List<WorkRecord> records, {
  DateTime? now,
  DateTime? first,
}) => buildTodayState(
  records: records,
  firstRecordDate: first ?? d(14),
  now: now ?? d(16, 12),
  rules: rules,
);

Future<void> pumpView(WidgetTester tester, TodayState state) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: TodayView(state: state, rules: rules, callbacks: noop()),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  final past = [rec(14, inH: 9, outH: 18), rec(15, inH: 9, outH: 18)];

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadPretendard();
  });

  setUp(() {
    SizeConfig.init(402);
  });

  final fixtures = <String, TodayState>{
    '출근 전': stateOf(past),
    '근무 중': stateOf([...past, rec(16, inH: 9, inM: 12)]),
    '퇴근 완료': stateOf([
      ...past,
      rec(16, inH: 9, inM: 12, outH: 18, outM: 5),
    ], now: d(16, 19)),
    '연차': stateOf([...past, rec(16, type: WorkType.dayOff)]),
    '첫 주 예외': stateOf([rec(16, inH: 9, inM: 12)], first: d(16)),
  };

  // 평일 근무 중은 "남은 시간 공제하고 퇴근" 줄만큼 상태 블록이 늘어날 수 있다 (2026-09-27) — 그 상태만 "같거나 아래".
  testWidgets('주 버튼의 Y 좌표: 공제 체크가 없는 상태끼리는 같고, 평일 근무 중은 같거나 아래', (tester) async {
    tester.view.physicalSize = const Size(402 * 3, 874 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final ys = <String, double>{};
    for (final entry in {...fixtures, '공휴일 근무 중': stateOf([...past, rec(16, inH: 9, type: WorkType.holiday)])}.entries) {
      await pumpView(tester, entry.value);
      ys[entry.key] = tester.getTopLeft(find.byType(PrimaryButton)).dy;
    }
    final working = ys.remove('근무 중')!;
    expect(ys.values.toSet().length, 1, reason: '버튼 Y가 상태마다 다름: $ys');
    expect(working, greaterThanOrEqualTo(ys.values.first));
  });

  testWidgets('출근 전 라디오 3개가 폭 320에서 넘치지 않는다', (tester) async {
    SizeConfig.init(320);
    tester.view.physicalSize = const Size(320 * 3, 640 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await pumpView(tester, fixtures['출근 전']!);
    expect(tester.takeException(), isNull);
    expect(find.text('출장'), findsOneWidget);
  });

  testWidgets('공휴일 상태는 출근하기가 눌리고, 연차·출장은 안 눌린다', (tester) async {
    Future<bool> tapClockIn(TodayState state) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: TodayView(
              state: state,
              rules: rules,
              callbacks: TodayCallbacks(
                onClockIn: () => tapped = true,
                onClockOut: (_) {},
                onHalfDayChanged: (_) {},
                onDayTypeChanged: (_) {},
                onRevert: () {},
                onEditTime: () {},
                onEditClockIn: () {},
                onCancelClockIn: () {},
                onCancelClockOut: () {},
                onUnrecordedTap: (_) {},
                onTripTap: () {},
                onTripRadioTap: () {},
                onDateLongPress: null,
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.byType(PrimaryButton));
      return tapped;
    }

    expect(await tapClockIn(stateOf([...past, rec(16, type: WorkType.holiday)])), isTrue);
    expect(await tapClockIn(stateOf([...past, rec(16, type: WorkType.dayOff)])), isFalse);
    expect(await tapClockIn(stateOf([...past, rec(16, type: WorkType.businessTrip)])), isFalse);
  });

  testWidgets('공제 체크를 켜면 버튼이 바뀌고 퇴근 콜백에 true', (tester) async {
    bool? deduct;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: TodayView(
            state: fixtures['근무 중']!,
            rules: rules,
            callbacks: TodayCallbacks(
              onClockIn: () {},
              onClockOut: (v) => deduct = v,
              onHalfDayChanged: (_) {},
              onDayTypeChanged: (_) {},
              onRevert: () {},
              onEditTime: () {},
              onEditClockIn: () {},
              onCancelClockIn: () {},
              onCancelClockOut: () {},
              onUnrecordedTap: (_) {},
              onTripTap: () {},
              onTripRadioTap: () {},
              onDateLongPress: null,
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('남은 시간 공제하고 퇴근'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('공제하고 퇴근하기'), findsOneWidget);
    await tester.tap(find.byType(PrimaryButton));
    expect(deduct, isTrue);
  });

  testWidgets('공휴일 근무 중엔 반차·공제 체크가 없다', (tester) async {
    await pumpView(tester, stateOf([...past, rec(16, inH: 9, type: WorkType.holiday)]));
    expect(find.text('오늘 반차'), findsNothing);
    expect(find.text('남은 시간 공제하고 퇴근'), findsNothing);
    expect(find.text('출근 취소'), findsOneWidget);
  });

  testWidgets('기록 누락이 없으면 카드가 없고, 있으면 있다', (tester) async {
    await pumpView(tester, stateOf(past));
    expect(find.byType(UnrecordedCard), findsNothing);

    await pumpView(tester, stateOf([rec(14, inH: 9, outH: 18)], first: d(14)));
    expect(find.byType(UnrecordedCard), findsOneWidget);
    expect(find.text('기록 안 된 날 1개'), findsOneWidget);
  });

  testWidgets('첫 주 예외에서만 안내 카드', (tester) async {
    await pumpView(tester, stateOf(past));
    expect(find.byType(FirstWeekCard), findsNothing);
    await pumpView(tester, fixtures['첫 주 예외']!);
    expect(find.byType(FirstWeekCard), findsOneWidget);
  });

  testWidgets('상태별 버튼 라벨과 보조 슬롯', (tester) async {
    await pumpView(tester, fixtures['출근 전']!);
    expect(find.text('출근하기'), findsOneWidget);
    expect(find.text('연차'), findsOneWidget);
    expect(find.text('공휴일'), findsOneWidget);
    expect(find.text('출장'), findsOneWidget);

    await pumpView(tester, fixtures['근무 중']!);
    expect(find.text('퇴근하기'), findsOneWidget);
    expect(find.text('오늘 반차'), findsOneWidget);
    expect(find.text('출근 취소'), findsOneWidget);

    await pumpView(tester, fixtures['퇴근 완료']!);
    expect(find.text('오늘 퇴근 완료'), findsOneWidget);
    expect(find.text('시간 수정'), findsOneWidget);
    expect(find.text('퇴근 취소'), findsOneWidget);

    await pumpView(tester, fixtures['연차']!);
    expect(find.text('되돌리기'), findsOneWidget);
    expect(find.text('기록하려면'), findsNothing);
    expect(find.text('연차'), findsOneWidget);
  });

  testWidgets('콜백 연결: 출근하기 탭', (tester) async {
    var clockedIn = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: TodayView(
            state: fixtures['출근 전']!,
            rules: rules,
            callbacks: TodayCallbacks(
              onClockIn: () => clockedIn = true,
              onClockOut: (_) {},
              onHalfDayChanged: (_) {},
              onDayTypeChanged: (_) {},
              onRevert: () {},
              onEditTime: () {},
              onEditClockIn: () {},
              onCancelClockIn: () {},
              onCancelClockOut: () {},
              onUnrecordedTap: (_) {},
              onTripTap: () {},
              onTripRadioTap: () {},
              onDateLongPress: null,
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('출근하기'));
    expect(clockedIn, isTrue);
  });

  testWidgets('보조 슬롯 히트 영역이 44 이상, 가장자리도 탭된다', (tester) async {
    bool? halfDay;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: TodayView(
            state: fixtures['근무 중']!,
            rules: rules,
            callbacks: TodayCallbacks(
              onClockIn: () {},
              onClockOut: (_) {},
              onHalfDayChanged: (v) => halfDay = v,
              onDayTypeChanged: (_) {},
              onRevert: () {},
              onEditTime: () {},
              onEditClockIn: () {},
              onCancelClockIn: () {},
              onCancelClockOut: () {},
              onUnrecordedTap: (_) {},
              onTripTap: () {},
              onTripRadioTap: () {},
              onDateLongPress: null,
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(
      tester.getSize(find.ancestor(of: find.text('오늘 반차'), matching: find.byType(SoiCheckbox))).height,
      greaterThanOrEqualTo(AppSizes.minTapHeight),
    );

    await tester.tapAt(
      tester.getCenter(find.text('오늘 반차')) +
          Offset(0, AppSizes.minTapHeight / 2 - 1),
    );
    expect(halfDay, isTrue);
  });

  testWidgets('되돌리기 링크 히트 영역이 44 이상, 탭하면 콜백', (tester) async {
    var reverted = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: TodayView(
            state: fixtures['연차']!,
            rules: rules,
            callbacks: TodayCallbacks(
              onClockIn: () {},
              onClockOut: (_) {},
              onHalfDayChanged: (_) {},
              onDayTypeChanged: (_) {},
              onRevert: () => reverted = true,
              onEditTime: () {},
              onEditClockIn: () {},
              onCancelClockIn: () {},
              onCancelClockOut: () {},
              onUnrecordedTap: (_) {},
              onTripTap: () {},
              onTripRadioTap: () {},
              onDateLongPress: null,
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    final revertHitBox = find
        .ancestor(of: find.text('되돌리기'), matching: find.byType(GestureDetector))
        .first;
    expect(
      tester.getSize(revertHitBox).height,
      greaterThanOrEqualTo(AppSizes.minTapHeight),
    );

    await tester.tap(find.text('되돌리기'));
    expect(reverted, isTrue);
  });

  testWidgets('목표를 넘긴 주: 히어로에 0h와 초과 문구', (tester) async {
    await pumpView(
      tester,
      stateOf([
        for (final day in [14, 15, 16, 17]) rec(day, inH: 8, outH: 21),
      ], now: d(20, 12)),
    );
    expect(find.text('0h'), findsOneWidget);
    expect(find.text('이번 주에 8시간 더 일했어요'), findsOneWidget);
  });

  group('시간 출장 칩 (핸드오프 6 §4)', () {
    TodayCallbacks callbacks({VoidCallback? onTripTap, VoidCallback? onTripRadioTap, ValueChanged<WorkType?>? onDayType}) =>
        TodayCallbacks(
          onClockIn: () {},
          onClockOut: (_) {},
          onHalfDayChanged: (_) {},
          onDayTypeChanged: onDayType ?? (_) {},
          onRevert: () {},
          onEditTime: () {},
          onEditClockIn: () {},
          onCancelClockIn: () {},
          onCancelClockOut: () {},
          onUnrecordedTap: (_) {},
          onTripTap: onTripTap ?? () {},
          onTripRadioTap: onTripRadioTap ?? () {},
          onDateLongPress: null,
        );
    Future<void> pump(WidgetTester tester, TodayState state, TodayCallbacks cb) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: Scaffold(body: TodayView(state: state, rules: rules, callbacks: cb))),
      );
      await tester.pump(const Duration(milliseconds: 500));
    }

    final working = stateOf([...past, rec(16, inH: 9, inM: 12)]);
    final workingTrip = stateOf([...past, rec(16, inH: 9, inM: 12, tripInH: 9, tripInM: 12, tripOutH: 12, tripOutM: 12)]);
    final beforeTrip = stateOf([...past, rec(16, tripInH: 9, tripOutH: 12)]);
    final doneTrip = stateOf(
      [...past, rec(16, inH: 9, inM: 12, outH: 18, outM: 5, tripInH: 9, tripInM: 12, tripOutH: 12, tripOutM: 12)],
      now: d(16, 19),
    );

    testWidgets('근무 중: "09:12 출근" 옆에 "+ 출장", 탭하면 onTripTap', (tester) async {
      var taps = 0;
      await pump(tester, working, callbacks(onTripTap: () => taps++));
      expect(find.text('+ 출장'), findsOneWidget);
      final clock = tester.getRect(find.text('09:12 출근'));
      final chip = tester.getRect(find.text('+ 출장'));
      expect(chip.left, greaterThan(clock.right));
      expect((chip.center.dy - clock.center.dy).abs(), lessThan(3));
      await tester.tap(find.text('+ 출장'));
      expect(taps, 1);
      // 누르는 자리는 칩보다 넓다 — 칩 위쪽 가장자리 밖도 탭된다
      await tester.tapAt(Offset(chip.center.dx, chip.top - 2));
      expect(taps, 2);
    });

    testWidgets('근무 중: 범위가 있으면 출장색 칩 "출장 09:12–12:12"', (tester) async {
      var taps = 0;
      await pump(tester, workingTrip, callbacks(onTripTap: () => taps++));
      expect(find.text('+ 출장'), findsNothing);
      expect(tester.widget<Text>(find.text('출장 09:12–12:12')).style?.color, AppColors.tripText);
      await tester.tap(find.text('출장 09:12–12:12'));
      expect(taps, 1);
    });

    testWidgets('출근 전: 범위가 없으면 칩이 없고, 있으면 "아직 출근 전" 옆에 있다 — 출근 버튼·라디오는 그대로', (tester) async {
      await pump(tester, stateOf(past), callbacks());
      expect(find.byType(TripChip), findsNothing);
      var taps = 0;
      await pump(tester, beforeTrip, callbacks(onTripTap: () => taps++));
      expect(find.text('아직 출근 전'), findsOneWidget);
      expect(find.text('출장 09:00–12:00'), findsOneWidget);
      expect(find.text('출근하기'), findsOneWidget);
      expect(find.text('연차'), findsOneWidget);
      await tester.tap(find.text('출장 09:00–12:00'));
      expect(taps, 1);
    });

    testWidgets('출근 전 "출장" 라디오는 유형을 바로 바꾸지 않고 onTripRadioTap을 부른다', (tester) async {
      var radio = 0;
      WorkType? changed;
      var typeChanged = false;
      await pump(
        tester,
        stateOf(past),
        callbacks(onTripRadioTap: () => radio++, onDayType: (t) {
          typeChanged = true;
          changed = t;
        }),
      );
      await tester.tap(find.text('출장'));
      expect(radio, 1);
      expect(typeChanged, isFalse);
      await tester.tap(find.text('연차'));
      expect(changed, WorkType.dayOff);
    });

    testWidgets('퇴근 완료: 범위가 있으면 요약 위에 칩(탭 반응 없음), 없으면 없다', (tester) async {
      var taps = 0;
      await pump(tester, doneTrip, callbacks(onTripTap: () => taps++));
      final chip = tester.getRect(find.text('출장 09:12–12:12'));
      expect(chip.bottom, lessThanOrEqualTo(tester.getRect(find.byType(SummaryRow)).top + 1));
      await tester.tap(find.text('출장 09:12–12:12'));
      expect(taps, 0);
      await pump(tester, fixtures['퇴근 완료']!, callbacks());
      expect(find.byType(TripChip), findsNothing);
    });

    for (final width in [320.0, 360.0, 402.0]) {
      testWidgets('칩이 붙어도 주 버튼 Y가 그대로이고 폭 $width에서 넘치지 않는다', (tester) async {
        SizeConfig.init(width);
        tester.view.physicalSize = Size(width * 3, 874 * 3);
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);
        Future<double> buttonY(TodayState state) async {
          await pump(tester, state, callbacks());
          expect(tester.takeException(), isNull);
          return tester.getTopLeft(find.byType(PrimaryButton)).dy;
        }

        // 출근 전·퇴근 완료: 칩 유무와 무관하게 같다
        expect(await buttonY(beforeTrip), await buttonY(stateOf(past)));
        expect(await buttonY(doneTrip), await buttonY(fixtures['퇴근 완료']!));
        // 근무 중: "+ 출장"·범위 칩 모두 칩이 없던 때(출근 전 기준)의 평일 근무 중 높이를 넘기지 않는다
        final plainWorking = await buttonY(working);
        expect(await buttonY(workingTrip), plainWorking);
        // 주말 근무 중(공제 줄 없음)은 다른 상태와 같은 Y
        final weekendWorking = stateOf([rec(19, inH: 10, tripInH: 10, tripOutH: 12)], now: d(19, 12), first: d(14));
        expect(await buttonY(weekendWorking), await buttonY(stateOf(past)));
      });
    }

    testWidgets('"오늘 출장" 시트: 두 행, 종일·시간을 고르면 그 값으로 닫힌다', (tester) async {
      Object? result = 'pending';
      Future<void> open(String? range) async {
        result = 'pending';
        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async => result = await showTodayTripSheet(context, tripRange: range),
                child: const Text('open'),
              ),
            ),
          ),
        ));
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
      }

      await open(null);
      expect(find.text('오늘 출장'), findsOneWidget);
      expect(find.text('출근 없이 8시간 근무로 인정돼요'), findsOneWidget);
      expect(find.text('출퇴근은 그대로 찍고, 출장 시간만 남겨요'), findsOneWidget);
      await tester.tap(find.text('종일 출장'));
      await tester.pumpAndSettle();
      expect(result, TodayTripChoice.fullDay);

      await open('09:00–12:00');
      expect(find.text('09:00–12:00'), findsOneWidget);
      await tester.tap(find.text('시간 출장'));
      await tester.pumpAndSettle();
      expect(result, TodayTripChoice.timed);

      await open(null);
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(result, isNull);
    });

    testWidgets('"오늘 출장" 시트가 폭 320에서 넘치지 않는다', (tester) async {
      SizeConfig.init(320);
      tester.view.physicalSize = const Size(320 * 3, 568 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showTodayTripSheet(context, tripRange: '09:00–12:00'),
              child: const Text('open'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('오늘이 공휴일이고 시간 출장을 넣어둔 날: 배지 옆에 칩이 보이고 주 버튼 Y는 그대로', (tester) async {
    tester.view.physicalSize = const Size(402 * 3, 874 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await pumpView(tester, stateOf([...past, rec(16, type: WorkType.holiday)]));
    final plainY = tester.getTopLeft(find.byType(PrimaryButton)).dy;
    expect(find.byType(TripChip), findsNothing);
    await pumpView(tester, stateOf([...past, rec(16, type: WorkType.holiday, tripInH: 9, tripOutH: 12)]));
    expect(tester.takeException(), isNull);
    expect(find.text('출장 09:00–12:00'), findsOneWidget);
    expect(tester.getTopLeft(find.byType(PrimaryButton)).dy, plainY);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:soi_duty/presentation/today/widgets/unrecorded_card.dart';
import 'package:soi_duty/ui/app_theme.dart';

import '../helpers/records.dart';

const rules = WorkRules();

TodayCallbacks noop() => TodayCallbacks(
      onClockIn: () {},
      onClockOut: () {},
      onHalfDayChanged: (_) {},
      onDayTypeChanged: (_) {},
      onRevert: () {},
      onEditTime: () {},
      onUnrecordedTap: (_) {},
      onDateLongPress: null,
    );

// 기본 firstRecordDate는 `past`의 첫 기록일(14, 월)과 맞춘다. d(7)(전주 월요일)을 쓰면
// 7~11일이 기록 없는 평일로 잡혀 기록 누락 카드가 의도치 않게 뜬다 — 그 시나리오는
// 아래 '기록 누락' 테스트에서 별도로 first를 넘겨 명시적으로 검증한다.
TodayState stateOf(List<WorkRecord> records, {DateTime? now, DateTime? first}) =>
    buildTodayState(records: records, firstRecordDate: first ?? d(14), now: now ?? d(16, 12), rules: rules);

/// 테스트 기본 폰트는 글자마다 1em 폭이라 한 줄짜리 문구가 줄바꿈된다.
/// 실제 Pretendard를 로드해야 레이아웃 불변 테스트가 의미 있다.
Future<void> loadPretendard() async {
  final loader = FontLoader('Pretendard')
    ..addFont(rootBundle.load('assets/fonts/Pretendard-Regular.otf'))
    ..addFont(rootBundle.load('assets/fonts/Pretendard-Medium.otf'))
    ..addFont(rootBundle.load('assets/fonts/Pretendard-SemiBold.otf'));
  await loader.load();
}

Future<void> pumpView(WidgetTester tester, TodayState state) async {
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.light,
    home: TodayView(state: state, rules: rules, callbacks: noop()),
  ));
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
    '퇴근 완료': stateOf([...past, rec(16, inH: 9, inM: 12, outH: 18, outM: 5)], now: d(16, 19)),
    '연차': stateOf([...past, rec(16, type: WorkType.dayOff)]),
    '첫 주 예외': stateOf([rec(16, inH: 9, inM: 12)], first: d(16)),
  };

  testWidgets('다섯 상태에서 주 버튼의 Y 좌표가 같다', (tester) async {
    tester.view.physicalSize = const Size(402 * 3, 874 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final ys = <String, double>{};
    for (final entry in fixtures.entries) {
      await pumpView(tester, entry.value);
      ys[entry.key] = tester.getTopLeft(find.byType(PrimaryButton)).dy;
    }
    final distinct = ys.values.toSet();
    expect(distinct.length, 1, reason: '버튼 Y가 상태마다 다름: $ys');
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
    expect(find.text('오늘은 연차'), findsOneWidget);
    expect(find.text('오늘은 공휴일'), findsOneWidget);

    await pumpView(tester, fixtures['근무 중']!);
    expect(find.text('퇴근하기'), findsOneWidget);
    expect(find.text('오늘은 반차'), findsOneWidget);

    await pumpView(tester, fixtures['퇴근 완료']!);
    expect(find.text('오늘 퇴근 완료'), findsOneWidget);
    expect(find.text('시간 수정하기'), findsOneWidget);

    await pumpView(tester, fixtures['연차']!);
    expect(find.text('되돌리기'), findsOneWidget);
    expect(find.text('연차'), findsOneWidget);
  });

  testWidgets('콜백 연결: 출근하기 탭', (tester) async {
    var clockedIn = false;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: TodayView(
        state: fixtures['출근 전']!,
        rules: rules,
        callbacks: TodayCallbacks(
          onClockIn: () => clockedIn = true,
          onClockOut: () {},
          onHalfDayChanged: (_) {},
          onDayTypeChanged: (_) {},
          onRevert: () {},
          onEditTime: () {},
          onUnrecordedTap: (_) {},
          onDateLongPress: null,
        ),
      ),
    ));
    await tester.tap(find.text('출근하기'));
    expect(clockedIn, isTrue);
  });
}

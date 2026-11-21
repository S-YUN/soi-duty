import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/core/presentation/size_config.dart';
import 'package:soi_duty/presentation/record_edit/widgets/time_wheel.dart';
import 'package:soi_duty/presentation/record_edit/widgets/trip_sheet.dart';
import 'package:soi_duty/presentation/shared/confirm_dialog.dart';
import 'package:soi_duty/ui/app_colors.dart';
import 'package:soi_duty/ui/app_theme.dart';

import '../helpers/fonts.dart';
import '../helpers/records.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadPretendard();
  });

  /// 열고, 닫힌 뒤의 결과를 [result]로 받는다. 닫히기 전엔 [_pending].
  const pending = Object();
  Object? result = pending;

  Future<void> pumpSheet(
    WidgetTester tester, {
    Size size = const Size(402, 874),
    DateTime? start,
    DateTime? end,
    bool existing = false,
    String confirmLabel = '확인',
  }) async {
    result = pending;
    SizeConfig.init(size.width);
    tester.view.physicalSize = size * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async => result = await showTripSheet(
              context,
              start: start ?? d(16, 9),
              end: end ?? d(16, 12),
              existing: existing,
              confirmLabel: confirmLabel,
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Color? valueColor(WidgetTester tester, String value) => tester.widget<Text>(find.text(value)).style?.color;

  testWidgets('열면 "시작" 칸이 선택돼 있고 결과 줄이 범위와 길이를 말한다', (tester) async {
    await pumpSheet(tester);
    expect(find.text('시간 출장'), findsOneWidget);
    expect(find.text('몇 시부터 몇 시까지 출장이었는지 기록으로 남겨요.'), findsOneWidget);
    expect(valueColor(tester, '09:00'), AppColors.brand);
    expect(valueColor(tester, '12:00'), AppColors.ink);
    expect(find.text('09:00–12:00 · 3시간'), findsOneWidget);
    expect(find.text('출장 지우기'), findsNothing);
    final wheel = tester.widget<TimeWheel>(find.byType(TimeWheel));
    expect((wheel.hour, wheel.minute), (9, 0));
  });

  testWidgets('"끝" 칸을 누르면 선택이 옮겨가고 휠이 끝 값을 가리킨다', (tester) async {
    await pumpSheet(tester, end: d(16, 12, 30));
    await tester.tap(find.text('끝'));
    await tester.pumpAndSettle();
    expect(valueColor(tester, '12:30'), AppColors.brand);
    expect(valueColor(tester, '09:00'), AppColors.ink);
    final wheel = tester.widget<TimeWheel>(find.byType(TimeWheel));
    expect((wheel.hour, wheel.minute), (12, 30));
  });

  testWidgets('휠을 돌리면 고른 칸의 값과 결과 줄이 바뀐다', (tester) async {
    await pumpSheet(tester);
    tester.widget<TimeWheel>(find.byType(TimeWheel)).onChanged(9, 20);
    await tester.pump();
    expect(find.text('09:20'), findsOneWidget);
    expect(find.text('09:20–12:00 · 2시간 40분'), findsOneWidget);
    await tester.tap(find.text('끝'));
    await tester.pumpAndSettle();
    tester.widget<TimeWheel>(find.byType(TimeWheel)).onChanged(12, 30);
    await tester.pump();
    expect(find.text('09:20–12:30 · 3시간 10분'), findsOneWidget);
    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();
    final set = result as TripSheetSet;
    expect((set.start, set.end), (d(16, 9, 20), d(16, 12, 30)));
  });

  testWidgets('끝이 시작보다 늦지 않으면 안내가 뜨고 버튼이 눌리지 않는다', (tester) async {
    await pumpSheet(tester, start: d(16, 12), end: d(16, 12));
    expect(find.text('끝이 시작보다 늦어야 해요'), findsOneWidget);
    expect(find.textContaining('시간', findRichText: false).evaluate().where((e) => (e.widget as Text).data!.contains('·')), isEmpty);
    expect(tester.widget<SheetButton>(find.byType(SheetButton)).onTap, isNull);
    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();
    expect(find.byType(TripSheet), findsOneWidget);
    expect(result, same(pending));
  });

  testWidgets('이미 있는 범위를 고칠 때만 "출장 지우기"가 있고, 누르면 지움 결과로 닫힌다', (tester) async {
    await pumpSheet(tester, existing: true, confirmLabel: '저장');
    expect(find.text('저장'), findsOneWidget);
    await tester.tap(find.text('출장 지우기'));
    await tester.pumpAndSettle();
    expect(result, isA<TripSheetCleared>());
  });

  testWidgets('바깥을 탭하면 아무 결과 없이 닫힌다', (tester) async {
    await pumpSheet(tester);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.byType(TripSheet), findsNothing);
    expect(result, isNull);
  });

  testWidgets('작은 기기(320×568)에서 넘치지 않고 버튼·지우기까지 닿는다', (tester) async {
    await pumpSheet(tester, size: const Size(320, 568), existing: true);
    expect(tester.takeException(), isNull);
    final sheet = tester.getRect(find.byType(TripSheet));
    expect(sheet.top, greaterThanOrEqualTo(0));
    expect(sheet.bottom, lessThanOrEqualTo(568));
    await tester.ensureVisible(find.text('출장 지우기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('출장 지우기'));
    await tester.pumpAndSettle();
    expect(result, isA<TripSheetCleared>());
  });
}

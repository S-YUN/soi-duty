import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/core/presentation/size_config.dart';
import 'package:soi_duty/presentation/record_edit/widgets/time_wheel.dart';
import 'package:soi_duty/presentation/settings/default_times_sheet.dart';
import 'package:soi_duty/presentation/shared/confirm_dialog.dart';
import 'package:soi_duty/ui/app_colors.dart';
import 'package:soi_duty/ui/app_theme.dart';

import '../helpers/fonts.dart';

/// 기본 출퇴근 시각 시트 (핸드오프 7 §4).
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadPretendard();
  });

  var saved = <(int, int)>[];

  Future<void> pumpSheet(
    WidgetTester tester, {
    Size size = const Size(402, 874),
    int clockIn = 8 * 60,
    int clockOut = 17 * 60,
  }) async {
    saved = [];
    SizeConfig.init(size.width);
    tester.view.physicalSize = size * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showDefaultTimesSheet(
              context,
              clockInMinutes: clockIn,
              clockOutMinutes: clockOut,
              onSave: (i, o) async => saved.add((i, o)),
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
  TimeWheel wheel(WidgetTester tester) => tester.widget<TimeWheel>(find.byType(TimeWheel));

  testWidgets('열면 저장된 값이 채워지고 출근 칸이 선택돼 있다 — 되돌리기 링크는 없다', (tester) async {
    await pumpSheet(tester, clockIn: 9 * 60 + 30, clockOut: 18 * 60 + 30);
    expect(find.text('기본 출퇴근 시각'), findsOneWidget);
    expect(find.text('기록이 없는 날에 시각을 넣을 때 처음 보이는 값이에요.'), findsOneWidget);
    expect(find.text('출근'), findsOneWidget);
    expect(find.text('퇴근'), findsOneWidget);
    expect(valueColor(tester, '09:30'), AppColors.brand);
    expect(valueColor(tester, '18:30'), AppColors.ink);
    expect((wheel(tester).hour, wheel(tester).minute), (9, 30));
    expect(find.text('이미 넣은 기록은 바뀌지 않아요'), findsOneWidget);
    expect(valueColor(tester, '이미 넣은 기록은 바뀌지 않아요'), AppColors.subtle);
    expect(find.textContaining('되돌리기'), findsNothing);
    expect(find.text('저장'), findsOneWidget);
  });

  testWidgets('퇴근 칸을 누르면 선택이 옮겨가고 휠이 퇴근 값을 가리킨다', (tester) async {
    await pumpSheet(tester);
    await tester.tap(find.text('퇴근'));
    await tester.pumpAndSettle();
    expect(valueColor(tester, '17:00'), AppColors.brand);
    expect(valueColor(tester, '08:00'), AppColors.ink);
    expect((wheel(tester).hour, wheel(tester).minute), (17, 0));
  });

  testWidgets('휠로 두 값을 고치고 저장하면 분 단위로 넘기고 닫힌다', (tester) async {
    await pumpSheet(tester);
    wheel(tester).onChanged(9, 30);
    await tester.pump();
    await tester.tap(find.text('퇴근'));
    await tester.pumpAndSettle();
    wheel(tester).onChanged(18, 30);
    await tester.pump();
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();
    expect(saved, [(9 * 60 + 30, 18 * 60 + 30)]);
    expect(find.byType(DefaultTimesSheet), findsNothing);
  });

  testWidgets('퇴근이 출근보다 늦지 않으면 오류 문구가 뜨고 저장이 꺼진다 — 같아도 안 된다', (tester) async {
    await pumpSheet(tester);
    wheel(tester).onChanged(17, 0);
    await tester.pump();
    expect(find.text('퇴근이 출근보다 늦어야 해요'), findsOneWidget);
    expect(valueColor(tester, '퇴근이 출근보다 늦어야 해요'), AppColors.minus);
    expect(find.text('이미 넣은 기록은 바뀌지 않아요'), findsNothing);
    expect(tester.widget<SheetButton>(find.byType(SheetButton)).onTap, isNull);
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();
    expect(find.byType(DefaultTimesSheet), findsOneWidget);
    expect(saved, isEmpty);

    wheel(tester).onChanged(18, 0);
    await tester.pump();
    expect(find.text('퇴근이 출근보다 늦어야 해요'), findsOneWidget);
  });

  testWidgets('안내 줄이 정상 ↔ 오류로 바뀌어도 저장 버튼 자리는 그대로', (tester) async {
    await pumpSheet(tester);
    final before = tester.getTopLeft(find.byType(SheetButton)).dy;
    wheel(tester).onChanged(18, 0);
    await tester.pump();
    expect(tester.getTopLeft(find.byType(SheetButton)).dy, before);
  });

  testWidgets('바깥을 탭하면 저장하지 않고 닫힌다', (tester) async {
    await pumpSheet(tester);
    wheel(tester).onChanged(10, 0);
    await tester.pump();
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.byType(DefaultTimesSheet), findsNothing);
    expect(saved, isEmpty);
  });

  testWidgets('작은 기기(320×568)에서 넘치지 않고 저장까지 닿는다', (tester) async {
    await pumpSheet(tester, size: const Size(320, 568));
    expect(tester.takeException(), isNull);
    final sheet = tester.getRect(find.byType(DefaultTimesSheet));
    expect(sheet.top, greaterThanOrEqualTo(0));
    expect(sheet.bottom, lessThanOrEqualTo(568));
    await tester.ensureVisible(find.text('저장'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();
    expect(saved, [(8 * 60, 17 * 60)]);
  });
}

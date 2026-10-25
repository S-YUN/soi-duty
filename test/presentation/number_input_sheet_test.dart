import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/core/presentation/size_config.dart';
import 'package:soi_duty/presentation/shared/number_input_sheet.dart';
import 'package:soi_duty/ui/app_colors.dart';
import 'package:soi_duty/ui/app_theme.dart';

import '../helpers/fonts.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadPretendard();
  });
  setUp(() => SizeConfig.init(402));

  int? saved;
  var cleared = 0;

  Future<void> pumpSheet(
    WidgetTester tester, {
    int maxDigits = 2,
    bool grouping = false,
    int? initial,
    bool withClear = true,
    EdgeInsets viewInsets = EdgeInsets.zero,
  }) async {
    saved = null;
    cleared = 0;
    tester.view.physicalSize = const Size(402 * 3, 874 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(viewInsets: viewInsets),
        child: child!,
      ),
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showNumberInputSheet(
              context,
              title: '올해 총 연차',
              unit: '일',
              note: '1월~12월 기준이에요.',
              maxDigits: maxDigits,
              grouping: grouping,
              initial: initial,
              saveLabel: '저장',
              clearLabel: '사용 안 함으로 되돌리기',
              onSave: (v) => saved = v,
              onClear: withClear ? () => cleared++ : null,
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Finder saveButton() => find.ancestor(of: find.text('저장'), matching: find.byType(GestureDetector)).first;

  testWidgets('비어 있거나 0이면 저장 비활성, 1 이상이면 onSave(값)', (tester) async {
    await pumpSheet(tester);
    await tester.tap(saveButton());
    await tester.pumpAndSettle();
    expect(saved, isNull);
    expect(find.text('올해 총 연차'), findsOneWidget); // 시트가 그대로

    await tester.enterText(find.byType(TextField), '0');
    await tester.pump();
    await tester.tap(saveButton());
    await tester.pumpAndSettle();
    expect(saved, isNull);

    await tester.enterText(find.byType(TextField), '15');
    await tester.pump();
    await tester.tap(saveButton());
    await tester.pumpAndSettle();
    expect(saved, 15);
    expect(find.text('올해 총 연차'), findsNothing); // 닫힘
  });

  testWidgets('연차: 두 자리까지 — "123" 입력 뒤 표시 "12", 앞자리 0 제거', (tester) async {
    await pumpSheet(tester);
    await tester.enterText(find.byType(TextField), '123');
    await tester.pump();
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, '12');
    await tester.enterText(find.byType(TextField), '07');
    await tester.pump();
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, '7');
  });

  testWidgets('시급: 콤마 실시간, 7자리 한도 — "12345678" 입력 뒤 "1,234,567"', (tester) async {
    await pumpSheet(tester, maxDigits: 7, grouping: true, withClear: false);
    await tester.enterText(find.byType(TextField), '12500');
    await tester.pump();
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, '12,500');
    await tester.enterText(find.byType(TextField), '12345678');
    await tester.pump();
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, '1,234,567');
    await tester.tap(saveButton());
    await tester.pumpAndSettle();
    expect(saved, 1234567);
  });

  testWidgets('initial이 있으면 채워서 열리고 되돌리기 링크 → onClear 후 닫힘', (tester) async {
    await pumpSheet(tester, initial: 15);
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, '15');
    expect(find.text('사용 안 함으로 되돌리기'), findsOneWidget);
    await tester.tap(find.text('사용 안 함으로 되돌리기'));
    await tester.pumpAndSettle();
    expect(cleared, 1);
    expect(find.text('올해 총 연차'), findsNothing);
  });

  testWidgets('initial이 없으면 "0" 플레이스홀더(흐린 색)와 단위, 링크 없음', (tester) async {
    await pumpSheet(tester);
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, '');
    expect(field.decoration?.hintText, '0');
    expect(field.decoration?.hintStyle?.color, AppColors.dotInactive);
    expect(find.text('일'), findsOneWidget);
    expect(find.text('1월~12월 기준이에요.'), findsOneWidget);
    expect(find.text('사용 안 함으로 되돌리기'), findsNothing);
  });

  testWidgets('viewInsets 300에서도 저장 버튼이 보이고 탭 가능', (tester) async {
    await pumpSheet(tester, viewInsets: const EdgeInsets.only(bottom: 300));
    final bottom = tester.getBottomLeft(saveButton()).dy;
    expect(bottom, lessThanOrEqualTo(874 - 300));
    await tester.enterText(find.byType(TextField), '3');
    await tester.pump();
    await tester.tap(saveButton());
    await tester.pumpAndSettle();
    expect(saved, 3);
  });
}

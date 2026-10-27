import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/core/presentation/size_config.dart';
import 'package:soi_duty/presentation/shared/number_input_sheet.dart';
import 'package:soi_duty/ui/app_colors.dart';
import 'package:soi_duty/ui/app_sizes.dart';
import 'package:soi_duty/ui/app_theme.dart';

import '../helpers/fonts.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadPretendard();
  });
  setUp(() => SizeConfig.init(402));

  num? saved;
  var cleared = 0;

  const leaveNotes = [
    '회사에서 보여주는 지금 남은 연차를 그대로 넣어주세요.',
    '오늘이 기준일이 되고, 내일부터 찍는 연차를 빼서 보여드려요.',
    '신청해 둔 연차도 아직 안 쓴 것으로 쳐서 넣어주세요.',
  ];
  const leaveHighlight = '이 뒤로 찍어둔 연차 1.5일은 여기서 빼서 보여드려요.';

  /// leave: 연차 모드(소수점 2자리 · 0 허용 · 0.5 단위 검증 · 헤드라인 · 안내 세 줄). 아니면 시급 모드(기존 동작).
  Future<void> pumpSheet(
    WidgetTester tester, {
    bool leave = false,
    bool highlight = false,
    int maxDigits = 2,
    bool grouping = false,
    num? initial,
    bool withClear = true,
    EdgeInsets viewInsets = EdgeInsets.zero,
    double height = 874,
  }) async {
    saved = null;
    cleared = 0;
    tester.view.physicalSize = Size(402 * 3, height * 3);
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
              title: leave ? '남은 연차' : '시급',
              headline: leave ? '오늘(10월 26일) 기준 남은 연차' : null,
              unit: leave ? '일' : '원',
              notes: leave ? leaveNotes : const ['이 기기에만 저장돼요. 누구도 해당 내용을 알 수 없어요.'],
              highlightNote: highlight ? leaveHighlight : null,
              maxDigits: maxDigits,
              decimalPlaces: leave ? 2 : 0,
              grouping: grouping,
              emptyCaption: leave ? '입력 전' : null,
              isValid: leave ? (v) => v >= 0 && v <= 99 && (v * 480) % 240 == 0 : null,
              invalidNote: leave ? (v) => v > 99 ? '99일까지 넣을 수 있어요' : '0.5일 단위로 넣어주세요' : null,
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
  String fieldText(WidgetTester tester) => tester.widget<TextField>(find.byType(TextField)).controller!.text;
  Future<void> type(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.pump();
  }

  group('단위는 항상 오른쪽 끝', () {
    // Flexible(필드) + Spacer가 flex를 반씩 나눠 단위가 가운데로 떠다니던 회귀(리뷰 2026-10-27).
    double unitRight(WidgetTester tester, String unit) => tester.getTopRight(find.text(unit)).dx;
    final expected = 402 - AppSizes.sheetPadding.left - AppSizes.numberFieldPadding.right;

    testWidgets('시급 모드 — 빈 값·채운 값 모두 "원"이 오른쪽 끝', (tester) async {
      await pumpSheet(tester, maxDigits: 7, grouping: true, withClear: false);
      expect(unitRight(tester, '원'), closeTo(expected, 0.5));
      await type(tester, '12500');
      expect(unitRight(tester, '원'), closeTo(expected, 0.5));
    });

    testWidgets('연차 모드 — "입력 전" 캡션이 있어도, 값을 쳐도 "일"이 오른쪽 끝', (tester) async {
      await pumpSheet(tester, leave: true);
      expect(unitRight(tester, '일'), closeTo(expected, 0.5));
      await type(tester, '8.5');
      expect(unitRight(tester, '일'), closeTo(expected, 0.5));
    });
  });

  group('입력줄 폭 (IntrinsicWidth 회귀 감시)', () {
    testWidgets('필드가 0폭으로 접히지 않고, 캡션은 필드 오른쪽에, 폭 320에서도 넘치지 않는다', (tester) async {
      await pumpSheet(tester, leave: true);
      final emptyWidth = tester.getSize(find.byType(TextField)).width;
      expect(emptyWidth, greaterThan(10)); // "0" 플레이스홀더 폭
      expect(tester.getTopLeft(find.text('입력 전')).dx, greaterThan(tester.getTopRight(find.byType(TextField)).dx - 1));
      await type(tester, '12.5');
      expect(tester.getSize(find.byType(TextField)).width, greaterThan(emptyWidth));
      expect(tester.takeException(), isNull);
    });

    testWidgets('폭 320 시급 7자리 — 넘치지 않고 단위는 오른쪽 끝', (tester) async {
      SizeConfig.init(320);
      tester.view.physicalSize = const Size(320 * 3, 874 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showNumberInputSheet(
                context,
                title: '시급',
                unit: '원',
                notes: const ['이 기기에만 저장돼요.'],
                maxDigits: 7,
                grouping: true,
                saveLabel: '저장',
                clearLabel: '되돌리기',
                onSave: (v) => saved = v,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await type(tester, '9999999');
      expect(tester.takeException(), isNull);
      expect(tester.getTopRight(find.text('원')).dx, closeTo(320 - AppSizes.sheetPadding.left - AppSizes.numberFieldPadding.right, 0.5));
    });
  });

  group('시급 모드 (기존)', () {
    testWidgets('비어 있거나 0이면 저장 비활성, 1 이상이면 onSave(값)', (tester) async {
      await pumpSheet(tester);
      await tester.tap(saveButton());
      await tester.pumpAndSettle();
      expect(saved, isNull);
      expect(find.text('시급'), findsOneWidget); // 시트가 그대로

      await type(tester, '0');
      await tester.tap(saveButton());
      await tester.pumpAndSettle();
      expect(saved, isNull);

      await type(tester, '15');
      await tester.tap(saveButton());
      await tester.pumpAndSettle();
      expect(saved, 15);
      expect(find.text('시급'), findsNothing); // 닫힘
    });

    testWidgets('두 자리까지 — "123" 입력 뒤 표시 "12", 앞자리 0 제거', (tester) async {
      await pumpSheet(tester);
      await type(tester, '123');
      expect(fieldText(tester), '12');
      await type(tester, '07');
      expect(fieldText(tester), '7');
    });

    testWidgets('콤마 실시간, 7자리 한도 — "12345678" 입력 뒤 "1,234,567"', (tester) async {
      await pumpSheet(tester, maxDigits: 7, grouping: true, withClear: false);
      await type(tester, '12500');
      expect(fieldText(tester), '12,500');
      await type(tester, '12345678');
      expect(fieldText(tester), '1,234,567');
      expect(tester.widget<TextField>(find.byType(TextField)).controller!.selection, const TextSelection.collapsed(offset: 9));
      await tester.tap(saveButton());
      await tester.pumpAndSettle();
      expect(saved, 1234567);
    });

    testWidgets('initial이 있으면 채워서 열리고 되돌리기 링크 → onClear 후 닫힘', (tester) async {
      await pumpSheet(tester, initial: 15);
      expect(fieldText(tester), '15');
      expect(find.text('사용 안 함으로 되돌리기'), findsOneWidget);
      await tester.tap(find.text('사용 안 함으로 되돌리기'));
      await tester.pumpAndSettle();
      expect(cleared, 1);
      expect(find.text('시급'), findsNothing);
    });

    testWidgets('initial이 없으면 "0" 플레이스홀더(흐린 색)와 단위·안내, 링크·캡션 없음', (tester) async {
      await pumpSheet(tester);
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, '');
      expect(field.decoration?.hintText, '0');
      expect(field.decoration?.hintStyle?.color, AppColors.dotInactive);
      expect(find.text('원'), findsOneWidget);
      expect(find.text('이 기기에만 저장돼요. 누구도 해당 내용을 알 수 없어요.'), findsOneWidget);
      expect(find.text('사용 안 함으로 되돌리기'), findsNothing);
      expect(find.text('입력 전'), findsNothing);
    });

    testWidgets('viewInsets 300에서도 저장 버튼이 보이고 탭 가능', (tester) async {
      await pumpSheet(tester, viewInsets: const EdgeInsets.only(bottom: 300));
      final bottom = tester.getBottomLeft(saveButton()).dy;
      expect(bottom, lessThanOrEqualTo(874 - 300));
      await type(tester, '3');
      await tester.tap(saveButton());
      await tester.pumpAndSettle();
      expect(saved, 3);
    });
  });

  group('연차 모드', () {
    testWidgets('빈 값 — "0" 플레이스홀더 + "입력 전", 저장 비활성, 오류 줄 없음', (tester) async {
      await pumpSheet(tester, leave: true);
      expect(find.text('입력 전'), findsOneWidget);
      expect(tester.widget<TextField>(find.byType(TextField)).decoration?.hintText, '0');
      expect(find.text('0.5일 단위로 넣어주세요'), findsNothing);
      await tester.tap(saveButton());
      await tester.pumpAndSettle();
      expect(saved, isNull);
      expect(find.text('남은 연차'), findsOneWidget);
    });

    testWidgets('"8.5" — 캡션 사라지고 저장 활성, onSave(8.5)', (tester) async {
      await pumpSheet(tester, leave: true);
      await type(tester, '8.5');
      expect(find.text('입력 전'), findsNothing);
      await tester.tap(saveButton());
      await tester.pumpAndSettle();
      expect(saved, 8.5);
      expect(find.text('남은 연차'), findsNothing);
    });

    testWidgets('"0" — 저장 활성 (0 허용), onSave(0)', (tester) async {
      await pumpSheet(tester, leave: true);
      await type(tester, '0');
      expect(find.text('입력 전'), findsNothing);
      await tester.tap(saveButton());
      await tester.pumpAndSettle();
      expect(saved, 0);
    });

    testWidgets('"8." — 비활성, 오류 줄 없음', (tester) async {
      await pumpSheet(tester, leave: true);
      await type(tester, '8.');
      expect(fieldText(tester), '8.');
      expect(find.text('0.5일 단위로 넣어주세요'), findsNothing);
      await tester.tap(saveButton());
      await tester.pumpAndSettle();
      expect(saved, isNull);
    });

    testWidgets('"8.3" — 비활성, "0.5일 단위로 넣어주세요"(minus)', (tester) async {
      await pumpSheet(tester, leave: true);
      await type(tester, '8.3');
      expect(find.text('0.5일 단위로 넣어주세요'), findsOneWidget);
      expect(tester.widget<Text>(find.text('0.5일 단위로 넣어주세요')).style?.color, AppColors.minus);
      await tester.tap(saveButton());
      await tester.pumpAndSettle();
      expect(saved, isNull);
      await type(tester, '8.5');
      expect(find.text('0.5일 단위로 넣어주세요'), findsNothing);
    });

    testWidgets('"99.5" — 한도 초과는 단위 문구가 아니라 한도 문구', (tester) async {
      await pumpSheet(tester, leave: true);
      await type(tester, '99.5');
      expect(find.text('99일까지 넣을 수 있어요'), findsOneWidget);
      expect(find.text('0.5일 단위로 넣어주세요'), findsNothing);
      await tester.tap(saveButton());
      await tester.pumpAndSettle();
      expect(saved, isNull);
    });

    testWidgets('포매터 — ","는 ".", 소수 셋째 자리 무시, 정수 3자리 무시, 점 하나만, "."부터 치면 "0.", 앞자리 0 정리', (tester) async {
      await pumpSheet(tester, leave: true);
      await type(tester, '8,5');
      expect(fieldText(tester), '8.5');
      await type(tester, '8.255');
      expect(fieldText(tester), '8.25');
      await type(tester, '123');
      expect(fieldText(tester), '12');
      await type(tester, '8.5.5');
      expect(fieldText(tester), '8.55');
      await type(tester, '.5');
      expect(fieldText(tester), '0.5');
      await type(tester, '08');
      expect(fieldText(tester), '8');
      await type(tester, '00');
      expect(fieldText(tester), '0');
    });

    testWidgets('initial 8.5 → "8.5"; 되돌리기 → onClear', (tester) async {
      await pumpSheet(tester, leave: true, initial: 8.5);
      expect(fieldText(tester), '8.5');
      expect(find.text('사용 안 함으로 되돌리기'), findsOneWidget);
      await tester.tap(find.text('사용 안 함으로 되돌리기'));
      await tester.pumpAndSettle();
      expect(cleared, 1);
    });

    testWidgets('initial 15.0 → "15"', (tester) async {
      await pumpSheet(tester, leave: true, initial: 15.0);
      expect(fieldText(tester), '15');
    });

    testWidgets('initial 0 → "0", 캡션 없음', (tester) async {
      await pumpSheet(tester, leave: true, initial: 0);
      expect(fieldText(tester), '0');
      expect(find.text('입력 전'), findsNothing);
    });

    testWidgets('헤드라인·안내 세 줄·강조 줄(brand)이 보인다, 강조 없으면 안 보인다', (tester) async {
      await pumpSheet(tester, leave: true, highlight: true);
      expect(find.text('오늘(10월 26일) 기준 남은 연차'), findsOneWidget);
      for (final n in leaveNotes) {
        expect(find.text(n), findsOneWidget);
      }
      expect(find.text(leaveHighlight), findsOneWidget);
      expect(tester.widget<Text>(find.text(leaveHighlight)).style?.color, AppColors.brand);
    });

    testWidgets('강조 줄이 없으면 안 보인다', (tester) async {
      await pumpSheet(tester, leave: true);
      expect(find.text('오늘(10월 26일) 기준 남은 연차'), findsOneWidget);
      expect(find.text(leaveHighlight), findsNothing);
    });

    testWidgets('높이 640 + 키보드 300 — 저장 버튼이 키보드 위에 보이고 제목은 스크롤로 닿는다', (tester) async {
      await pumpSheet(tester, leave: true, highlight: true, initial: 8.5, height: 640, viewInsets: const EdgeInsets.only(bottom: 300));
      expect(tester.getBottomLeft(saveButton()).dy, lessThanOrEqualTo(640 - 300));
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      await tester.ensureVisible(find.text('남은 연차'));
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.text('남은 연차')).dy, greaterThanOrEqualTo(0));
      await tester.tap(saveButton());
      await tester.pumpAndSettle();
      expect(saved, 8.5);
    });
  });
}

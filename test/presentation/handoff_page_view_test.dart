import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/presentation/shared/handoff_page_view.dart';

void main() {
  late PageController outer;
  late PageController inner;

  setUp(() {
    outer = PageController();
    inner = PageController();
  });
  tearDown(() {
    outer.dispose();
    inner.dispose();
  });

  Future<void> pump(WidgetTester tester) => tester.pumpWidget(MaterialApp(
        home: PageView(
          controller: outer,
          children: [
            HandoffPageView(
              controller: inner,
              itemCount: 2,
              itemBuilder: (_, i) => Center(child: Text('inner $i')),
            ),
            const Center(child: Text('outer 1')),
          ],
        ),
      ));

  Future<void> swipeLeft(WidgetTester tester) async {
    await tester.fling(find.byType(HandoffPageView), const Offset(-300, 0), 1000);
    await tester.pumpAndSettle();
  }

  testWidgets('안쪽에 남은 페이지가 있으면 안쪽이 넘어간다', (tester) async {
    await pump(tester);
    await swipeLeft(tester);
    expect(inner.page, 1);
    expect(outer.page, 0);
  });

  testWidgets('안쪽 끝에서 더 밀면 바깥 PageView가 넘어간다', (tester) async {
    await pump(tester);
    await swipeLeft(tester);
    await swipeLeft(tester);
    expect(outer.page, 1);
    expect(find.text('outer 1'), findsOneWidget);
  });

  testWidgets('끝에서 살짝 밀다 되돌리면 바깥은 제자리', (tester) async {
    await pump(tester);
    await swipeLeft(tester);
    final gesture = await tester.startGesture(tester.getCenter(find.byType(HandoffPageView)));
    await gesture.moveBy(const Offset(-40, 0)); // 터치 슬롭 소비
    await gesture.moveBy(const Offset(-40, 0));
    await tester.pump();
    expect(outer.offset, 40);
    await gesture.moveBy(const Offset(40, 0));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    expect(outer.page, 0);
    expect(inner.page, 1);
  });
}

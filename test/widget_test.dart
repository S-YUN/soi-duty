import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/main.dart';

void main() {
  testWidgets('앱이 부팅되고 초기 화면이 뜬다', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SoiDutyApp()));
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('SOI DUTY'), findsOneWidget);
  });
}

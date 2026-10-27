import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/core/presentation/size_config.dart';
import 'package:soi_duty/presentation/today/widgets/summary_row.dart';
import 'package:soi_duty/ui/app_sizes.dart';
import 'package:soi_duty/ui/app_theme.dart';

import '../helpers/fonts.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadPretendard();
  });

  const labels = ['출근', '퇴근', '근무', '기준 대비'];
  const values = ['23:30', '23:46', '16m', '−7h 44m'];

  Future<void> pump(WidgetTester tester, double width) async {
    SizeConfig.init(width);
    tester.view.physicalSize = Size(width * 3, 874 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.bodyPadding.left + AppSizes.statusCardPadding.left),
          child: SummaryRow(labels: labels, values: values),
        ),
      ),
    ));
    await tester.pump();
  }

  for (final width in [320.0, 360.0, 402.0]) {
    testWidgets('폭 ${width.toInt()} — 긴 값("−7h 44m")도 한 줄이고 칸 가운데에 있다 (2026-10-27 밤 퇴근 때 줄바꿈·왼쪽 정렬)', (tester) async {
      await pump(tester, width);
      expect(tester.takeException(), isNull);
      final oneLine = tester.getSize(find.text('23:30')).height;
      for (final v in values) {
        final text = find.text(v);
        expect(tester.getSize(text).height, closeTo(oneLine, 0.5), reason: '$v 가 줄바꿈됨');
        final cell = find.ancestor(of: text, matching: find.byType(Padding)).first;
        expect(tester.getCenter(text).dx, closeTo(tester.getCenter(cell).dx, 1), reason: '$v 가 가운데가 아님');
      }
    });
  }
}

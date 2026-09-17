import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/core/presentation/size_config.dart';
import 'package:soi_duty/presentation/shared/app_toast.dart';
import 'package:soi_duty/ui/app_sizes.dart';

void main() {
  setUp(() => SizeConfig.init(402));

  testWidgets('토스트는 떴다가 시간이 지나면 사라지고, 새 토스트가 오면 이전 것을 치운다', (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (c) {
      ctx = c;
      return const SizedBox();
    })));
    showAppToast(ctx, '첫 번째');
    await tester.pump();
    await tester.pump(AppDurations.toastFade);
    expect(find.text('첫 번째'), findsOneWidget);
    expect(tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity, 1);
    final box = tester.getRect(find.text('첫 번째'));
    final screen = tester.getRect(find.byType(MaterialApp));
    expect(box.bottom, lessThan(screen.bottom));
    expect(box.top, greaterThan(screen.height / 2), reason: '화면 아래쪽에 떠야 한다');

    showAppToast(ctx, '두 번째');
    await tester.pump();
    expect(find.text('첫 번째'), findsNothing);
    expect(find.text('두 번째'), findsOneWidget);

    await tester.pump(AppDurations.toast);
    await tester.pump();
    expect(find.text('두 번째'), findsNothing);
  });
}

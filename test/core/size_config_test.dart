import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/core/presentation/size_config.dart';

void main() {
  test('기준폭 402에서는 1:1', () {
    SizeConfig.init(402);
    expect(20.w, 20);
    expect(13.5.sp, 13.5);
  });

  test('좁은 화면은 비례 축소', () {
    SizeConfig.init(201);
    expect(20.w, 10);
  });

  test('상한 480을 넘는 폭은 480으로 고정', () {
    SizeConfig.init(1000);
    expect(SizeConfig.scale, 480 / 402);
  });
}

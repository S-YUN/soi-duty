import 'dart:math' as math;

/// 디자인 기준폭(402) 대비 비율로 크기를 환산한다.
/// 앱 루트에서 [init]을 한 번 호출하고, 토큰은 `.w` / `.sp`로 값을 꺼낸다.
abstract final class SizeConfig {
  static const double designWidth = 402;
  static const double maxScaledWidth = 480;

  static double _scale = 1;
  static double get scale => _scale;

  static void init(double screenWidth) {
    _scale = math.min(screenWidth, maxScaledWidth) / designWidth;
  }
}

extension SizeX on num {
  /// 폭·높이·간격·radius
  double get w => this * SizeConfig.scale;

  /// 폰트 크기
  double get sp => this * SizeConfig.scale;
}

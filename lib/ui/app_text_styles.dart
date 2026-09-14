import 'package:flutter/painting.dart';

import '../core/presentation/size_config.dart';
import 'app_colors.dart';

/// 디자인 핸드오프 Typography 표. letter-spacing은 em → px 환산.
abstract final class AppTextStyles {
  static const fontFamily = 'Pretendard';

  static TextStyle _style(
    double size,
    FontWeight weight, {
    double? letterSpacingEm,
    double? height,
    Color color = AppColors.ink,
  }) {
    final fontSize = size.sp;
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: weight,
      letterSpacing: letterSpacingEm == null ? null : fontSize * letterSpacingEm,
      height: height,
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  static TextStyle get heroValue =>
      _style(54, FontWeight.w600, letterSpacingEm: -0.04, height: 1.02, color: AppColors.brand);
  static TextStyle get dateTitle => _style(22, FontWeight.w600, letterSpacingEm: -0.03);
  static TextStyle get primaryButton => _style(16.5, FontWeight.w600, color: AppColors.onBrand);
  static TextStyle get primaryButtonDisabled => _style(16.5, FontWeight.w600, color: AppColors.subtle);
  static TextStyle get statusMain => _style(15, FontWeight.w500, letterSpacingEm: -0.01);
  static TextStyle get summaryValue => _style(14.5, FontWeight.w600, letterSpacingEm: -0.01);
  static TextStyle get summaryLabel => _style(11, FontWeight.w400, color: AppColors.subtle);
  static TextStyle get tabSelected => _style(13.5, FontWeight.w600);
  static TextStyle get tabUnselected => _style(13.5, FontWeight.w500, color: AppColors.subtle);
  static TextStyle get body => _style(13.5, FontWeight.w400, color: AppColors.subtle);
  static TextStyle get bodyInk => _style(13.5, FontWeight.w400);
  static TextStyle get bodyParagraph => _style(13.5, FontWeight.w400, height: 1.55, color: AppColors.subtle);
  static TextStyle get label => _style(13, FontWeight.w500, color: AppColors.subtle);
  static TextStyle get reason => _style(13, FontWeight.w400, color: AppColors.subtle);
  static TextStyle get caption => _style(12.5, FontWeight.w400, color: AppColors.subtle);
  static TextStyle get captionMedium => _style(12.5, FontWeight.w500, color: AppColors.subtle);
  static TextStyle get captionParagraph => _style(12.5, FontWeight.w400, height: 1.55, color: AppColors.subtle);
  static TextStyle get link => _style(12.5, FontWeight.w400, color: AppColors.subtle,)
      .copyWith(decoration: TextDecoration.underline, decorationColor: AppColors.subtle);
  static TextStyle get linkBrand => _style(12.5, FontWeight.w600, color: AppColors.brand)
      .copyWith(decoration: TextDecoration.underline, decorationColor: AppColors.brand);
  static TextStyle get badge => _style(12.5, FontWeight.w600);

  /// 반차 체크박스 라벨 (13.5)
  static TextStyle checkLabel({required bool checked}) => _style(
        13.5,
        checked ? FontWeight.w600 : FontWeight.w500,
        letterSpacingEm: -0.01,
        color: checked ? AppColors.brand : AppColors.subtle,
      );

  /// 연차·공휴일 라디오형 라벨 (13)
  static TextStyle dayTypeLabel({required bool checked}) => _style(
        13,
        checked ? FontWeight.w600 : FontWeight.w500,
        letterSpacingEm: -0.01,
        color: checked ? AppColors.brand : AppColors.subtle,
      );
}

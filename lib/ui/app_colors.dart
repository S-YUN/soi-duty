import 'dart:ui';

/// 디자인 핸드오프 Design Tokens > Colors. 역할 기반 이름.
abstract final class AppColors {
  static const screenBackground = Color(0xFFE9EBE6);
  static const card = Color(0xFFFCFCFB);
  static const cardInner = Color(0xFFF1F3EE);
  static const listRow = Color(0xFFEFF1EC);
  static const listRowPressed = Color(0xFFE7EAE4);
  static const tabContainer = Color(0xFFE1E4DD);
  static const divider = Color(0xFFE4E7E0);
  static const ink = Color(0xFF16191A);
  static const subtle = Color(0xFF5F6559);
  static const brand = Color(0xFF2C5A4C);
  static const brandPressed = Color(0xFF24483E);
  static const brandDeep = Color(0xFF1B473A);
  static const mint = Color(0xFF9FD3B4);
  static const onBrand = Color(0xFFF4F6F3);
  static const buttonDisabled = Color(0xFFEDEFEA);
  static const minus = Color(0xFFA8503F);
  static const dayOffBackground = Color(0xFFDFD2DD);
  static const dayOffBorder = Color(0xFFD3C2D0);
  static const dayOffText = Color(0xFF5C4459);
  static const holidayBackground = Color(0xFFE6CFC6);
  static const holidayBorder = Color(0xFFDCBFB4);
  static const holidayText = Color(0xFF7A4536);
  static const halfDayBackground = Color(0xFFE5DCBB);
  static const halfDayText = Color(0xFF6A5C2E);
  static const checkboxBorder = Color(0xFFCFD3CA);
  static const dotInactive = Color(0xFFC3C7BE);

  // 그림자·글로우 (알파 포함)
  static const cardShadow = Color(0x0D16191A); // rgba(22,25,26,.05)
  static const tabShadow = Color(0x1716191A); // rgba(22,25,26,.09)
  static const dotGlow = Color(0x242C5A4C); // rgba(44,90,76,.14)
}

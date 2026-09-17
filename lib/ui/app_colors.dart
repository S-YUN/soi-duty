import 'dart:ui';

import '../domain/model/work_type.dart';

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
  static const hairline = Color(0xFFDCDFD8);
  static const rowDivider = Color(0xFFE7E9E3);
  static const faint = Color(0xFF8B9184);
  static const weekendNone = Color(0xFFC9CDC4);
  static const todayRow = Color(0xFFF3F5F1);
  static const chipNeutral = Color(0xFFF0F2ED);
  static const wheelUnselected = Color(0xFF9DA296);

  // 월간 캘린더 — 숫자 뒤 원. 유형이 있으면 typeColors, 없으면 아래.
  static const calendarWorked = Color(0xFFEFF1EC); // 일반 근무일 (주말 포함)
  static const calendarWeekendNum = Color(0xFF9C5F50); // 토·일 헤더·숫자
  static const scrim = Color(0x6B16191A); // rgba(22,25,26,.42)
  static const toastBackground = Color(0xE616191A); // ink 90%
  static const sheetShadow = Color(0x2E16191A); // rgba(22,25,26,.18)

  // 그림자·글로우 (알파 포함)
  static const cardShadow = Color(0x0D16191A); // rgba(22,25,26,.05)
  static const tabShadow = Color(0x1716191A); // rgba(22,25,26,.09)
  static const dotGlow = Color(0x242C5A4C); // rgba(44,90,76,.14)

  /// 유형 배지·칩·범례의 (배경, 글자). 주간 행·캘린더·시트가 같은 매핑을 쓴다.
  static (Color, Color) typeColors(WorkType t) => switch (t) {
        WorkType.halfDay => (halfDayBackground, halfDayText),
        WorkType.dayOff => (dayOffBackground, dayOffText),
        WorkType.holiday => (holidayBackground, holidayText),
        WorkType.normal => (chipNeutral, subtle),
      };
}

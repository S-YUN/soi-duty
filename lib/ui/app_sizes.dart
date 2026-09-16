import 'package:flutter/widgets.dart';

import '../core/presentation/size_config.dart';

/// 간격·radius·고정 높이. 전부 SizeConfig 비율이 적용된 getter.
abstract final class AppSizes {
  // 화면 골격
  static double get topInset => 8.w;
  static double get screenHPadding => 20.w;
  static EdgeInsets get datePadding => EdgeInsets.fromLTRB(20.w, 18.w, 20.w, 14.w);
  static EdgeInsets get bodyPadding => EdgeInsets.fromLTRB(16.w, 4.w, 16.w, 20.w);
  static double get cardGap => 12.w;

  // 알약 탭
  static double get tabPadding => 3.w;
  static double get tabGap => 2.w;
  static double get tabItemVPadding => 9.w;

  // 카드
  static double get cardRadius => 20.w;
  static EdgeInsets get heroPadding => EdgeInsets.fromLTRB(22.w, 24.w, 22.w, 22.w);
  static EdgeInsets get statusCardPadding => EdgeInsets.fromLTRB(18.w, 16.w, 18.w, 18.w);
  static EdgeInsets get firstWeekCardPadding => EdgeInsets.symmetric(vertical: 14.w, horizontal: 16.w);
  static EdgeInsets get unrecordedCardPadding => EdgeInsets.fromLTRB(16.w, 15.w, 16.w, 12.w);

  // 히어로
  static double get heroValueTop => 8.w;
  static double get heroReasonTop => 9.w;
  static double get progressBarTop => 18.w;
  static double get progressBar => 6.w;

  // 상태 카드 고정 높이 — 다섯 상태에서 동일
  static double get statusBlock => 104.w;
  static double get primaryButton => 56.w;
  static double get secondarySlot => 40.w;
  static double get secondarySlotGap => 10.w;
  /// 보조 슬롯의 실제 히트 영역(44)을 확보하기 위해 위아래로 파고드는 여백.
  static double get secondarySlotHitInset => (minTapHeight - secondarySlot) / 2;
  static double get statusBlockGap => 10.w;
  static double get buttonRadius => 14.w;

  // 상태 블록 내부
  static double get dot => 7.w;
  static double get dotGlow => 3.w;
  static double get dotGap => 7.w;
  static EdgeInsets get badgePadding => EdgeInsets.symmetric(vertical: 7.w, horizontal: 14.w);
  static double get badgeBorder => 1.w;

  // 4칸 요약
  static double get summaryRadius => 12.w;
  static EdgeInsets get summaryCellPadding => EdgeInsets.symmetric(vertical: 10.w, horizontal: 4.w);
  static double get summaryValueTop => 3.w;
  static double get summaryDivider => 1.w;

  // 체크박스
  static double get checkboxSquare => 19.w;
  static double get checkboxRound => 18.w;
  static double get checkboxSquareRadius => 6.w;
  static double get checkboxBorderOff => 1.5.w;
  static double get checkboxBorderOn => 1.w;
  static double get checkboxIcon => 12.sp;
  static double get checkboxGap => 9.w;
  static double get checkRowRadius => 11.w;
  static EdgeInsets get checkRowPadding => EdgeInsets.symmetric(vertical: 7.w, horizontal: 10.w);
  static double get dayTypeRowRadius => 10.w;
  static double get dayTypeGap => 18.w;
  static double get minTapHeight => 44.w;
  static double get linkGap => 6.w;

  // 기록 안 된 날
  static EdgeInsets get unrecordedTitlePadding => EdgeInsets.fromLTRB(2.w, 0, 2.w, 9.w);
  static double get unrecordedRowGap => 6.w;
  static double get unrecordedRowRadius => 12.w;
  static EdgeInsets get unrecordedRowPadding => EdgeInsets.symmetric(vertical: 12.w, horizontal: 14.w);

  // 보조 슬롯 텍스트 버튼
  static EdgeInsets get quietButtonPadding => EdgeInsets.symmetric(vertical: 8.w, horizontal: 4.w);
  static double get slotDividerWidth => 1.w;
  static double get slotDividerHeight => 11.w;
  static double get slotItemGap => 16.w;

  // 기간 네비게이터
  static EdgeInsets get navPadding => EdgeInsets.fromLTRB(20.w, 16.w, 20.w, 14.w);
  static double get navArrow => 30.w;
  static double get navLabelMinWidth => 186.w;
  static double get navGap => 4.w;

  // 주간 누적 카드
  static EdgeInsets get weekCardPadding => EdgeInsets.all(20.w);
  static double get weekValueTop => 8.w;
  static double get weekReasonTop => 7.w;
  static double get weekBarTop => 14.w;

  // 주간 일별 행
  static EdgeInsets get rowPadding => EdgeInsets.symmetric(vertical: 13.w, horizontal: 18.w);
  static double get rowGap => 12.w;
  static double get rowDateWidth => 30.w;
  static double get rowValueWidth => 58.w;
  static double get rowNoteMinHeight => 16.w;
  static double get rowNoteTop => 3.w;
  static double get rowDowTop => 1.w;
  static double get rowBadgeGap => 6.w;
  static EdgeInsets get rowBadgePadding => EdgeInsets.symmetric(vertical: 2.w, horizontal: 7.w);
  static double get rowBadgeRadius => 5.w;
  static double get rowDivider => 1.w;

  // 월간 캘린더
  static EdgeInsets get calendarPadding => EdgeInsets.fromLTRB(14.w, 16.w, 14.w, 16.w);
  static EdgeInsets get calendarHeaderPadding => EdgeInsets.fromLTRB(2.w, 14.w, 2.w, 6.w);
  static EdgeInsets get calendarGridPadding => EdgeInsets.symmetric(horizontal: 2.w);
  static double get calendarCell => 58.w;
  static double get calendarCellRadius => 10.w;
  static double get calendarCellTop => 9.w;
  static double get calendarCellGap => 5.w;
  static double get calendarRowGap => 4.w;
  static double get calendarColGap => 3.w;
  static EdgeInsets get calendarBadgePadding => EdgeInsets.symmetric(vertical: 1.w, horizontal: 5.w);
  static double get calendarBadgeRadius => 4.w;
  static EdgeInsets get legendPadding => EdgeInsets.fromLTRB(6.w, 2.w, 6.w, 0);
  static double get legendChip => 13.w;
  static double get legendChipRadius => 4.w;
  static double get legendChipGap => 6.w;
  static double get legendRunGap => 8.w;
  static double get legendItemGap => 14.w;

  // 시간 수정 시트
  static double get sheetRadius => 24.w;
  static EdgeInsets get sheetPadding => EdgeInsets.fromLTRB(20.w, 10.w, 20.w, 30.w);
  static double get sheetHandleWidth => 38.w;
  static double get sheetHandleHeight => 4.w;
  static double get sheetHandleBottom => 14.w;
  static double get sheetShadowBlur => 34.w;
  static Offset get sheetShadowOffset => Offset(0, -8.w);
  static EdgeInsets get sheetNotePadding => EdgeInsets.symmetric(vertical: 11.w, horizontal: 13.w);
  static EdgeInsets get sheetNoteMargin => EdgeInsets.fromLTRB(0, 12.w, 0, 4.w);
  static double get sheetNoteRadius => 11.w;
  static EdgeInsets get chipsMargin => EdgeInsets.fromLTRB(0, 14.w, 0, 4.w);
  static double get chipGap => 7.w;
  static EdgeInsets get chipPadding => EdgeInsets.symmetric(vertical: 11.w);
  static double get chipRadius => 11.w;
  static double get timeRowOutdent => 12.w;
  static EdgeInsets get timeRowPadding => EdgeInsets.symmetric(vertical: 15.w, horizontal: 12.w);
  static double get timeRowRadius => 12.w;
  static double get wheelBoxTop => 14.w;
  static EdgeInsets get wheelBoxPadding => EdgeInsets.symmetric(vertical: 16.w, horizontal: 14.w);
  static double get wheelBoxRadius => 14.w;
  static double get wheelTitleBottom => 10.w;
  static double get wheelHeight => 176.w;
  static double get wheelItem => 44.w;
  static double get wheelBandRadius => 11.w;
  static double get wheelColonPadding => 2.w;
  static double get calcTop => 16.w;
  static double get sheetButtonsTop => 20.w;
  static double get sheetButton => 52.w;
  static double get sheetButtonRadius => 13.w;
  static double get sheetButtonGap => 9.w;
  static double get deleteLinkTop => 16.w;

  // 확인 다이얼로그
  static EdgeInsets get dialogPadding => EdgeInsets.all(20.w);
  static double get dialogMessageTop => 8.w;
  static double get dialogButtonsTop => 18.w;
  static double get dialogButton => 44.w;

  static double get pill => 999.w;
  static Offset get shadowOffset => Offset(0, 1.w);
  static double get shadowBlur => 2.w;
}

/// 애니메이션 시간. 핸드오프 Interactions 표.
abstract final class AppDurations {
  static const progressBar = Duration(milliseconds: 400);
  static const checkbox = Duration(milliseconds: 150);
  static const buttonColor = Duration(milliseconds: 200);
  static const buttonScale = Duration(milliseconds: 100);
  static const sheetSlide = Duration(milliseconds: 260);
  static const wheelItem = Duration(milliseconds: 120);
  static const pressedOpacity = Duration(milliseconds: 100);
}

abstract final class AppScales {
  static const buttonPressed = 0.985;
  static const rowPressed = 0.99;
}

abstract final class AppCurves {
  static const sheet = Cubic(0.22, 0.8, 0.3, 1);
}

abstract final class AppOpacities {
  static const quietPressed = 0.55;
  static const cellPressed = 0.6;
}

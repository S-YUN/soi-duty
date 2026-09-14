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
  static double get secondarySlot => 38.w;
  static double get secondarySlotGap => 12.w;
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
}

abstract final class AppScales {
  static const buttonPressed = 0.985;
  static const rowPressed = 0.99;
}

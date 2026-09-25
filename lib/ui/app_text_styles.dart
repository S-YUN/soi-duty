import 'package:flutter/painting.dart';

import '../core/presentation/size_config.dart';
import 'app_colors.dart';

/// 디자인 핸드오프 Typography 표. letter-spacing은 em → px 환산.
/// 오늘 요약 라벨·안내, 시트 안내·계산 내역, 확인 다이얼로그는 실기기에서 작게 느껴져 핸드오프보다 1~1.5 키웠다.
abstract final class AppTextStyles {
  static const fontFamily = 'Pretendard';

  static TextStyle _style(
    double size,
    FontWeight weight, {
    double? letterSpacingEm,
    double? height,
    Color color = AppColors.ink,
    bool tabularFigures = true,
  }) {
    final fontSize = size.sp;
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: weight,
      letterSpacing: letterSpacingEm == null ? null : fontSize * letterSpacingEm,
      height: height,
      color: color,
      // 고정폭 숫자가 기본 — 숫자가 바뀔 때 칸이 흔들리지 않는다. 폭이 빠듯한 곳만 해제한다.
      fontFeatures: tabularFigures ? const [FontFeature.tabularFigures()] : const [],
    );
  }

  static TextStyle get heroValue =>
      _style(54, FontWeight.w600, letterSpacingEm: -0.04, height: 1.02, color: AppColors.brand);
  static TextStyle get dateTitle => _style(22, FontWeight.w600, letterSpacingEm: -0.03);
  static TextStyle get primaryButton => _style(16.5, FontWeight.w600, color: AppColors.onBrand);
  static TextStyle get primaryButtonDisabled => _style(16.5, FontWeight.w600, color: AppColors.subtle);
  static TextStyle get statusMain => _style(15, FontWeight.w500, letterSpacingEm: -0.01);
  /// 근무 중 "09:12 출근"
  static TextStyle get statusClock => _style(20, FontWeight.w600, letterSpacingEm: -0.02);
  /// 상태 블록 본문 — "아직 출근 전", "7시간 15분째 근무중". body(14.5)보다 한 단계 크게
  static TextStyle get statusLine => _style(16, FontWeight.w500, color: AppColors.subtle);
  /// 상태 블록 안내 — 출근 전 격려 문구. caption(13.5)보다 한 단계 크게
  static TextStyle get statusNote => _style(15, FontWeight.w400, color: AppColors.subtle);
  static TextStyle get summaryValue => _style(18, FontWeight.w600, letterSpacingEm: -0.01);
  static TextStyle get summaryLabel => _style(12.5, FontWeight.w400, color: AppColors.subtle);
  static TextStyle get tabSelected => _style(13, FontWeight.w600);
  static TextStyle get tabUnselected => _style(13, FontWeight.w500, color: AppColors.subtle);
  static TextStyle get body => _style(14.5, FontWeight.w400, color: AppColors.subtle);
  static TextStyle get bodyInk => _style(14.5, FontWeight.w400);
  static TextStyle get bodyParagraph => _style(14.5, FontWeight.w400, height: 1.55, color: AppColors.subtle);
  static TextStyle get label => _style(13, FontWeight.w500, color: AppColors.subtle);
  /// 오늘·주간 첫 카드의 제목 ("이번 주 남은 근무시간", "이번 주 근무 통계")
  static TextStyle get cardTitle => _style(16, FontWeight.w600, letterSpacingEm: -0.01, color: AppColors.subtle);
  static TextStyle get reason => _style(13.5, FontWeight.w400, color: AppColors.subtle);
  static TextStyle get caption => _style(13.5, FontWeight.w400, color: AppColors.subtle);
  static TextStyle get captionMedium => _style(13.5, FontWeight.w500, color: AppColors.subtle);
  static TextStyle get captionParagraph => _style(13.5, FontWeight.w400, height: 1.55, color: AppColors.subtle);
  static TextStyle get link => _style(13.5, FontWeight.w400, color: AppColors.subtle,)
      .copyWith(decoration: TextDecoration.underline, decorationColor: AppColors.subtle);
  static TextStyle get linkBrand => _style(13.5, FontWeight.w600, color: AppColors.brand)
      .copyWith(decoration: TextDecoration.underline, decorationColor: AppColors.brand);
  static TextStyle get badge => _style(12.5, FontWeight.w600);

  // 보조 슬롯 텍스트 버튼
  static TextStyle get quietButton => _style(13, FontWeight.w500, color: AppColors.brand);

  // 기간 네비게이터
  static TextStyle get navLabel => _style(19, FontWeight.w600, letterSpacingEm: -0.02);
  static TextStyle get navArrow => _style(18, FontWeight.w400, color: AppColors.subtle);
  static TextStyle get navArrowDisabled => _style(18, FontWeight.w400, color: AppColors.hairline);

  // 주간
  static TextStyle get weekValue => _style(26, FontWeight.w600, letterSpacingEm: -0.03);
  static TextStyle get weekGoal => _style(17, FontWeight.w400, color: AppColors.subtle);
  static TextStyle get weekReason => _style(12.5, FontWeight.w400, height: 1.5, color: AppColors.subtle);
  static TextStyle get rowNum => _style(15, FontWeight.w500, height: 1.15);
  static TextStyle get rowNumWeekend => _style(15, FontWeight.w500, height: 1.15, color: AppColors.faint);
  static TextStyle get rowDow => _style(11.5, FontWeight.w400, color: AppColors.subtle);
  static TextStyle get rowDowWeekend => _style(11.5, FontWeight.w400, color: AppColors.faint);
  static TextStyle get rowMain => _style(15, FontWeight.w500);
  static TextStyle get rowMainDim => _style(15, FontWeight.w400, color: AppColors.subtle);
  static TextStyle get rowMainNone => _style(15, FontWeight.w400, color: AppColors.weekendNone);
  static TextStyle get rowNote => _style(11.5, FontWeight.w400, color: AppColors.subtle);
  static TextStyle rowBadge(Color color) => _style(11, FontWeight.w600, color: color);
  static TextStyle rowValue(Color color) => _style(13.5, FontWeight.w500, color: color);

  // 월간
  static TextStyle get calendarHeader => _style(12.5, FontWeight.w500, color: AppColors.subtle);
  /// 원 안의 날짜 숫자. 원이 있으면 유형색/잉크로 진하게, 없으면 subtle. 흐림은 셀 투명도가 맡는다.
  static TextStyle calendarNum(Color color, {required bool onCircle}) =>
      _style(12, onCircle ? FontWeight.w600 : FontWeight.w400, color: color);
  static TextStyle get calendarHeaderWeekend => _style(12.5, FontWeight.w500, color: AppColors.calendarWeekendNum);
  /// 캘린더 셀 값. 칸이 44남짓이라 "+3h 52m"(47.1)이 안 들어간다 — 비례 숫자 + 좁은 자간 +
  /// 얇은 공백(formatNarrowHm)으로 43.2까지 줄여 원래 크기로 넣는다. 셀 폭을 바꾸면 다시 측정해야 한다.
  static TextStyle calendarValue(Color color) =>
      _style(11.5, FontWeight.w500, color: color, letterSpacingEm: -0.022, tabularFigures: false);
  static TextStyle get calendarWeekendValue =>
      _style(11, FontWeight.w400, color: AppColors.subtle, letterSpacingEm: -0.022, tabularFigures: false);
  static TextStyle get legend => _style(11.5, FontWeight.w400, color: AppColors.subtle);

  // 시간 수정 시트
  static TextStyle get sheetTitle => _style(16, FontWeight.w600, letterSpacingEm: -0.01);
  static TextStyle get sheetNote => _style(12.5, FontWeight.w400, height: 1.5, color: AppColors.subtle);
  static TextStyle get sheetSubtitle => _style(13, FontWeight.w400, color: AppColors.subtle);
  /// 선택 여부와 무관 — 상태는 행 배경과 체크가 말한다.
  static TextStyle get typeRowLabel => _style(15.5, FontWeight.w500);
  static TextStyle chip({required bool selected, required Color selectedColor}) =>
      _style(12.5, selected ? FontWeight.w600 : FontWeight.w500, color: selected ? selectedColor : AppColors.subtle);
  static TextStyle get timeLabel => _style(13, FontWeight.w400, color: AppColors.subtle);
  static TextStyle timeValue({required bool selected}) => _style(
        20,
        selected ? FontWeight.w600 : FontWeight.w500,
        letterSpacingEm: -0.01,
        color: selected ? AppColors.brand : AppColors.ink,
      );
  static TextStyle get wheelTitle => _style(12, FontWeight.w500, color: AppColors.subtle);
  static TextStyle get wheelSelected => _style(25, FontWeight.w600, letterSpacingEm: -0.02);
  static TextStyle get wheelItem =>
      _style(20, FontWeight.w500, letterSpacingEm: -0.02, color: AppColors.wheelUnselected);
  static TextStyle get wheelColon => _style(20, FontWeight.w600);
  static TextStyle get calcRow => _style(13.5, FontWeight.w400, height: 1.9);
  static TextStyle get calcValue => _style(13.5, FontWeight.w500, height: 1.9);
  static TextStyle get calcNote => _style(12.5, FontWeight.w400, height: 1.9, color: AppColors.subtle);
  static TextStyle get calcSum => _style(13.5, FontWeight.w500, height: 1.9, color: AppColors.brand);
  static TextStyle get calcError => _style(13.5, FontWeight.w500, height: 1.9, color: AppColors.minus);
  static TextStyle get sheetButtonPrimary => _style(15, FontWeight.w600, color: AppColors.onBrand);
  static TextStyle get sheetButtonSecondary => _style(15, FontWeight.w600, color: AppColors.subtle);
  static TextStyle get deleteLink => _style(13.5, FontWeight.w400, color: AppColors.subtle);

  static TextStyle get toast => _style(13.5, FontWeight.w500, color: AppColors.onBrand);

  // 확인 다이얼로그
  static TextStyle get dialogTitle => _style(16, FontWeight.w600);
  static TextStyle get dialogMessage => _style(14, FontWeight.w400, height: 1.5, color: AppColors.subtle);

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

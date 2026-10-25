import '../../core/presentation/format/date_format.dart';
import '../../core/presentation/format/number_format.dart';
import '../../core/presentation/format/time_format.dart';
import '../../domain/model/work_type.dart';
import 'month_state.dart';

/// 월간 화면의 모든 문구.
abstract final class MonthTexts {
  /// 요일 헤더 — 첫 주의 실제 날짜로 그린다(시작 요일 설정에 따라 월…일 또는 일…토).
  static String weekday(DateTime d) => weekdayShort(d);
  static const legend = [
    (WorkType.halfDay, '반차'),
    (WorkType.dayOff, '연차'),
    (WorkType.holiday, '공휴일'),
    (WorkType.businessTrip, '출장'),
  ];

  static String title(DateTime month) => formatMonthTitle(month);

  /// 근무 중인 오늘을 탭했을 때. 퇴근은 오늘 화면이 찍는다.
  static const todayInProgressToast = '오늘 기록은 퇴근한 뒤에 수정할 수 있어요';

  static String value(MonthCellValue v) => switch (v) {
        MonthCellNone() => '',
        MonthCellDelta(:final minutes) => formatSignedNarrowHm(minutes),
        MonthCellWeekendActual(:final minutes) => formatNarrowHm(minutes),
        MonthCellWorking() => '···',
        MonthCellUnrecorded() => '—',
      };

  // 수당 카드 (그 달)
  static String extraWorkTitle(DateTime month) => '${month.month}월 주말·공휴일 근무';
  static const weekendLabel = '주말';
  static const holidayLabel = '공휴일';
  static const amountLabel = '예상 금액';
  /// 계산은 되지만 그 기간 기록이 없음 (주말·공휴일 행)
  static const noRecord = '기록 없음';
  static const wageNudge = '시급을 알려주시면 예상 금액을 보여드려요';
  static String minutes(int m) => formatHm(m);
  static String amount(int won) => formatWon(won);

  // 연차 카드 (그 해)
  static String leaveTitle(int year) => '$year년 연차';
  static const leaveTotalLabel = '총 연차';
  static const leaveUsedLabel = '사용';
  static const leaveRemainLabel = '잔여';
  static const leaveOverLabel = '초과';
  /// 입력값이 없어 계산할 수 없는 값 (잔여 연차 · 예상 금액)
  static const none = '—';
  /// 사용자가 넣는 값을 아직 안 넣음 (총 연차)
  static const notEntered = '미입력';
  static String days(int halfDays) => formatLeaveDays(halfDays);
  static String plannedLine(int halfDays) => '예정 ${formatLeaveDays(halfDays)} 포함';
  static const leaveNudge = '올해 연차 개수를 알려주시면 남은 연차를 보여드려요';
}

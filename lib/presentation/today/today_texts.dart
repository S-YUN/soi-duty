import '../../core/presentation/format/date_format.dart';
import '../../core/presentation/format/time_format.dart';
import '../../domain/model/work_type.dart';
import '../../domain/rules/work_rules.dart';
import 'today_state.dart';

/// 오늘 화면의 모든 문구. 숫자(TodayState) → 문자열 조립은 여기서만 한다.
abstract final class TodayTexts {
  static const tabs = ['오늘', '주간', '월간'];
  static const beforeWork = '아직 출근 전';
  static const doneTitle = '오늘 기록 완료';
  static const halfDay = '오늘은 반차';
  static const dayOff = '오늘은 연차';
  static const holiday = '오늘은 공휴일';
  static const editTime = '시간 수정';
  static const cancelClockIn = '출근 취소';
  static const cancelClockOut = '퇴근 취소';
  static const revert = '되돌리기';
  static const record = '기록하기 →';
  static const firstWeekNotice =
      '첫 기록일이 월요일이 아니라 이번 주는 목표를 세우지 않아요. 기록한 시간만 그대로 보여드립니다. 다음 주부터 주 40시간 기준으로 계산돼요.';
  static const summaryLabels = ['출근', '퇴근', '근무', '기준 대비'];
  static const firstWeekWorking = '오늘 기록 중 · 이번 주는 목표 없이 실적만';

  static String heroLabel(TodayState s) => s.isFirstWeek ? '이번 주 기록한 시간' : '이번 주 남은 시간';

  static String heroValue(TodayState s) =>
      formatHm(s.isFirstWeek ? s.week.workedMinutes : (s.week.remainingMinutes ?? 0));

  static String heroReason(TodayState s, WorkRules rules) {
    if (s.isFirstWeek) {
      final first = s.firstRecordDate;
      return first == null ? '' : '${formatDateTitle(first)}부터 기록';
    }
    final w = s.week;
    final parts = ['${formatHm(w.workedMinutes)} / ${formatHm(w.targetMinutes ?? 0)}'];
    if (w.halfDayCount > 0) parts.add('반차 ${w.halfDayCount}회');
    if (w.dayOffCount > 0) {
      parts.add('연차 ${w.dayOffCount}일로 목표 ${formatHm(w.dayOffCount * rules.dayOffCreditMinutes)} 차감');
    }
    if (w.holidayCount > 0) {
      parts.add('공휴일 ${w.holidayCount}일로 목표 ${formatHm(w.holidayCount * rules.dayOffCreditMinutes)} 차감');
    }
    return parts.join(' · ');
  }

  /// 진행률 0..1. 첫 주 예외면 null (바를 그리지 않는다).
  static double? progress(TodayState s) {
    final target = s.week.targetMinutes;
    if (target == null || target == 0) return null;
    return (s.week.workedMinutes / target).clamp(0.0, 1.0);
  }

  static String statusMain(TodayState s) {
    if (s.isFirstWeek) return firstWeekWorking;
    final expected = s.expectedClockOut;
    return expected == null ? '' : '오늘 ${formatClock(expected)}에 퇴근하면 딱 맞아';
  }

  static String statusSub(TodayState s) {
    final clockIn = s.clockIn;
    final elapsed = s.elapsedMinutes;
    if (clockIn == null || elapsed == null) return '';
    return '${formatClock(clockIn)} 출근 · ${formatHm(elapsed)}째';
  }

  static String buttonLabel(TodayState s) => switch (s.screenState) {
        TodayScreenState.beforeWork || TodayScreenState.dayType => '출근하기',
        TodayScreenState.working => '퇴근하기',
        TodayScreenState.done => '오늘 퇴근 완료',
      };

  static String dayTypeMessage(WorkType type) {
    final name = type == WorkType.dayOff ? '연차' : '공휴일';
    return '오늘은 $name로 처리돼 있어요\n근무 기록은 남기지 않습니다';
  }

  static String badgeLabel(WorkType type) => type == WorkType.dayOff ? '연차' : '공휴일';

  static String unrecordedTitle(int count) => '기록 안 된 날 $count개';
}

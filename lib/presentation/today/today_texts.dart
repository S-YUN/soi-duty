import '../../core/presentation/format/time_format.dart';
import '../../domain/model/work_type.dart';
import '../../domain/rules/work_rules.dart';
import 'today_state.dart';

/// 오늘 화면의 모든 문구. 숫자(TodayState) → 문자열 조립은 여기서만 한다.
abstract final class TodayTexts {
  static const tabs = ['오늘', '주간', '월간'];
  static const beforeWork = '아직 출근 전';
  static const halfDay = '오늘은 반차';
  static const dayOff = '오늘은 연차';
  static const holiday = '오늘은 공휴일';
  static const editTime = '시간 수정';
  static const editClockIn = '출근 변경';
  static const clockInSheetTitle = '출근 시각';
  static const clockInTooLate = '지금보다 늦을 수 없어요';
  static const save = '저장';
  static const cancelClockIn = '출근 취소';
  static const cancelClockOut = '퇴근 취소';
  static const revert = '되돌리기';
  static const record = '기록하기 →';
  static const firstWeekNotice =
      '첫 기록을 시작하시는군요! 환영합니다.\n기록 안 된 날을 모두 채우면 이번 주 목표 시간이 계산돼요.\n채우지 않아도 다음 주부터는 자동으로 계산됩니다.';
  static const summaryLabels = ['출근', '퇴근', '근무', '기준 대비'];

  static String heroLabel(TodayState s) =>
      s.isFirstWeek ? '이번 주 기록한 시간' : '이번 주 남은 근무시간';

  static String heroValue(TodayState s) => formatHm(
    s.isFirstWeek ? s.week.workedMinutes : (s.week.remainingMinutes ?? 0),
  );

  /// 진행률 0..1. 첫 주 예외면 null (바를 그리지 않는다).
  static double? progress(TodayState s) {
    final target = s.week.targetMinutes;
    if (target == null || target == 0) return null;
    return (s.week.workedMinutes / target).clamp(0.0, 1.0);
  }

  // ---- 상태 블록 ----

  /// 근무 중 첫 줄: "09:12 출근"
  static String clockInLine(TodayState s) =>
      s.clockIn == null ? '' : '${formatClock(s.clockIn!)} 출근';

  /// 근무 중 둘째 줄: "7시간 15분째 근무중". 퇴근 추천 시각은 계산만 하고 아직 화면에 띄우지 않는다.
  static String workingLine(TodayState s) {
    final elapsed = s.elapsedMinutes;
    return elapsed == null ? '' : '${formatKoreanDuration(elapsed)}째 근무중';
  }

  /// 안내 문구 (CLAUDE.md "안내 문구"). 출근 전에만. 오늘 몫을 8h와 비교, 기준선 ±30분.
  static String encouragement(TodayState s, WorkRules rules) {
    if (s.isWeekend) return weekendNote;
    if (s.isFirstWeek) return firstWeekNote;
    if (s.isLastWorkday) {
      return s.date.weekday == DateTime.friday ? lastDayFriday : lastDay;
    }
    if (s.isFirstWorkday) return firstDay;
    final share = s.todayShareMinutes;
    if (share == null || s.isHalfDay) return onPace;
    if (share < rules.dailyStandardMinutes - paceBandMinutes) return ahead;
    if (share > rules.dailyStandardMinutes + paceBandMinutes) return behind;
    return onPace;
  }

  static const weekendNote = '주말 근무는 주 40시간에 포함되지 않아요';
  static const firstWeekNote = '이번 주 기록 안 된 날을 채워주세요';
  static const firstDay = '자, 이번주 시작해볼까요?';
  static const lastDayFriday = '드디어 금요일! 오늘도 힘내세요';
  static const lastDay = '이번 주 마지막 날! 오늘도 힘내세요';
  static const ahead = '오늘은 조금 일찍 퇴근하셔도 괜찮아요';
  static const behind = '오늘은 좀 더 일하는 것을 추천해요';
  static const onPace = '이번 주 페이스 좋아요';

  /// 안내 문구 판정 기준선 (±30분)
  static const paceBandMinutes = 30;

  static String buttonLabel(TodayState s) => switch (s.screenState) {
    TodayScreenState.beforeWork || TodayScreenState.dayType => '출근하기',
    TodayScreenState.working => '퇴근하기',
    TodayScreenState.done => '오늘 퇴근 완료',
  };

  static String dayTypeMessage(WorkType type) => type == WorkType.dayOff
      ? '오늘은 연차입니다\n근무 기록을 남기지 않습니다'
      : '오늘은 공휴일입니다\n행복한 휴일 되세요';

  static String badgeLabel(WorkType type) =>
      type == WorkType.dayOff ? '연차' : '공휴일';

  static String unrecordedTitle(int count) => '기록 안 된 날 $count개';
}

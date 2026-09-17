/// 회사마다 다른 값. 계산 함수는 항상 이 인스턴스를 인자로 받는다.
class WorkRules {
  const WorkRules({
    this.weeklyTargetMinutes = 2400,
    this.lunchBreakMinutes = 60,
    this.halfDayCreditMinutes = 240,
    this.dayOffCreditMinutes = 480,
    this.defaultClockInMinutes = 8 * 60,
    this.defaultClockOutMinutes = 17 * 60,
  });

  final int weeklyTargetMinutes;
  final int lunchBreakMinutes;
  final int halfDayCreditMinutes;
  final int dayOffCreditMinutes;

  /// 시트에서 빈 출근/퇴근 행을 열 때 휠이 시작하는 시각(자정 기준 분). 저장값·표시와는 무관.
  final int defaultClockInMinutes;
  final int defaultClockOutMinutes;

  /// 평일 하루 기준시간 (8h). 연차 1일 차감량과 같다.
  int get dailyStandardMinutes => dayOffCreditMinutes;
}

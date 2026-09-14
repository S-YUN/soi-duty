/// 회사마다 다른 값. 계산 함수는 항상 이 인스턴스를 인자로 받는다.
class WorkRules {
  const WorkRules({
    this.weeklyTargetMinutes = 2400,
    this.lunchBreakMinutes = 60,
    this.halfDayCreditMinutes = 240,
    this.dayOffCreditMinutes = 480,
  });

  final int weeklyTargetMinutes;
  final int lunchBreakMinutes;
  final int halfDayCreditMinutes;
  final int dayOffCreditMinutes;

  /// 평일 하루 기준시간 (8h). 연차 1일 차감량과 같다.
  int get dailyStandardMinutes => dayOffCreditMinutes;
}

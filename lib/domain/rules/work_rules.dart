/// 회사마다 다른 값. 계산 함수는 항상 이 인스턴스를 인자로 받는다.
class WorkRules {
  const WorkRules({
    this.weeklyTargetMinutes = 2400,
    this.lunchBreakMinutes = 60,
    this.lunchStartMinutes = 12 * 60,
    this.halfDayCreditMinutes = 240,
    this.dayOffCreditMinutes = 480,
    this.businessTripCreditMinutes = 480,
    this.deductionStepMinutes = 10,
    this.defaultClockInMinutes = 8 * 60,
    this.defaultClockOutMinutes = 17 * 60,
    this.extraWorkPayMultiplier = 1.5,
    this.leaveStepMinutes = 240,
  });

  final int weeklyTargetMinutes;
  final int lunchBreakMinutes;

  /// 점심 창 시작(자정 기준 분). 근무 중인 오늘의 진행분이 이 시각부터 [lunchBreakMinutes] 동안 멈춘다.
  /// 하루 합계(`actualMinutes`)는 정액 공제라 이 값과 무관하다. 지금은 기본값만 쓴다 — 설정으로 뺄 때 시작 시각만 받는다.
  final int lunchStartMinutes;
  final int halfDayCreditMinutes;
  final int dayOffCreditMinutes;

  /// 출장 1일 차감량 (8h)
  final int businessTripCreditMinutes;

  /// 시간공제 휠의 분 단위
  final int deductionStepMinutes;

  /// 시트에서 빈 출근/퇴근 행을 열 때 휠이 시작하는 시각(자정 기준 분). 저장값·표시와는 무관.
  final int defaultClockInMinutes;
  final int defaultClockOutMinutes;

  /// 주말·공휴일 근무 수당 배율. 사용자 설정이 아니다 — 테스트 회사 규정(1.5배 고정).
  final double extraWorkPayMultiplier;

  /// 남은 연차 입력 단위(0.5일). 반반차가 생기면 120으로.
  final int leaveStepMinutes;

  /// 평일 하루 기준시간 (8h). 연차 1일 차감량과 같다.
  int get dailyStandardMinutes => dayOffCreditMinutes;
}

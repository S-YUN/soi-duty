import 'package:freezed_annotation/freezed_annotation.dart';

part 'leave_balance.freezed.dart';

/// 사용자가 넣은 "지금 남은 연차"와 그 숫자가 어느 날 기준인지. 잔여 = [remainingMinutes] − 기준일 다음 날부터 찍힌 연차·반차.
/// 단위는 분(연차 1일 = `WorkRules.dayOffCreditMinutes`) — 반반차·시간 단위 연차가 와도 저장을 다시 뜯지 않게.
@freezed
abstract class LeaveBalance with _$LeaveBalance {
  const factory LeaveBalance({
    required int remainingMinutes,
    /// 저장한 날(날짜만). 당일 연차는 회사 숫자에 이미 반영된 것으로 보고 빼지 않는다.
    required DateTime baseDate,
  }) = _LeaveBalance;
}

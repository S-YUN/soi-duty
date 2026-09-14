import 'package:freezed_annotation/freezed_annotation.dart';

part 'week_summary.freezed.dart';

@freezed
abstract class WeekSummary with _$WeekSummary {
  const factory WeekSummary({
    /// 첫 주 예외면 null
    int? targetMinutes,
    required int workedMinutes,
    /// target − worked. target이 null이면 null
    int? remainingMinutes,
    required int halfDayCount,
    required int dayOffCount,
    required int holidayCount,
    required bool isFirstWeekException,
  }) = _WeekSummary;
}

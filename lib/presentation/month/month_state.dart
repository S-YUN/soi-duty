import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/model/work_type.dart';

part 'month_state.freezed.dart';

@freezed
sealed class MonthCellValue with _$MonthCellValue {
  const factory MonthCellValue.none() = MonthCellNone;
  const factory MonthCellValue.delta(int minutes) = MonthCellDelta;
  const factory MonthCellValue.weekendActual(int minutes) = MonthCellWeekendActual;
  const factory MonthCellValue.working() = MonthCellWorking;
  const factory MonthCellValue.unrecorded() = MonthCellUnrecorded;
}

@freezed
abstract class MonthCell with _$MonthCell {
  const factory MonthCell({
    required DateTime date,
    required bool isCurrentMonth,
    required bool isToday,
    required bool isWeekend,
    required bool isFuture,
    /// 배지. normal이면 null
    WorkType? type,
    required MonthCellValue value,
    required bool hasBackground,
  }) = _MonthCell;
}

@freezed
abstract class MonthState with _$MonthState {
  const factory MonthState({
    required DateTime month,
    required bool canGoPrev,
    required bool canGoNext,
    required List<List<MonthCell>> weeks,
  }) = _MonthState;
}

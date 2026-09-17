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
    /// 첫 기록 주의 월요일보다 앞 — 앱 설치 전. 흐리게만 보이고 탭해도 열리지 않는다.
    required bool isBeforeFirstWeek,
    /// 배지. normal이면 null
    WorkType? type,
    required MonthCellValue value,
  }) = _MonthCell;
}

@freezed
abstract class MonthState with _$MonthState {
  const factory MonthState({
    required DateTime month,
    required List<List<MonthCell>> weeks,
  }) = _MonthState;
}

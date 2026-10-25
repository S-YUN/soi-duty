import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/model/work_type.dart';

part 'month_state.freezed.dart';

@freezed
sealed class MonthCellValue with _$MonthCellValue {
  const factory MonthCellValue.none() = MonthCellNone;
  const factory MonthCellValue.delta(int minutes) = MonthCellDelta;
  /// 주말·공휴일 근무 — 기준 대비 없이 근무시간
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
    /// 오늘 근무 중(출근만 찍힘) — 탭해도 시트 대신 안내만.
    required bool isTodayWorking,
    required bool isWeekend,
    required bool isFuture,
    /// 첫 기록 주의 월요일보다 앞 — 앱 설치 전. 흐리게만 보이고 탭해도 열리지 않는다.
    required bool isBeforeFirstWeek,
    /// 배지. normal이면 null
    WorkType? type,
    required MonthCellValue value,
  }) = _MonthCell;
}

/// 그 달 주말·공휴일 근무 카드. 합계가 0인 달은 카드 자체가 없다(null).
@freezed
abstract class MonthExtraWork with _$MonthExtraWork {
  const factory MonthExtraWork({
    required int weekendMinutes,
    required int holidayMinutes,
    /// 시급이 있을 때만. 없으면 유도 줄.
    int? payWon,
  }) = _MonthExtraWork;
}

/// 그 해 연차 카드. 총 연차도 없고 사용도 0이면 카드가 없다(null).
@freezed
abstract class MonthLeave with _$MonthLeave {
  const factory MonthLeave({
    required int year,
    /// 그 해 총 연차(일). 없으면 "—" + 유도 줄.
    int? totalDays,
    /// 반일 단위. 미리 찍은 미래 날짜 포함.
    required int usedHalfDays,
    /// 사용 중 오늘보다 뒤인 것(반일 단위). 0보다 크면 "예정 n일 포함".
    required int plannedHalfDays,
    /// total×2 − used. 음수면 초과. total 없으면 null.
    int? remainingHalfDays,
  }) = _MonthLeave;
}

@freezed
abstract class MonthState with _$MonthState {
  const factory MonthState({
    required DateTime month,
    required List<List<MonthCell>> weeks,
    MonthExtraWork? extraWork,
    MonthLeave? leave,
  }) = _MonthState;
}

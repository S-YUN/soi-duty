import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/model/work_type.dart';

import '../../domain/model/leave_balance.dart';

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

/// 그 달 주말·공휴일 근무 카드. 항상 보인다 — 근무가 없으면 행에 "기록 없음", 시급이 없으면 금액 "—" + 유도 줄.
@freezed
abstract class MonthExtraWork with _$MonthExtraWork {
  const factory MonthExtraWork({
    required int weekendMinutes,
    required int holidayMinutes,
    /// 시급이 있을 때만. 없으면 유도 줄.
    int? payWon,
  }) = _MonthExtraWork;
}

/// 그 해 연차 카드. 항상 보인다 — 값이 없으면 "미입력" · 잔여 "—" + 유도 줄, 사용 0은 숫자 "0일".
/// 값이 있으면 제목 아래 "n월 n일 기준" 줄, 2칸은 기준일 다음 날부터의 "이후 사용", 없으면 올해 전체 "올해 사용" (2026-10-27).
@freezed
abstract class MonthLeave with _$MonthLeave {
  const factory MonthLeave({
    required int year,
    /// 사용자가 넣은 남은 연차 + 기준일. 없으면 "미입력" + 유도 줄.
    LeaveBalance? balance,
    /// 분. 값이 있으면 기준일 다음 날부터, 없으면 그 해 전체. 미리 찍은 미래 날짜 포함.
    required int usedMinutes,
    /// 사용 중 오늘(과 기준일)보다 뒤인 것(분). 0보다 크면 "예정 n일 포함".
    required int plannedMinutes,
    /// balance.remainingMinutes − usedMinutes. 음수면 초과. balance 없으면 null.
    int? remainingMinutes,
    /// 연차 1일의 분(표기용, `WorkRules.dayOffCreditMinutes`).
    required int dayMinutes,
  }) = _MonthLeave;
}

@freezed
abstract class MonthState with _$MonthState {
  const factory MonthState({
    required DateTime month,
    required List<List<MonthCell>> weeks,
    required MonthExtraWork extraWork,
    required MonthLeave leave,
  }) = _MonthState;
}

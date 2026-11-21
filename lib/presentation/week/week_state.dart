import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/model/work_record.dart';
import '../../domain/model/work_type.dart';
import '../../domain/rules/week_summary.dart';

part 'week_state.freezed.dart';

enum WeekDayKind {
  recorded,
  working,
  beforeWork,
  unrecorded,
  partial,
  off,
  future,
  weekendRecorded,
  /// 공휴일에 출퇴근까지 찍힘 — 주말 근무처럼 근무시간만, ± 없음
  holidayRecorded,
  weekendEmpty,
}

/// 주간 행 배지의 종류. 순서가 곧 그리는 순서 — 유형 → 시간 출장 → 시간공제.
enum WeekBadgeKind { type, trip, deduction }

/// 주간 행 배지. [type]은 유형 배지일 때만 — 색을 고른다. 시간 출장은 출장색, 시간공제는 중립색.
class WeekBadge {
  const WeekBadge(this.label, this.kind, {this.type});

  final String label;
  final WeekBadgeKind kind;
  final WorkType? type;
}

@freezed
abstract class WeekDay with _$WeekDay {
  const factory WeekDay({
    required DateTime date,
    WorkRecord? record,
    required WeekDayKind kind,
    int? actualMinutes,
    int? deltaMinutes,
    required bool isToday,
    /// 오늘 근무 중(출근만 찍힘) — 탭해도 시트 대신 안내만.
    required bool isTodayWorking,
  }) = _WeekDay;
}

@freezed
abstract class WeekState with _$WeekState {
  const factory WeekState({
    required DateTime monday,
    required bool isCurrentWeek,
    required bool canGoPrev,
    required bool canGoNext,
    required WeekSummary summary,
    required int excludedMinutes,
    required List<WeekDay> days,
    DateTime? firstRecordDate,
  }) = _WeekState;
}

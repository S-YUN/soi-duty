import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/model/work_record.dart';
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
  weekendEmpty,
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
    /// 오늘인데 출퇴근이 덜 찍힘 — 탭해도 시트 대신 안내만.
    required bool isTodayInProgress,
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
    required int weekendMinutes,
    required List<WeekDay> days,
    DateTime? firstRecordDate,
  }) = _WeekState;
}

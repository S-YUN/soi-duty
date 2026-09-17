import '../../domain/model/work_record.dart';
import '../../domain/model/work_type.dart';
import '../../domain/rules/navigation_bounds.dart';
import '../../domain/rules/work_calculator.dart';
import '../../domain/rules/work_rules.dart';
import 'week_state.dart';

/// (기록 전체, 첫 기록일, 현재 시각, 규칙, 선택한 주) → 주간 화면 상태. 순수 함수.
WeekState buildWeekState({
  required List<WorkRecord> records,
  required DateTime? firstRecordDate,
  required DateTime now,
  required WorkRules rules,
  required DateTime monday,
}) {
  final today = dateOnly(now);
  final start = dateOnly(monday);
  firstRecordDate = effectiveFirstRecordDate(firstRecordDate, now);
  final thisMonday = mondayOf(today);
  final byDate = recordsByDate(records);

  return WeekState(
    monday: start,
    isCurrentWeek: start == thisMonday,
    canGoPrev: start.isAfter(earliestMonday(firstRecordDate, today)),
    canGoNext: start.isBefore(thisMonday),
    summary: weekSummary(records: records, monday: start, rules: rules, now: now, firstRecordDate: firstRecordDate),
    weekendMinutes: weekendMinutes(records, start, rules),
    days: [for (var i = 0; i < 7; i++) _day(addDays(start, i), byDate, today, rules)],
    firstRecordDate: firstRecordDate,
  );
}

WeekDay _day(DateTime date, Map<DateTime, WorkRecord> byDate, DateTime today, WorkRules rules) {
  final r = byDate[date];
  final isToday = date == today;
  final hasBoth = r?.clockIn != null && r?.clockOut != null;

  final WeekDayKind kind;
  if (isWeekend(date)) {
    kind = hasBoth ? WeekDayKind.weekendRecorded : WeekDayKind.weekendEmpty;
  } else if (r != null && (r.type == WorkType.dayOff || r.type == WorkType.holiday)) {
    kind = WeekDayKind.off;
  } else if (date.isAfter(today)) {
    kind = WeekDayKind.future;
  } else if (hasBoth) {
    kind = WeekDayKind.recorded;
  } else if (isToday) {
    kind = r?.clockIn != null ? WeekDayKind.working : WeekDayKind.beforeWork;
  } else if (r == null || (r.clockIn == null && r.clockOut == null)) {
    kind = WeekDayKind.unrecorded;
  } else {
    kind = WeekDayKind.partial;
  }

  return WeekDay(
    date: date,
    record: r,
    kind: kind,
    actualMinutes: hasBoth ? actualMinutes(r!, rules) : null,
    deltaMinutes: kind == WeekDayKind.recorded ? deltaMinutes(r!, rules) : null,
    isToday: isToday,
    isTodayInProgress: isTodayInProgress(r, date, today),
  );
}

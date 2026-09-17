import '../../domain/model/work_record.dart';
import '../../domain/model/work_type.dart';
import '../../domain/rules/navigation_bounds.dart';
import '../../domain/rules/work_calculator.dart';
import '../../domain/rules/work_rules.dart';
import 'month_state.dart';

/// (기록 전체, 첫 기록일, 현재 시각, 규칙, 선택한 달) → 월간 화면 상태. 순수 함수.
MonthState buildMonthState({
  required List<WorkRecord> records,
  required DateTime? firstRecordDate,
  required DateTime now,
  required WorkRules rules,
  required DateTime month,
}) {
  final today = dateOnly(now);
  final start = firstOfMonth(month);
  firstRecordDate = effectiveFirstRecordDate(firstRecordDate, now);
  final byDate = recordsByDate(records);

  final editableFrom = earliestMonday(firstRecordDate, today);
  final cells = [for (final d in calendarDays(start)) _cell(d, byDate, start, today, editableFrom, rules)];
  return MonthState(
    month: start,
    weeks: [for (var i = 0; i < cells.length; i += 7) cells.sublist(i, i + 7)],
  );
}

MonthCell _cell(
  DateTime date,
  Map<DateTime, WorkRecord> byDate,
  DateTime month,
  DateTime today,
  DateTime editableFrom,
  WorkRules rules,
) {
  final r = byDate[date];
  final weekend = isWeekend(date);
  final future = date.isAfter(today);
  final beforeFirstWeek = date.isBefore(editableFrom);
  final isCurrentMonth = date.month == month.month && date.year == month.year;
  final type = r == null || r.type == WorkType.normal ? null : r.type;
  final hasBoth = r?.clockIn != null && r?.clockOut != null;

  final MonthCellValue value;
  if (type == WorkType.dayOff || type == WorkType.holiday) {
    value = const MonthCellValue.none();
  } else if (weekend) {
    value = hasBoth ? MonthCellValue.weekendActual(actualMinutes(r!, rules) ?? 0) : const MonthCellValue.none();
  } else if (future || beforeFirstWeek) {
    value = const MonthCellValue.none();
  } else if (hasBoth) {
    value = MonthCellValue.delta(deltaMinutes(r!, rules) ?? 0);
  } else if (date == today) {
    value = r?.clockIn != null ? const MonthCellValue.working() : const MonthCellValue.none();
  } else {
    value = const MonthCellValue.unrecorded();
  }

  return MonthCell(
    date: date,
    isCurrentMonth: isCurrentMonth,
    isToday: date == today,
    isWeekend: weekend,
    isFuture: future,
    isBeforeFirstWeek: beforeFirstWeek,
    type: type,
    value: value,
    // 평일은 지난 날 전부, 주말은 근무 기록이 있는 날만.
    hasBackground: isCurrentMonth && !future && !beforeFirstWeek && (!weekend || hasBoth),
  );
}

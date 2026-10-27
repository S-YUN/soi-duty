
import '../../domain/model/work_record.dart';
import '../../domain/model/work_type.dart';
import '../../domain/rules/work_calculator.dart';
import '../../domain/rules/work_rules.dart';
import 'today_state.dart';

/// (기록 전체, 첫 기록일, 현재 시각, 규칙) → 오늘 화면 상태. 순수 함수.
TodayState buildTodayState({
  required List<WorkRecord> records,
  required DateTime? firstRecordDate,
  required DateTime now,
  required WorkRules rules,
}) {
  final today = dateOnly(now);
  final record = recordsByDate(records)[today];
  firstRecordDate = effectiveFirstRecordDate(firstRecordDate, now);

  final phase = switch (record) {
    null => TodayPhase.before,
    WorkRecord(clockIn: null) => TodayPhase.before,
    WorkRecord(clockOut: null) => TodayPhase.working,
    _ => TodayPhase.done,
  };

  final type = record?.type ?? WorkType.normal;
  final dayType = isOffType(type) ? type : null;

  final week = weekSummary(
    records: records,
    monday: mondayOf(today),
    rules: rules,
    now: now,
    firstRecordDate: firstRecordDate,
  );

  final remaining = weekRemainingBeforeToday(records: records, today: today, rules: rules, firstRecordDate: firstRecordDate);
  final share = phase == TodayPhase.done
      ? null
      : todayShareMinutes(records: records, today: today, rules: rules, firstRecordDate: firstRecordDate);
  DateTime? expected;
  if (phase == TodayPhase.working && record != null && share != null && remaining != null && remaining > 0) {
    expected = expectedClockOut(record, share, rules);
  }

  return TodayState(
    date: today,
    record: record,
    phase: phase,
    dayType: dayType,
    isHalfDay: type == WorkType.halfDay,
    clockIn: record?.clockIn,
    clockOut: record?.clockOut,
    // 위 카드의 잔여와 같은 기준(점심 창에서 멈추는 실근무). 미래 출근 시각은 함수 안에서 0으로.
    elapsedMinutes: phase == TodayPhase.working ? ongoingMinutes(record!, now, rules) : null,
    expectedClockOut: expected,
    todayShareMinutes: share,
    weekRemainingBeforeToday: remaining,
    todayStandardMinutes: dayStandardMinutes(record, rules),
    isFirstWorkday: isFirstWorkday(records, today),
    isLastWorkday: isLastWorkday(records, today),
    todayActual: phase == TodayPhase.done ? actualMinutes(record!, rules) : null,
    todayDelta: phase == TodayPhase.done ? deltaMinutes(record!, rules) : null,
    week: week,
    unrecordedDays: unrecordedWeekdays(rules: rules, records: records, today: today, firstRecordDate: firstRecordDate),
    firstRecordDate: firstRecordDate,
  );
}

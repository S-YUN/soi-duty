import 'dart:math' as math;

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

  final phase = switch (record) {
    null => TodayPhase.before,
    WorkRecord(clockIn: null) => TodayPhase.before,
    WorkRecord(clockOut: null) => TodayPhase.working,
    _ => TodayPhase.done,
  };

  final type = record?.type ?? WorkType.normal;
  final dayType = (type == WorkType.dayOff || type == WorkType.holiday) ? type : null;

  final week = weekSummary(
    records: records,
    monday: mondayOf(today),
    rules: rules,
    now: now,
    firstRecordDate: firstRecordDate,
  );

  DateTime? expected;
  if (phase == TodayPhase.working && record != null) {
    final target = todayTargetMinutes(
      records: records,
      today: today,
      rules: rules,
      firstRecordDate: firstRecordDate,
    );
    if (target != null) expected = expectedClockOut(record, target, rules);
  }

  return TodayState(
    date: today,
    record: record,
    phase: phase,
    dayType: dayType,
    isHalfDay: type == WorkType.halfDay,
    clockIn: record?.clockIn,
    clockOut: record?.clockOut,
    // 시트로 출근 시각을 미래로 잡을 수 있으므로 음수는 0으로.
    elapsedMinutes: phase == TodayPhase.working ? math.max(0, now.difference(record!.clockIn!).inMinutes) : null,
    expectedClockOut: expected,
    todayActual: phase == TodayPhase.done ? actualMinutes(record!, rules) : null,
    todayDelta: phase == TodayPhase.done ? deltaMinutes(record!, rules) : null,
    week: week,
    unrecordedDays: unrecordedWeekdays(records: records, today: today, firstRecordDate: firstRecordDate),
    firstRecordDate: firstRecordDate,
  );
}

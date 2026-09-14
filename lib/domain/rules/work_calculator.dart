import 'dart:math' as math;

import '../model/work_record.dart';
import '../model/work_type.dart';
import 'week_summary.dart';
import 'work_rules.dart';

// ---- 날짜 유틸 ----

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

bool isWeekend(DateTime d) => d.weekday >= DateTime.saturday;

DateTime mondayOf(DateTime d) {
  final day = dateOnly(d);
  return DateTime(day.year, day.month, day.day - (day.weekday - DateTime.monday));
}

// ---- 하루 단위 ----

/// 점심 공제 조건: 반차가 아니고, 주말이 아닐 것.
bool deductsLunch(WorkRecord r) => r.type != WorkType.halfDay && !isWeekend(r.date);

/// 그날 기준시간.
int standardMinutes(WorkType type, WorkRules rules) => switch (type) {
      WorkType.normal => rules.dailyStandardMinutes,
      WorkType.halfDay => rules.halfDayCreditMinutes,
      WorkType.dayOff || WorkType.holiday => 0,
    };

/// 하루 실근무. 연차·공휴일은 0, 출퇴근이 비면 null.
int? actualMinutes(WorkRecord r, WorkRules rules) {
  if (r.type == WorkType.dayOff || r.type == WorkType.holiday) return 0;
  final clockIn = r.clockIn;
  final clockOut = r.clockOut;
  if (clockIn == null || clockOut == null) return null;
  final raw = clockOut.difference(clockIn).inMinutes;
  final lunch = deductsLunch(r) ? rules.lunchBreakMinutes : 0;
  return math.max(0, raw - lunch);
}

/// 근무 중인 오늘의 진행분. 오늘이 아니거나 출근·퇴근 조건이 안 맞으면 null.
int? ongoingMinutes(WorkRecord r, DateTime now, WorkRules rules) {
  if (dateOnly(now) != dateOnly(r.date)) return null;
  final clockIn = r.clockIn;
  if (clockIn == null || r.clockOut != null) return null;
  final raw = now.difference(clockIn).inMinutes;
  final lunch = deductsLunch(r) ? rules.lunchBreakMinutes : 0;
  return math.max(0, raw - lunch);
}

/// 기준 대비 (실근무 − 그날 기준시간). 주말은 기준이 없으므로 null.
int? deltaMinutes(WorkRecord r, WorkRules rules) {
  if (isWeekend(r.date)) return null;
  final actual = actualMinutes(r, rules);
  if (actual == null) return null;
  return actual - standardMinutes(r.type, rules);
}

// ---- 주간 ----

/// 첫 기록일이 그 주의 월요일이 아니면, 그 주만 잔여 계산을 하지 않는다.
bool isFirstWeekException(DateTime monday, DateTime? firstRecordDate) {
  if (firstRecordDate == null) return false;
  final first = dateOnly(firstRecordDate);
  return mondayOf(first) == dateOnly(monday) && first.weekday != DateTime.monday;
}

/// 월~금 5일을 순회한다. 기록이 없는 평일은 normal(8h)로 간주한다.
Iterable<DateTime> weekdaysOf(DateTime monday) sync* {
  final start = dateOnly(monday);
  for (var i = 0; i < 5; i++) {
    yield DateTime(start.year, start.month, start.day + i);
  }
}

Map<DateTime, WorkRecord> recordsByDate(List<WorkRecord> records) =>
    {for (final r in records) dateOnly(r.date): r};

WeekSummary weekSummary({
  required List<WorkRecord> records,
  required DateTime monday,
  required WorkRules rules,
  required DateTime now,
  required DateTime? firstRecordDate,
}) {
  final byDate = recordsByDate(records);
  final firstWeek = isFirstWeekException(monday, firstRecordDate);

  var reduction = 0;
  var worked = 0;
  var halfDays = 0;
  var dayOffs = 0;
  var holidays = 0;

  for (final day in weekdaysOf(monday)) {
    final r = byDate[day];
    final type = r?.type ?? WorkType.normal;
    reduction += rules.dailyStandardMinutes - standardMinutes(type, rules);
    switch (type) {
      case WorkType.halfDay:
        halfDays++;
      case WorkType.dayOff:
        dayOffs++;
      case WorkType.holiday:
        holidays++;
      case WorkType.normal:
        break;
    }
    if (r != null) {
      worked += actualMinutes(r, rules) ?? ongoingMinutes(r, now, rules) ?? 0;
    }
  }

  final target = rules.weeklyTargetMinutes - reduction;

  return WeekSummary(
    targetMinutes: firstWeek ? null : target,
    workedMinutes: worked,
    remainingMinutes: firstWeek ? null : target - worked,
    halfDayCount: halfDays,
    dayOffCount: dayOffs,
    holidayCount: holidays,
    isFirstWeekException: firstWeek,
  );
}

// ---- 오늘 목표 · 퇴근 예상 (CLAUDE.md "퇴근 예상 시각") ----

/// 오늘 목표 = max(0, (주간 목표 − 오늘 제외 주간 실적) − 오늘 이후 평일 기준시간 합).
/// 첫 주 예외·주말이면 null.
int? todayTargetMinutes({
  required List<WorkRecord> records,
  required DateTime today,
  required WorkRules rules,
  required DateTime? firstRecordDate,
}) {
  final day = dateOnly(today);
  if (isWeekend(day)) return null;
  final monday = mondayOf(day);
  if (isFirstWeekException(monday, firstRecordDate)) return null;

  final byDate = recordsByDate(records);
  var reduction = 0;
  var workedExcludingToday = 0;
  var remainingStandard = 0;

  for (final weekday in weekdaysOf(monday)) {
    final r = byDate[weekday];
    final type = r?.type ?? WorkType.normal;
    reduction += rules.dailyStandardMinutes - standardMinutes(type, rules);
    if (weekday.isBefore(day)) {
      if (r != null) workedExcludingToday += actualMinutes(r, rules) ?? 0;
    } else if (weekday.isAfter(day)) {
      remainingStandard += standardMinutes(type, rules);
    }
  }

  final target = rules.weeklyTargetMinutes - reduction;
  return math.max(0, target - workedExcludingToday - remainingStandard);
}

/// 퇴근 예상 = 출근 + 오늘 목표 + 점심 공제(해당 시).
DateTime? expectedClockOut(WorkRecord today, int todayTarget, WorkRules rules) {
  final clockIn = today.clockIn;
  if (clockIn == null) return null;
  final lunch = deductsLunch(today) ? rules.lunchBreakMinutes : 0;
  return clockIn.add(Duration(minutes: todayTarget + lunch));
}

// ---- 기록 누락 ----

/// 첫 기록일 ~ 어제의 평일 중 기록이 없거나, 출퇴근이 필요한 유형인데 하나라도 빈 날. 최신순.
List<DateTime> unrecordedWeekdays({
  required List<WorkRecord> records,
  required DateTime today,
  required DateTime? firstRecordDate,
}) {
  if (firstRecordDate == null) return const [];
  final byDate = recordsByDate(records);
  final end = dateOnly(today);
  final result = <DateTime>[];

  var cursor = dateOnly(firstRecordDate);
  while (cursor.isBefore(end)) {
    if (!isWeekend(cursor)) {
      final r = byDate[cursor];
      final needsClock = r == null || r.type == WorkType.normal || r.type == WorkType.halfDay;
      final incomplete = r == null || r.clockIn == null || r.clockOut == null;
      if (needsClock && incomplete) result.add(cursor);
    }
    cursor = DateTime(cursor.year, cursor.month, cursor.day + 1);
  }
  return result.reversed.toList();
}

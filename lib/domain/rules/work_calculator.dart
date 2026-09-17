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

DateTime addDays(DateTime d, int n) => DateTime(d.year, d.month, d.day + n);

DateTime firstOfMonth(DateTime d) => DateTime(d.year, d.month);

DateTime addMonths(DateTime month, int n) => DateTime(month.year, month.month + n);

/// 월요일 시작, 앞뒤를 채운 완전한 주 단위 (4~6주 × 7일).
List<DateTime> calendarDays(DateTime month) {
  final first = firstOfMonth(month);
  final last = DateTime(first.year, first.month + 1, 0);
  final start = mondayOf(first);
  final end = addDays(mondayOf(last), 6);
  return [for (var d = start; !d.isAfter(end); d = addDays(d, 1)) d];
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

/// 둘 다 있을 때 퇴근이 출근보다 이르면 무효. 자정 넘김은 지원하지 않는다.
bool isValidClockRange(DateTime? clockIn, DateTime? clockOut) {
  if (clockIn == null || clockOut == null) return true;
  return !clockOut.isBefore(clockIn);
}

// ---- 주간 ----

/// 첫 기록일이 아직 없으면 오늘을 첫 기록일로 간주한다. 설치 직후 목요일에 "남은 40h"가 뜨지 않도록 —
/// 첫 기록을 찍는 순간 어차피 첫 주 예외가 되므로 그 전부터 같은 모양이어야 한다.
DateTime effectiveFirstRecordDate(DateTime? firstRecordDate, DateTime now) => firstRecordDate ?? dateOnly(now);

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

/// 그 주 토·일 실근무 합. 주 40시간 집계에는 안 들어가고 근거 문구("주말 4h 30m 제외")에만 쓴다.
int weekendMinutes(List<WorkRecord> records, DateTime monday, WorkRules rules) {
  final start = dateOnly(monday);
  var sum = 0;
  for (final r in records) {
    final day = dateOnly(r.date);
    if (!isWeekend(day) || mondayOf(day) != start) continue;
    sum += actualMinutes(r, rules) ?? 0;
  }
  return sum;
}

// ---- 오늘 몫 · 퇴근 예상 (CLAUDE.md "오늘 퇴근 시각 계산") ----

bool _isOff(WorkRecord? r) => r != null && (r.type == WorkType.dayOff || r.type == WorkType.holiday);

/// 이번 주 평일 중 연차·공휴일이 아닌 날. 기록 없는 날은 normal.
List<DateTime> workdaysOfWeek(List<WorkRecord> records, DateTime monday) {
  final byDate = recordsByDate(records);
  return [for (final d in weekdaysOf(monday)) if (!_isOff(byDate[d])) d];
}

/// 오늘 포함, 이번 주 남은 근무일 수 (연차·공휴일 제외). 주말이면 0.
int remainingWorkdays(List<WorkRecord> records, DateTime today) {
  final day = dateOnly(today);
  if (isWeekend(day)) return 0;
  return workdaysOfWeek(records, mondayOf(day)).where((d) => !d.isBefore(day)).length;
}

/// 이번 주 남은 시간 = 주간 목표 − 오늘 이전 평일 실근무. 오늘 진행분은 넣지 않는다 (오늘 몫을 구하는 중이므로).
/// 첫 주 예외·주말이면 null. 0 이하면 이미 채운 것.
int? weekRemainingBeforeToday({
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
  var workedBefore = 0;
  for (final weekday in weekdaysOf(monday)) {
    final r = byDate[weekday];
    reduction += rules.dailyStandardMinutes - standardMinutes(r?.type ?? WorkType.normal, rules);
    if (weekday.isBefore(day) && r != null) workedBefore += actualMinutes(r, rules) ?? 0;
  }
  return rules.weeklyTargetMinutes - reduction - workedBefore;
}

/// 오늘 몫 = 남은 시간 ÷ 남은 근무일 수. 반차인 날은 4h 고정. 마지막 근무일은 남은 시간 전부.
/// 첫 주 예외·주말·연차·공휴일이면 null. 0 이하일 수 있다 (이미 채움).
int? todayShareMinutes({
  required List<WorkRecord> records,
  required DateTime today,
  required WorkRules rules,
  required DateTime? firstRecordDate,
}) {
  final day = dateOnly(today);
  final r = recordsByDate(records)[day];
  if (_isOff(r)) return null;
  if (r?.type == WorkType.halfDay) return rules.halfDayCreditMinutes;
  final remaining = weekRemainingBeforeToday(records: records, today: day, rules: rules, firstRecordDate: firstRecordDate);
  if (remaining == null) return null;
  final days = remainingWorkdays(records, day);
  if (days == 0) return null;
  return (remaining / days).round();
}

/// 오늘이 이번 주 첫 근무일인지 (연차·공휴일 제외). 월요일이 연차면 화요일이 첫 근무일.
bool isFirstWorkday(List<WorkRecord> records, DateTime today) {
  final day = dateOnly(today);
  if (isWeekend(day)) return false;
  final days = workdaysOfWeek(records, mondayOf(day));
  return days.isNotEmpty && days.first == day;
}

/// 오늘이 이번 주 마지막 근무일인지. 금요일이 공휴일이면 목요일이 마지막.
bool isLastWorkday(List<WorkRecord> records, DateTime today) {
  final day = dateOnly(today);
  if (isWeekend(day)) return false;
  final days = workdaysOfWeek(records, mondayOf(day));
  return days.isNotEmpty && days.last == day;
}

/// 퇴근 예상 = 출근 + 오늘 몫 + 점심 공제(해당 시).
DateTime? expectedClockOut(WorkRecord today, int todayShare, WorkRules rules) {
  final clockIn = today.clockIn;
  if (clockIn == null) return null;
  final lunch = deductsLunch(today) ? rules.lunchBreakMinutes : 0;
  return clockIn.add(Duration(minutes: todayShare + lunch));
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

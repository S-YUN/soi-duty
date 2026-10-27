import 'dart:math' as math;

import '../model/app_settings.dart';
import '../model/work_record.dart';
import '../model/work_type.dart';
import 'week_summary.dart';
import 'work_rules.dart';

// ---- 날짜 유틸 ----

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// 초 이하를 버린다. 화면은 분까지만 보이므로 저장·계산도 분 단위로 맞춘다.
DateTime minuteOnly(DateTime d) => DateTime(d.year, d.month, d.day, d.hour, d.minute);

/// 분 단위로 자른 두 시각의 차. 09:10:45 → 11:10:20 이 1h 59m가 아니라 2h가 되게.
int minutesBetween(DateTime from, DateTime to) => minuteOnly(to).difference(minuteOnly(from)).inMinutes;

bool isWeekend(DateTime d) => d.weekday >= DateTime.saturday;

DateTime mondayOf(DateTime d) {
  final day = dateOnly(d);
  return DateTime(day.year, day.month, day.day - (day.weekday - DateTime.monday));
}

DateTime addDays(DateTime d, int n) => DateTime(d.year, d.month, d.day + n);

DateTime firstOfMonth(DateTime d) => DateTime(d.year, d.month);

DateTime addMonths(DateTime month, int n) => DateTime(month.year, month.month + n);

/// 그 날이 속한 주의 시작일. 월요일 시작이면 [mondayOf], 일요일 시작이면 그 날 이전(포함) 가장 가까운 일요일.
DateTime weekStartOf(DateTime d, WeekStart weekStart) => switch (weekStart) {
      WeekStart.monday => mondayOf(d),
      WeekStart.sunday => addDays(dateOnly(d), -(d.weekday % 7)),
    };

/// 앞뒤를 채운 완전한 주 단위 (4~6주 × 7일). 시작 요일은 월간 캘린더 설정 — 주 40시간 계산과 무관하다.
List<DateTime> calendarDays(DateTime month, {WeekStart weekStart = WeekStart.monday}) {
  final first = firstOfMonth(month);
  final last = DateTime(first.year, first.month + 1, 0);
  final start = weekStartOf(first, weekStart);
  final end = addDays(weekStartOf(last, weekStart), 6);
  return [for (var d = start; !d.isAfter(end); d = addDays(d, 1)) d];
}

// ---- 하루 단위 ----

/// 쉬는 날 — 목표에서 하루가 통째로 빠지고 근무일로 세지 않는다.
bool isOffType(WorkType t) => t == WorkType.dayOff || t == WorkType.holiday || t == WorkType.businessTrip;

/// 시간공제를 가질 수 있는 날: 평일 && 일반·반차.
bool canDeduct(DateTime date, WorkType t) => !isWeekend(date) && (t == WorkType.normal || t == WorkType.halfDay);

/// 주 40시간 실적에 들어가는 날. 주말·공휴일 근무는 기록만 되고 빠진다.
bool countsTowardWeek(WorkRecord r) => !isWeekend(r.date) && r.type != WorkType.holiday;

/// 점심 공제 조건: 반차가 아니고, 주말이 아니고, 공휴일이 아닐 것.
bool deductsLunch(WorkRecord r) => r.type != WorkType.halfDay && r.type != WorkType.holiday && !isWeekend(r.date);

/// 유형의 기본 기준시간 (시간공제 전).
int standardMinutes(WorkType type, WorkRules rules) => switch (type) {
      WorkType.normal => rules.dailyStandardMinutes,
      WorkType.halfDay => rules.halfDayCreditMinutes,
      WorkType.businessTrip => math.max(0, rules.dailyStandardMinutes - rules.businessTripCreditMinutes),
      WorkType.dayOff || WorkType.holiday => 0,
    };

/// 그날 기준시간 = 기본 − 시간공제. 기록 없는 평일은 8h.
int dayStandardMinutes(WorkRecord? r, WorkRules rules) {
  if (r == null) return rules.dailyStandardMinutes;
  final deduction = canDeduct(r.date, r.type) ? r.deductionMinutes : 0;
  return math.max(0, standardMinutes(r.type, rules) - deduction);
}

/// 하루 실근무. 점심 공제는 정액이 아니라 **근무 구간이 점심 창(12:00–13:00)과 겹친 만큼**(2026-10-27) —
/// 9~18시는 60분, 14~18시는 0분, 12:30~18시는 30분. 밤에 찍은 10분짜리 근무가 0이 되던 문제를 없앤다.
int? actualMinutes(WorkRecord r, WorkRules rules) {
  if (r.type == WorkType.dayOff || r.type == WorkType.businessTrip) return 0;
  final clockIn = r.clockIn;
  final clockOut = r.clockOut;
  if (clockIn == null || clockOut == null) return r.type == WorkType.holiday ? 0 : null;
  return math.max(0, minutesBetween(clockIn, clockOut) - _lunchOverlap(r, clockIn, clockOut, rules));
}

/// 그 기록의 점심 공제 분(겹친 만큼). 공제 없는 유형·주말은 0, 출퇴근 중 하나라도 없으면 null(모름).
int? lunchMinutes(WorkRecord r, WorkRules rules) {
  final clockIn = r.clockIn;
  final clockOut = r.clockOut;
  if (clockIn == null || clockOut == null) return null;
  return _lunchOverlap(r, clockIn, clockOut, rules);
}

/// [from]~[to]가 [from] 날짜의 점심 창과 겹친 분. 분 단위로 자른 시각끼리 센다.
int _lunchOverlap(WorkRecord r, DateTime from, DateTime to, WorkRules rules) {
  if (!deductsLunch(r)) return 0;
  final (start, end) = lunchWindow(from, rules);
  final a = minuteOnly(from).isAfter(start) ? minuteOnly(from) : start;
  final b = minuteOnly(to).isBefore(end) ? minuteOnly(to) : end;
  return math.max(0, b.difference(a).inMinutes);
}

/// [day]의 점심 창 (시작, 끝).
(DateTime, DateTime) lunchWindow(DateTime day, WorkRules rules) {
  final start = dateOnly(day).add(Duration(minutes: rules.lunchStartMinutes));
  return (start, start.add(Duration(minutes: rules.lunchBreakMinutes)));
}

/// 근무 중인 오늘의 진행분. 오늘이 아니거나 출근·퇴근 조건이 안 맞으면 null.
/// [actualMinutes]와 같은 규칙(점심 창과 겹친 만큼) — 창 전에는 경과가 그대로 오르고, 창 안에서는 멈추고, 창 뒤 출근은 바로 오른다.
/// 퇴근 순간 저장값과 같다.
int? ongoingMinutes(WorkRecord r, DateTime now, WorkRules rules) {
  if (dateOnly(now) != dateOnly(r.date)) return null;
  final clockIn = r.clockIn;
  if (clockIn == null || r.clockOut != null) return null;
  return math.max(0, minutesBetween(clockIn, now) - _lunchOverlap(r, clockIn, now, rules));
}

/// 기준 대비 (실근무 − 그날 기준시간). 주말·공휴일은 기준이 없으므로 null.
int? deltaMinutes(WorkRecord r, WorkRules rules) {
  if (isWeekend(r.date) || r.type == WorkType.holiday) return null;
  final actual = actualMinutes(r, rules);
  if (actual == null) return null;
  return actual - dayStandardMinutes(r, rules);
}

/// "남은 시간 공제하고 퇴근" — 퇴근 순간 기본 기준에서 실근무를 뺀 나머지. 기존 공제는 무시하고 새로 잡는다.
int closingDeduction(WorkRecord r, DateTime clockOut, WorkRules rules) {
  final worked = actualMinutes(r.copyWith(clockOut: clockOut), rules) ?? 0;
  return math.max(0, standardMinutes(r.type, rules) - worked);
}

/// 반차 날은 4h, 일반은 8h까지.
bool isValidDeduction(WorkType type, int minutes, WorkRules rules) =>
    minutes >= 0 && minutes <= standardMinutes(type, rules);

/// 저장 직전 불변식. 쉬는 날·주말은 공제 없음, 공제는 그날 기본 기준(반차 4h)까지, 연차·출장은 시각 없음. 저장소가 모든 저장에서 부른다 — 반차 전환·유형 자동 저장 같은 경로도 한도를 넘지 못한다.
WorkRecord sanitizeRecord(WorkRecord r, WorkRules rules) {
  final deduction =
      canDeduct(r.date, r.type) ? r.deductionMinutes.clamp(0, standardMinutes(r.type, rules)) : 0;
  final dropTimes = r.type == WorkType.dayOff || r.type == WorkType.businessTrip;
  return r.copyWith(
    clockIn: dropTimes ? null : r.clockIn,
    clockOut: dropTimes ? null : r.clockOut,
    deductionMinutes: deduction,
  );
}

/// 오늘 근무 중(출근만 찍힘). 주간·월간에서 탭해도 시트 대신 토스트 — 퇴근은 오늘 화면이 찍는다.
/// 출근 전 오늘은 미래처럼 유형·시간공제만 고르는 시트가 열리고, 퇴근까지 찍힌 오늘은 다른 날처럼 편집한다.
bool isTodayWorking(WorkRecord? record, DateTime date, DateTime today) =>
    dateOnly(date) == dateOnly(today) && record?.clockIn != null && record?.clockOut == null;

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
  var trips = 0;
  var deductions = 0;

  for (final day in weekdaysOf(monday)) {
    final r = byDate[day];
    final type = r?.type ?? WorkType.normal;
    reduction += rules.dailyStandardMinutes - dayStandardMinutes(r, rules);
    if (r != null && canDeduct(r.date, r.type)) deductions += r.deductionMinutes;
    switch (type) {
      case WorkType.halfDay:
        halfDays++;
      case WorkType.dayOff:
        dayOffs++;
      case WorkType.holiday:
        holidays++;
      case WorkType.businessTrip:
        trips++;
      case WorkType.normal:
        break;
    }
    if (r != null && countsTowardWeek(r)) {
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
    businessTripCount: trips,
    deductionMinutes: deductions,
    isFirstWeekException: firstWeek,
  );
}

/// 주 40시간 집계에서 빠지는 근무 — 주말 + 공휴일 근무. 근거 문구에만 쓴다.
int excludedMinutes(List<WorkRecord> records, DateTime monday, WorkRules rules) {
  final start = dateOnly(monday);
  var sum = 0;
  for (final r in records) {
    final day = dateOnly(r.date);
    if (mondayOf(day) != start || countsTowardWeek(r)) continue;
    if (r.clockIn == null || r.clockOut == null) continue;
    sum += actualMinutes(r, rules) ?? 0;
  }
  return sum;
}

// ---- 오늘 몫 · 퇴근 예상 (CLAUDE.md "오늘 퇴근 시각 계산") ----

bool _isOff(WorkRecord? r) => r != null && isOffType(r.type);

/// 이번 주 평일 중 쉬는 날(연차·공휴일·출장)이 아닌 날. 기록 없는 날은 normal.
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
    reduction += rules.dailyStandardMinutes - dayStandardMinutes(r, rules);
    if (weekday.isBefore(day) && r != null && countsTowardWeek(r)) workedBefore += actualMinutes(r, rules) ?? 0;
  }
  return rules.weeklyTargetMinutes - reduction - workedBefore;
}

/// 오늘 몫 = 남은 시간 ÷ 남은 근무일 수 − 오늘 시간공제 (공제는 그날에만). 반차인 날은 4h − 공제 고정.
/// 마지막 근무일은 남은 시간 전부.
/// 첫 주 예외·주말·연차·공휴일이면 null. 0 이하일 수 있다 (이미 채움).
int? todayShareMinutes({
  required List<WorkRecord> records,
  required DateTime today,
  required WorkRules rules,
  required DateTime? firstRecordDate,
}) {
  final day = dateOnly(today);
  final byDate = recordsByDate(records);
  final r = byDate[day];
  if (_isOff(r)) return null;
  final todayDeduction = r?.deductionMinutes ?? 0;
  if (r?.type == WorkType.halfDay) return math.max(0, rules.halfDayCreditMinutes - todayDeduction);
  final remaining = weekRemainingBeforeToday(records: records, today: day, rules: rules, firstRecordDate: firstRecordDate);
  if (remaining == null) return null;
  if (isWeekend(day)) return null;
  final days = workdaysOfWeek(records, mondayOf(day)).where((d) => !d.isBefore(day)).toList();
  if (days.isEmpty) return null;
  // 공제는 그날에만 — 남은 날들의 공제를 되돌려 균등 배분한 뒤 오늘 공제만 뺀다.
  final pending = days.fold<int>(0, (sum, d) => sum + (byDate[d]?.deductionMinutes ?? 0));
  return ((remaining + pending) / days.length).round() - todayDeduction;
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

/// 퇴근 예상 = 출근 + 오늘 몫, 점심 창에 걸리면 창이 끝난 뒤로 밀린다 (창 뒤 출근은 점심 없음, 창 전에 끝나면 없음).
DateTime? expectedClockOut(WorkRecord today, int todayShare, WorkRules rules) {
  final clockIn = today.clockIn;
  if (clockIn == null) return null;
  if (!deductsLunch(today)) return clockIn.add(Duration(minutes: todayShare));
  final (start, end) = lunchWindow(clockIn, rules);
  final from = minuteOnly(clockIn);
  if (!from.isBefore(end)) return clockIn.add(Duration(minutes: todayShare));
  final beforeLunch = math.max(0, start.difference(from).inMinutes);
  if (todayShare <= beforeLunch) return clockIn.add(Duration(minutes: todayShare));
  return end.add(Duration(minutes: todayShare - beforeLunch));
}

// ---- 기록 누락 ----

/// 어제까지의 평일 중 그날 기준시간이 남아 있는데(기록 없음 포함) 출퇴근이 하나라도 빈 날. 오래된 순 —
/// 채우는 순서가 시간 순이고, 오래된 누락일수록 잊히기 쉽다.
///
/// 시작점은 **첫 기록 주 안에 있는 동안은 그 주 월요일, 그 뒤로는 첫 기록일**. 첫 기록 전 날들은 첫 주에만
/// "채워볼래요?"로 보여주고(채우면 첫 기록일이 당겨져 첫 주 예외가 풀린다), 그 주가 지나면 설치 전 날짜로 취급해
/// 더 조르지 않는다 — 첫 주는 목표가 없어 그 날들이 어떤 계산에도 쓰이지 않기 때문이다.
List<DateTime> unrecordedWeekdays({
  required WorkRules rules,
  required List<WorkRecord> records,
  required DateTime today,
  required DateTime? firstRecordDate,
}) {
  if (firstRecordDate == null) return const [];
  final byDate = recordsByDate(records);
  final end = dateOnly(today);
  final result = <DateTime>[];

  final first = dateOnly(firstRecordDate);
  final inFirstWeek = mondayOf(end) == mondayOf(first);
  var cursor = inFirstWeek ? mondayOf(first) : first;
  while (cursor.isBefore(end)) {
    if (!isWeekend(cursor)) {
      final r = byDate[cursor];
      final needsClock = dayStandardMinutes(r, rules) > 0;
      final incomplete = r == null || r.clockIn == null || r.clockOut == null;
      if (needsClock && incomplete) result.add(cursor);
    }
    cursor = DateTime(cursor.year, cursor.month, cursor.day + 1);
  }
  return result;
}

// ---- 월간 카드: 주말·공휴일 수당, 연차 ----

/// 그 달의 주말 근무·평일 공휴일 근무(분). 출퇴근 둘 다 있는 날만 — 근무 중인 오늘은 넣지 않는다.
/// 둘 다 점심 공제가 없다([deductsLunch]). 주 40시간과 무관한 월별 합산.
({int weekendMinutes, int holidayMinutes}) extraWorkMinutesOfMonth(
  List<WorkRecord> records,
  DateTime month,
  WorkRules rules,
) {
  var weekend = 0, holiday = 0;
  for (final r in records) {
    if (r.date.year != month.year || r.date.month != month.month) continue;
    if (r.clockIn == null || r.clockOut == null) continue;
    if (isWeekend(r.date)) {
      weekend += actualMinutes(r, rules) ?? 0;
    } else if (r.type == WorkType.holiday) {
      holiday += actualMinutes(r, rules) ?? 0;
    }
  }
  return (weekendMinutes: weekend, holidayMinutes: holiday);
}

/// 예상 수당(원) = 분 ÷ 60 × 시급 × 배율, 소수점 버림.
int extraPayWon(int minutes, int hourlyWage, WorkRules rules) =>
    (minutes * hourlyWage * rules.extraWorkPayMultiplier / 60).floor();

/// 유형 하나가 연차에서 까는 분. 연차 1일 · 반차 반일 · 그 외 0.
int leaveMinutesOf(WorkType t, WorkRules rules) => switch (t) {
      WorkType.dayOff => rules.dayOffCreditMinutes,
      WorkType.halfDay => rules.halfDayCreditMinutes,
      WorkType.normal || WorkType.holiday || WorkType.businessTrip => 0,
    };

/// 그 해에 쓴(쓸) 연차 분. 미리 찍은 미래 날짜도 포함 — 이미 계획한 날은 더 쓸 수 없는 날이다.
/// [after]가 있으면 그 날짜 **다음 날부터**만 센다(기준일 당일은 회사 숫자에 이미 반영된 것으로 본다). 날짜만 본다.
int leaveMinutesUsed(List<WorkRecord> records, int year, WorkRules rules, {DateTime? after}) {
  final from = after == null ? null : dateOnly(after);
  return records
      .where((r) => r.date.year == year && (from == null || r.date.isAfter(from)))
      .fold(0, (sum, r) => sum + leaveMinutesOf(r.type, rules));
}

/// 남은 연차 입력값 검사 — 0 이상, 99일 이하, 입력 단위(`leaveStepMinutes`)의 배수.
bool isValidLeaveMinutes(int minutes, WorkRules rules) =>
    minutes >= 0 &&
    minutes <= AppSettings.maxLeaveDays * rules.dayOffCreditMinutes &&
    minutes % rules.leaveStepMinutes == 0;

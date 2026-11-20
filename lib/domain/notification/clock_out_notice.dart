import '../model/work_record.dart';
import '../model/work_type.dart';
import '../rules/work_calculator.dart';
import '../rules/work_rules.dart';

/// 퇴근 알림의 종류 — 문구가 갈린다 (핸드오프 6 §10).
enum ClockOutNoticeKind {
  /// N1 — 그날 채울 시간을 다 채웠다
  daily,

  /// N2 — 이번 주 목표를 다 채웠다, 마지막 근무일
  weekly,

  /// N2′ — 이번 주 목표를 다 채웠다, 아직 근무일이 남았다 (드묾)
  weeklyEarly,
}

/// 오늘 보낼 퇴근 알림 하나 — 무엇을([kind]) 언제([at], 앱 시계 기준 · 분 단위).
class ClockOutNotice {
  const ClockOutNotice(this.kind, this.at);

  final ClockOutNoticeKind kind;
  final DateTime at;

  @override
  bool operator ==(Object other) => other is ClockOutNotice && other.kind == kind && other.at == at;

  @override
  int get hashCode => Object.hash(kind, at);

  @override
  String toString() => 'ClockOutNotice(${kind.name} @ $at)';
}

/// 오늘의 퇴근 알림 계획. 알림은 하루 최대 하나이고 **"이제 가도 돼요"** 한 가지 뜻뿐이다 —
/// "아직 남았어요" 알림은 없다(알림이 안 온 것 자체가 "아직"이다).
///
/// ```
/// 근무 중(출근 있음 · 퇴근 없음)이 아니면            → 없음
/// 주말 · 공휴일 근무                                → 없음 (그날 기준이 없다)
/// T기준 = 출근 + 그날 기준시간 (점심 창에 걸리면 창 뒤로)
/// 첫 주 예외 (주간 목표를 모른다)                    → daily @ T기준
/// 출근 전에 이미 이번 주를 채움                      → 없음
/// T주간 = 출근 + 이번 주 남은 시간 (같은 점심 처리)
/// 마지막 근무일                                     → weekly @ T주간 (오늘 안일 때만)
/// T주간 ≤ T기준                                     → weeklyEarly @ T주간
/// 그 외                                             → daily @ T기준
/// ```
///
/// 그날 기준시간이 0(시간공제로 다 빠진 날)이면 daily는 없다 — 채울 게 없는 날 출근하자마자 울리지 않게.
/// 알림 시각이 오늘을 넘기면(자정 뒤) 일일·주간 모두 없다.
/// 시간 출장 범위는 보지 않는다(기록일 뿐이다). 오늘 몫(균등 배분)도 쓰지 않는다 — 알림 시각이 매일 달라져 헷갈린다.
/// [firstRecordDate]는 호출부가 `effectiveFirstRecordDate`를 먼저 적용해 넘긴다.
ClockOutNotice? planClockOutNotice({
  required List<WorkRecord> records,
  required DateTime today,
  required WorkRules rules,
  required DateTime? firstRecordDate,
}) {
  final day = dateOnly(today);
  final record = recordsByDate(records)[day];
  if (record == null || record.clockIn == null || record.clockOut != null) return null;
  if (isWeekend(day) || record.type == WorkType.holiday || isOffType(record.type)) return null;

  final standard = dayStandardMinutes(record, rules);
  final dailyAt = minuteOnly(expectedClockOut(record, standard, rules)!);
  // 자정을 넘기는 시각(16:30 출근 → 다음 날 00:30)은 보내지 않는다 — 날이 바뀌면 앱은 그날을 더는 "근무 중"으로 보지 않는다.
  final daily = standard > 0 && dateOnly(dailyAt) == day ? ClockOutNotice(ClockOutNoticeKind.daily, dailyAt) : null;

  final remaining = weekRemainingBeforeToday(
    records: records,
    today: day,
    rules: rules,
    firstRecordDate: firstRecordDate,
  );
  if (remaining == null) return daily; // 첫 주 예외
  if (remaining <= 0) return null;

  final weeklyAt = minuteOnly(expectedClockOut(record, remaining, rules)!);
  final weeklyIsToday = dateOnly(weeklyAt) == day;
  if (isLastWorkday(records, day)) {
    return weeklyIsToday ? ClockOutNotice(ClockOutNoticeKind.weekly, weeklyAt) : null;
  }
  if (weeklyIsToday && !weeklyAt.isAfter(dailyAt)) return ClockOutNotice(ClockOutNoticeKind.weeklyEarly, weeklyAt);
  return daily;
}

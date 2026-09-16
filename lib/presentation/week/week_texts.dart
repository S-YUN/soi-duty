import '../../core/presentation/format/date_format.dart';
import '../../core/presentation/format/time_format.dart';
import '../../domain/model/work_type.dart';
import '../../domain/rules/work_rules.dart';
import 'week_state.dart';

/// 주간 화면의 모든 문구. 숫자(WeekState) → 문자열은 여기서만.
abstract final class WeekTexts {
  static const dash = '—';
  static const none = '';
  static const _dow = ['월', '화', '수', '목', '금', '토', '일'];

  static String dow(DateTime d) => _dow[d.weekday - DateTime.monday];

  static String summaryLabel(WeekState s) {
    if (s.summary.isFirstWeekException) return '이번 주 기록한 시간';
    return s.isCurrentWeek ? '이번 주 누적' : '주간 누적';
  }

  static String summaryValue(WeekState s) => formatHm(s.summary.workedMinutes);

  /// "/ 36h". 첫 주 예외면 빈 문자열.
  static String summaryGoal(WeekState s) {
    final target = s.summary.targetMinutes;
    return target == null ? none : '/ ${formatHm(target)}';
  }

  static String summaryReason(WeekState s, WorkRules rules) {
    final w = s.summary;
    if (w.isFirstWeekException) {
      final first = s.firstRecordDate;
      return first == null ? '목표 없음' : '${formatDateTitle(first)}부터 기록 · 목표 없음';
    }
    final remaining = w.remainingMinutes ?? 0;
    final parts = <String>[];
    if (s.isCurrentWeek) {
      parts.add(remaining > 0 ? '남은 ${formatHm(remaining)}' : '목표 달성 · ${formatSignedHm(-remaining)}');
    } else if (remaining > 0) {
      parts.add('${formatHm(remaining)} 부족');
    } else if (remaining < 0) {
      parts.add('${formatHm(-remaining)} 초과');
    } else {
      parts.add('딱 맞음');
    }
    if (w.halfDayCount > 0) parts.add('반차 ${w.halfDayCount}회');
    if (w.dayOffCount > 0) {
      parts.add('연차 ${w.dayOffCount}일로 목표 ${formatHm(w.dayOffCount * rules.dayOffCreditMinutes)} 차감');
    }
    if (w.holidayCount > 0) {
      parts.add('공휴일 ${w.holidayCount}일로 목표 ${formatHm(w.holidayCount * rules.dayOffCreditMinutes)} 차감');
    }
    if (s.weekendMinutes > 0) parts.add('주말 ${formatHm(s.weekendMinutes)} 제외');
    return parts.join(' · ');
  }

  /// 진행률 0..1. 첫 주 예외면 null.
  static double? progress(WeekState s) {
    final target = s.summary.targetMinutes;
    if (target == null || target == 0) return null;
    return (s.summary.workedMinutes / target).clamp(0.0, 1.0);
  }

  static String main(WeekDay day) => switch (day.kind) {
        WeekDayKind.recorded || WeekDayKind.weekendRecorded => formatHm(day.actualMinutes ?? 0),
        WeekDayKind.working => '근무 중',
        WeekDayKind.unrecorded || WeekDayKind.partial => '기록 없음',
        WeekDayKind.off || WeekDayKind.future || WeekDayKind.beforeWork || WeekDayKind.weekendEmpty => dash,
      };

  static String note(WeekDay day) {
    final r = day.record;
    switch (day.kind) {
      case WeekDayKind.recorded:
        return formatClockRange(r!.clockIn!, r.clockOut!);
      case WeekDayKind.weekendRecorded:
        return '주 40시간 제외 · ${formatClockRange(r!.clockIn!, r.clockOut!)}';
      case WeekDayKind.working:
        return '${formatClock(r!.clockIn!)} 출근';
      case WeekDayKind.off:
        return '근무 없음';
      case WeekDayKind.unrecorded:
        return '눌러서 입력';
      case WeekDayKind.partial:
        final clockIn = r?.clockIn;
        final clockOut = r?.clockOut;
        return '${clockIn == null ? '출근 없음' : '${formatClock(clockIn)} 출근'} · '
            '${clockOut == null ? '퇴근 없음' : '${formatClock(clockOut)} 퇴근'}';
      case WeekDayKind.beforeWork:
        return '아직 출근 전';
      case WeekDayKind.future || WeekDayKind.weekendEmpty:
        return none;
    }
  }

  /// 우측 값. 기준 대비가 있으면 ±, 평일인데 없으면 "—", 주말·미래는 빈 문자열.
  static String value(WeekDay day) => switch (day.kind) {
        WeekDayKind.recorded => formatSignedHm(day.deltaMinutes ?? 0),
        WeekDayKind.working ||
        WeekDayKind.beforeWork ||
        WeekDayKind.unrecorded ||
        WeekDayKind.partial ||
        WeekDayKind.off =>
          dash,
        WeekDayKind.future || WeekDayKind.weekendRecorded || WeekDayKind.weekendEmpty => none,
      };

  /// 배지. 반차는 kind와 무관하게 record.type으로 (미래 반차 포함).
  static WorkType? badge(WeekDay day) {
    final t = day.record?.type;
    return t == null || t == WorkType.normal ? null : t;
  }

  static String badgeLabel(WorkType t) => switch (t) {
        WorkType.halfDay => '반차',
        WorkType.dayOff => '연차',
        WorkType.holiday => '공휴일',
        WorkType.normal => none,
      };
}

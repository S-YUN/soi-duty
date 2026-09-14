import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/domain/model/work_record.dart';
import 'package:soi_duty/domain/model/work_type.dart';
import 'package:soi_duty/domain/rules/work_rules.dart';
import 'package:soi_duty/presentation/today/today_state.dart';
import 'package:soi_duty/presentation/today/today_state_builder.dart';

import '../helpers/records.dart';

void main() {
  const rules = WorkRules();
  final past = [rec(14, inH: 9, outH: 18), rec(15, inH: 9, outH: 18)];

  TodayState build(List<WorkRecord> records, {DateTime? now, DateTime? first}) => buildTodayState(
        records: records,
        firstRecordDate: first ?? d(7),
        now: now ?? d(16, 12),
        rules: rules,
      );

  test('기록 없음 → 출근 전', () {
    final s = build(past);
    expect(s.date, d(16));
    expect(s.phase, TodayPhase.before);
    expect(s.screenState, TodayScreenState.beforeWork);
    expect(s.record, isNull);
    expect(s.expectedClockOut, isNull);
    expect(s.week.remainingMinutes, 2400 - 960);
  });

  test('출근만 → 근무 중, 경과·퇴근 예상 있음', () {
    final s = build([...past, rec(16, inH: 9, inM: 12)], now: d(16, 16, 27));
    expect(s.phase, TodayPhase.working);
    expect(s.screenState, TodayScreenState.working);
    expect(s.elapsedMinutes, 7 * 60 + 15);
    expect(s.expectedClockOut, d(16, 18, 12)); // 09:12 + 8h + 1h
    expect(s.week.workedMinutes, 960 + (7 * 60 + 15 - 60));
  });

  test('반차 근무 중 → isHalfDay, 퇴근 예상에 점심 없음', () {
    final s = build([...past, rec(16, inH: 9, inM: 12, type: WorkType.halfDay)]);
    expect(s.isHalfDay, isTrue);
    expect(s.expectedClockOut, d(16, 13, 12)); // 09:12 + 4h
  });

  test('출퇴근 모두 → 퇴근 완료, 오늘 실근무·기준 대비', () {
    final s = build([...past, rec(16, inH: 9, inM: 12, outH: 18, outM: 5)], now: d(16, 19));
    expect(s.phase, TodayPhase.done);
    expect(s.screenState, TodayScreenState.done);
    expect(s.todayActual, 8 * 60 + 53 - 60);
    expect(s.todayDelta, -7);
    expect(s.expectedClockOut, isNull);
  });

  test('연차 → dayType 화면', () {
    final s = build([...past, rec(16, type: WorkType.dayOff)]);
    expect(s.phase, TodayPhase.before);
    expect(s.dayType, WorkType.dayOff);
    expect(s.screenState, TodayScreenState.dayType);
    expect(s.week.targetMinutes, 2400 - 480);
  });

  test('첫 주 예외 → isFirstWeek, 목표·퇴근 예상 없음', () {
    final s = build([rec(16, inH: 9, inM: 12)], first: d(16));
    expect(s.isFirstWeek, isTrue);
    expect(s.week.targetMinutes, isNull);
    expect(s.expectedClockOut, isNull);
    expect(s.screenState, TodayScreenState.working);
  });

  test('기록 누락 리스트가 채워진다', () {
    final s = build([rec(14, inH: 9, outH: 18)], now: d(16, 12), first: d(14));
    expect(s.unrecordedDays, [d(15)]);
  });

  test('주말 → isWeekend, 퇴근 예상 없음', () {
    final s = build([rec(19, inH: 10)], now: d(19, 12));
    expect(s.isWeekend, isTrue);
    expect(s.phase, TodayPhase.working);
    expect(s.expectedClockOut, isNull);
  });
}

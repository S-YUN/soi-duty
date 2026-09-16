import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/domain/model/work_record.dart';
import 'package:soi_duty/domain/model/work_type.dart';
import 'package:soi_duty/domain/rules/work_rules.dart';
import 'package:soi_duty/presentation/week/week_state.dart';
import 'package:soi_duty/presentation/week/week_state_builder.dart';

import '../helpers/records.dart';

void main() {
  const rules = WorkRules();
  // 오늘 = 9/16(수) 12:00
  WeekState build(List<WorkRecord> records, {DateTime? monday, DateTime? first, DateTime? now}) => buildWeekState(
        records: records,
        firstRecordDate: first ?? d(7),
        now: now ?? d(16, 12),
        rules: rules,
        monday: monday ?? d(14),
      );

  WeekDay day(WeekState s, int date) => s.days.firstWhere((x) => x.date.day == date);

  test('7일, 월요일부터, 오늘 표시', () {
    final s = build([]);
    expect(s.days.length, 7);
    expect(s.days.first.date, d(14));
    expect(day(s, 16).isToday, isTrue);
    expect(s.isCurrentWeek, isTrue);
  });

  test('kind 판정', () {
    final s = build([
      rec(14, inH: 9, inM: 5, outH: 18, outM: 36),
      rec(15, type: WorkType.holiday),
      rec(16, inH: 9, inM: 12),
      rec(18, type: WorkType.halfDay),
      rec(19, inH: 10, outH: 14, outM: 30),
    ]);
    expect(day(s, 14).kind, WeekDayKind.recorded);
    expect(day(s, 14).actualMinutes, 511);
    expect(day(s, 14).deltaMinutes, 31);
    expect(day(s, 15).kind, WeekDayKind.off);
    expect(day(s, 16).kind, WeekDayKind.working);
    expect(day(s, 17).kind, WeekDayKind.future);
    expect(day(s, 18).kind, WeekDayKind.future); // 미래 반차 — 배지는 record.type으로
    expect(day(s, 18).record?.type, WorkType.halfDay);
    expect(day(s, 19).kind, WeekDayKind.weekendRecorded);
    expect(day(s, 19).actualMinutes, 270);
    expect(day(s, 20).kind, WeekDayKind.weekendEmpty);
  });

  test('과거 미기록·부분 기록·오늘 출근 전', () {
    final s = build([rec(15, inH: 9)]);
    expect(day(s, 14).kind, WeekDayKind.unrecorded);
    expect(day(s, 15).kind, WeekDayKind.partial);
    expect(day(s, 16).kind, WeekDayKind.beforeWork);
  });

  test('지난 주는 미래 없음, 이동 가능', () {
    final s = build([], monday: d(7));
    expect(s.isCurrentWeek, isFalse);
    expect(s.canGoNext, isTrue);
    expect(s.canGoPrev, isFalse); // 첫 기록일 9/7
    expect(day(s, 11).kind, WeekDayKind.unrecorded);
  });

  test('이번 주는 next 불가, 첫 기록 주보다 뒤면 prev 가능', () {
    final s = build([]);
    expect(s.canGoNext, isFalse);
    expect(s.canGoPrev, isTrue);
  });

  test('주말 합과 주간 요약', () {
    final s = build([rec(14, inH: 9, outH: 18), rec(19, inH: 10, outH: 12)]);
    expect(s.weekendMinutes, 120);
    expect(s.summary.workedMinutes, 480);
  });
}

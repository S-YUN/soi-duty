import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/domain/model/work_record.dart';
import 'package:soi_duty/domain/model/work_type.dart';
import 'package:soi_duty/domain/rules/work_rules.dart';
import 'package:soi_duty/presentation/week/week_state.dart';
import 'package:soi_duty/presentation/week/week_state_builder.dart';
import 'package:soi_duty/presentation/week/week_texts.dart';

import '../helpers/records.dart';

void main() {
  const rules = WorkRules();
  WeekState build(List<WorkRecord> records, {DateTime? monday, DateTime? first, DateTime? now}) => buildWeekState(
        records: records,
        firstRecordDate: first ?? d(7),
        now: now ?? d(16, 12),
        rules: rules,
        monday: monday ?? d(14),
      );

  test('이번 주 근거: 남은 시간 · 반차 차감 · 주말 제외', () {
    final s = build([
      rec(14, inH: 9, outH: 18), // 8h
      rec(15, inH: 13, outH: 18, type: WorkType.halfDay), // 5h
      rec(19, inH: 10, outH: 14, outM: 30),
    ]);
    expect(WeekTexts.summaryLabel(s), '이번 주 누적');
    expect(WeekTexts.summaryValue(s), '13h');
    expect(WeekTexts.summaryGoal(s), '/ 36h');
    expect(WeekTexts.summaryReason(s, rules), '남은 23h · 반차 1회 · 주말 4h 30m 제외');
  });

  test('지난 주 부족·초과·딱 맞음', () {
    final short = build([for (var day = 7; day <= 11; day++) rec(day, inH: 9, outH: 17)], monday: d(7));
    expect(WeekTexts.summaryLabel(short), '주간 누적');
    expect(WeekTexts.summaryReason(short, rules), '5h 부족');
    final over = build([for (var day = 7; day <= 11; day++) rec(day, inH: 9, outH: 19)], monday: d(7));
    expect(WeekTexts.summaryReason(over, rules), '5h 초과');
    final exact = build([for (var day = 7; day <= 11; day++) rec(day, inH: 9, outH: 18)], monday: d(7));
    expect(WeekTexts.summaryReason(exact, rules), '딱 맞음');
  });

  test('이번 주 목표 달성', () {
    final s = build([for (var day = 14; day <= 16; day++) rec(day, inH: 8, outH: 23)], now: d(16, 23, 30));
    expect(WeekTexts.summaryReason(s, rules), startsWith('목표 달성 · +'));
  });

  test('첫 주 예외', () {
    final s = build([rec(16, inH: 9)], first: d(16));
    expect(WeekTexts.summaryLabel(s), '이번 주 기록한 시간');
    expect(WeekTexts.summaryGoal(s), '');
    expect(WeekTexts.summaryReason(s, rules), '9월 16일 수요일부터 기록 · 목표 없음');
  });

  test('행 문구', () {
    final s = build([
      rec(14, inH: 9, inM: 5, outH: 18, outM: 36),
      rec(15, type: WorkType.holiday),
      rec(16, inH: 9, inM: 12),
      rec(19, inH: 10, outH: 14, outM: 30),
    ]);
    WeekDay day(int n) => s.days.firstWhere((x) => x.date.day == n);
    expect(WeekTexts.main(day(14)), '8h 31m');
    expect(WeekTexts.note(day(14)), '09:05 – 18:36');
    expect(WeekTexts.value(day(14)), '+31m');
    expect(WeekTexts.main(day(15)), '—');
    expect(WeekTexts.note(day(15)), '근무 없음');
    expect(WeekTexts.main(day(16)), '근무 중');
    expect(WeekTexts.note(day(16)), '09:12 출근');
    expect(WeekTexts.value(day(16)), '—');
    expect(WeekTexts.main(day(17)), '—');
    expect(WeekTexts.value(day(17)), '');
    expect(WeekTexts.note(day(19)), '주 40시간 제외 · 10:00 – 14:30');
    expect(WeekTexts.value(day(19)), '');
  });

  test('부분 기록·미기록·출근 전', () {
    final s = build([rec(15, inH: 9), rec(14, outH: 18)]);
    WeekDay day(int n) => s.days.firstWhere((x) => x.date.day == n);
    expect(WeekTexts.main(day(15)), '기록 없음');
    expect(WeekTexts.note(day(15)), '09:00 출근 · 퇴근 없음');
    expect(WeekTexts.note(day(14)), '출근 없음 · 18:00 퇴근');
    expect(WeekTexts.note(day(16)), '아직 출근 전');
  });
}

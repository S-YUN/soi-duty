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

  test('이번 주: 실적 / 그 주 목표 · 반차 개수 (주말은 실적에 안 들어감)', () {
    final s = build([
      rec(14, inH: 9, outH: 18), // 8h
      rec(15, inH: 13, outH: 18, type: WorkType.halfDay), // 5h
      rec(19, inH: 10, outH: 14, outM: 30),
    ]);
    expect(WeekTexts.summaryLabel(s), '이번 주 근무 통계');
    expect(WeekTexts.summaryValue(s), '13h');
    expect(WeekTexts.summaryGoal(s), '/ 36h');
    expect(WeekTexts.summaryDetail(s), '반차 1');
  });

  test('연·반·공이 다 있으면 연차 · 반차 · 공휴일 순, 없으면 빈 줄', () {
    final s = build([
      rec(14, type: WorkType.dayOff),
      rec(15, inH: 13, outH: 18, type: WorkType.halfDay),
      rec(16, type: WorkType.holiday),
    ]);
    expect(WeekTexts.summaryDetail(s), '연차 1 · 반차 1 · 공휴일 1');
    expect(WeekTexts.summaryGoal(s), '/ 20h');
    final plain = build([for (var day = 7; day <= 11; day++) rec(day, inH: 9, outH: 17)], monday: d(7));
    expect(WeekTexts.summaryLabel(plain), '주간 근무 통계');
    expect(WeekTexts.summaryDetail(plain), '');
  });

  test('첫 주 예외', () {
    final s = build([rec(16, inH: 9)], first: d(16));
    expect(WeekTexts.summaryLabel(s), '이번 주 기록한 시간');
    expect(WeekTexts.summaryGoal(s), '');
    expect(WeekTexts.summaryDetail(s), '9월 16일 수요일부터 기록 · 목표 없음');
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
    expect(WeekTexts.main(day(15)), ''); // 연차·공휴일은 배지만
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

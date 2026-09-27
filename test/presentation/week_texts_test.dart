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

  group('출장 · 시간공제 · 공휴일 근무', () {
    WeekDay dayOf(WeekState s, int date) => s.days.firstWhere((x) => x.date.day == date);

    test('요약 줄: 출장·공제 포함, 0 생략', () {
      final s = build([
        rec(14, type: WorkType.dayOff),
        rec(15, inH: 13, outH: 17, type: WorkType.halfDay),
        rec(16, type: WorkType.holiday),
        rec(17, type: WorkType.businessTrip),
        rec(18, ded: 150),
      ]);
      expect(WeekTexts.summaryDetail(s), '연차 1 · 반차 1 · 공휴일 1 · 출장 1 · 공제 2h 30m');
      expect(WeekTexts.summaryDetail(build([rec(18, ded: 60)])), '공제 1h');
    });

    test('배지: 반차 + 공제, 공휴일 근무는 공휴일만', () {
      final s = build([rec(15, inH: 13, outH: 17, type: WorkType.halfDay, ded: 150), rec(14, inH: 10, outH: 15, type: WorkType.holiday)]);
      expect(WeekTexts.badges(dayOf(s, 15)).map((b) => (b.type, b.label)).toList(), [
        (WorkType.halfDay, '반차'),
        (null, '2h 30m 공제'),
      ]);
      expect(WeekTexts.badges(dayOf(s, 14)).map((b) => b.label).toList(), ['공휴일']);
    });

    test('공휴일 근무 행: 근무시간, 주 40시간 제외 메모, ± 비움', () {
      final s = build([rec(14, inH: 10, outH: 15, type: WorkType.holiday)]);
      final day = dayOf(s, 14);
      expect(WeekTexts.main(day), '5h');
      expect(WeekTexts.note(day), '주 40시간 제외 · 10:00 – 15:00');
      expect(WeekTexts.value(day), '');
    });

    test('잠금 토스트는 한 문구', () => expect(WeekTexts.todayInProgressToast, '오늘 기록은 퇴근한 뒤에 수정할 수 있어요'));
  });

  test('퇴근 안 찍은 지난 공휴일: 출근만 메모 + 공휴일 배지', () {
    final s = build([rec(14, inH: 9, type: WorkType.holiday)]);
    final day = s.days.firstWhere((x) => x.date.day == 14);
    expect(WeekTexts.note(day), '09:00 출근 · 퇴근 없음');
    expect(WeekTexts.badges(day).map((b) => b.label).toList(), ['공휴일']);
  });
}

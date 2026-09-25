import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/domain/model/work_record.dart';
import 'package:soi_duty/domain/model/work_type.dart';
import 'package:soi_duty/domain/rules/work_rules.dart';
import 'package:soi_duty/presentation/month/month_state.dart';
import 'package:soi_duty/presentation/month/month_state_builder.dart';
import 'package:soi_duty/presentation/month/month_texts.dart';

import '../helpers/records.dart';

void main() {
  const rules = WorkRules();
  MonthState build(List<WorkRecord> records, {DateTime? month, DateTime? first}) => buildMonthState(
        records: records,
        firstRecordDate: first ?? DateTime(2026, 8, 20),
        now: d(16, 12),
        rules: rules,
        month: month ?? DateTime(2026, 9),
      );
  MonthCell cell(MonthState s, DateTime date) => s.weeks.expand((w) => w).firstWhere((c) => c.date == date);

  test('2026-09은 5주, 8/31로 시작, 다른 달 표시', () {
    final s = build([]);
    expect(s.weeks.length, 5);
    expect(s.weeks.first.first.date, DateTime(2026, 8, 31));
    expect(cell(s, DateTime(2026, 8, 31)).isCurrentMonth, isFalse);
    expect(cell(s, d(1)).isCurrentMonth, isTrue);
    expect(cell(s, d(16)).isToday, isTrue);
    expect(cell(s, d(16)).isTodayInProgress, isTrue); // 기록 없음
    expect(cell(s, d(15)).isTodayInProgress, isFalse);
  });

  test('값 판정', () {
    final s = build([
      rec(14, inH: 9, inM: 5, outH: 18, outM: 36),
      rec(15, type: WorkType.holiday),
      rec(16, inH: 9, inM: 12),
      rec(9, inH: 13, outH: 18, type: WorkType.halfDay),
      rec(12, inH: 10, outH: 14, outM: 30),
      rec(23, type: WorkType.dayOff),
    ]);
    expect(cell(s, d(14)).value, const MonthCellValue.delta(31));
    expect(cell(s, d(15)).value, const MonthCellValue.none());
    expect(cell(s, d(15)).type, WorkType.holiday);
    expect(cell(s, d(16)).value, const MonthCellValue.working());
    expect(cell(s, d(9)).value, const MonthCellValue.delta(60)); // 반차: 배지 + 기준 대비
    expect(cell(s, d(9)).type, WorkType.halfDay);
    expect(cell(s, d(12)).value, const MonthCellValue.weekendActual(270));
    expect(cell(s, d(10)).value, const MonthCellValue.unrecorded());
    expect(cell(s, d(17)).value, const MonthCellValue.none());
    expect(cell(s, d(17)).isFuture, isTrue);
    expect(cell(s, d(23)).type, WorkType.dayOff);
  });

  test('문구', () {
    expect(MonthTexts.value(const MonthCellValue.delta(-15)), '−15m');
    expect(MonthTexts.value(const MonthCellValue.working()), '···');
    expect(MonthTexts.value(const MonthCellValue.unrecorded()), '—');
    expect(MonthTexts.value(const MonthCellValue.weekendActual(270)), '4h30m');
    expect(MonthTexts.value(const MonthCellValue.delta(232)), '+3h52m'); // 좁은 셀이라 공백 없음
    expect(MonthTexts.value(const MonthCellValue.none()), '');
  });

  test('첫 기록 주 이전은 앱 설치 전 — 값 없음, 편집 불가', () {
    // 첫 기록일 9/17(목) → 편집 가능 범위는 9/14(월)부터
    final s = build([rec(10, inH: 9, outH: 18)], first: d(17));
    expect(cell(s, d(10)).isBeforeFirstWeek, isTrue);
    expect(cell(s, d(10)).value, const MonthCellValue.none()); // 기록이 있어도 안 보여준다
    expect(cell(s, d(14)).isBeforeFirstWeek, isFalse);
    expect(cell(s, d(15)).value, const MonthCellValue.unrecorded());
  });
}

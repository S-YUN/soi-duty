import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/core/presentation/format/time_format.dart';
import 'package:soi_duty/domain/model/app_settings.dart';
import 'package:soi_duty/domain/model/work_record.dart';
import 'package:soi_duty/domain/model/work_type.dart';
import 'package:soi_duty/domain/rules/work_rules.dart';
import 'package:soi_duty/presentation/month/month_state.dart';
import 'package:soi_duty/presentation/month/month_state_builder.dart';
import 'package:soi_duty/presentation/month/month_texts.dart';

import '../helpers/records.dart';

void main() {
  const rules = WorkRules();
  MonthState build(List<WorkRecord> records, {DateTime? month, DateTime? first, AppSettings settings = const AppSettings()}) =>
      buildMonthState(
        records: records,
        firstRecordDate: first ?? DateTime(2026, 8, 20),
        now: d(16, 12),
        rules: rules,
        month: month ?? DateTime(2026, 9),
        settings: settings,
      );
  MonthCell cell(MonthState s, DateTime date) => s.weeks.expand((w) => w).firstWhere((c) => c.date == date);

  test('2026-09은 5주, 8/31로 시작, 다른 달 표시', () {
    final s = build([]);
    expect(s.weeks.length, 5);
    expect(s.weeks.first.first.date, DateTime(2026, 8, 31));
    expect(cell(s, DateTime(2026, 8, 31)).isCurrentMonth, isFalse);
    expect(cell(s, d(1)).isCurrentMonth, isTrue);
    expect(cell(s, d(16)).isToday, isTrue);
    expect(cell(s, d(16)).isTodayWorking, isFalse); // 기록 없음 — 출근 전 오늘은 유형 전용 시트가 열린다
    expect(cell(s, d(15)).isTodayWorking, isFalse);
  });

  test('일요일 시작 — 첫 셀이 일요일, 설치 전 판정은 월요일 기준 그대로', () {
    final s = build([], first: DateTime(2026, 9, 14), settings: const AppSettings(weekStart: WeekStart.sunday));
    expect(s.weeks.first.first.date, DateTime(2026, 8, 30));
    expect(s.weeks.first.first.date.weekday, DateTime.sunday);
    expect(cell(s, DateTime(2026, 9, 13)).isBeforeFirstWeek, isTrue); // 첫 기록 주 월요일(9/14) 앞의 일요일
    expect(cell(s, DateTime(2026, 9, 14)).isBeforeFirstWeek, isFalse);
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
    expect(MonthTexts.value(const MonthCellValue.weekendActual(270)), '4h${narrowSpace}30m');
    expect(MonthTexts.value(const MonthCellValue.delta(232)), '+3h${narrowSpace}52m'); // 좁은 셀이라 얇은 공백
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

  test('공휴일 근무 · 출장 · 공제', () {
    final s = build([
      rec(14, inH: 9, outH: 15, ded: 120), // 실근무 5h, 기준 6h → −1h
      rec(15, inH: 10, outH: 15, type: WorkType.holiday),
      rec(16, inH: 9, type: WorkType.holiday),
      rec(11, type: WorkType.businessTrip),
    ]);
    expect(cell(s, d(14)).value, const MonthCellValue.delta(-60));
    expect(cell(s, d(15)).type, WorkType.holiday);
    expect(cell(s, d(15)).value, const MonthCellValue.weekendActual(300));
    expect(cell(s, d(16)).value, const MonthCellValue.working());
    expect(cell(s, d(16)).isTodayWorking, isTrue);
    expect(cell(s, d(11)).type, WorkType.businessTrip);
    expect(cell(s, d(11)).value, const MonthCellValue.none());
  });

  test('범례에 출장, 잠금 토스트는 한 문구', () {
    expect(MonthTexts.legend.map((e) => e.$2).toList(), ['반차', '연차', '공휴일', '출장']);
    expect(MonthTexts.todayInProgressToast, '오늘 기록은 퇴근한 뒤에 수정할 수 있어요');
  });

  test('공제로 기준이 0이 된 날은 미기록 표시 없음', () {
    final s = build([rec(14, ded: 480)]);
    expect(cell(s, d(14)).value, const MonthCellValue.none());
  });

  test('퇴근을 안 찍은 지난 공휴일은 — 표시, 기록 안 된 날 목록엔 없다', () {
    final s = build([rec(14, inH: 9, type: WorkType.holiday)]);
    expect(cell(s, d(14)).value, const MonthCellValue.unrecorded());
  });

  group('월간 카드 데이터', () {
    test('수당 카드 — 주말·공휴일 근무 없는 달은 null, 있으면 분과 (시급 있을 때) 금액', () {
      expect(build([rec(14, inH: 9, outH: 18)]).extraWork, isNull);
      final rs = [rec(19, inH: 9, outH: 14), rec(15, inH: 9, outH: 13, type: WorkType.holiday)];
      expect(build(rs).extraWork, const MonthExtraWork(weekendMinutes: 300, holidayMinutes: 240, payWon: null));
      expect(
        build(rs, settings: const AppSettings(hourlyWage: 12500)).extraWork,
        const MonthExtraWork(weekendMinutes: 300, holidayMinutes: 240, payWon: 168750),
      );
    });

    test('연차 카드 — 총 연차 없고 사용 0이면 null, 사용만 있으면 total null·remaining null', () {
      expect(build([]).leave, isNull);
      expect(
        build([rec(14, type: WorkType.dayOff)]).leave,
        const MonthLeave(year: 2026, totalDays: null, usedHalfDays: 2, plannedHalfDays: 0, remainingHalfDays: null),
      );
      expect(
        build([], settings: const AppSettings(annualLeaveDaysByYear: {2026: 15})).leave,
        const MonthLeave(year: 2026, totalDays: 15, usedHalfDays: 0, plannedHalfDays: 0, remainingHalfDays: 30),
      );
    });

    test('연차 카드 — 총 6일에 사용 7.5일이면 remainingHalfDays == -3', () {
      final rs = [for (final day in [1, 2, 3, 4, 7, 8, 9]) rec(day, type: WorkType.dayOff), rec(10, inH: 9, outH: 13, type: WorkType.halfDay)];
      final leave = build(rs, settings: const AppSettings(annualLeaveDaysByYear: {2026: 6})).leave!;
      expect(leave.usedHalfDays, 15);
      expect(leave.remainingHalfDays, -3);
    });

    test('연차 카드 — 2027-01이면 year 2027, 총 연차는 2027 키, 2026년 사용분은 빠진다', () {
      final rs = [rec(14, type: WorkType.dayOff), WorkRecord(date: DateTime(2027, 1, 5), type: WorkType.halfDay)];
      const settings = AppSettings(annualLeaveDaysByYear: {2026: 15});
      expect(
        build(rs, month: DateTime(2027, 1), settings: settings).leave,
        const MonthLeave(year: 2027, totalDays: null, usedHalfDays: 1, plannedHalfDays: 1, remainingHalfDays: null),
      );
      expect(
        build(rs, month: DateTime(2027, 1), settings: settings.withAnnualLeaveDays(2027, 16)).leave!.remainingHalfDays,
        31,
      );
    });

    test('연차 카드 — plannedHalfDays는 오늘 이후 연차·반차만 (오늘 9/16)', () {
      final rs = [rec(14, type: WorkType.dayOff), rec(16, type: WorkType.dayOff), rec(17, type: WorkType.halfDay), rec(24, type: WorkType.dayOff)];
      final leave = build(rs).leave!;
      expect(leave.usedHalfDays, 7);
      expect(leave.plannedHalfDays, 3);
    });
  });
}

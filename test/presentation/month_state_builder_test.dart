import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/core/presentation/format/time_format.dart';
import 'package:soi_duty/domain/model/app_settings.dart';
import 'package:soi_duty/domain/model/leave_balance.dart';
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
    test('수당 카드 — 항상 있다. 근무 없으면 0, 시급 없으면 payWon null, 시급 있으면 0원도 숫자', () {
      expect(build([rec(14, inH: 9, outH: 18)]).extraWork, const MonthExtraWork(weekendMinutes: 0, holidayMinutes: 0, payWon: null));
      expect(
        build([rec(14, inH: 9, outH: 18)], settings: const AppSettings(hourlyWage: 12500)).extraWork,
        const MonthExtraWork(weekendMinutes: 0, holidayMinutes: 0, payWon: 0),
      );
      final rs = [rec(19, inH: 9, outH: 14), rec(15, inH: 9, outH: 13, type: WorkType.holiday)];
      expect(build(rs).extraWork, const MonthExtraWork(weekendMinutes: 300, holidayMinutes: 240, payWon: null));
      expect(
        build(rs, settings: const AppSettings(hourlyWage: 12500)).extraWork,
        const MonthExtraWork(weekendMinutes: 300, holidayMinutes: 240, payWon: 168750),
      );
    });

    test('연차 카드 — 미입력이면 올해 전체 사용, 잔여 null', () {
      expect(build([]).leave, const MonthLeave(year: 2026, balance: null, usedMinutes: 0, plannedMinutes: 0, remainingMinutes: null, dayMinutes: 480));
      expect(
        build([rec(14, type: WorkType.dayOff), rec(18, type: WorkType.halfDay)]).leave,
        const MonthLeave(year: 2026, balance: null, usedMinutes: 720, plannedMinutes: 240, remainingMinutes: null, dayMinutes: 480),
      );
    });

    test('연차 카드 — 값 있음: 기준일 다음 날부터만 빼고, 예정은 오늘 뒤', () {
      final b = LeaveBalance(remainingMinutes: 4080, baseDate: DateTime(2026, 9, 14));
      final leave = build(
        [rec(14, type: WorkType.dayOff), rec(15, type: WorkType.halfDay), rec(18, type: WorkType.dayOff)],
        settings: AppSettings(leaveBalanceByYear: {2026: b}),
      ).leave;
      expect(leave.balance, b);
      expect(leave.usedMinutes, 720); // 14일은 기준일 당일 → 제외, 15 반차 + 18 연차
      expect(leave.plannedMinutes, 480); // 18일만 오늘(16) 뒤
      expect(leave.remainingMinutes, 4080 - 720);
    });

    test('연차 카드 — 초과면 잔여 음수', () {
      final b = LeaveBalance(remainingMinutes: 240, baseDate: DateTime(2026, 9, 1));
      expect(build([rec(14, type: WorkType.dayOff)], settings: AppSettings(leaveBalanceByYear: {2026: b})).leave.remainingMinutes, -240);
    });

    test('연차 카드 — 기준일이 오늘보다 뒤여도 예정은 기준일 뒤만', () {
      final b = LeaveBalance(remainingMinutes: 4080, baseDate: DateTime(2026, 9, 20));
      final leave = build([rec(18, type: WorkType.dayOff), rec(24, type: WorkType.dayOff)], settings: AppSettings(leaveBalanceByYear: {2026: b})).leave;
      expect(leave.usedMinutes, 480);
      expect(leave.plannedMinutes, 480);
    });

    test('연차 카드 — 12월에 1월 카드에서 넣은 값: 해 2027, 기준일 2026-12-20, 2027 기록은 전부 이후, 2026 기록은 제외', () {
      final b = LeaveBalance(remainingMinutes: 7200, baseDate: DateTime(2026, 12, 20));
      final leave = build(
        [rec(28, type: WorkType.dayOff), WorkRecord(date: DateTime(2027, 1, 5), type: WorkType.dayOff)],
        month: DateTime(2027, 1),
        settings: AppSettings(leaveBalanceByYear: {2027: b}),
      ).leave;
      expect(leave.year, 2027);
      expect(leave.usedMinutes, 480);
      expect(leave.plannedMinutes, 480);
      expect(leave.remainingMinutes, 7200 - 480);
      // 2026 값만 있으면 2027 카드는 미입력
      expect(build([], month: DateTime(2027, 1), settings: AppSettings(leaveBalanceByYear: {2026: b})).leave.balance, isNull);
    });
  });
}

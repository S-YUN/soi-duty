import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/domain/model/work_record.dart';
import 'package:soi_duty/domain/model/work_type.dart';
import 'package:soi_duty/domain/rules/week_summary.dart';
import 'package:soi_duty/domain/rules/work_calculator.dart';
import 'package:soi_duty/domain/rules/work_rules.dart';

import '../helpers/records.dart';

const rules = WorkRules();

void main() {
  group('날짜 유틸', () {
    test('isWeekend', () {
      expect(isWeekend(d(18)), isFalse); // 금
      expect(isWeekend(d(19)), isTrue); // 토
      expect(isWeekend(d(20)), isTrue); // 일
    });

    test('mondayOf', () {
      expect(mondayOf(d(16, 13, 30)), d(14));
      expect(mondayOf(d(14)), d(14));
      expect(mondayOf(d(20)), d(14));
    });

    test('dateOnly', () {
      expect(dateOnly(d(16, 13, 30)), d(16));
    });
  });

  group('점심 공제', () {
    test('일반 평일은 공제', () => expect(deductsLunch(rec(14)), isTrue));
    test('반차는 공제 없음', () => expect(deductsLunch(rec(14, type: WorkType.halfDay)), isFalse));
    test('주말은 공제 없음', () => expect(deductsLunch(rec(19)), isFalse));
  });

  group('standardMinutes', () {
    test('유형별 기준시간', () {
      expect(standardMinutes(WorkType.normal, rules), 480);
      expect(standardMinutes(WorkType.halfDay, rules), 240);
      expect(standardMinutes(WorkType.dayOff, rules), 0);
      expect(standardMinutes(WorkType.holiday, rules), 0);
    });
  });

  group('actualMinutes', () {
    test('일반: 퇴근 − 출근 − 60분', () {
      expect(actualMinutes(rec(14, inH: 9, outH: 18), rules), 480);
    });
    test('반차: 점심 공제 없음', () {
      expect(actualMinutes(rec(14, inH: 9, outH: 13, type: WorkType.halfDay), rules), 240);
    });
    test('주말: 점심 공제 없음', () {
      expect(actualMinutes(rec(19, inH: 10, outH: 14), rules), 240);
    });
    test('연차·공휴일은 출퇴근과 무관하게 0', () {
      expect(actualMinutes(rec(14, type: WorkType.dayOff), rules), 0);
      expect(actualMinutes(rec(14, inH: 9, outH: 18, type: WorkType.holiday), rules), 0);
    });
    test('출퇴근 중 하나라도 없으면 null', () {
      expect(actualMinutes(rec(14, inH: 9), rules), isNull);
      expect(actualMinutes(rec(14, outH: 18), rules), isNull);
      expect(actualMinutes(rec(14), rules), isNull);
    });
    test('공제 후 음수면 0', () {
      expect(actualMinutes(rec(14, inH: 9, outH: 9, outM: 30), rules), 0);
    });
  });

  group('ongoingMinutes', () {
    test('오늘 출근만 찍었으면 현재까지 − 점심', () {
      expect(ongoingMinutes(rec(14, inH: 9), d(14, 12), rules), 120);
    });
    test('점심 공제 전이면 0', () {
      expect(ongoingMinutes(rec(14, inH: 9), d(14, 9, 30), rules), 0);
    });
    test('반차면 점심 공제 없음', () {
      expect(ongoingMinutes(rec(14, inH: 9, type: WorkType.halfDay), d(14, 12), rules), 180);
    });
    test('오늘이 아니면 null (과거 미완 기록은 진행분이 아님)', () {
      expect(ongoingMinutes(rec(14, inH: 9), d(15, 12), rules), isNull);
    });
    test('퇴근 찍었으면 null', () {
      expect(ongoingMinutes(rec(14, inH: 9, outH: 18), d(14, 19), rules), isNull);
    });
    test('출근 안 찍었으면 null', () {
      expect(ongoingMinutes(rec(14), d(14, 12), rules), isNull);
    });
  });

  group('deltaMinutes', () {
    test('일반: 실근무 − 8h', () {
      expect(deltaMinutes(rec(14, inH: 9, inM: 12, outH: 18, outM: 5), rules), -7);
    });
    test('반차: 실근무 − 4h', () {
      expect(deltaMinutes(rec(14, inH: 9, outH: 13, outM: 10, type: WorkType.halfDay), rules), 10);
    });
    test('주말은 기준 대비 없음', () {
      expect(deltaMinutes(rec(19, inH: 10, outH: 14), rules), isNull);
    });
    test('실근무 없으면 null', () {
      expect(deltaMinutes(rec(14, inH: 9), rules), isNull);
    });
  });

  group('isFirstWeekException', () {
    test('첫 기록일이 이번 주 수요일이면 예외', () {
      expect(isFirstWeekException(d(14), d(16)), isTrue);
    });
    test('첫 기록일이 이번 주 월요일이면 정상', () {
      expect(isFirstWeekException(d(14), d(14)), isFalse);
    });
    test('첫 기록일이 지난 주면 정상 (예외는 그 주만)', () {
      expect(isFirstWeekException(d(14), d(9)), isFalse);
    });
    test('첫 기록일이 없으면 정상', () {
      expect(isFirstWeekException(d(14), null), isFalse);
    });
  });

  group('weekSummary', () {
    WeekSummary week(List<WorkRecord> records, {DateTime? now, DateTime? first}) => weekSummary(
          records: records,
          monday: d(14),
          rules: rules,
          now: now ?? d(18, 23),
          firstRecordDate: first ?? d(7),
        );

    test('평일 5일 전부 일반이면 목표 40h', () {
      final s = week([for (var day = 14; day <= 18; day++) rec(day, inH: 9, outH: 18)]);
      expect(s.targetMinutes, 2400);
      expect(s.workedMinutes, 2400);
      expect(s.remainingMinutes, 0);
    });

    test('반차·연차·공휴일이 섞이면 목표에서 차감', () {
      final s = week([
        rec(14, inH: 9, outH: 18),
        rec(15, inH: 9, outH: 13, type: WorkType.halfDay),
        rec(16, type: WorkType.dayOff),
        rec(17, type: WorkType.holiday),
        rec(18, inH: 9, outH: 18),
      ]);
      expect(s.targetMinutes, 2400 - 240 - 480 - 480);
      expect(s.halfDayCount, 1);
      expect(s.dayOffCount, 1);
      expect(s.holidayCount, 1);
      expect(s.workedMinutes, 480 + 240 + 0 + 0 + 480);
    });

    test('미리 찍은 미래 반차·연차도 그 주 목표에 바로 반영된다 (월요일 시점, 금요일 반차)', () {
      final s = week([rec(14, inH: 9, outH: 18), rec(18, type: WorkType.halfDay)], now: d(14, 19));
      expect(s.targetMinutes, 2400 - 240); // 36h
      expect(s.remainingMinutes, 2160 - 480);
      expect(s.halfDayCount, 1);
    });

    test('기록이 없는 평일은 normal로 간주해 목표 8h 유지', () {
      final s = week([rec(14, inH: 9, outH: 18), rec(15, inH: 9, outH: 18)]);
      expect(s.targetMinutes, 2400);
      expect(s.workedMinutes, 960);
      expect(s.remainingMinutes, 1440);
    });

    test('주말 근무는 실적에도 목표에도 안 들어감', () {
      final s = week([rec(14, inH: 9, outH: 18), rec(19, inH: 10, outH: 14)]);
      expect(s.targetMinutes, 2400);
      expect(s.workedMinutes, 480);
    });

    test('근무 중인 오늘의 진행분 포함', () {
      final s = week([rec(14, inH: 9, outH: 18), rec(15, inH: 9)], now: d(15, 12));
      expect(s.workedMinutes, 480 + 120);
    });

    test('출퇴근이 빈 과거 기록은 0으로 집계 (목표는 그대로 8h)', () {
      final s = week([rec(14, inH: 9)], now: d(18, 23));
      expect(s.workedMinutes, 0);
      expect(s.targetMinutes, 2400);
    });

    test('첫 주 예외면 목표·잔여 없이 실적만', () {
      final s = week([rec(16, inH: 9, outH: 18), rec(17, inH: 9, outH: 18)], first: d(16));
      expect(s.isFirstWeekException, isTrue);
      expect(s.targetMinutes, isNull);
      expect(s.remainingMinutes, isNull);
      expect(s.workedMinutes, 960);
    });

    test('다른 주의 기록은 무시', () {
      final s = week([rec(7, inH: 9, outH: 18), rec(14, inH: 9, outH: 18)]);
      expect(s.workedMinutes, 480);
    });

    test('weeklyTargetMinutes가 기본값과 다르면 목표에 반영된다', () {
      const customRules = WorkRules(weeklyTargetMinutes: 2100); // 35h
      final s = weekSummary(
        records: [for (var day = 14; day <= 18; day++) rec(day, inH: 9, outH: 18)],
        monday: d(14),
        rules: customRules,
        now: d(18, 23),
        firstRecordDate: d(7),
      );
      expect(s.targetMinutes, 2100);
    });
  });

  group('todayShareMinutes (CLAUDE.md 오늘 퇴근 시각 계산)', () {
    int? share(List<WorkRecord> records, int day, {DateTime? first}) => todayShareMinutes(
          records: records,
          today: d(day),
          rules: rules,
          firstRecordDate: first ?? d(7),
        );

    test('앞선 날이 정확히 8h씩이면 오늘 몫 8h', () {
      expect(share([rec(14, inH: 9, outH: 18), rec(15, inH: 9, outH: 18), rec(16, inH: 9)], 16), 480);
    });

    test('앞선 날 초과분을 남은 근무일에 나눠 오늘 몫이 줄어든다', () {
      // 월 9h → 1h 초과, 수·목·금 3일 → 20분씩 → 수 7h 40m
      expect(share([rec(14, inH: 9, outH: 19), rec(15, inH: 9, outH: 18), rec(16, inH: 9)], 16), 460);
    });

    test('앞선 날 부족분을 남은 근무일에 나눠 오늘 몫이 늘어난다', () {
      // 월 7h → 1h 부족 → 수 8h 20m
      expect(share([rec(14, inH: 9, outH: 17), rec(15, inH: 9, outH: 18), rec(16, inH: 9)], 16), 500);
    });

    test('오늘이 반차면 4h 고정', () {
      final r = [rec(14, inH: 9, outH: 19), rec(15, inH: 9, outH: 18), rec(16, inH: 9, type: WorkType.halfDay)];
      expect(share(r, 16), 240);
    });

    test('남은 평일에 연차가 있으면 일수에서 빠진다', () {
      // 목 연차 → 목표 1920, 월·화 960 → 남은 960을 수·금 2일로 → 480
      final r = [rec(14, inH: 9, outH: 18), rec(15, inH: 9, outH: 18), rec(16, inH: 9), rec(17, type: WorkType.dayOff)];
      expect(share(r, 16), 480);
      expect(remainingWorkdays(r, d(16)), 2);
    });

    test('마지막 평일(금)은 남은 시간 전부', () {
      final r = [for (var day = 14; day <= 17; day++) rec(day, inH: 9, outH: 17, outM: 30), rec(18, inH: 9)];
      // 월~목 각 7.5h = 1800 → 2400 − 1800 = 600
      expect(share(r, 18), 600);
    });

    test('이미 채웠으면 0 이하', () {
      // 월·화 0:00–23:59 → 각 22h 59m → 45h 58m ≥ 40h
      final r = [rec(14, inH: 0, outH: 23, outM: 59), rec(15, inH: 0, outH: 23, outM: 59), rec(16, inH: 9)];
      expect(share(r, 16), lessThanOrEqualTo(0));
      expect(weekRemainingBeforeToday(records: r, today: d(16), rules: rules, firstRecordDate: d(7)), lessThanOrEqualTo(0));
    });

    test('오늘의 진행분은 계산에서 제외', () {
      final r = [rec(14, inH: 9, outH: 18), rec(15, inH: 9, outH: 18), rec(16, inH: 9, outH: 12)];
      expect(share(r, 16), 480);
    });

    test('오늘이 연차·첫 주 예외·주말이면 null', () {
      expect(share([rec(16, type: WorkType.dayOff)], 16), isNull);
      expect(share([rec(16, inH: 9)], 16, first: d(16)), isNull);
      expect(share([rec(19, inH: 9)], 19), isNull);
    });
  });

  group('첫·마지막 근무일', () {
    test('월요일이 첫 근무일, 금요일이 마지막', () {
      expect(isFirstWorkday([], d(14)), isTrue);
      expect(isFirstWorkday([], d(15)), isFalse);
      expect(isLastWorkday([], d(18)), isTrue);
      expect(isLastWorkday([], d(17)), isFalse);
    });
    test('월요일이 연차면 화요일이 첫 근무일, 금요일이 공휴일이면 목요일이 마지막', () {
      final r = [rec(14, type: WorkType.dayOff), rec(18, type: WorkType.holiday)];
      expect(isFirstWorkday(r, d(15)), isTrue);
      expect(isFirstWorkday(r, d(14)), isFalse);
      expect(isLastWorkday(r, d(17)), isTrue);
      expect(isLastWorkday(r, d(18)), isFalse);
    });
    test('주말은 둘 다 아니다', () {
      expect(isFirstWorkday([], d(19)), isFalse);
      expect(isLastWorkday([], d(20)), isFalse);
    });
  });

  group('expectedClockOut', () {
    test('일반: 출근 + 오늘 목표 + 점심', () {
      expect(expectedClockOut(rec(16, inH: 9, inM: 12), 420, rules), d(16, 17, 12));
    });
    test('반차: 점심 없음', () {
      expect(expectedClockOut(rec(16, inH: 9, inM: 12, type: WorkType.halfDay), 240, rules), d(16, 13, 12));
    });
    test('출근 없으면 null', () {
      expect(expectedClockOut(rec(16), 480, rules), isNull);
    });
  });

  group('unrecordedWeekdays', () {
    test('첫 기록일부터 어제까지의 평일 중 비거나 불완전한 날, 최신순', () {
      final r = [
        rec(7, inH: 9, outH: 18),
        rec(8, inH: 9, outH: 18),
        rec(10, inH: 9), // 퇴근 누락
        rec(14, inH: 9, outH: 18),
        rec(16, inH: 9), // 오늘, 대상 아님
      ];
      expect(
        unrecordedWeekdays(records: r, today: d(16), firstRecordDate: d(7)),
        [d(15), d(11), d(10), d(9)],
      );
    });

    test('주말은 대상이 아니다', () {
      final r = [rec(11, inH: 9, outH: 18), rec(14, inH: 9, outH: 18)];
      expect(unrecordedWeekdays(records: r, today: d(15), firstRecordDate: d(11)), isEmpty);
    });

    test('연차·공휴일은 출퇴근이 없어도 누락이 아니다', () {
      final r = [rec(14, type: WorkType.dayOff), rec(15, type: WorkType.holiday)];
      expect(unrecordedWeekdays(records: r, today: d(16), firstRecordDate: d(14)), isEmpty);
    });

    test('첫 기록일 이전은 대상이 아니다', () {
      // 첫 기록일이 16이면 14·15는 비어 있어도 대상이 아니다.
      expect(unrecordedWeekdays(records: [rec(16, inH: 9, outH: 18)], today: d(17), firstRecordDate: d(16)), isEmpty);
    });

    test('첫 기록일이 없으면 빈 리스트', () {
      expect(unrecordedWeekdays(records: const [], today: d(16), firstRecordDate: null), isEmpty);
    });
  });

  group('isValidClockRange', () {
    test('둘 중 하나라도 없으면 유효', () {
      expect(isValidClockRange(null, null), isTrue);
      expect(isValidClockRange(d(14, 9), null), isTrue);
    });
    test('퇴근 < 출근이면 무효, 같으면 유효', () {
      expect(isValidClockRange(d(14, 22), d(14, 2)), isFalse);
      expect(isValidClockRange(d(14, 9), d(14, 9)), isTrue);
    });
  });

  group('weekendMinutes', () {
    test('그 주 토·일 실근무 합, 점심 공제 없음', () {
      final records = [
        rec(14, inH: 9, outH: 18),
        rec(19, inH: 10, outH: 14, outM: 30), // 토
        rec(20, inH: 10, outH: 11), // 일
        rec(12, inH: 10, outH: 12), // 지난주 토
      ];
      expect(weekendMinutes(records, d(14), rules), 270 + 60);
    });
  });

  group('calendarDays', () {
    test('2026-09: 8/31(월)부터 10/4(일)까지 5주', () {
      final days = calendarDays(DateTime(2026, 9));
      expect(days.length, 35);
      expect(days.first, DateTime(2026, 8, 31));
      expect(days.last, DateTime(2026, 10, 4));
    });
    test('2026-02: 2/1이 일요일 → 1/26부터, 5주', () {
      final days = calendarDays(DateTime(2026, 2));
      expect(days.first, DateTime(2026, 1, 26));
      expect(days.length, 35);
    });
    test('2026-08: 6주', () => expect(calendarDays(DateTime(2026, 8)).length, 42));
    test('2027-02: 2/1 월요일, 28일 → 딱 4주', () => expect(calendarDays(DateTime(2027, 2)).length, 28));
  });

  test('isTodayInProgress: 오늘이고 출퇴근이 덜 찍혔을 때만', () {
    expect(isTodayInProgress(null, d(16), d(16, 12)), isTrue);
    expect(isTodayInProgress(rec(16, inH: 9), d(16), d(16, 12)), isTrue);
    expect(isTodayInProgress(rec(16, type: WorkType.dayOff), d(16), d(16, 12)), isTrue);
    expect(isTodayInProgress(rec(16, inH: 9, outH: 18), d(16), d(16, 12)), isFalse);
    expect(isTodayInProgress(null, d(15), d(16, 12)), isFalse); // 어제
    expect(isTodayInProgress(null, d(17), d(16, 12)), isFalse); // 내일
  });

  test('addMonths는 해를 넘긴다', () {
    expect(addMonths(DateTime(2026, 12), 1), DateTime(2027, 1));
    expect(addMonths(DateTime(2026, 1), -1), DateTime(2025, 12));
  });
}

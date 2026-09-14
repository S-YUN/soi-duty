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
  });
}

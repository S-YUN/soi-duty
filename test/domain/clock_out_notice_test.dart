import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/domain/model/work_record.dart';
import 'package:soi_duty/domain/model/work_type.dart';
import 'package:soi_duty/domain/notification/clock_out_notice.dart';
import 'package:soi_duty/domain/rules/work_rules.dart';

import '../helpers/records.dart';

/// 2026-09-14(월) ~ 18(금) 주. 앞선 날은 따로 말하지 않으면 9–18시(8h).
void main() {
  const rules = WorkRules();

  ClockOutNotice? plan(List<WorkRecord> records, int today, {DateTime? first}) => planClockOutNotice(
        records: records,
        today: d(today, 23), // 시각은 쓰이지 않는다 — 날짜만
        rules: rules,
        firstRecordDate: first ?? d(7),
      );
  List<WorkRecord> full(Iterable<int> days) => [for (final day in days) rec(day, inH: 9, outH: 18)];
  ClockOutNotice daily(int day, int h, [int m = 0]) => ClockOutNotice(ClockOutNoticeKind.daily, d(day, h, m));
  ClockOutNotice weekly(int day, int h, [int m = 0]) => ClockOutNotice(ClockOutNoticeKind.weekly, d(day, h, m));
  ClockOutNotice early(int day, int h, [int m = 0]) => ClockOutNotice(ClockOutNoticeKind.weeklyEarly, d(day, h, m));

  group('일일 알림 (N1) — 그날 기준시간을 채우는 시각', () {
    test('일반 08:30 출근 → 17:30 (점심 창을 지나간다)', () {
      expect(plan([...full([14, 15]), rec(16, inH: 8, inM: 30)], 16), daily(16, 17, 30));
    });

    test('점심 창 뒤 13:30 출근 → 21:30 (점심 없음)', () {
      expect(plan([...full([14, 15]), rec(16, inH: 13, inM: 30)], 16), daily(16, 21, 30));
    });

    test('점심 창 안 12:30 출근 → 21:00 (창이 끝난 뒤부터 8h)', () {
      expect(plan([...full([14, 15]), rec(16, inH: 12, inM: 30)], 16), daily(16, 21));
    });

    test('반차 08:30 → 12:30 (4h, 점심 공제 없음)', () {
      expect(plan([...full([14, 15]), rec(16, inH: 8, inM: 30, type: WorkType.halfDay)], 16), daily(16, 12, 30));
    });

    test('시간공제 2h, 09:00 → 16:00', () {
      expect(plan([...full([14, 15]), rec(16, inH: 9, ded: 120)], 16), daily(16, 16));
    });

    test('반차 + 공제 1h, 13:00 → 16:00', () {
      expect(plan([...full([14, 15]), rec(16, inH: 13, type: WorkType.halfDay, ded: 60)], 16), daily(16, 16));
    });

    test('공제로 그날 기준이 0이면 없다 — 채울 게 없는 날 출근하자마자 울리지 않는다', () {
      expect(plan([...full([14, 15]), rec(16, inH: 9, ded: 480)], 16), isNull);
      expect(plan([...full([14, 15]), rec(16, inH: 13, type: WorkType.halfDay, ded: 240)], 16), isNull);
    });

    test('시간 출장은 알림 시각을 바꾸지 않는다', () {
      final without = plan([...full([14, 15]), rec(16, inH: 9)], 16);
      final withTrip = plan([...full([14, 15]), rec(16, inH: 9, tripInH: 9, tripOutH: 12)], 16);
      expect(withTrip, without);
      expect(without, daily(16, 18));
    });

    test('앞선 날 초과·부족은 일일 알림 시각을 바꾸지 않는다 — 오늘 몫(균등 배분)을 쓰지 않는다', () {
      final over = plan([rec(14, inH: 9, outH: 20), rec(15, inH: 9, outH: 18), rec(16, inH: 9)], 16);
      final under = plan([rec(14, inH: 9, outH: 16), rec(15, inH: 9, outH: 18), rec(16, inH: 9)], 16);
      expect(over, daily(16, 18));
      expect(under, daily(16, 18));
    });

    test('월요일(첫 근무일)', () {
      expect(plan([rec(14, inH: 9, inM: 12)], 14), daily(14, 18, 12));
    });
  });

  group('주간 알림 (N2) — 마지막 근무일은 이번 주를 다 채운 시각에 한 번만', () {
    test('금요일, 남은 8h → 18:00', () {
      expect(plan([...full([14, 15, 16, 17]), rec(18, inH: 9)], 18), weekly(18, 18));
    });

    test('금요일, 남은 6h(앞에서 +2h) → 16:00 — 8h 알림은 없다', () {
      final records = [rec(14, inH: 9, outH: 20), ...full([15, 16, 17]), rec(18, inH: 9)];
      expect(plan(records, 18), weekly(18, 16));
    });

    test('금요일, 남은 10h(앞에서 −2h) → 20:00 — 17:30·18:00에 "남았어요" 알림은 없다', () {
      final records = [rec(14, inH: 9, outH: 16), ...full([15, 16, 17]), rec(18, inH: 9)];
      expect(plan(records, 18), weekly(18, 20));
    });

    test('금요일, 남은 3h → 12:00 (점심 창 전에 끝난다)', () {
      final records = [rec(14, inH: 9, outH: 23), ...full([15, 16, 17]), rec(18, inH: 9)];
      expect(plan(records, 18), weekly(18, 12));
    });

    test('금요일, 남은 시간이 오늘 안에 안 끝나면 없다', () {
      expect(plan([...full([14, 15]), rec(18, inH: 9)], 18), isNull); // 남은 24h
    });

    test('금요일이 연차면 목요일이 마지막 근무일', () {
      final records = [...full([14, 15, 16]), rec(17, inH: 9), rec(18, type: WorkType.dayOff)];
      expect(plan(records, 17), weekly(17, 18));
    });

    test('금요일이 종일 출장·공휴일이어도 목요일이 마지막', () {
      for (final type in [WorkType.businessTrip, WorkType.holiday]) {
        final records = [...full([14, 15, 16]), rec(17, inH: 9), rec(18, type: type)];
        expect(plan(records, 17), weekly(17, 18), reason: '$type');
      }
    });

    test('마지막 근무일 반차: 남은 4h → 출근 + 4h (점심 공제 없음)', () {
      final records = [...full([14, 15, 16, 17]), rec(18, inH: 9, type: WorkType.halfDay)];
      expect(plan(records, 18), weekly(18, 13));
    });

    test('마지막 근무일에 공제로 그날 기준이 0이어도, 주간이 남았으면 주간 알림은 간다', () {
      final records = [rec(14, inH: 9, outH: 16), ...full([15, 16, 17]), rec(18, inH: 9, ded: 480)];
      expect(plan(records, 18), weekly(18, 11)); // 남은 2h
    });
  });

  group('주간 알림 (N2′) — 근무일이 남았는데 이번 주가 먼저 끝나는 날', () {
    test('목요일, 남은 3h → 12:00 weeklyEarly, 일일 알림은 건너뛴다', () {
      final records = [rec(14, inH: 9, outH: 22), rec(15, inH: 9, outH: 22), rec(16, inH: 9, outH: 23), rec(17, inH: 9)];
      expect(plan(records, 17), early(17, 12));
    });

    test('목요일, 남은 시간 = 그날 기준(8h) → 같은 시각이면 주간 알림 하나', () {
      final records = [rec(14, inH: 9, outH: 22), rec(15, inH: 9, outH: 22), rec(16, inH: 9, outH: 18), rec(17, inH: 9)];
      expect(plan(records, 17), early(17, 18));
    });

    test('목요일, 남은 시간이 그날 기준보다 1분이라도 길면 일일 알림', () {
      final records = [rec(14, inH: 9, outH: 22), rec(15, inH: 9, outH: 22), rec(16, inH: 9, outH: 17, outM: 59), rec(17, inH: 9)];
      expect(plan(records, 17), daily(17, 18));
    });
  });

  group('알림이 없는 경우', () {
    test('출근 전에 이미 이번 주를 다 채웠다', () {
      final records = [for (final day in [14, 15, 16]) rec(day, inH: 8, outH: 23, outM: 59), rec(17, inH: 9)];
      expect(plan(records, 17), isNull);
    });

    test('주말 근무', () {
      expect(plan([...full([14, 15, 16, 17, 18]), rec(19, inH: 10)], 19), isNull);
    });

    test('평일 공휴일 근무', () {
      expect(plan([...full([14, 15]), rec(16, inH: 9, type: WorkType.holiday)], 16), isNull);
    });

    test('출근 전 · 퇴근 완료 · 연차 · 종일 출장 · 기록 없음', () {
      expect(plan(full([14, 15]), 16), isNull);
      expect(plan([...full([14, 15]), rec(16)], 16), isNull);
      expect(plan([...full([14, 15]), rec(16, tripInH: 9, tripOutH: 12)], 16), isNull);
      expect(plan(full([14, 15, 16]), 16), isNull);
      expect(plan([...full([14, 15]), rec(16, type: WorkType.dayOff)], 16), isNull);
      expect(plan([...full([14, 15]), rec(16, type: WorkType.businessTrip)], 16), isNull);
    });

    test('다른 날의 근무 중 기록은 보지 않는다 (어제 퇴근을 안 찍었어도 오늘 기준)', () {
      expect(plan([rec(14, inH: 9), rec(15, inH: 9)], 15), daily(15, 18));
      expect(plan([rec(14, inH: 9)], 15), isNull);
    });
  });

  group('첫 주 예외 — 주간 목표를 모르므로 일일 알림만', () {
    test('첫 기록일이 수요일인 주의 목요일 09:00 → 18:00', () {
      expect(plan([rec(16, inH: 9, outH: 18), rec(17, inH: 9)], 17, first: d(16)), daily(17, 18));
    });

    test('첫 주의 금요일도 주간이 아니라 일일', () {
      expect(plan([rec(16, inH: 9, outH: 18), rec(18, inH: 9)], 18, first: d(16)), daily(18, 18));
    });

    test('첫 주에도 그날 기준이 0이면 없다', () {
      expect(plan([rec(17, inH: 9, ded: 480)], 17, first: d(16)), isNull);
    });
  });

  test('ClockOutNotice 동등성', () {
    expect(daily(16, 18), daily(16, 18));
    expect(daily(16, 18) == weekly(16, 18), isFalse);
    expect(daily(16, 18) == daily(16, 18, 1), isFalse);
    expect({daily(16, 18), daily(16, 18)}, hasLength(1));
  });
}

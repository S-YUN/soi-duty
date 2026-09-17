import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/domain/model/work_record.dart';
import 'package:soi_duty/domain/model/work_type.dart';
import 'package:soi_duty/domain/rules/work_rules.dart';
import 'package:soi_duty/presentation/today/today_state_builder.dart';
import 'package:soi_duty/presentation/today/today_texts.dart';

import '../helpers/records.dart';

void main() {
  const rules = WorkRules();
  final past = [rec(14, inH: 9, outH: 18), rec(15, inH: 9, outH: 13, type: WorkType.halfDay)];

  test('히어로: 정상 주', () {
    final s = buildTodayState(records: past, firstRecordDate: d(7), now: d(16, 12), rules: rules);
    expect(TodayTexts.heroLabel(s), '이번 주 남은 근무시간');
    expect(TodayTexts.heroValue(s), '24h');
    expect(TodayTexts.progress(s), closeTo(720 / 2160, 0.0001));
  });

  test('히어로: 연차가 있으면 잔여와 진행률이 줄어든 목표 기준', () {
    final s = buildTodayState(
      records: [rec(14, inH: 9, outH: 18), rec(16, type: WorkType.dayOff)],
      firstRecordDate: d(7),
      now: d(16, 12),
      rules: rules,
    );
    expect(TodayTexts.heroValue(s), '24h'); // 32h − 8h
    expect(TodayTexts.progress(s), closeTo(480 / 1920, 0.0001));
  });

  test('히어로: 첫 주 예외', () {
    final s = buildTodayState(records: [rec(16, inH: 9)], firstRecordDate: d(16), now: d(16, 12), rules: rules);
    expect(TodayTexts.heroLabel(s), '이번 주 기록한 시간');
    expect(TodayTexts.progress(s), isNull);
  });

  test('상태 문구: 근무 중 — 출근 시각, 경과 · 퇴근 추천, 안내', () {
    // 월 8h, 화 반차 4h → 남은 24h를 수·목·금 3일로 → 오늘 몫 8h → 09:12 + 8h + 1h = 18:12
    final s = buildTodayState(
      records: [...past, rec(16, inH: 9, inM: 12)],
      firstRecordDate: d(7),
      now: d(16, 16, 27),
      rules: rules,
    );
    expect(TodayTexts.clockInLine(s), '09:12 출근');
    expect(TodayTexts.workingLine(s), '7시간 15분째 근무중');
    expect(s.expectedClockOut, d(16, 18, 12)); // 계산은 되지만 화면엔 아직 안 띄움
    expect(TodayTexts.buttonLabel(s), '퇴근하기');
  });

  test('상태 문구: 첫 주 근무 중 — 퇴근 추천 없음', () {
    final s = buildTodayState(records: [rec(16, inH: 9, inM: 12)], firstRecordDate: d(16), now: d(16, 12), rules: rules);
    expect(TodayTexts.workingLine(s), '2시간 48분째 근무중');
    expect(TodayTexts.encouragement(s, rules), '지난 요일을 채우면 이번 주도 목표가 계산돼요');
  });

  test('상태 문구: 이미 채웠으면 시각 대신 안내', () {
    // 월·화 0:00–23:59 → 45h 58m ≥ 40h
    final s = buildTodayState(
      records: [rec(14, inH: 0, outH: 23, outM: 59), rec(15, inH: 0, outH: 23, outM: 59), rec(16, inH: 9)],
      firstRecordDate: d(7),
      now: d(16, 10),
      rules: rules,
    );
    expect(s.isWeekFilled, isTrue);
    expect(s.expectedClockOut, isNull);
    expect(TodayTexts.workingLine(s), '1시간째 근무중');
    expect(TodayTexts.encouragement(s, rules), '오늘은 조금 일찍 퇴근하셔도 괜찮아요');
  });

  group('안내 문구', () {
    String enc(List<WorkRecord> records, int day, {int hour = 8}) => TodayTexts.encouragement(
          buildTodayState(records: records, firstRecordDate: d(7), now: d(day, hour), rules: rules),
          rules,
        );

    test('월요일(첫 근무일)', () => expect(enc([], 14), '자, 이번주 시작해볼까요?'));
    test('월요일이 연차면 화요일이 첫 근무일', () => expect(enc([rec(14, type: WorkType.dayOff)], 15), '자, 이번주 시작해볼까요?'));
    test('금요일(마지막)', () => expect(enc([for (var day = 14; day <= 17; day++) rec(day, inH: 9, outH: 18)], 18), '드디어 금요일! 오늘도 힘내세요'));
    test('금요일이 공휴일이면 목요일이 마지막', () {
      expect(enc([rec(18, type: WorkType.holiday)], 17), '이번 주 마지막 날! 오늘도 힘내세요');
    });
    test('앞서 많이 함 → 일찍', () {
      // 월 12h, 화 12h → 남은 16h / 3일 = 5h 20m < 7h 30m
      expect(enc([rec(14, inH: 8, outH: 21), rec(15, inH: 8, outH: 21)], 16), '오늘은 조금 일찍 퇴근하셔도 괜찮아요');
    });
    test('모자람 → 더', () {
      // 월 5h, 화 5h → 남은 30h / 3일 = 10h > 8h 30m
      expect(enc([rec(14, inH: 9, outH: 15), rec(15, inH: 9, outH: 15)], 16), '오늘은 좀 더 일하는 것을 추천해요');
    });
    test('비슷함 → 페이스', () => expect(enc([rec(14, inH: 9, outH: 18), rec(15, inH: 9, outH: 18)], 16), '이번 주 페이스 좋아요'));
    test('주말', () => expect(enc([], 19), '주말 근무는 주 40시간에 포함되지 않아요'));
  });

  test('버튼 라벨', () {
    expect(TodayTexts.buttonLabel(buildTodayState(records: past, firstRecordDate: d(7), now: d(16, 8), rules: rules)), '출근하기');
    expect(
      TodayTexts.buttonLabel(buildTodayState(records: [rec(16, inH: 9, outH: 18)], firstRecordDate: d(7), now: d(16, 19), rules: rules)),
      '오늘 퇴근 완료',
    );
  });

  test('연차/공휴일 안내', () {
    expect(TodayTexts.dayTypeMessage(WorkType.dayOff), '오늘은 연차입니다\n근무 기록을 남기지 않습니다');
    expect(TodayTexts.dayTypeMessage(WorkType.holiday), '오늘은 공휴일입니다\n행복한 휴일 되세요');
  });

  test('기록 안 된 날 타이틀', () {
    expect(TodayTexts.unrecordedTitle(2), '기록 안 된 날 2개');
  });
}

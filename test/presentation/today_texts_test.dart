import 'package:flutter_test/flutter_test.dart';
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
    expect(TodayTexts.heroLabel(s), '이번 주 남은 시간');
    expect(TodayTexts.heroValue(s), '24h');
    expect(TodayTexts.heroReason(s, rules), '12h / 36h · 반차 1회');
    expect(TodayTexts.progress(s), closeTo(720 / 2160, 0.0001));
  });

  test('히어로: 연차 문구', () {
    final s = buildTodayState(
      records: [rec(14, inH: 9, outH: 18), rec(16, type: WorkType.dayOff)],
      firstRecordDate: d(7),
      now: d(16, 12),
      rules: rules,
    );
    expect(TodayTexts.heroReason(s, rules), '8h / 32h · 연차 1일로 목표 8h 차감');
  });

  test('히어로: 첫 주 예외', () {
    final s = buildTodayState(records: [rec(16, inH: 9)], firstRecordDate: d(16), now: d(16, 12), rules: rules);
    expect(TodayTexts.heroLabel(s), '이번 주 기록한 시간');
    expect(TodayTexts.heroReason(s, rules), '9월 16일 수요일부터 기록');
    expect(TodayTexts.progress(s), isNull);
  });

  test('상태 문구: 근무 중', () {
    final s = buildTodayState(
      records: [...past, rec(16, inH: 9, inM: 12)],
      firstRecordDate: d(7),
      now: d(16, 16, 27),
      rules: rules,
    );
    expect(TodayTexts.statusMain(s), '오늘 18:12에 퇴근하면 딱 맞아');
    expect(TodayTexts.statusSub(s), '09:12 출근 · 7h 15m째');
    expect(TodayTexts.buttonLabel(s), '퇴근하기');
  });

  test('상태 문구: 첫 주 근무 중', () {
    final s = buildTodayState(records: [rec(16, inH: 9, inM: 12)], firstRecordDate: d(16), now: d(16, 12), rules: rules);
    expect(TodayTexts.statusMain(s), '오늘 기록 중 · 이번 주는 목표 없이 실적만');
  });

  test('버튼 라벨', () {
    expect(TodayTexts.buttonLabel(buildTodayState(records: past, firstRecordDate: d(7), now: d(16, 8), rules: rules)), '출근하기');
    expect(
      TodayTexts.buttonLabel(buildTodayState(records: [rec(16, inH: 9, outH: 18)], firstRecordDate: d(7), now: d(16, 19), rules: rules)),
      '오늘 퇴근 완료',
    );
  });

  test('연차/공휴일 안내', () {
    expect(TodayTexts.dayTypeMessage(WorkType.dayOff), '오늘은 연차로 처리돼 있어요\n근무 기록은 남기지 않습니다');
    expect(TodayTexts.dayTypeMessage(WorkType.holiday), '오늘은 공휴일로 처리돼 있어요\n근무 기록은 남기지 않습니다');
  });

  test('기록 안 된 날 타이틀', () {
    expect(TodayTexts.unrecordedTitle(2), '기록 안 된 날 2개');
  });
}

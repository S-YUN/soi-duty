import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/core/presentation/format/date_format.dart';
import 'package:soi_duty/core/presentation/format/time_format.dart';

void main() {
  test('formatCompactHm / formatSignedCompactHm — 좁은 칸용, 공백 없음', () {
    expect(formatCompactHm(442), '7h22m');
    expect(formatCompactHm(2160), '36h');
    expect(formatCompactHm(22), '22m');
    expect(formatSignedCompactHm(232), '+3h52m');
    expect(formatSignedCompactHm(-65), '−1h5m');
    expect(formatSignedCompactHm(31), '+31m');
    expect(formatSignedCompactHm(0), '0m');
  });

  test('formatHm', () {
    expect(formatHm(442), '7h 22m');
    expect(formatHm(2160), '36h');
    expect(formatHm(22), '22m');
    expect(formatHm(0), '0m');
    expect(formatHm(-7), '−7m');
    expect(formatHm(-130), '−2h 10m');
  });

  test('formatSignedHm', () {
    expect(formatSignedHm(10), '+10m');
    expect(formatSignedHm(-7), '−7m');
    expect(formatSignedHm(0), '0m');
  });

  test('formatClock', () {
    expect(formatClock(DateTime(2026, 9, 11, 9, 5)), '09:05');
    expect(formatClock(DateTime(2026, 9, 11, 18, 30)), '18:30');
  });

  test('formatDateTitle / formatDateShort', () {
    expect(formatDateTitle(DateTime(2026, 9, 11)), '9월 11일 금요일');
    expect(formatDateShort(DateTime(2026, 9, 4)), '9월 4일 금');
    expect(formatDateShort(DateTime(2026, 9, 20)), '9월 20일 일');
  });

  group('formatWeekTitle — 목요일이 속한 달 기준', () {
    test('달 첫 주', () => expect(formatWeekTitle(DateTime(2026, 9, 7)), '9월 2째주'));
    test('달 중간', () => expect(formatWeekTitle(DateTime(2026, 9, 14)), '9월 3째주'));
    test('월요일은 전달, 목요일은 이번 달 → 이번 달 1째주',
        () => expect(formatWeekTitle(DateTime(2026, 8, 31)), '9월 1째주'));
    test('월요일은 이번 달, 목요일은 다음 달 → 다음 달 1째주',
        () => expect(formatWeekTitle(DateTime(2026, 9, 28)), '10월 1째주'));
    test('해 넘김', () => expect(formatWeekTitle(DateTime(2026, 12, 28)), '12월 5째주'));
    test('1월 1일이 목요일이면 1월 1째주', () => expect(formatWeekTitle(DateTime(2025, 12, 29)), '1월 1째주'));
  });
  test('formatMonthTitle', () => expect(formatMonthTitle(DateTime(2026, 9)), '2026년 9월'));
  test('formatClockRange', () =>
      expect(formatClockRange(DateTime(2026, 9, 7, 9, 5), DateTime(2026, 9, 7, 18, 36)), '09:05 – 18:36'));
}

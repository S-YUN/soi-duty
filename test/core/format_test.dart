import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/core/presentation/format/date_format.dart';
import 'package:soi_duty/core/presentation/format/time_format.dart';

void main() {
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

  group('formatWeekRange', () {
    test('같은 달', () => expect(formatWeekRange(DateTime(2026, 9, 7)), '9월 7일 – 13일'));
    test('다른 달', () => expect(formatWeekRange(DateTime(2026, 8, 31)), '8월 31일 – 9월 6일'));
    test('해 넘김', () => expect(formatWeekRange(DateTime(2026, 12, 28)), '12월 28일 – 1월 3일'));
  });
  test('formatMonthTitle', () => expect(formatMonthTitle(DateTime(2026, 9)), '2026년 9월'));
  test('formatClockRange', () =>
      expect(formatClockRange(DateTime(2026, 9, 7, 9, 5), DateTime(2026, 9, 7, 18, 36)), '09:05 – 18:36'));
}

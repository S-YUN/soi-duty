import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/domain/rules/navigation_bounds.dart';

import '../helpers/records.dart';

void main() {
  test('첫 기록일 없으면 이번 주 월요일', () => expect(earliestMonday(null, d(16)), d(14)));
  test('첫 기록일 있으면 그 주 월요일', () => expect(earliestMonday(d(9), d(16)), d(7)));
  test('첫 기록일이 미래(미리 찍은 연차)면 이번 주를 넘지 않는다', () => expect(earliestMonday(d(23), d(16)), d(14)));
  test('첫 기록일 없으면 이번 달', () => expect(earliestMonth(null, d(16)), DateTime(2026, 9)));
  test('첫 기록일 있으면 그 달', () => expect(earliestMonth(DateTime(2026, 7, 20), d(16)), DateTime(2026, 7)));
  test('첫 기록일이 다음 달이면 이번 달', () => expect(earliestMonth(DateTime(2026, 10, 2), d(16)), DateTime(2026, 9)));
  test('상한은 올해 12월', () => expect(latestMonth(d(16)), DateTime(2026, 12)));
  test('해가 바뀌면 새해 12월', () => expect(latestMonth(DateTime(2027, 1, 3)), DateTime(2027, 12)));
}

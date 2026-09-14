import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/domain/model/work_record.dart';
import 'package:soi_duty/domain/model/work_type.dart';
import 'package:soi_duty/domain/rules/work_rules.dart';

void main() {
  test('기본 type은 normal', () {
    final r = WorkRecord(date: DateTime(2026, 9, 14));
    expect(r.type, WorkType.normal);
    expect(r.clockIn, isNull);
  });

  test('json 왕복', () {
    final r = WorkRecord(
      date: DateTime(2026, 9, 14),
      clockIn: DateTime(2026, 9, 14, 9, 12),
      clockOut: DateTime(2026, 9, 14, 18, 5),
      type: WorkType.halfDay,
    );
    expect(WorkRecord.fromJson(r.toJson()), r);
  });

  test('WorkRules 기본값', () {
    const rules = WorkRules();
    expect(rules.weeklyTargetMinutes, 2400);
    expect(rules.lunchBreakMinutes, 60);
    expect(rules.halfDayCreditMinutes, 240);
    expect(rules.dayOffCreditMinutes, 480);
    expect(rules.dailyStandardMinutes, 480);
  });
}

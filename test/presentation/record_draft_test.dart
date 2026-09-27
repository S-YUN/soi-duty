import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/domain/model/work_record.dart';
import 'package:soi_duty/domain/model/work_type.dart';
import 'package:soi_duty/domain/rules/work_rules.dart';
import 'package:soi_duty/presentation/record_edit/record_draft.dart';
import 'package:soi_duty/presentation/record_edit/record_edit_texts.dart';

import '../helpers/records.dart';

void main() {
  const rules = WorkRules();
  final today = d(16);

  test('기록에서 초안: 값과 existing', () {
    final draft = RecordDraft.fromRecord(date: d(14), today: today, record: rec(14, inH: 9, outH: 18));
    expect(draft.clockIn, d(14, 9));
    expect(draft.existing, isTrue);
    expect(draft.editing, isNull);
  });

  test('기록 없으면 normal, 시각 null, existing false', () {
    final draft = RecordDraft.fromRecord(date: d(14), today: today, record: null);
    expect(draft.type, WorkType.normal);
    expect(draft.clockIn, isNull);
    expect(draft.existing, isFalse);
  });

  test('주말은 유형 칩 없음', () {
    expect(RecordDraft.fromRecord(date: d(19), today: today, record: null).showsTypeChips, isFalse);
    expect(RecordDraft.fromRecord(date: d(14), today: today, record: null).showsTypeChips, isTrue);
  });

  test('미래·연차·공휴일은 시각 행 없음', () {
    final future = RecordDraft.fromRecord(date: d(23), today: today, record: null);
    expect(future.isFuture, isTrue);
    expect(future.showsTimeRows, isFalse);
    final off = RecordDraft.fromRecord(date: d(14), today: today, record: null).withType(WorkType.dayOff);
    expect(off.showsTimeRows, isFalse);
    expect(RecordDraft.fromRecord(date: d(14), today: today, record: null).showsTimeRows, isTrue);
  });

  test('연차로 저장하면 시각이 비워진다', () {
    final draft = RecordDraft.fromRecord(date: d(14), today: today, record: rec(14, inH: 9, outH: 18))
        .withType(WorkType.dayOff);
    final r = draft.toRecord();
    expect(r.type, WorkType.dayOff);
    expect(r.clockIn, isNull);
    expect(r.clockOut, isNull);
  });

  test('미래 날짜는 유형이 있어도 시각이 비워진다', () {
    final draft = RecordDraft.fromRecord(date: d(23), today: today, record: rec(23, inH: 9, outH: 18))
        .withType(WorkType.halfDay);
    expect(draft.toRecord().clockIn, isNull);
  });

  test('withType(null)은 normal', () {
    final draft = RecordDraft.fromRecord(date: d(14), today: today, record: null).withType(WorkType.halfDay);
    expect(draft.withType(null).type, WorkType.normal);
  });

  test('휠을 열면 null이던 값이 기본 시각(출근 08:00·퇴근 17:00)으로 채워지고, 다시 탭하면 접힌다', () {
    var draft = RecordDraft.fromRecord(date: d(14), today: today, record: null);
    draft = draft.toggleEditing(EditingRow.clockIn, rules);
    expect(draft.editing, EditingRow.clockIn);
    expect(draft.clockIn, d(14, 8, 0));
    draft = draft.toggleEditing(EditingRow.clockIn, rules);
    expect(draft.editing, isNull);
    expect(draft.clockIn, d(14, 8, 0));
    expect(draft.toggleEditing(EditingRow.clockOut, rules).clockOut, d(14, 17, 0));
  });

  test('값이 있으면 기본 시각 대신 그 값으로 연다', () {
    final draft = RecordDraft.fromRecord(date: d(14), today: today, record: rec(14, inH: 9, inM: 12, outH: 18));
    expect(draft.toggleEditing(EditingRow.clockIn, rules).clockIn, d(14, 9, 12));
  });

  test('withTime은 날짜를 유지하고 시분만 바꾼다', () {
    final draft = RecordDraft.fromRecord(date: d(14), today: today, record: null).withTime(EditingRow.clockOut, 18, 5);
    expect(draft.clockOut, d(14, 18, 5));
  });

  test('퇴근 < 출근이면 무효', () {
    final draft = RecordDraft.fromRecord(date: d(14), today: today, record: null)
        .withTime(EditingRow.clockIn, 22, 0)
        .withTime(EditingRow.clockOut, 2, 0);
    expect(draft.isValid(rules), isFalse);
  });

  test('빈 normal 판정', () {
    final empty = RecordDraft.fromRecord(date: d(14), today: today, record: null);
    expect(empty.isEmptyNormal, isTrue);
    expect(empty.withType(WorkType.holiday).isEmptyNormal, isFalse);
    expect(empty.withTime(EditingRow.clockIn, 9, 0).isEmptyNormal, isFalse);
    // 미래 반차 해제 → 시각 없는 normal → 빈 기록
    final future = RecordDraft.fromRecord(date: d(23), today: today, record: rec(23, type: WorkType.halfDay));
    expect(future.withType(null).isEmptyNormal, isTrue);
  });

  group('calcLines', () {
    test('평일 일반: 근무·점심·기준·기준 대비', () {
      final draft = RecordDraft.fromRecord(date: d(14), today: today, record: rec(14, inH: 9, outH: 18, outM: 20));
      final lines = calcLines(draft, rules);
      expect(lines.map((l) => l.label), ['근무', '점심 공제', '기준', '기준 대비']);
      expect(lines.map((l) => l.value), ['8h 20m', '1h', '8h', '+20m']);
      expect(lines.last.kind, CalcKind.sum);
    });
    test('반차: 점심 없음, 기준 4h', () {
      final draft =
          RecordDraft.fromRecord(date: d(14), today: today, record: rec(14, inH: 13, outH: 18, type: WorkType.halfDay));
      final values = calcLines(draft, rules).map((l) => l.value).toList();
      expect(values, ['5h', '없음 (반차)', '4h', '+1h']);
    });
    test('주말: 근무·점심 두 줄', () {
      final draft = RecordDraft.fromRecord(date: d(12), today: today, record: rec(12, inH: 10, outH: 14, outM: 30));
      final lines = calcLines(draft, rules);
      expect(lines.map((l) => l.label), ['근무', '점심 공제']);
      expect(lines.map((l) => l.value), ['4h 30m', '없음']);
    });
    test('시각이 비면 근무·기준 대비는 —', () {
      final draft = RecordDraft.fromRecord(date: d(14), today: today, record: null);
      final values = calcLines(draft, rules).map((l) => l.value).toList();
      expect(values, ['—', '1h', '8h', '—']);
    });
  });

  RecordDraft mk({required DateTime date, DateTime? today, WorkRecord? record}) =>
      RecordDraft.fromRecord(date: date, today: today ?? d(16), record: record);

  group('유형 전용 모드', () {
    test('미래는 유형 전용', () => expect(mk(date: d(18)).isTypeOnly, isTrue));
    test('출근 전 오늘도 유형 전용', () => expect(mk(date: d(16)).isTypeOnly, isTrue));
    test('유형만 찍힌 오늘도 유형 전용', () => expect(mk(date: d(16), record: rec(16, type: WorkType.dayOff)).isTypeOnly, isTrue));
    test('퇴근 완료 오늘은 아님', () => expect(mk(date: d(16), record: rec(16, inH: 9, outH: 18)).isTypeOnly, isFalse));
    test('과거는 아님', () => expect(mk(date: d(14)).isTypeOnly, isFalse));
  });

  group('공휴일 근무', () {
    test('공휴일은 기본으로 시각 행 대신 버튼, 펼치면 시각 행', () {
      final x = mk(date: d(14), record: rec(14, type: WorkType.holiday));
      expect((x.showsTimeRows, x.showsHolidayWorkButton), (false, true));
      final y = x.expandHolidayWork();
      expect((y.showsTimeRows, y.showsHolidayWorkButton), (true, false));
    });
    test('시각이 있는 공휴일은 펼친 채로 열린다', () {
      expect(mk(date: d(14), record: rec(14, inH: 10, outH: 15, type: WorkType.holiday)).showsTimeRows, isTrue);
    });
    test('시각 있던 날을 공휴일로 바꾸면 접힌 상태 — 시각이 지워진다', () {
      final x = mk(date: d(14), record: rec(14, inH: 9, outH: 18)).withType(WorkType.holiday);
      expect(x.showsTimeRows, isFalse);
      expect(x.toRecord().clockIn, isNull);
    });
    test('미래 공휴일엔 버튼 없음', () {
      expect(mk(date: d(18), record: rec(18, type: WorkType.holiday)).showsHolidayWorkButton, isFalse);
    });
    test('펼친 공휴일 저장 시 시각이 남는다', () {
      final x = mk(date: d(14), record: rec(14, type: WorkType.holiday))
          .expandHolidayWork()
          .withTime(EditingRow.clockIn, 10, 0)
          .withTime(EditingRow.clockOut, 15, 0);
      final r = x.toRecord();
      expect((r.type, r.clockIn, r.clockOut), (WorkType.holiday, d(14, 10), d(14, 15)));
    });
    test('공휴일 계산 내역: 근무 · 점심 공제(없음 (공휴일))', () {
      final x = mk(date: d(14), record: rec(14, inH: 10, outH: 15, type: WorkType.holiday));
      expect(calcLines(x, rules).map((l) => (l.label, l.value)).toList(), [('근무', '5h'), ('점심 공제', '없음 (공휴일)')]);
    });
  });

  group('시간공제', () {
    test('평일 일반·반차만 공제 행', () {
      expect(mk(date: d(14)).showsDeductionRow, isTrue);
      expect(mk(date: d(14), record: rec(14, type: WorkType.halfDay)).showsDeductionRow, isTrue);
      expect(mk(date: d(19), today: d(20)).showsDeductionRow, isFalse); // 주말
      expect(mk(date: d(14), record: rec(14, type: WorkType.holiday)).showsDeductionRow, isFalse);
    });
    test('반차 4h 초과는 무효', () {
      final x = mk(date: d(14), record: rec(14, inH: 9, outH: 13, type: WorkType.halfDay)).withDeduction(250);
      expect(x.isDeductionValid(rules), isFalse);
      expect(x.isValid(rules), isFalse);
    });
    test('toRecord: 공제 반영', () {
      final base = mk(date: d(14), record: rec(14, inH: 9, outH: 15));
      expect(base.withDeduction(120).toRecord().deductionMinutes, 120);
    });
    test('기록의 공제를 들고 열린다', () {
      expect(mk(date: d(14), record: rec(14, inH: 9, outH: 15, ded: 90)).deductionMinutes, 90);
    });
    test('연차로 바꾸면 공제가 저장되지 않는다', () {
      expect(mk(date: d(14), record: rec(14, ded: 60)).withType(WorkType.dayOff).toRecord().deductionMinutes, 0);
    });
    test('공제만 있는 normal은 빈 기록이 아니다', () {
      expect(mk(date: d(18)).withDeduction(60).isEmptyNormal, isFalse);
      expect(mk(date: d(18)).isEmptyNormal, isTrue);
    });
    test('출·퇴근 휠을 펴면 계산 내역을 숨긴다 — 시트가 화면을 넘지 않게', () {
      final x = mk(date: d(14), record: rec(14, inH: 9, outH: 15));
      expect(x.showsCalcRows, isTrue);
      final opened = x.toggleEditing(EditingRow.clockIn, rules);
      expect(opened.showsCalcRows, isFalse);
      expect(opened.toggleEditing(EditingRow.clockIn, rules).showsCalcRows, isTrue);
    });
    test('계산 내역에 시간공제 줄과 공제 반영 기준', () {
      final x = mk(date: d(14), record: rec(14, inH: 9, outH: 15, ded: 120));
      expect(calcLines(x, rules).map((l) => (l.label, l.value)).toList(), [
        ('근무', '5h'),
        ('점심 공제', '1h'),
        ('시간공제', '−2h'),
        ('기준', '6h'),
        ('기준 대비', '−1h'),
      ]);
    });
    test('공제 표시 문구', () {
      expect(RecordEditTexts.deduction(0), '없음');
      expect(RecordEditTexts.deduction(150), '2시간 30분');
      expect(RecordEditTexts.deduction(30), '30분');
    });
  });
}

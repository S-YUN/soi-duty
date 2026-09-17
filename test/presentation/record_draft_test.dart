import 'package:flutter_test/flutter_test.dart';
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
    draft = draft.toggleEditing(EditingRow.clockIn);
    expect(draft.editing, EditingRow.clockIn);
    expect(draft.clockIn, d(14, 8, 0));
    draft = draft.toggleEditing(EditingRow.clockIn);
    expect(draft.editing, isNull);
    expect(draft.clockIn, d(14, 8, 0));
    expect(draft.toggleEditing(EditingRow.clockOut).clockOut, d(14, 17, 0));
  });

  test('값이 있으면 기본 시각 대신 그 값으로 연다', () {
    final draft = RecordDraft.fromRecord(date: d(14), today: today, record: rec(14, inH: 9, inM: 12, outH: 18));
    expect(draft.toggleEditing(EditingRow.clockIn).clockIn, d(14, 9, 12));
  });

  test('withTime은 날짜를 유지하고 시분만 바꾼다', () {
    final draft = RecordDraft.fromRecord(date: d(14), today: today, record: null).withTime(EditingRow.clockOut, 18, 5);
    expect(draft.clockOut, d(14, 18, 5));
  });

  test('퇴근 < 출근이면 무효', () {
    final draft = RecordDraft.fromRecord(date: d(14), today: today, record: null)
        .withTime(EditingRow.clockIn, 22, 0)
        .withTime(EditingRow.clockOut, 2, 0);
    expect(draft.isValid, isFalse);
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
}

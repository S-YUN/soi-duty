import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/domain/backup/backup_codec.dart';
import 'package:soi_duty/domain/model/app_settings.dart';
import 'package:soi_duty/domain/model/backup_snapshot.dart';
import 'package:soi_duty/domain/model/work_type.dart';

import '../helpers/records.dart';

void main() {
  final snapshot = BackupSnapshot(
    exportedAt: DateTime(2026, 10, 25, 9, 12),
    firstRecordDate: DateTime(2026, 9, 14),
    weekStart: WeekStart.sunday,
    annualLeaveDaysByYear: const {2026: 15, 2027: 16},
    hourlyWage: 12500,
    records: [rec(14, inH: 9, outH: 18), rec(15, type: WorkType.dayOff), rec(16, inH: 9, inM: 12)],
  );

  test('encode → decode 왕복 동일', () {
    final text = encodeBackup(snapshot);
    final json = jsonDecode(text) as Map<String, dynamic>;
    expect(json['app'], 'soi_duty');
    expect(json['format'], 1);
    expect(json['firstRecordDate'], '2026-09-14');
    expect((json['settings'] as Map)['annualLeaveDaysByYear'], {'2026': 15, '2027': 16});
    expect((json['settings'] as Map).containsKey('lastExportDate'), isFalse);
    expect(decodeBackup(text), snapshot);
  });

  test('firstRecordDate · 시급 없음도 왕복', () {
    final s = snapshot.copyWith(firstRecordDate: null, hourlyWage: null, annualLeaveDaysByYear: const {}, records: []);
    expect(decodeBackup(encodeBackup(s)), s);
  });

  test('decode 실패 — JSON 아님 / app 다름 / format 2 / records가 배열 아님 / 레코드 date 없음', () {
    String withPatch(Map<String, dynamic> Function(Map<String, dynamic>) patch) =>
        jsonEncode(patch(jsonDecode(encodeBackup(snapshot)) as Map<String, dynamic>));
    expect(() => decodeBackup('not json'), throwsA(isA<BackupFormatException>()));
    expect(() => decodeBackup('[1, 2]'), throwsA(isA<BackupFormatException>()));
    expect(() => decodeBackup(withPatch((j) => j..['app'] = 'other')), throwsA(isA<BackupFormatException>()));
    expect(() => decodeBackup(withPatch((j) => j..['format'] = 2)), throwsA(isA<BackupFormatException>()));
    expect(() => decodeBackup(withPatch((j) => j..['records'] = 'x')), throwsA(isA<BackupFormatException>()));
    expect(
      () => decodeBackup(withPatch((j) => j..['records'] = [<String, dynamic>{'clockIn': null}])),
      throwsA(isA<BackupFormatException>()),
    );
  });

  test('settings가 빠져 있어도 기본값으로 읽는다', () {
    final text = jsonEncode({'app': 'soi_duty', 'format': 1, 'exportedAt': '2026-10-25T09:12:00.000', 'records': []});
    final s = decodeBackup(text);
    expect(s.weekStart, WeekStart.monday);
    expect(s.annualLeaveDaysByYear, isEmpty);
    expect(s.hourlyWage, isNull);
  });

  test('범위 밖 값은 거른다 — 시급 0·8자리는 null, 총 연차 0·100은 그 해 제거, 퇴근<출근은 시각 제거', () {
    String withPatch(Map<String, dynamic> Function(Map<String, dynamic>) patch) =>
        jsonEncode(patch(jsonDecode(encodeBackup(snapshot)) as Map<String, dynamic>));
    expect(decodeBackup(withPatch((j) => j..['settings'] = {...j['settings'] as Map, 'hourlyWage': 0})).hourlyWage, isNull);
    expect(decodeBackup(withPatch((j) => j..['settings'] = {...j['settings'] as Map, 'hourlyWage': 10000000})).hourlyWage, isNull);
    expect(decodeBackup(withPatch((j) => j..['settings'] = {...j['settings'] as Map, 'hourlyWage': 9999999})).hourlyWage, 9999999);
    final leave = decodeBackup(withPatch((j) => j..['settings'] = {...j['settings'] as Map, 'annualLeaveDaysByYear': {'2026': 0, '2027': 100, '2028': 99}}));
    expect(leave.annualLeaveDaysByYear, {2028: 99});
    final bad = decodeBackup(withPatch((j) => j..['records'] = [
          {'date': '2026-09-14T00:00:00.000', 'clockIn': '2026-09-14T18:00:00.000', 'clockOut': '2026-09-14T09:00:00.000', 'type': 'normal', 'deductionMinutes': 0},
        ]));
    expect(bad.records.single.clockIn, isNull);
    expect(bad.records.single.clockOut, isNull);
  });
}

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
}

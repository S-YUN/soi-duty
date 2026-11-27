import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/domain/backup/backup_codec.dart';
import 'package:soi_duty/domain/model/app_settings.dart';
import 'package:soi_duty/domain/model/backup_snapshot.dart';
import 'package:soi_duty/domain/model/leave_balance.dart';
import 'package:soi_duty/domain/model/work_type.dart';

import '../helpers/records.dart';

void main() {
  final snapshot = BackupSnapshot(
    exportedAt: DateTime(2026, 10, 25, 9, 12),
    firstRecordDate: DateTime(2026, 9, 14),
    weekStart: WeekStart.sunday,
    leaveBalanceByYear: {
      2026: LeaveBalance(remainingMinutes: 4080, baseDate: DateTime(2026, 10, 26)),
      2027: LeaveBalance(remainingMinutes: 7680, baseDate: DateTime(2027, 1, 1)),
    },
    hourlyWage: 12500,
    records: [rec(14, inH: 9, outH: 18), rec(15, type: WorkType.dayOff), rec(16, inH: 9, inM: 12)],
  );
  String withPatch(Map<String, dynamic> Function(Map<String, dynamic>) patch) =>
      jsonEncode(patch(jsonDecode(encodeBackup(snapshot)) as Map<String, dynamic>));

  test('encode → decode 왕복 동일', () {
    final text = encodeBackup(snapshot);
    final json = jsonDecode(text) as Map<String, dynamic>;
    expect(json['app'], 'soi_duty');
    expect(json['format'], 3);
    expect(json['firstRecordDate'], '2026-09-14');
    expect((json['settings'] as Map)['leaveBalanceByYear'], {
      '2026': {'remainingMinutes': 4080, 'baseDate': '2026-10-26'},
      '2027': {'remainingMinutes': 7680, 'baseDate': '2027-01-01'},
    });
    expect((json['settings'] as Map).containsKey('lastExportDate'), isFalse);
    expect(decodeBackup(text), snapshot);
  });

  test('firstRecordDate · 시급 없음도 왕복', () {
    final s = snapshot.copyWith(firstRecordDate: null, hourlyWage: null, leaveBalanceByYear: const {}, records: []);
    expect(decodeBackup(encodeBackup(s)), s);
  });

  test('decode 실패 — JSON 아님 / app 다름 / format 4 / records가 배열 아님 / 레코드 date 없음', () {
    expect(() => decodeBackup('not json'), throwsA(isA<BackupFormatException>()));
    expect(() => decodeBackup('[1, 2]'), throwsA(isA<BackupFormatException>()));
    expect(() => decodeBackup(withPatch((j) => j..['app'] = 'other')), throwsA(isA<BackupFormatException>()));
    expect(() => decodeBackup(withPatch((j) => j..['format'] = 4)), throwsA(isA<BackupFormatException>()));
    expect(() => decodeBackup(withPatch((j) => j..['records'] = 'x')), throwsA(isA<BackupFormatException>()));
    expect(
      () => decodeBackup(withPatch((j) => j..['records'] = [<String, dynamic>{'clockIn': null}])),
      throwsA(isA<BackupFormatException>()),
    );
  });

  test('settings가 빠져 있어도 기본값으로 읽는다', () {
    final text = jsonEncode({'app': 'soi_duty', 'format': 2, 'exportedAt': '2026-10-25T09:12:00.000', 'records': []});
    final s = decodeBackup(text);
    expect(s.weekStart, WeekStart.monday);
    expect(s.leaveBalanceByYear, isEmpty);
    expect(s.hourlyWage, isNull);
  });

  group('기본 출퇴근 시각 (핸드오프 7) — format 3 그대로', () {
    final withTimes = snapshot.copyWith(defaultClockInMinutes: 9 * 60 + 30, defaultClockOutMinutes: 18 * 60 + 30);
    String patched(Object? clockIn, Object? clockOut) => jsonEncode(
          (jsonDecode(encodeBackup(withTimes)) as Map<String, dynamic>)
            ..['settings'] = {
              ...(jsonDecode(encodeBackup(withTimes)) as Map<String, dynamic>)['settings'] as Map<String, dynamic>,
              'defaultClockIn': clockIn,
              'defaultClockOut': clockOut,
            },
        );

    test('HH:mm으로 쓰고 왕복 동일, 형식 버전은 올리지 않는다', () {
      final json = jsonDecode(encodeBackup(withTimes)) as Map<String, dynamic>;
      expect(json['format'], 3);
      expect((json['settings'] as Map)['defaultClockIn'], '09:30');
      expect((json['settings'] as Map)['defaultClockOut'], '18:30');
      expect(decodeBackup(encodeBackup(withTimes)), withTimes);
    });

    test('값이 없는 파일(예전 파일)은 null — 가져오면 08:00 · 17:00', () {
      final settings = (jsonDecode(encodeBackup(snapshot)) as Map<String, dynamic>)['settings'] as Map;
      expect((settings['defaultClockIn'], settings['defaultClockOut']), (null, null));
      final old = decodeBackup(withPatch((j) => j..['settings'] = {'weekStart': 'sunday', 'hourlyWage': 12500}));
      expect((old.defaultClockInMinutes, old.defaultClockOutMinutes), (null, null));
    });

    test('하나만 있음 · 형식 틀림 · 하루 밖 · 퇴근 ≤ 출근은 둘 다 버린다', () {
      for (final (clockIn, clockOut) in <(Object?, Object?)>[
        ('09:30', null),
        (null, '18:30'),
        ('9:30', '18:30'),
        ('09:30', '24:00'),
        ('09:30', '18:60'),
        (570, 1110),
        ('18:30', '09:30'),
        ('09:30', '09:30'),
      ]) {
        final s = decodeBackup(patched(clockIn, clockOut));
        expect((s.defaultClockInMinutes, s.defaultClockOutMinutes), (null, null), reason: '$clockIn–$clockOut');
      }
    });
  });

  test('format 1 파일의 annualLeaveDaysByYear는 일 × 480 · 기준일 1/1로 받는다 (범위 밖은 그 해 제거)', () {
    final s = decodeBackup(withPatch((j) => j
      ..['format'] = 1
      ..['settings'] = {'weekStart': 'monday', 'annualLeaveDaysByYear': {'2026': 15, '2027': 0, '2028': 100}, 'hourlyWage': null}));
    expect(s.leaveBalanceByYear, {2026: LeaveBalance(remainingMinutes: 7200, baseDate: DateTime(2026, 1, 1))});
  });

  test('범위 밖·단위 안 맞음·기준일 파싱 실패는 그 해만 버린다', () {
    final s = decodeBackup(withPatch((j) => j..['settings'] = {...j['settings'] as Map, 'leaveBalanceByYear': {
      '2026': {'remainingMinutes': 120, 'baseDate': '2026-10-26'},
      '2027': {'remainingMinutes': 4080, 'baseDate': 'nope'},
      '2028': {'remainingMinutes': 0, 'baseDate': '2028-03-01'},
      '2029': {'remainingMinutes': 99 * 480 + 240, 'baseDate': '2029-03-01'},
      '2030': 'junk',
    }}));
    expect(s.leaveBalanceByYear, {2028: LeaveBalance(remainingMinutes: 0, baseDate: DateTime(2028, 3, 1))});
  });

  test('범위 밖 값은 거른다 — 시급 0·8자리는 null, 퇴근<출근은 시각 제거', () {
    expect(decodeBackup(withPatch((j) => j..['settings'] = {...j['settings'] as Map, 'hourlyWage': 0})).hourlyWage, isNull);
    expect(decodeBackup(withPatch((j) => j..['settings'] = {...j['settings'] as Map, 'hourlyWage': 10000000})).hourlyWage, isNull);
    expect(decodeBackup(withPatch((j) => j..['settings'] = {...j['settings'] as Map, 'hourlyWage': 9999999})).hourlyWage, 9999999);
    final bad = decodeBackup(withPatch((j) => j..['records'] = [
          {'date': '2026-09-14T00:00:00.000', 'clockIn': '2026-09-14T18:00:00.000', 'clockOut': '2026-09-14T09:00:00.000', 'type': 'normal', 'deductionMinutes': 0},
        ]));
    expect(bad.records.single.clockIn, isNull);
    expect(bad.records.single.clockOut, isNull);
  });

  test('시간 출장 범위가 왕복되고, format 2 파일(범위 없음)도 읽힌다', () {
    final s = snapshot.copyWith(records: [rec(14, inH: 9, outH: 18, tripInH: 9, tripInM: 20, tripOutH: 12, tripOutM: 30)]);
    expect(decodeBackup(encodeBackup(s)), s);
    final v2 = decodeBackup(withPatch((j) => j..['format'] = 2));
    expect(v2.records, snapshot.records);
    expect(v2.records.every((r) => r.tripStart == null && r.tripEnd == null), isTrue);
  });

  test('끝 ≤ 시작이거나 하나만 있는 출장 범위는 둘 다 버린다 — 출퇴근은 그대로', () {
    Map<String, dynamic> record(String date, Map<String, dynamic> trip) => {
          'date': '${date}T00:00:00.000',
          'clockIn': '${date}T09:00:00.000',
          'clockOut': '${date}T18:00:00.000',
          'type': 'normal',
          'deductionMinutes': 0,
          ...trip,
        };
    final decoded = decodeBackup(withPatch((j) => j
      ..['records'] = [
        record('2026-09-14', {'tripStart': '2026-09-14T12:00:00.000', 'tripEnd': '2026-09-14T09:00:00.000'}),
        record('2026-09-15', {'tripStart': '2026-09-15T09:00:00.000'}),
      ]));
    expect(decoded.records, hasLength(2));
    for (final r in decoded.records) {
      expect((r.tripStart, r.tripEnd), (null, null));
      expect(r.clockIn, isNotNull);
      expect(r.clockOut, isNotNull);
    }
  });
}

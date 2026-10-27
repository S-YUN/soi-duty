import 'dart:convert';

import '../model/app_settings.dart';
import '../model/backup_snapshot.dart';
import '../model/leave_balance.dart';
import '../model/work_record.dart';
import '../rules/work_calculator.dart';
import '../rules/work_rules.dart';

/// 백업 파일 형식 버전. 읽을 수 있는 최대 버전이기도 하다 — 더 큰 값은 새 앱이 쓴 파일이라 거부한다.
/// 1: `settings.annualLeaveDaysByYear`(총 연차, 정수 일) · 2: `settings.leaveBalanceByYear`(남은 연차 분 + 기준일, 2026-10-27).
const backupFormatVersion = 2;
const _appId = 'soi_duty';

class BackupFormatException implements Exception {
  const BackupFormatException(this.reason);

  final String reason;

  @override
  String toString() => 'BackupFormatException: $reason';
}

/// 스펙 §5 모양. 날짜는 local ISO(Z 없음), 첫 기록일은 'yyyy-MM-dd'.
String encodeBackup(BackupSnapshot s) => const JsonEncoder.withIndent('  ').convert({
      'app': _appId,
      'format': backupFormatVersion,
      'exportedAt': s.exportedAt.toIso8601String(),
      'firstRecordDate': s.firstRecordDate == null ? null : _dateKey(s.firstRecordDate!),
      'settings': {
        'weekStart': s.weekStart.name,
        'leaveBalanceByYear': {
          for (final e in s.leaveBalanceByYear.entries)
            '${e.key}': {'remainingMinutes': e.value.remainingMinutes, 'baseDate': _dateKey(e.value.baseDate)},
        },
        'hourlyWage': s.hourlyWage,
      },
      'records': [for (final r in s.records) r.toJson()],
    });

/// 내보낸 파일이 아니거나 읽을 수 없으면 [BackupFormatException].
BackupSnapshot decodeBackup(String text, {WorkRules rules = const WorkRules()}) {
  final Object? root;
  try {
    root = jsonDecode(text);
  } on FormatException catch (e) {
    throw BackupFormatException('JSON이 아님: ${e.message}');
  }
  if (root is! Map<String, dynamic>) throw const BackupFormatException('최상위가 객체가 아님');
  if (root['app'] != _appId) throw const BackupFormatException('이 앱의 백업 파일이 아님');
  final format = root['format'];
  if (format is! int || format < 1 || format > backupFormatVersion) {
    throw BackupFormatException('지원하지 않는 형식 버전: $format');
  }
  final records = root['records'];
  if (records is! List) throw const BackupFormatException('records가 배열이 아님');
  final settings = root['settings'];
  final settingsMap = settings is Map<String, dynamic> ? settings : const <String, dynamic>{};
  try {
    final wage = (settingsMap['hourlyWage'] as num?)?.toInt();
    // 손으로 고친 파일의 범위 밖 값은 UI가 허용하는 범위로 거른다 — 시급 0이 "설정됨"으로 보이지 않게.
    return BackupSnapshot(
      exportedAt: DateTime.parse(root['exportedAt'] as String),
      firstRecordDate: root['firstRecordDate'] == null ? null : DateTime.parse(root['firstRecordDate'] as String),
      weekStart: WeekStart.values.asNameMap()[settingsMap['weekStart']] ?? WeekStart.monday,
      leaveBalanceByYear: format == 1 ? _legacyLeave(settingsMap['annualLeaveDaysByYear'], rules) : _leave(settingsMap['leaveBalanceByYear'], rules),
      hourlyWage: wage != null && AppSettings.isValidHourlyWage(wage) ? wage : null,
      records: [for (final r in records) _dropInvalidRange(WorkRecord.fromJson(r as Map<String, dynamic>))],
    );
  } on BackupFormatException {
    rethrow;
  } catch (e) {
    throw BackupFormatException('내용을 읽을 수 없음: $e');
  }
}

/// format 2: {"2026": {"remainingMinutes": 4080, "baseDate": "2026-10-26"}}. 범위 밖·단위 안 맞음·기준일 파싱 실패·모양 다름은 그 해만 버린다.
Map<int, LeaveBalance> _leave(Object? byYear, WorkRules rules) {
  if (byYear is! Map<String, dynamic>) return const {};
  final out = <int, LeaveBalance>{};
  for (final e in byYear.entries) {
    final year = int.tryParse(e.key);
    final v = e.value;
    if (year == null || v is! Map<String, dynamic>) continue;
    final minutes = v['remainingMinutes'];
    final base = v['baseDate'];
    if (minutes is! num || base is! String) continue;
    final m = minutes.toInt();
    final d = DateTime.tryParse(base);
    if (d == null || !isValidLeaveMinutes(m, rules)) continue;
    out[year] = LeaveBalance(remainingMinutes: m, baseDate: DateTime(d.year, d.month, d.day));
  }
  return out;
}

/// format 1: {"2026": 15} = 그 해 총 연차(정수 일) → 일 × 하루 분, 기준일 1월 1일 (옛 계산과 같은 뜻). 1~99 밖은 그 해 제거.
Map<int, LeaveBalance> _legacyLeave(Object? byYear, WorkRules rules) {
  if (byYear is! Map<String, dynamic>) return const {};
  return {
    for (final e in byYear.entries)
      if (int.tryParse(e.key) != null && e.value is num && (e.value as num).toInt() >= 1 && (e.value as num).toInt() <= AppSettings.maxLeaveDays)
        int.parse(e.key): LeaveBalance(
          remainingMinutes: (e.value as num).toInt() * rules.dayOffCreditMinutes,
          baseDate: DateTime(int.parse(e.key), 1, 1),
        ),
  };
}

/// 자정 넘김 미지원 — 퇴근 < 출근이면 시각 둘 다 버린다(기록 안 된 날로).
WorkRecord _dropInvalidRange(WorkRecord r) =>
    isValidClockRange(r.clockIn, r.clockOut) ? r : r.copyWith(clockIn: null, clockOut: null);

String _dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

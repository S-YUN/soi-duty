
import '../../domain/model/app_settings.dart';
import '../../domain/model/leave_balance.dart';
import '../../domain/rules/work_rules.dart';
import '../../domain/repository/app_settings_repository.dart';
import '../database/app_database.dart';
import 'drift_work_record_repository.dart' show dateKey, parseDateKey;

/// 기존 Settings(key/value) 테이블에 키로 저장한다. 스키마 변경 없음.
/// `first_record_date`는 [DriftWorkRecordRepository]의 것 — 여기서는 읽지도 쓰지도 않는다.
///
/// 연차는 해마다 `leave_remaining_minutes_<year>` + `leave_base_date_<year>` 두 키. 옛 키 `annual_leave_days_<year>`(총 연차, 정수 일)는
/// 읽을 때만 "일 × 하루 분, 기준일 1월 1일"로 변환하고(지금 계산과 같은 뜻), 저장할 때 지운다 — 첫 저장이 마이그레이션이다 (2026-10-27).
class DriftAppSettingsRepository implements AppSettingsRepository {
  DriftAppSettingsRepository(this._db, {this.rules = const WorkRules()});

  static const weekStartKey = 'week_start';
  static const leaveMinutesKeyPrefix = 'leave_remaining_minutes_';
  static const leaveBaseDateKeyPrefix = 'leave_base_date_';
  static const legacyAnnualLeaveDaysKeyPrefix = 'annual_leave_days_';
  static const hourlyWageKey = 'hourly_wage';
  static const lastExportDateKey = 'last_export_date';
  static const _leavePrefixes = [leaveMinutesKeyPrefix, leaveBaseDateKeyPrefix, legacyAnnualLeaveDaysKeyPrefix];

  final AppDatabase _db;
  final WorkRules rules;

  @override
  Stream<AppSettings> watch() => _db.select(_db.settings).watch().map(fromRows);

  /// 일회성 읽기. 스트림의 `.first`는 위젯 테스트의 가짜 시간에서 값을 내지 않아 쓰지 않는다.
  Future<AppSettings> read() async => fromRows(await _db.select(_db.settings).get());

  @override
  Future<void> save(AppSettings s) => _db.transaction(() async {
        await _put(weekStartKey, s.weekStart.name);
        await _put(hourlyWageKey, s.hourlyWage?.toString());
        await _put(lastExportDateKey, s.lastExportDate == null ? null : dateKey(s.lastExportDate!));
        // LIKE의 '_'는 한 글자 와일드카드라 비슷한 키가 휩쓸린다 — Dart에서 접두사로 고른다.
        final leaveKeys = (await _db.select(_db.settings).get())
            .map((r) => r.key)
            .where((k) => _leavePrefixes.any(k.startsWith))
            .toList();
        if (leaveKeys.isNotEmpty) await (_db.delete(_db.settings)..where((t) => t.key.isIn(leaveKeys))).go();
        for (final e in s.leaveBalanceByYear.entries) {
          await _put('$leaveMinutesKeyPrefix${e.key}', e.value.remainingMinutes.toString());
          await _put('$leaveBaseDateKeyPrefix${e.key}', dateKey(e.value.baseDate));
        }
      });

  Future<void> _put(String key, String? value) {
    if (value == null) return (_db.delete(_db.settings)..where((t) => t.key.equals(key))).go();
    return _db.into(_db.settings).insertOnConflictUpdate(SettingsCompanion.insert(key: key, value: value));
  }

  AppSettings fromRows(List<SettingRow> rows) {
    var s = const AppSettings();
    final minutesByYear = <int, int>{};
    final baseByYear = <int, DateTime>{};
    final legacyDaysByYear = <int, int>{};
    for (final row in rows) {
      switch (row.key) {
        case weekStartKey:
          s = s.copyWith(weekStart: WeekStart.values.asNameMap()[row.value] ?? WeekStart.monday);
        case hourlyWageKey:
          s = s.copyWith(hourlyWage: int.tryParse(row.value));
        case lastExportDateKey:
          s = s.copyWith(lastExportDate: _tryParseDate(row.value));
        default:
          _collectYearKey(row, leaveMinutesKeyPrefix, (y) => minutesByYear[y] = int.parse(row.value));
          _collectYearKey(row, leaveBaseDateKeyPrefix, (y) {
            final d = _tryParseDate(row.value);
            if (d != null) baseByYear[y] = d;
          });
          _collectYearKey(row, legacyAnnualLeaveDaysKeyPrefix, (y) => legacyDaysByYear[y] = int.parse(row.value));
      }
    }
    final byYear = <int, LeaveBalance>{
      for (final e in legacyDaysByYear.entries)
        e.key: LeaveBalance(remainingMinutes: e.value * rules.dayOffCreditMinutes, baseDate: DateTime(e.key, 1, 1)),
      for (final e in minutesByYear.entries)
        if (baseByYear[e.key] != null) e.key: LeaveBalance(remainingMinutes: e.value, baseDate: baseByYear[e.key]!),
    };
    return s.copyWith(leaveBalanceByYear: byYear);
  }

  /// `<prefix><year>` 꼴이고 값이 정수로 읽히면 [put]. 아니면 무시.
  static void _collectYearKey(SettingRow row, String prefix, void Function(int year) put) {
    if (!row.key.startsWith(prefix)) return;
    final year = int.tryParse(row.key.substring(prefix.length));
    if (year == null) return;
    try {
      put(year);
    } on FormatException {
      // 손상된 값 — 그 해는 없는 것
    }
  }

  static DateTime? _tryParseDate(String value) {
    try {
      return parseDateKey(value);
    } on FormatException {
      return null;
    }
  }
}

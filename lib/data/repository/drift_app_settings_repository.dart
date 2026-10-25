import 'package:drift/drift.dart';

import '../../domain/model/app_settings.dart';
import '../../domain/repository/app_settings_repository.dart';
import '../database/app_database.dart';
import 'drift_work_record_repository.dart' show dateKey, parseDateKey;

/// 기존 Settings(key/value) 테이블에 키로 저장한다. 스키마 변경 없음.
/// `first_record_date`는 [DriftWorkRecordRepository]의 것 — 여기서는 읽지도 쓰지도 않는다.
class DriftAppSettingsRepository implements AppSettingsRepository {
  DriftAppSettingsRepository(this._db);

  static const weekStartKey = 'week_start';
  static const annualLeaveDaysKeyPrefix = 'annual_leave_days_';
  static const hourlyWageKey = 'hourly_wage';
  static const lastExportDateKey = 'last_export_date';

  final AppDatabase _db;

  @override
  Stream<AppSettings> watch() => _db.select(_db.settings).watch().map(fromRows);

  /// 일회성 읽기. 스트림의 `.first`는 위젯 테스트의 가짜 시간에서 값을 내지 않아 쓰지 않는다.
  Future<AppSettings> read() async => fromRows(await _db.select(_db.settings).get());

  @override
  Future<void> save(AppSettings s) => _db.transaction(() async {
        await _put(weekStartKey, s.weekStart.name);
        await _put(hourlyWageKey, s.hourlyWage?.toString());
        await _put(lastExportDateKey, s.lastExportDate == null ? null : dateKey(s.lastExportDate!));
        await (_db.delete(_db.settings)..where((t) => t.key.like('$annualLeaveDaysKeyPrefix%'))).go();
        for (final e in s.annualLeaveDaysByYear.entries) {
          await _put('$annualLeaveDaysKeyPrefix${e.key}', e.value.toString());
        }
      });

  Future<void> _put(String key, String? value) {
    if (value == null) return (_db.delete(_db.settings)..where((t) => t.key.equals(key))).go();
    return _db.into(_db.settings).insertOnConflictUpdate(SettingsCompanion.insert(key: key, value: value));
  }

  static AppSettings fromRows(List<SettingRow> rows) {
    var s = const AppSettings();
    final byYear = <int, int>{};
    for (final row in rows) {
      switch (row.key) {
        case weekStartKey:
          s = s.copyWith(weekStart: WeekStart.values.asNameMap()[row.value] ?? WeekStart.monday);
        case hourlyWageKey:
          s = s.copyWith(hourlyWage: int.tryParse(row.value));
        case lastExportDateKey:
          s = s.copyWith(lastExportDate: _tryParseDate(row.value));
        default:
          if (row.key.startsWith(annualLeaveDaysKeyPrefix)) {
            final year = int.tryParse(row.key.substring(annualLeaveDaysKeyPrefix.length));
            final days = int.tryParse(row.value);
            if (year != null && days != null) byYear[year] = days;
          }
      }
    }
    return s.copyWith(annualLeaveDaysByYear: byYear);
  }

  static DateTime? _tryParseDate(String value) {
    try {
      return parseDateKey(value);
    } on FormatException {
      return null;
    }
  }
}


import '../../domain/model/backup_snapshot.dart';
import '../../domain/repository/backup_repository.dart';
import '../../domain/rules/work_calculator.dart';
import '../../domain/rules/work_rules.dart';
import '../database/app_database.dart';
import 'drift_app_settings_repository.dart';
import 'drift_work_record_repository.dart';

/// 기록·첫 기록일·설정을 한 번에 담고(snapshot) 한 트랜잭션으로 바꾼다(restore).
class DriftBackupRepository implements BackupRepository {
  DriftBackupRepository(this._db, {this.rules = const WorkRules()})
      : _records = DriftWorkRecordRepository(_db, rules: rules),
        _settings = DriftAppSettingsRepository(_db);

  final AppDatabase _db;
  final WorkRules rules;
  final DriftWorkRecordRepository _records;
  final DriftAppSettingsRepository _settings;

  @override
  Future<BackupSnapshot> snapshot(DateTime now) async {
    final settings = await _settings.watch().first;
    return BackupSnapshot(
      exportedAt: now,
      firstRecordDate: await _records.watchFirstRecordDate().first,
      weekStart: settings.weekStart,
      annualLeaveDaysByYear: settings.annualLeaveDaysByYear,
      hourlyWage: settings.hourlyWage,
      records: await _records.watchAll().first,
    );
  }

  @override
  Future<void> restore(BackupSnapshot s) => _db.transaction(() async {
        await _db.delete(_db.workRecords).go();
        for (final r in s.records) {
          // 다른 폰에서 온 기록도 같은 불변식을 지나게 한다(쉬는 날의 시각·공제 등).
          await _db.into(_db.workRecords).insertOnConflictUpdate(
                DriftWorkRecordRepository.toCompanion(sanitizeRecord(r, rules)),
              );
        }
        final first = s.firstRecordDate ??
            (s.records.isEmpty ? null : s.records.map((r) => r.date).reduce((a, b) => a.isBefore(b) ? a : b));
        final firstKey = DriftWorkRecordRepository.firstRecordDateKey;
        if (first == null) {
          await (_db.delete(_db.settings)..where((t) => t.key.equals(firstKey))).go();
        } else {
          await _db.into(_db.settings).insertOnConflictUpdate(SettingsCompanion.insert(key: firstKey, value: dateKey(first)));
        }
        final current = await _settings.watch().first;
        await _settings.save(current.copyWith(
          weekStart: s.weekStart,
          annualLeaveDaysByYear: s.annualLeaveDaysByYear,
          hourlyWage: s.hourlyWage,
        ));
      });

  @override
  Future<int> recordCount() async => (await _db.select(_db.workRecords).get()).length;
}

import 'package:drift/drift.dart';

import '../../domain/model/work_record.dart';
import '../../domain/repository/work_record_repository.dart';
import '../../domain/rules/work_calculator.dart';
import '../../domain/rules/work_rules.dart';
import '../database/app_database.dart';

String dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime parseDateKey(String key) {
  final parts = key.split('-').map(int.parse).toList();
  return DateTime(parts[0], parts[1], parts[2]);
}

class DriftWorkRecordRepository implements WorkRecordRepository {
  DriftWorkRecordRepository(this._db, {this.rules = const WorkRules()});

  static const firstRecordDateKey = 'first_record_date';

  final AppDatabase _db;

  /// 저장 직전 정리([sanitizeRecord])에 쓰는 규칙 — 시간공제 한도.
  final WorkRules rules;

  @override
  Stream<List<WorkRecord>> watchAll() =>
      _db.select(_db.workRecords).watch().map((rows) => rows.map(_toDomain).toList());

  @override
  Stream<DateTime?> watchFirstRecordDate() => (_db.select(_db.settings)
        ..where((s) => s.key.equals(firstRecordDateKey)))
      .watchSingleOrNull()
      .map((row) => row == null ? null : parseDateKey(row.value));

  @override
  Future<void> save(WorkRecord input) => _db.transaction(() async {
        // 쉬는 날의 공제·연차의 시각 같은 모순은 여기 한 곳에서 걷어낸다.
        final record = sanitizeRecord(input, rules);
        await _db.into(_db.workRecords).insertOnConflictUpdate(_toCompanion(record));
        final first = await (_db.select(_db.settings)..where((s) => s.key.equals(firstRecordDateKey)))
            .getSingleOrNull();
        final current = first == null ? null : parseDateKey(first.value);
        if (current == null || record.date.isBefore(current)) {
          await _db.into(_db.settings).insertOnConflictUpdate(
                SettingsCompanion.insert(key: firstRecordDateKey, value: dateKey(record.date)),
              );
        }
      });

  @override
  Future<void> delete(DateTime date) =>
      (_db.delete(_db.workRecords)..where((t) => t.date.equals(dateKey(date)))).go();

  static WorkRecord _toDomain(WorkRecordRow row) => WorkRecord(
        date: parseDateKey(row.date),
        clockIn: row.clockIn,
        clockOut: row.clockOut,
        type: row.type,
        deductionMinutes: row.deductionMinutes,
      );

  static WorkRecordsCompanion _toCompanion(WorkRecord r) => WorkRecordsCompanion.insert(
        date: dateKey(r.date),
        clockIn: Value(r.clockIn),
        clockOut: Value(r.clockOut),
        type: r.type,
        deductionMinutes: Value(r.deductionMinutes),
      );
}

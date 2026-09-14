import 'package:drift/drift.dart';

import '../../domain/model/work_record.dart';
import '../../domain/repository/work_record_repository.dart';
import '../database/app_database.dart';

String dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime parseDateKey(String key) {
  final parts = key.split('-').map(int.parse).toList();
  return DateTime(parts[0], parts[1], parts[2]);
}

class DriftWorkRecordRepository implements WorkRecordRepository {
  DriftWorkRecordRepository(this._db);

  static const firstRecordDateKey = 'first_record_date';

  final AppDatabase _db;

  @override
  Stream<List<WorkRecord>> watchAll() =>
      _db.select(_db.workRecords).watch().map((rows) => rows.map(_toDomain).toList());

  @override
  Stream<DateTime?> watchFirstRecordDate() => (_db.select(_db.settings)
        ..where((s) => s.key.equals(firstRecordDateKey)))
      .watchSingleOrNull()
      .map((row) => row == null ? null : parseDateKey(row.value));

  @override
  Future<void> save(WorkRecord record) => _db.transaction(() async {
        await _db.into(_db.workRecords).insertOnConflictUpdate(_toCompanion(record));
        final first = await (_db.select(_db.settings)..where((s) => s.key.equals(firstRecordDateKey)))
            .getSingleOrNull();
        if (first == null) {
          await _db.into(_db.settings).insert(
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
      );

  static WorkRecordsCompanion _toCompanion(WorkRecord r) => WorkRecordsCompanion.insert(
        date: dateKey(r.date),
        clockIn: Value(r.clockIn),
        clockOut: Value(r.clockOut),
        type: r.type,
      );
}

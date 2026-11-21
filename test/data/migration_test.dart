import 'package:drift/drift.dart' hide isNull;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/data/database/app_database.dart';
import 'package:soi_duty/data/repository/drift_work_record_repository.dart';
import 'package:soi_duty/domain/model/work_type.dart';

import '../generated_migrations/schema.dart';
import '../helpers/records.dart';

/// 친구들 폰에 깔린 v1 DB가 업데이트 후에도 그대로 읽히는지. drift_schemas/의 덤프가 기준이다.
void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    verifier = SchemaVerifier(GeneratedHelper());
  });

  test('v1 → 현재 스키마가 일치한다', () async {
    final connection = await verifier.startAt(1);
    final db = AppDatabase(connection);
    await verifier.migrateAndValidate(db, 3);
    await db.close();
  });

  test('v1 기록·첫 기록일이 현재 스키마에서 그대로 읽히고 공제는 0', () async {
    final schema = await verifier.schemaAt(1);
    int secs(DateTime t) => t.millisecondsSinceEpoch ~/ 1000;
    schema.rawDatabase.execute(
      "INSERT INTO work_records (date, clock_in, clock_out, type) VALUES ('2026-09-14', ?, ?, 'halfDay')",
      [secs(d(14, 13)), secs(d(14, 17))],
    );
    schema.rawDatabase.execute("INSERT INTO settings (key, value) VALUES ('first_record_date', '2026-09-14')");

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 3);
    final repo = DriftWorkRecordRepository(db);
    final r = (await repo.watchAll().first).single;
    expect(r.type, WorkType.halfDay);
    expect((r.clockIn, r.clockOut), (d(14, 13), d(14, 17)));
    expect(r.deductionMinutes, 0);
    expect(await repo.watchFirstRecordDate().first, d(14));
    await db.close();
  });

  test('v1 → v3 · v2 → v3 스키마가 일치한다', () async {
    for (final from in [1, 2]) {
      final connection = await verifier.startAt(from);
      final db = AppDatabase(connection);
      await verifier.migrateAndValidate(db, 3);
      await db.close();
    }
  });

  test('v2 기록·공제·첫 기록일이 v3에서 그대로 읽히고 출장 범위는 null', () async {
    final schema = await verifier.schemaAt(2);
    int secs(DateTime t) => t.millisecondsSinceEpoch ~/ 1000;
    schema.rawDatabase.execute(
      "INSERT INTO work_records (date, clock_in, clock_out, type, deduction_minutes) VALUES ('2026-09-14', ?, ?, 'normal', 120)",
      [secs(d(14, 9)), secs(d(14, 16))],
    );
    schema.rawDatabase.execute("INSERT INTO work_records (date, type, deduction_minutes) VALUES ('2026-09-15', 'dayOff', 0)");
    schema.rawDatabase.execute("INSERT INTO settings (key, value) VALUES ('first_record_date', '2026-09-14')");
    schema.rawDatabase.execute("INSERT INTO settings (key, value) VALUES ('hourly_wage', '12500')");

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 3);
    final repo = DriftWorkRecordRepository(db);
    final all = await repo.watchAll().first;
    expect(all, hasLength(2));
    final worked = all.firstWhere((r) => r.date == d(14));
    expect((worked.clockIn, worked.clockOut), (d(14, 9), d(14, 16)));
    expect(worked.deductionMinutes, 120);
    expect(all.firstWhere((r) => r.date == d(15)).type, WorkType.dayOff);
    expect(all.every((r) => r.tripStart == null && r.tripEnd == null), isTrue);
    expect(await repo.watchFirstRecordDate().first, d(14));
    final wage = await (db.select(db.settings)..where((t) => t.key.equals('hourly_wage'))).getSingle();
    expect(wage.value, '12500');
    await db.close();
  });
}

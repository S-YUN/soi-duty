import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/data/database/app_database.dart';
import 'package:soi_duty/data/repository/drift_app_settings_repository.dart';
import 'package:soi_duty/data/repository/drift_backup_repository.dart';
import 'package:soi_duty/data/repository/drift_work_record_repository.dart';
import 'package:soi_duty/domain/model/app_settings.dart';
import 'package:soi_duty/domain/model/backup_snapshot.dart';
import 'package:soi_duty/domain/model/work_type.dart';

import '../helpers/records.dart';

void main() {
  late AppDatabase db;
  late DriftWorkRecordRepository records;
  late DriftAppSettingsRepository settings;
  late DriftBackupRepository backup;

  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    records = DriftWorkRecordRepository(db);
    settings = DriftAppSettingsRepository(db);
    backup = DriftBackupRepository(db);
  });

  tearDown(() => db.close());

  Future<String?> settingValue(String key) async =>
      (await (db.select(db.settings)..where((t) => t.key.equals(key))).getSingleOrNull())?.value;

  test('restore — 기존 3건이 파일 2건으로 바뀌고 첫 기록일은 파일 값, 설정 세 값 덮어쓰고 last_export_date 유지', () async {
    for (final r in [rec(7, inH: 9, outH: 18), rec(8, inH: 9, outH: 18), rec(9, type: WorkType.dayOff)]) {
      await records.save(r);
    }
    await settings.save(AppSettings(hourlyWage: 10000, annualLeaveDaysByYear: const {2026: 10}, lastExportDate: DateTime(2026, 10, 24)));

    await backup.restore(BackupSnapshot(
      exportedAt: DateTime(2026, 10, 25),
      firstRecordDate: DateTime(2026, 9, 14),
      weekStart: WeekStart.sunday,
      annualLeaveDaysByYear: const {2026: 15},
      hourlyWage: 12500,
      records: [rec(14, inH: 9, outH: 18), rec(15, type: WorkType.dayOff)],
    ));

    expect(await records.watchAll().first, [rec(14, inH: 9, outH: 18), rec(15, type: WorkType.dayOff)]);
    expect(await records.watchFirstRecordDate().first, DateTime(2026, 9, 14));
    expect(
      await settings.watch().first,
      AppSettings(weekStart: WeekStart.sunday, annualLeaveDaysByYear: const {2026: 15}, hourlyWage: 12500, lastExportDate: DateTime(2026, 10, 24)),
    );
    expect(await backup.recordCount(), 2);
  });

  test('restore — firstRecordDate null이면 최소 날짜, 기록 0건이면 first_record_date 행 삭제', () async {
    await records.save(rec(7, inH: 9, outH: 18));
    await backup.restore(BackupSnapshot(
      exportedAt: DateTime(2026, 10, 25),
      weekStart: WeekStart.monday,
      annualLeaveDaysByYear: const {},
      records: [rec(16, inH: 9, outH: 18), rec(15, type: WorkType.dayOff)],
    ));
    expect(await records.watchFirstRecordDate().first, d(15));

    await backup.restore(BackupSnapshot(
      exportedAt: DateTime(2026, 10, 25),
      weekStart: WeekStart.monday,
      annualLeaveDaysByYear: const {},
      records: const [],
    ));
    expect(await records.watchAll().first, isEmpty);
    expect(await settingValue('first_record_date'), isNull);
  });

  test('restore — 오늘 출근만 찍힌 기록이 그대로 복원되고, 모순 기록은 sanitize된다', () async {
    await backup.restore(BackupSnapshot(
      exportedAt: DateTime(2026, 10, 25),
      weekStart: WeekStart.monday,
      annualLeaveDaysByYear: const {},
      records: [rec(16, inH: 9, inM: 12), rec(15, inH: 9, outH: 18, type: WorkType.dayOff, ded: 60)],
    ));
    final all = await records.watchAll().first;
    expect(all, contains(rec(16, inH: 9, inM: 12)));
    expect(all, contains(rec(15, type: WorkType.dayOff))); // 연차는 시각·공제 없음
  });

  test('snapshot — 현재 기록·첫 기록일·설정이 담기고 lastExportDate는 담기지 않는다', () async {
    await records.save(rec(14, inH: 9, outH: 18));
    await records.save(rec(10, type: WorkType.halfDay));
    await settings.save(AppSettings(weekStart: WeekStart.sunday, annualLeaveDaysByYear: const {2026: 15}, hourlyWage: 12500, lastExportDate: DateTime(2026, 10, 24)));
    final s = await backup.snapshot(DateTime(2026, 10, 25, 9, 12));
    expect(s.exportedAt, DateTime(2026, 10, 25, 9, 12));
    expect(s.firstRecordDate, d(10));
    expect(s.weekStart, WeekStart.sunday);
    expect(s.annualLeaveDaysByYear, {2026: 15});
    expect(s.hourlyWage, 12500);
    expect(s.records, containsAll([rec(14, inH: 9, outH: 18), rec(10, type: WorkType.halfDay)]));
  });
}

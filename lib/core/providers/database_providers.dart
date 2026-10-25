import 'package:drift_flutter/drift_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/database/app_database.dart';
import '../../data/repository/drift_app_settings_repository.dart';
import '../../data/repository/drift_work_record_repository.dart';
import '../../domain/model/app_settings.dart';
import '../../domain/model/work_record.dart';
import '../../domain/repository/app_settings_repository.dart';
import '../../domain/repository/work_record_repository.dart';
import '../../domain/rules/work_rules.dart';

part 'database_providers.g.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase(driftDatabase(name: 'soi_duty'));
  ref.onDispose(db.close);
  return db;
}

@Riverpod(keepAlive: true)
WorkRecordRepository workRecordRepository(Ref ref) =>
    DriftWorkRecordRepository(ref.watch(appDatabaseProvider), rules: ref.watch(workRulesProvider));

@Riverpod(keepAlive: true)
WorkRules workRules(Ref ref) => const WorkRules();

@riverpod
Stream<List<WorkRecord>> allRecords(Ref ref) => ref.watch(workRecordRepositoryProvider).watchAll();

@riverpod
Stream<DateTime?> firstRecordDate(Ref ref) =>
    ref.watch(workRecordRepositoryProvider).watchFirstRecordDate();

@Riverpod(keepAlive: true)
AppSettingsRepository appSettingsRepository(Ref ref) => DriftAppSettingsRepository(ref.watch(appDatabaseProvider));

@riverpod
Stream<AppSettings> appSettings(Ref ref) => ref.watch(appSettingsRepositoryProvider).watch();

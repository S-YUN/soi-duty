import 'package:drift_flutter/drift_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/database/app_database.dart';
import '../../data/repository/drift_work_record_repository.dart';
import '../../domain/model/work_record.dart';
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
    DriftWorkRecordRepository(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
WorkRules workRules(Ref ref) => const WorkRules();

@riverpod
Stream<List<WorkRecord>> allRecords(Ref ref) => ref.watch(workRecordRepositoryProvider).watchAll();

@riverpod
Stream<DateTime?> firstRecordDate(Ref ref) =>
    ref.watch(workRecordRepositoryProvider).watchFirstRecordDate();

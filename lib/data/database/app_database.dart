import 'package:drift/drift.dart';

import '../../domain/model/work_type.dart';

part 'app_database.g.dart';

@DataClassName('WorkRecordRow')
class WorkRecords extends Table {
  /// 'yyyy-MM-dd'. DateTime 컬럼은 UTC로 저장돼 날짜가 밀릴 수 있어 문자열 키를 쓴다.
  TextColumn get date => text()();
  DateTimeColumn get clockIn => dateTime().nullable()();
  DateTimeColumn get clockOut => dateTime().nullable()();
  TextColumn get type => textEnum<WorkType>()();
  IntColumn get deductionMinutes => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {date};
}

@DataClassName('SettingRow')
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DriftDatabase(tables: [WorkRecords, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          // v2: 시간공제 (2026-09-27). 기존 행은 공제 0.
          if (from < 2) {
            await m.addColumn(workRecords, workRecords.deductionMinutes);
          }
        },
      );
}

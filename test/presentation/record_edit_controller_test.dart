import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/core/providers/database_providers.dart';
import 'package:soi_duty/data/database/app_database.dart';
import 'package:soi_duty/domain/model/work_record.dart';
import 'package:soi_duty/domain/model/work_type.dart';
import 'package:soi_duty/presentation/record_edit/record_draft.dart';
import 'package:soi_duty/presentation/record_edit/record_edit_controller.dart';

import '../helpers/records.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer.test(overrides: [appDatabaseProvider.overrideWithValue(db)]);
    container.listen(recordEditControllerProvider, (_, _) {});
  });
  tearDown(() => db.close());

  RecordEditController controller() => container.read(recordEditControllerProvider.notifier);
  Future<List<WorkRecord>> all() => container.read(workRecordRepositoryProvider).watchAll().first;

  test('save는 기록을 저장한다', () async {
    final draft = RecordDraft.fromRecord(date: d(14), today: d(16), record: null).withTime(EditingRow.clockIn, 9, 0);
    await controller().save(draft);
    expect((await all()).length, 1);
  });

  test('빈 normal은 저장 대신 삭제한다', () async {
    await container.read(workRecordRepositoryProvider).save(rec(23, type: WorkType.halfDay));
    final draft =
        RecordDraft.fromRecord(date: d(23), today: d(16), record: rec(23, type: WorkType.halfDay)).withType(null);
    await controller().save(draft);
    expect(await all(), isEmpty);
  });

  test('delete', () async {
    await container.read(workRecordRepositoryProvider).save(rec(14, inH: 9, outH: 18));
    await controller().delete(d(14));
    expect(await all(), isEmpty);
  });
}

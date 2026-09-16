import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/core/providers/clock_provider.dart';
import 'package:soi_duty/core/providers/database_providers.dart';
import 'package:soi_duty/data/database/app_database.dart';
import 'package:soi_duty/presentation/week/selected_week.dart';

import '../helpers/records.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer.test(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      clockProvider.overrideWithValue(() => d(16, 12)),
    ]);
    await container.read(workRecordRepositoryProvider).save(rec(2, inH: 9, outH: 18)); // 첫 기록일 9/2(수)
    container.listen(firstRecordDateProvider, (_, _) {});
    await container.read(firstRecordDateProvider.future);
  });
  tearDown(() => db.close());

  test('초기값은 이번 주 월요일, next는 막힘', () {
    final n = container.read(selectedWeekProvider.notifier);
    expect(container.read(selectedWeekProvider), d(14));
    n.next();
    expect(container.read(selectedWeekProvider), d(14));
  });

  test('prev는 첫 기록 주(8/31)까지만', () {
    final n = container.read(selectedWeekProvider.notifier);
    n.prev();
    n.prev();
    expect(container.read(selectedWeekProvider), DateTime(2026, 8, 31));
    n.prev();
    expect(container.read(selectedWeekProvider), DateTime(2026, 8, 31));
    n.next();
    expect(container.read(selectedWeekProvider), d(7));
  });
}

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/data/database/app_database.dart';
import 'package:soi_duty/data/repository/drift_app_settings_repository.dart';
import 'package:soi_duty/domain/model/app_settings.dart';

void main() {
  late AppDatabase db;
  late DriftAppSettingsRepository repo;

  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftAppSettingsRepository(db);
  });

  tearDown(() => db.close());

  test('비어 있으면 기본값', () async => expect(await repo.watch().first, const AppSettings()));

  test('저장한 값이 그대로 읽히고 null은 행을 지운다', () async {
    await repo.save(
      const AppSettings(weekStart: WeekStart.sunday, annualLeaveDaysByYear: {2026: 15, 2027: 16}, hourlyWage: 12500),
    );
    await repo.save((await repo.watch().first).copyWith(lastExportDate: DateTime(2026, 10, 24)));
    expect(
      await repo.watch().first,
      AppSettings(
        weekStart: WeekStart.sunday,
        annualLeaveDaysByYear: const {2026: 15, 2027: 16},
        hourlyWage: 12500,
        lastExportDate: DateTime(2026, 10, 24),
      ),
    );
    expect(
      (await db.select(db.settings).get()).map((r) => r.key),
      containsAll(['annual_leave_days_2026', 'annual_leave_days_2027']),
    );
    await repo.save(const AppSettings(weekStart: WeekStart.sunday));
    expect((await db.select(db.settings).get()).map((r) => r.key), ['week_start']);
  });

  test('first_record_date 행은 건드리지 않는다', () async {
    await db.into(db.settings).insert(SettingsCompanion.insert(key: 'first_record_date', value: '2026-09-14'));
    await repo.save(const AppSettings(hourlyWage: 10000));
    await repo.save(const AppSettings());
    final first = await (db.select(db.settings)..where((t) => t.key.equals('first_record_date'))).getSingle();
    expect(first.value, '2026-09-14');
    expect(await repo.watch().first, const AppSettings());
  });

  test('watch는 save마다 새 값을 흘린다', () async {
    final future = expectLater(
      repo.watch(),
      emitsInOrder([const AppSettings(), const AppSettings(hourlyWage: 9860)]),
    );
    await Future<void>.delayed(Duration.zero);
    await repo.save(const AppSettings(hourlyWage: 9860));
    await future;
  });

  test('annualLeaveDaysOf / withAnnualLeaveDays', () {
    const s = AppSettings(annualLeaveDaysByYear: {2026: 15});
    expect(s.annualLeaveDaysOf(2026), 15);
    expect(s.annualLeaveDaysOf(2027), isNull);
    expect(s.withAnnualLeaveDays(2027, 16).annualLeaveDaysByYear, {2026: 15, 2027: 16});
    expect(s.withAnnualLeaveDays(2026, null).annualLeaveDaysByYear, isEmpty);
  });

  test("'annual_leave_days' 접두 키만 지운다 — LIKE의 '_' 와일드카드에 비슷한 키가 휩쓸리지 않는다", () async {
    await db.into(db.settings).insert(SettingsCompanion.insert(key: 'annual_leave_daysX2026', value: 'keep'));
    await repo.save(const AppSettings(annualLeaveDaysByYear: {2026: 15}));
    await repo.save(const AppSettings());
    final keys = (await db.select(db.settings).get()).map((r) => r.key);
    expect(keys, contains('annual_leave_daysX2026'));
    expect(keys, isNot(contains('annual_leave_days_2026')));
  });
}

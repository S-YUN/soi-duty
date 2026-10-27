import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/data/database/app_database.dart';
import 'package:soi_duty/data/repository/drift_app_settings_repository.dart';
import 'package:soi_duty/domain/model/app_settings.dart';
import 'package:soi_duty/domain/model/leave_balance.dart';

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

  final b26 = LeaveBalance(remainingMinutes: 4080, baseDate: DateTime(2026, 10, 26));
  final b27 = LeaveBalance(remainingMinutes: 7680, baseDate: DateTime(2027, 1, 1));

  test('저장한 값이 그대로 읽히고 null은 행을 지운다', () async {
    await repo.save(AppSettings(weekStart: WeekStart.sunday, leaveBalanceByYear: {2026: b26, 2027: b27}, hourlyWage: 12500));
    await repo.save((await repo.watch().first).copyWith(lastExportDate: DateTime(2026, 10, 24)));
    expect(
      await repo.watch().first,
      AppSettings(
        weekStart: WeekStart.sunday,
        leaveBalanceByYear: {2026: b26, 2027: b27},
        hourlyWage: 12500,
        lastExportDate: DateTime(2026, 10, 24),
      ),
    );
    final rows = (await db.select(db.settings).get()).map((r) => '${r.key}=${r.value}');
    expect(
      rows,
      containsAll([
        'leave_remaining_minutes_2026=4080',
        'leave_base_date_2026=2026-10-26',
        'leave_remaining_minutes_2027=7680',
        'leave_base_date_2027=2027-01-01',
      ]),
    );
    await repo.save(const AppSettings(weekStart: WeekStart.sunday));
    expect((await db.select(db.settings).get()).map((r) => r.key), ['week_start']);
  });

  test('옛 키 annual_leave_days_<year>는 일 × 480 · 기준일 1/1로 읽는다', () async {
    await db.into(db.settings).insert(SettingsCompanion.insert(key: 'annual_leave_days_2026', value: '15'));
    expect((await repo.read()).leaveBalanceOf(2026), LeaveBalance(remainingMinutes: 7200, baseDate: DateTime(2026, 1, 1)));
  });

  test('옛 키와 새 키가 같이 있으면 새 키가 이기고, 저장하면 옛 키가 사라진다', () async {
    await db.into(db.settings).insert(SettingsCompanion.insert(key: 'annual_leave_days_2026', value: '15'));
    await db.into(db.settings).insert(SettingsCompanion.insert(key: 'leave_remaining_minutes_2026', value: '4080'));
    await db.into(db.settings).insert(SettingsCompanion.insert(key: 'leave_base_date_2026', value: '2026-10-26'));
    expect((await repo.read()).leaveBalanceOf(2026), b26);
    await repo.save(await repo.read());
    final keys = (await db.select(db.settings).get()).map((r) => r.key);
    expect(keys, isNot(contains('annual_leave_days_2026')));
    expect(keys, containsAll(['leave_remaining_minutes_2026', 'leave_base_date_2026']));
  });

  test('기준일 키가 없거나 못 읽으면 그 해는 없는 것', () async {
    await db.into(db.settings).insert(SettingsCompanion.insert(key: 'leave_remaining_minutes_2026', value: '4080'));
    await db.into(db.settings).insert(SettingsCompanion.insert(key: 'leave_remaining_minutes_2027', value: '4080'));
    await db.into(db.settings).insert(SettingsCompanion.insert(key: 'leave_base_date_2027', value: 'nope'));
    expect((await repo.read()).leaveBalanceByYear, isEmpty);
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

  test('leaveBalanceOf / withLeaveBalance', () {
    final b26 = LeaveBalance(remainingMinutes: 4080, baseDate: DateTime(2026, 10, 26));
    final b27 = LeaveBalance(remainingMinutes: 7680, baseDate: DateTime(2027, 1, 1));
    final s = AppSettings(leaveBalanceByYear: {2026: b26});
    expect(s.leaveBalanceOf(2026), b26);
    expect(s.leaveBalanceOf(2027), isNull);
    expect(s.withLeaveBalance(2027, b27).leaveBalanceByYear, {2026: b26, 2027: b27});
    expect(s.withLeaveBalance(2026, null).leaveBalanceByYear, isEmpty);
  });

  test("연차 접두 키만 지운다 — LIKE의 '_' 와일드카드에 비슷한 키가 휩쓸리지 않는다", () async {
    await db.into(db.settings).insert(SettingsCompanion.insert(key: 'annual_leave_daysX2026', value: 'keep'));
    await db.into(db.settings).insert(SettingsCompanion.insert(key: 'leave_remaining_minutesX2026', value: 'keep'));
    await repo.save(AppSettings(leaveBalanceByYear: {2026: b26}));
    await repo.save(const AppSettings());
    final keys = (await db.select(db.settings).get()).map((r) => r.key);
    expect(keys, contains('annual_leave_daysX2026'));
    expect(keys, isNot(contains('annual_leave_days_2026')));
  });
}

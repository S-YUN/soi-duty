import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/data/database/app_database.dart';
import 'package:soi_duty/data/repository/drift_app_settings_repository.dart';
import 'package:soi_duty/domain/model/app_settings.dart';
import 'package:soi_duty/domain/model/leave_balance.dart';
import 'package:soi_duty/domain/rules/work_rules.dart';

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

  group('기본 출퇴근 시각 (핸드오프 7)', () {
    Future<void> put(String key, String value) =>
        db.into(db.settings).insertOnConflictUpdate(SettingsCompanion.insert(key: key, value: value));

    test('없으면 null — 읽는 쪽이 WorkRules 기본값(08:00 · 17:00)을 쓴다', () async {
      final s = await repo.read();
      expect((s.defaultClockInMinutes, s.defaultClockOutMinutes), (null, null));
      expect(s.defaultClockTimes(const WorkRules()), (8 * 60, 17 * 60));
    });

    test('HH:mm 두 키로 저장되고 그대로 읽힌다, 다른 설정을 저장해도 남는다', () async {
      await repo.save(const AppSettings().withDefaultClockTimes(9 * 60 + 30, 18 * 60 + 30));
      final rows = (await db.select(db.settings).get()).map((r) => '${r.key}=${r.value}');
      expect(rows, containsAll(['default_clock_in=09:30', 'default_clock_out=18:30']));
      await repo.save((await repo.read()).copyWith(hourlyWage: 12500));
      expect((await repo.read()).defaultClockTimes(const WorkRules()), (9 * 60 + 30, 18 * 60 + 30));
    });

    test('하나만 있거나 · 못 읽거나 · 퇴근 ≤ 출근이면 둘 다 없는 것으로 읽는다', () async {
      await put('default_clock_in', '09:30');
      expect((await repo.read()).defaultClockInMinutes, isNull);
      for (final out in ['nope', '25:00', '9:30', '09:30', '08:00']) {
        await put('default_clock_out', out);
        final s = await repo.read();
        expect((s.defaultClockInMinutes, s.defaultClockOutMinutes), (null, null), reason: out);
      }
    });

    test('못 쓰는 쌍을 저장하면 행을 남기지 않는다', () async {
      await repo.save(const AppSettings().withDefaultClockTimes(9 * 60, 18 * 60));
      await repo.save(const AppSettings(defaultClockInMinutes: 18 * 60, defaultClockOutMinutes: 9 * 60));
      expect((await db.select(db.settings).get()).map((r) => r.key), isNot(contains(startsWith('default_clock'))));
    });
  });

  test('옛 키 annual_leave_days_<year>는 일 × 480 · 기준일 1/1로 읽는다', () async {
    await db.into(db.settings).insert(SettingsCompanion.insert(key: 'annual_leave_days_2026', value: '15'));
    expect((await repo.read()).leaveBalanceOf(2026), LeaveBalance(remainingMinutes: 7200, baseDate: DateTime(2026, 1, 1)));
  });

  test('옛 키 변환은 받은 WorkRules의 하루 분을 쓴다', () async {
    await db.into(db.settings).insert(SettingsCompanion.insert(key: 'annual_leave_days_2026', value: '15'));
    final repo600 = DriftAppSettingsRepository(db, rules: const WorkRules(dayOffCreditMinutes: 600));
    expect((await repo600.read()).leaveBalanceOf(2026)!.remainingMinutes, 15 * 600);
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

  group('퇴근 알림 설정 (기기 값)', () {
    test('기본은 꺼짐·묻지 않음, 저장한 값이 그대로 읽힌다', () async {
      expect((await repo.read()).clockOutNotificationEnabled, isFalse);
      expect((await repo.read()).notificationPrompted, isFalse);
      await repo.save(const AppSettings(clockOutNotificationEnabled: true, notificationPrompted: true));
      final s = await repo.read();
      expect(s.clockOutNotificationEnabled, isTrue);
      expect(s.notificationPrompted, isTrue);
      await repo.save(s.copyWith(clockOutNotificationEnabled: false));
      expect((await repo.read()).clockOutNotificationEnabled, isFalse);
      expect((await repo.read()).notificationPrompted, isTrue, reason: '끈다고 다시 묻지 않는다');
    });

    test('다른 설정을 저장해도 알림 설정·알림 상태 키는 그대로다', () async {
      await repo.save(const AppSettings(clockOutNotificationEnabled: true, notificationPrompted: true));
      await db.into(db.settings).insert(SettingsCompanion.insert(key: 'clock_out_notice', value: '2026-09-16T17:30:00.000|daily'));
      await db.into(db.settings).insert(SettingsCompanion.insert(key: 'notification_os_asked', value: '1'));
      await repo.save((await repo.read()).copyWith(hourlyWage: 12500, leaveBalanceByYear: {2026: b26}));
      final s = await repo.read();
      expect((s.clockOutNotificationEnabled, s.notificationPrompted, s.hourlyWage), (true, true, 12500));
      final keys = (await db.select(db.settings).get()).map((r) => r.key).toSet();
      expect(keys, containsAll(['clock_out_notice', 'notification_os_asked']));
    });
  });
}

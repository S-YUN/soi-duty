import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/data/database/app_database.dart';
import 'package:soi_duty/data/repository/drift_work_record_repository.dart';
import 'package:soi_duty/data/seed/debug_seed.dart';
import 'package:soi_duty/domain/model/work_type.dart';
import 'package:soi_duty/domain/rules/work_calculator.dart';

import '../helpers/records.dart';

void main() {
  late AppDatabase db;
  late DriftWorkRecordRepository repo;

  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftWorkRecordRepository(db);
  });
  tearDown(() => db.close());

  final today = d(16); // 수요일

  test('empty는 기록과 첫 기록일을 모두 지운다', () async {
    await repo.save(rec(14, inH: 9));
    await applySeed(db, SeedScenario.empty, today: today);
    expect(await repo.watchAll().first, isEmpty);
    expect(await repo.watchFirstRecordDate().first, isNull);
  });

  test('working은 오늘 출근만 찍힌 기록을 만든다', () async {
    await applySeed(db, SeedScenario.working, today: today);
    final all = await repo.watchAll().first;
    final todayRec = all.singleWhere((r) => r.date == today);
    expect(todayRec.clockIn, isNotNull);
    expect(todayRec.clockOut, isNull);
  });

  test('done은 오늘 출퇴근이 모두 있다', () async {
    await applySeed(db, SeedScenario.done, today: today);
    final all = await repo.watchAll().first;
    final todayRec = all.singleWhere((r) => r.date == today);
    expect(todayRec.clockIn, isNotNull);
    expect(todayRec.clockOut, isNotNull);
  });

  test('dayOff / holiday는 오늘 유형만 있다', () async {
    await applySeed(db, SeedScenario.dayOff, today: today);
    var all = await repo.watchAll().first;
    expect(all.singleWhere((r) => r.date == today).type, WorkType.dayOff);
    await applySeed(db, SeedScenario.holiday, today: today);
    all = await repo.watchAll().first;
    expect(all.singleWhere((r) => r.date == today).type, WorkType.holiday);
  });

  test('firstWeek는 첫 기록일이 이번 주 월요일이 아니다', () async {
    await applySeed(db, SeedScenario.firstWeek, today: d(18));
    final first = await repo.watchFirstRecordDate().first;
    expect(isFirstWeekException(mondayOf(d(18)), first), isTrue);
  });

  test('withGaps는 이전 평일에 누락이 있다', () async {
    await applySeed(db, SeedScenario.withGaps, today: today);
    final all = await repo.watchAll().first;
    final first = await repo.watchFirstRecordDate().first;
    expect(unrecordedWeekdays(records: all, today: today, firstRecordDate: first), isNotEmpty);
  });

  test('시드를 다시 적용하면 이전 기록이 남지 않는다', () async {
    await applySeed(db, SeedScenario.withGaps, today: today);
    await applySeed(db, SeedScenario.beforeWork, today: today);
    final all = await repo.watchAll().first;
    expect(all.any((r) => r.date == today), isFalse);
  });

  test('history: 8주치 기록, 유형이 섞이고 누락·주말 근무·미래 연차가 있다', () async {
    await applySeed(db, SeedScenario.history, today: today);
    final records = await repo.watchAll().first;
    final types = records.map((r) => r.type).toSet();
    expect(types, containsAll([WorkType.normal, WorkType.halfDay, WorkType.dayOff, WorkType.holiday]));
    expect(records.any((r) => r.date.isAfter(today) && r.type == WorkType.dayOff), isTrue);
    expect(records.any((r) => isWeekend(r.date) && r.clockOut != null), isTrue);
    final todayRec = records.singleWhere((r) => r.date == today);
    expect(todayRec.clockOut, isNull);
    final first = await repo.watchFirstRecordDate().first;
    expect(first, addDays(mondayOf(today), -56));
  });
}

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/data/database/app_database.dart';
import 'package:soi_duty/data/repository/drift_work_record_repository.dart';
import 'package:soi_duty/domain/model/work_type.dart';

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

  test('처음엔 비어 있다', () async {
    expect(await repo.watchAll().first, isEmpty);
    expect(await repo.watchFirstRecordDate().first, isNull);
  });

  test('save 후 watchAll이 방출하고 날짜·시각·유형이 왕복된다', () async {
    final r = rec(14, inH: 9, inM: 12, outH: 18, outM: 5, type: WorkType.halfDay);
    await repo.save(r);
    final all = await repo.watchAll().first;
    expect(all, [r]);
  });

  test('같은 날짜에 두 번 save하면 갱신 (행 하나)', () async {
    await repo.save(rec(14, inH: 9));
    await repo.save(rec(14, inH: 9, outH: 18));
    final all = await repo.watchAll().first;
    expect(all.length, 1);
    expect(all.single.clockOut, d(14, 18));
  });

  test('delete', () async {
    await repo.save(rec(14, inH: 9));
    await repo.delete(d(14));
    expect(await repo.watchAll().first, isEmpty);
  });

  test('첫 save가 첫 기록일을 기록하고, 이후 save·delete로 바뀌지 않는다', () async {
    await repo.save(rec(16, inH: 9));
    expect(await repo.watchFirstRecordDate().first, d(16));

    await repo.save(rec(14, inH: 9)); // 더 이른 날짜를 저장해도
    expect(await repo.watchFirstRecordDate().first, d(16));

    await repo.delete(d(16)); // 첫 기록을 지워도
    expect(await repo.watchFirstRecordDate().first, d(16));
  });

  test('watchAll은 변경마다 다시 방출한다', () async {
    final emissions = <int>[];
    final sub = repo.watchAll().listen((l) => emissions.add(l.length));
    await Future<void>.delayed(Duration.zero);
    await repo.save(rec(14, inH: 9));
    await Future<void>.delayed(Duration.zero);
    await repo.save(rec(15, inH: 9));
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();
    expect(emissions, [0, 1, 2]);
  });

  test('dateKey 왕복', () {
    expect(dateKey(d(3)), '2026-09-03');
    expect(parseDateKey('2026-09-03'), d(3));
  });
}

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/data/database/app_database.dart';
import 'package:soi_duty/data/repository/drift_notification_state_repository.dart';
import 'package:soi_duty/domain/notification/clock_out_notice.dart';

void main() {
  late AppDatabase db;
  late DriftNotificationStateRepository repo;

  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftNotificationStateRepository(db);
  });
  tearDown(() => db.close());

  test('마지막 알림: 처음엔 없고, 저장·덮어쓰기·삭제가 된다', () async {
    expect(await repo.lastNotice(), isNull);
    final a = ClockOutNotice(ClockOutNoticeKind.daily, DateTime(2026, 9, 16, 17, 30));
    final b = ClockOutNotice(ClockOutNoticeKind.weekly, DateTime(2026, 9, 18, 16));
    await repo.saveLastNotice(a);
    expect(await repo.lastNotice(), a);
    await repo.saveLastNotice(b);
    expect(await repo.lastNotice(), b);
    await repo.saveLastNotice(null);
    expect(await repo.lastNotice(), isNull);
    expect(await db.select(db.settings).get(), isEmpty);
  });

  test('손상된 값은 없는 것으로 읽는다', () async {
    await db.into(db.settings).insert(
          SettingsCompanion.insert(key: DriftNotificationStateRepository.lastNoticeKey, value: 'broken'),
        );
    expect(await repo.lastNotice(), isNull);
  });

  test('OS 창을 띄운 적: 기본 false, 한 번 표시하면 계속 true', () async {
    expect(await repo.osAsked(), isFalse);
    await repo.markOsAsked();
    await repo.markOsAsked();
    expect(await repo.osAsked(), isTrue);
  });
}

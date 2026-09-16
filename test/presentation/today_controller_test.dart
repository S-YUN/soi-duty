import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/core/providers/clock_provider.dart';
import 'package:soi_duty/core/providers/database_providers.dart';
import 'package:soi_duty/data/database/app_database.dart';
import 'package:soi_duty/domain/model/work_type.dart';
import 'package:soi_duty/presentation/today/today_controller.dart';
import 'package:soi_duty/presentation/today/today_state.dart';

import '../helpers/records.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  final now = d(16, 9, 12);

  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer.test(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(() => now),
        nowProvider.overrideWith((ref) => Stream.value(now)),
      ],
    );
    // autoDispose 프로바이더가 테스트 중 사라지지 않게 구독을 유지한다.
    container.listen(todayControllerProvider, (_, _) {});
  });

  tearDown(() => db.close());

  Future<TodayState> waitFor(bool Function(TodayState) test) async {
    for (var i = 0; i < 50; i++) {
      final s = await container.read(todayControllerProvider.future);
      if (test(s)) return s;
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    fail('상태가 기대대로 바뀌지 않음');
  }

  TodayController notifier() => container.read(todayControllerProvider.notifier);

  test('초기 상태는 출근 전', () async {
    final s = await container.read(todayControllerProvider.future);
    expect(s.phase, TodayPhase.before);
  });

  test('clockIn → 근무 중, 출근 시각은 clock 값', () async {
    await notifier().clockIn();
    final s = await waitFor((s) => s.phase == TodayPhase.working);
    expect(s.clockIn, now);
  });

  test('clockOut → 퇴근 완료', () async {
    await notifier().clockIn();
    await waitFor((s) => s.phase == TodayPhase.working);
    await notifier().clockOut();
    final s = await waitFor((s) => s.phase == TodayPhase.done);
    expect(s.clockOut, now);
  });

  test('setHalfDay는 출근 기록을 유지한 채 유형만 바꾼다', () async {
    await notifier().clockIn();
    await waitFor((s) => s.phase == TodayPhase.working);
    await notifier().setHalfDay(true);
    final s = await waitFor((s) => s.isHalfDay);
    expect(s.clockIn, now);
    await notifier().setHalfDay(false);
    await waitFor((s) => !s.isHalfDay);
  });

  test('setDayType(dayOff) → dayType 화면, revert → 출근 전', () async {
    await notifier().setDayType(WorkType.dayOff);
    await waitFor((s) => s.screenState == TodayScreenState.dayType);
    await notifier().revert();
    final s = await waitFor((s) => s.screenState == TodayScreenState.beforeWork);
    expect(s.record?.type, WorkType.normal);
  });

  test('첫 기록이 첫 기록일을 만든다', () async {
    await notifier().clockIn();
    final s = await waitFor((s) => s.firstRecordDate != null);
    expect(s.firstRecordDate, d(16));
  });

  test('연차인 날 clockIn하면 type이 normal로 정규화된다', () async {
    await notifier().setDayType(WorkType.dayOff);
    await waitFor((s) => s.screenState == TodayScreenState.dayType);
    await notifier().clockIn();
    final s = await waitFor((s) => s.phase == TodayPhase.working);
    expect(s.record?.type, WorkType.normal);
  });

  test('cancelClockIn → 기록이 지워지고 출근 전, 반차도 풀린다', () async {
    await notifier().clockIn();
    await waitFor((s) => s.phase == TodayPhase.working);
    await notifier().setHalfDay(true);
    await waitFor((s) => s.isHalfDay);
    await notifier().cancelClockIn();
    final s = await waitFor((s) => s.phase == TodayPhase.before);
    expect(s.record, isNull);
    expect(s.isHalfDay, isFalse);
  });

  test('cancelClockOut → 근무 중으로 돌아가고 type은 유지', () async {
    await notifier().clockIn();
    await waitFor((s) => s.phase == TodayPhase.working);
    await notifier().setHalfDay(true);
    await waitFor((s) => s.isHalfDay);
    await notifier().clockOut();
    await waitFor((s) => s.phase == TodayPhase.done);
    await notifier().cancelClockOut();
    final s = await waitFor((s) => s.phase == TodayPhase.working);
    expect(s.clockOut, isNull);
    expect(s.isHalfDay, isTrue);
  });
}

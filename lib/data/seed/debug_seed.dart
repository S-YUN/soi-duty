import '../../domain/model/work_record.dart';
import '../../domain/model/work_type.dart';
import '../../domain/rules/work_calculator.dart';
import '../database/app_database.dart';
import '../repository/drift_work_record_repository.dart';

/// 오늘 화면의 상태들을 손으로 만들지 않고 바로 확인하기 위한 시드.
/// 릴리즈 빌드에서는 호출 경로 자체가 없다 (kDebugMode 가드는 호출부 책임).
enum SeedScenario {
  empty('비우기'),
  beforeWork('출근 전'),
  working('근무 중'),
  done('퇴근 완료'),
  dayOff('연차'),
  holiday('공휴일'),
  firstWeek('첫 주 예외'),
  withGaps('기록 누락 있는 주');

  const SeedScenario(this.label);
  final String label;
}

/// 기존 기록과 첫 기록일을 전부 지우고 시나리오를 넣는다.
/// 기록은 이른 날짜부터 저장해 첫 기록일이 자연스럽게 잡히게 한다.
Future<void> applySeed(AppDatabase db, SeedScenario scenario, {required DateTime today}) async {
  await db.transaction(() async {
    await db.delete(db.workRecords).go();
    await db.delete(db.settings).go();
  });
  final repo = DriftWorkRecordRepository(db);
  final day = dateOnly(today);
  for (final r in _records(scenario, day)) {
    await repo.save(r);
  }
}

List<WorkRecord> _records(SeedScenario scenario, DateTime today) {
  final monday = mondayOf(today);
  final lastMonday = DateTime(monday.year, monday.month, monday.day - 7);

  WorkRecord full(DateTime date, {int inH = 9, int inM = 0, int outH = 18, int outM = 0}) => WorkRecord(
        date: date,
        clockIn: DateTime(date.year, date.month, date.day, inH, inM),
        clockOut: DateTime(date.year, date.month, date.day, outH, outM),
      );

  /// 지난 주 월~금 + 이번 주 오늘 이전 평일을 전부 채운다.
  List<WorkRecord> filledPast() => [
        for (final d in weekdaysOf(lastMonday)) full(d),
        for (final d in weekdaysOf(monday))
          if (d.isBefore(today)) full(d, outH: 18, outM: 20),
      ];

  switch (scenario) {
    case SeedScenario.empty:
      return const [];
    case SeedScenario.beforeWork:
      return filledPast();
    case SeedScenario.working:
      return [
        ...filledPast(),
        WorkRecord(date: today, clockIn: DateTime(today.year, today.month, today.day, 9, 12)),
      ];
    case SeedScenario.done:
      return [...filledPast(), full(today, inH: 9, inM: 12, outH: 18, outM: 5)];
    case SeedScenario.dayOff:
      return [...filledPast(), WorkRecord(date: today, type: WorkType.dayOff)];
    case SeedScenario.holiday:
      return [...filledPast(), WorkRecord(date: today, type: WorkType.holiday)];
    case SeedScenario.firstWeek:
      // 첫 기록일 = 이번 주 수요일. 오늘이 수요일 이전이면 오늘.
      final wednesday = DateTime(monday.year, monday.month, monday.day + 2);
      final first = wednesday.isAfter(today) ? today : wednesday;
      return [
        for (final d in weekdaysOf(monday))
          if (!d.isBefore(first) && d.isBefore(today)) full(d),
        WorkRecord(date: today, clockIn: DateTime(today.year, today.month, today.day, 9, 12)),
      ];
    case SeedScenario.withGaps:
      // 지난 주 수요일은 비우고, 금요일은 퇴근 누락.
      final wed = DateTime(lastMonday.year, lastMonday.month, lastMonday.day + 2);
      final fri = DateTime(lastMonday.year, lastMonday.month, lastMonday.day + 4);
      return [
        for (final d in weekdaysOf(lastMonday))
          if (d == fri)
            WorkRecord(date: d, clockIn: DateTime(d.year, d.month, d.day, 9))
          else if (d != wed)
            full(d),
        for (final d in weekdaysOf(monday))
          if (d.isBefore(today)) full(d),
        WorkRecord(date: today, clockIn: DateTime(today.year, today.month, today.day, 9, 12)),
      ];
  }
}

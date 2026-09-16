import '../../domain/model/work_record.dart';
import '../../domain/model/work_type.dart';
import '../../domain/rules/work_calculator.dart';
import '../database/app_database.dart';
import '../repository/drift_work_record_repository.dart';

/// 오늘 화면의 상태들과 주간·월간 탭을 손으로 만들지 않고 바로 확인하기 위한 시드.
/// 릴리즈 빌드에서는 호출 경로 자체가 없다 (kDebugMode 가드는 호출부 책임).
enum SeedScenario {
  empty('비우기'),
  beforeWork('출근 전'),
  working('근무 중'),
  done('퇴근 완료'),
  dayOff('연차'),
  holiday('공휴일'),
  firstWeek('첫 주 예외'),
  withGaps('기록 누락 있는 주'),
  history('두 달치 기록');

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
    case SeedScenario.history:
      // −8주 월요일부터 어제까지. 날짜로 결정되는 변동이라 ±가 골고루 나온다.
      final start = addDays(monday, -56);
      final records = <WorkRecord>[full(start)]; // 첫 기록일이 월요일이 되도록 시작일은 무조건 채운다
      for (var d = addDays(start, 1); d.isBefore(today); d = addDays(d, 1)) {
        final n = d.day;
        if (isWeekend(d)) {
          if (n % 9 == 0) records.add(full(d, inH: 10, outH: 14, outM: 30)); // 가끔 주말 근무
          continue;
        }
        if (n % 11 == 0) continue; // 누락
        if (n % 13 == 0) {
          records.add(WorkRecord(date: d, type: WorkType.dayOff));
        } else if (n % 17 == 0) {
          records.add(WorkRecord(date: d, type: WorkType.holiday));
        } else if (n % 7 == 0) {
          records.add(WorkRecord(
            date: d,
            type: WorkType.halfDay,
            clockIn: DateTime(d.year, d.month, d.day, 13, 30),
            clockOut: DateTime(d.year, d.month, d.day, 17, 40 + (n % 3) * 10),
          ));
        } else {
          records.add(full(d, inH: 9, inM: (n % 4) * 7, outH: 18, outM: (n % 5) * 9));
        }
      }
      // 오늘 근무 중 + 다음 주 수요일에 미리 찍은 연차
      records.add(WorkRecord(date: today, clockIn: DateTime(today.year, today.month, today.day, 9, 12)));
      records.add(WorkRecord(date: addDays(monday, 9), type: WorkType.dayOff));
      return records;
  }
}

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/clock_provider.dart';
import '../../core/providers/database_providers.dart';
import '../../domain/model/work_record.dart';
import '../../domain/model/work_type.dart';
import '../../domain/rules/work_calculator.dart';
import 'today_state.dart';
import 'today_state_builder.dart';

part 'today_controller.g.dart';

@riverpod
class TodayController extends _$TodayController {
  @override
  Future<TodayState> build() async {
    final records = await ref.watch(allRecordsProvider.future);
    final firstRecordDate = await ref.watch(firstRecordDateProvider.future);
    final now = await ref.watch(nowProvider.future);
    final rules = ref.watch(workRulesProvider);
    return buildTodayState(records: records, firstRecordDate: firstRecordDate, now: now, rules: rules);
  }

  Future<void> clockIn() => _saveToday((r, now) => r.copyWith(clockIn: now));

  Future<void> clockOut() => _saveToday((r, now) => r.copyWith(clockOut: now));

  Future<void> setHalfDay(bool on) =>
      _saveToday((r, _) => r.copyWith(type: on ? WorkType.halfDay : WorkType.normal));

  /// dayOff / holiday / null(→ normal). 출근 전 상태에서만 UI가 호출한다.
  Future<void> setDayType(WorkType? type) => _saveToday((r, _) => r.copyWith(type: type ?? WorkType.normal));

  Future<void> revert() => setDayType(null);

  Future<void> _saveToday(WorkRecord Function(WorkRecord record, DateTime now) update) async {
    final now = ref.read(clockProvider)();
    final current = await future;
    final base = current.record ?? WorkRecord(date: dateOnly(now));
    await ref.read(workRecordRepositoryProvider).save(update(base, now));
  }
}

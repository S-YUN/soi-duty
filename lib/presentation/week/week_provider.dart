import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/clock_provider.dart';
import '../../core/providers/database_providers.dart';
import 'selected_week.dart';
import 'week_state.dart';
import 'week_state_builder.dart';

part 'week_provider.g.dart';

@riverpod
Future<WeekState> weekState(Ref ref) async {
  final records = await ref.watch(allRecordsProvider.future);
  final firstRecordDate = await ref.watch(firstRecordDateProvider.future);
  final now = await ref.watch(nowProvider.future);
  final rules = ref.watch(workRulesProvider);
  final monday = ref.watch(selectedWeekProvider);
  return buildWeekState(records: records, firstRecordDate: firstRecordDate, now: now, rules: rules, monday: monday);
}

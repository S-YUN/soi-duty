import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/clock_provider.dart';
import '../../core/providers/database_providers.dart';
import 'month_state.dart';
import 'month_state_builder.dart';
import 'selected_month.dart';

part 'month_provider.g.dart';

@riverpod
Future<MonthState> monthState(Ref ref) async {
  final records = await ref.watch(allRecordsProvider.future);
  final firstRecordDate = await ref.watch(firstRecordDateProvider.future);
  final now = await ref.watch(nowProvider.future);
  final rules = ref.watch(workRulesProvider);
  final month = ref.watch(selectedMonthProvider);
  return buildMonthState(records: records, firstRecordDate: firstRecordDate, now: now, rules: rules, month: month);
}

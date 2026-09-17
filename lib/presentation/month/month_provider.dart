import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/clock_provider.dart';
import '../../core/providers/database_providers.dart';
import 'month_state.dart';
import 'month_state_builder.dart';

part 'month_provider.g.dart';

/// [month]의 1일을 키로 하는 family. 페이저가 이웃 달을 미리 그리므로 달마다 따로 계산한다.
@riverpod
Future<MonthState> monthState(Ref ref, DateTime month) async {
  final records = await ref.watch(allRecordsProvider.future);
  final firstRecordDate = await ref.watch(firstRecordDateProvider.future);
  final now = await ref.watch(nowProvider.future);
  final rules = ref.watch(workRulesProvider);
  return buildMonthState(records: records, firstRecordDate: firstRecordDate, now: now, rules: rules, month: month);
}

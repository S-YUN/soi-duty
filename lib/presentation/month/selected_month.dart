import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/clock_provider.dart';
import '../../core/providers/database_providers.dart';
import '../../domain/rules/navigation_bounds.dart';
import '../../domain/rules/work_calculator.dart';

part 'selected_month.g.dart';

/// 월간 탭이 보고 있는 달의 1일. 탭을 오가도 유지되고, 앱을 다시 켜면 이번 달.
@Riverpod(keepAlive: true)
class SelectedMonth extends _$SelectedMonth {
  @override
  // watch: 디버그 시계 이동 시 이번 달로 되돌아온다.
  DateTime build() => firstOfMonth(ref.watch(clockProvider)());

  void prev() {
    final today = ref.read(clockProvider)();
    final first = ref.read(firstRecordDateProvider).value;
    if (state.isAfter(earliestMonth(first, today))) state = addMonths(state, -1);
  }

  void next() {
    final thisMonth = firstOfMonth(ref.read(clockProvider)());
    if (state.isBefore(thisMonth)) state = addMonths(state, 1);
  }
}

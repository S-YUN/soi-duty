import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/clock_provider.dart';
import '../../core/providers/database_providers.dart';
import '../../domain/rules/navigation_bounds.dart';
import '../../domain/rules/work_calculator.dart';

part 'selected_week.g.dart';

/// 주간 탭이 보고 있는 주의 월요일. 탭을 오가도 유지되고, 앱을 다시 켜면 이번 주.
@Riverpod(keepAlive: true)
class SelectedWeek extends _$SelectedWeek {
  @override
  DateTime build() => mondayOf(ref.read(clockProvider)());

  void prev() {
    final today = ref.read(clockProvider)();
    final first = ref.read(firstRecordDateProvider).value;
    if (state.isAfter(earliestMonday(first, today))) state = addDays(state, -7);
  }

  void next() {
    final thisMonday = mondayOf(ref.read(clockProvider)());
    if (state.isBefore(thisMonday)) state = addDays(state, 7);
  }
}

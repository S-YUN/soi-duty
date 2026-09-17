import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/clock_provider.dart';
import '../../core/providers/database_providers.dart';
import '../../domain/rules/navigation_bounds.dart';
import '../../ui/app_colors.dart';
import '../../ui/app_sizes.dart';
import '../../ui/app_text_styles.dart';
import '../record_edit/record_edit_sheet.dart';
import '../shared/period_navigator.dart';
import 'month_provider.dart';
import 'month_state.dart';
import 'month_texts.dart';
import 'selected_month.dart';
import 'widgets/calendar_card.dart';
import 'widgets/legend.dart';

class MonthScreen extends ConsumerWidget {
  const MonthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(monthStateProvider);
    final notifier = ref.watch(selectedMonthProvider.notifier);
    final first = ref.watch(firstRecordDateProvider).value;
    final today = ref.watch(clockProvider)();
    return async.when(
      loading: () => const ColoredBox(color: AppColors.screenBackground, child: SizedBox.expand()),
      error: (e, _) => Center(child: Text('$e', style: AppTextStyles.caption)),
      data: (state) => MonthView(
        state: state,
        canGoPrev: state.month.isAfter(earliestMonth(first, today)),
        canGoNext: state.month.isBefore(latestMonth(today)),
        onCellTap: (date) => showRecordEditSheet(context, date),
        onPrev: notifier.prev,
        onNext: notifier.next,
      ),
    );
  }
}

/// 월간 화면의 순수 UI. 기간 네비게이터 → 캘린더 → 범례. 달 이동은 화살표로만. (리포트는 보류 — CLAUDE.md)
class MonthView extends StatelessWidget {
  const MonthView({
    super.key,
    required this.state,
    required this.canGoPrev,
    required this.canGoNext,
    required this.onCellTap,
    required this.onPrev,
    required this.onNext,
  });

  final MonthState state;
  final bool canGoPrev;
  final bool canGoNext;
  final ValueChanged<DateTime> onCellTap;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Column(
      children: [
        PeriodNavigator(
          label: MonthTexts.title(state.month),
          canGoPrev: canGoPrev,
          canGoNext: canGoNext,
          onPrev: onPrev,
          onNext: onNext,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: AppSizes.bodyPadding.copyWith(bottom: AppSizes.bodyPadding.bottom + bottomInset),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CalendarCard(state: state, onCellTap: onCellTap),
                SizedBox(height: AppSizes.cardGap),
                const Legend(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

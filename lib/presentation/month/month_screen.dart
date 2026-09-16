import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final selected = ref.watch(selectedMonthProvider.notifier);
    return async.when(
      loading: () => const ColoredBox(color: AppColors.screenBackground, child: SizedBox.expand()),
      error: (e, _) => Center(child: Text('$e', style: AppTextStyles.caption)),
      data: (state) => MonthView(
        state: state,
        onCellTap: (date) => showRecordEditSheet(context, date),
        onPrev: selected.prev,
        onNext: selected.next,
      ),
    );
  }
}

/// 월간 화면의 순수 UI. 기간 네비게이터 → 캘린더 → 범례. (리포트는 보류 — CLAUDE.md)
class MonthView extends StatelessWidget {
  const MonthView({
    super.key,
    required this.state,
    required this.onCellTap,
    required this.onPrev,
    required this.onNext,
  });

  final MonthState state;
  final ValueChanged<DateTime> onCellTap;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Column(
      children: [
        PeriodNavigator(
          label: MonthTexts.title(state),
          canGoPrev: state.canGoPrev,
          canGoNext: state.canGoNext,
          onPrev: onPrev,
          onNext: onNext,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: AppSizes.bodyPadding.copyWith(bottom: AppSizes.bodyPadding.bottom + bottomInset),
            child: Column(
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

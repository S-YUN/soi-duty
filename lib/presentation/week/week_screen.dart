import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/presentation/format/date_format.dart';
import '../../core/providers/database_providers.dart';
import '../../domain/rules/work_rules.dart';
import '../../ui/app_colors.dart';
import '../../ui/app_decorations.dart';
import '../../ui/app_sizes.dart';
import '../../ui/app_text_styles.dart';
import '../record_edit/record_edit_sheet.dart';
import '../shared/period_navigator.dart';
import 'selected_week.dart';
import 'week_provider.dart';
import 'week_state.dart';
import 'widgets/week_day_row.dart';
import 'widgets/week_summary_card.dart';

class WeekScreen extends ConsumerWidget {
  const WeekScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rules = ref.watch(workRulesProvider);
    final async = ref.watch(weekStateProvider);
    final selected = ref.watch(selectedWeekProvider.notifier);
    return async.when(
      loading: () => const ColoredBox(color: AppColors.screenBackground, child: SizedBox.expand()),
      error: (e, _) => Center(child: Text('$e', style: AppTextStyles.caption)),
      data: (state) => WeekView(
        state: state,
        rules: rules,
        onDayTap: (date) => showRecordEditSheet(context, date),
        onPrev: selected.prev,
        onNext: selected.next,
      ),
    );
  }
}

/// 주간 화면의 순수 UI. 상태와 콜백만 받고 프로바이더를 모른다.
class WeekView extends StatelessWidget {
  const WeekView({
    super.key,
    required this.state,
    required this.rules,
    required this.onDayTap,
    required this.onPrev,
    required this.onNext,
  });

  final WeekState state;
  final WorkRules rules;
  final ValueChanged<DateTime> onDayTap;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Column(
      children: [
        PeriodNavigator(
          label: formatWeekRange(state.monday),
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
                WeekSummaryCard(state: state, rules: rules),
                SizedBox(height: AppSizes.cardGap),
                // 행이 카드 폭을 꽉 채운다 — 카드 자체 패딩 없이 radius로 잘라낸다.
                Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: AppDecorations.card,
                  child: Column(
                    children: [
                      for (var i = 0; i < state.days.length; i++) ...[
                        if (i > 0) Container(height: AppSizes.rowDivider, color: AppColors.rowDivider),
                        WeekDayRow(day: state.days[i], onTap: () => onDayTap(state.days[i].date)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../domain/rules/work_rules.dart';
import '../../../ui/app_decorations.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';
import '../../shared/progress_bar.dart';
import '../week_state.dart';
import '../week_texts.dart';

/// 카드 A — 누적. 첫 주 예외면 목표·진행 바 없이 누적만.
class WeekSummaryCard extends StatelessWidget {
  const WeekSummaryCard({super.key, required this.state, required this.rules});

  final WeekState state;
  final WorkRules rules;

  @override
  Widget build(BuildContext context) {
    final progress = WeekTexts.progress(state);
    final goal = WeekTexts.summaryGoal(state);
    return Container(
      width: double.infinity,
      padding: AppSizes.weekCardPadding,
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(WeekTexts.summaryLabel(state), style: AppTextStyles.label),
          SizedBox(height: AppSizes.weekValueTop),
          Text.rich(
            TextSpan(
              text: WeekTexts.summaryValue(state),
              style: AppTextStyles.weekValue,
              children: [if (goal.isNotEmpty) TextSpan(text: ' $goal', style: AppTextStyles.weekGoal)],
            ),
          ),
          SizedBox(height: AppSizes.weekReasonTop),
          Text(WeekTexts.summaryReason(state, rules), style: AppTextStyles.weekReason),
          if (progress != null) ...[
            SizedBox(height: AppSizes.weekBarTop),
            ProgressBar(value: progress),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../ui/app_decorations.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';
import '../../shared/progress_bar.dart';
import '../week_state.dart';
import '../week_texts.dart';

/// 카드 A — 제목 → 실적 / 그 주 목표 → 연·반·공 개수(없으면 생략) → 진행 바. 첫 주 예외면 목표·바 없이 누적만.
class WeekSummaryCard extends StatelessWidget {
  const WeekSummaryCard({super.key, required this.state});

  final WeekState state;

  @override
  Widget build(BuildContext context) {
    final progress = WeekTexts.progress(state);
    final goal = WeekTexts.summaryGoal(state);
    final detail = WeekTexts.summaryDetail(state);
    return Container(
      width: double.infinity,
      padding: AppSizes.weekCardPadding,
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(WeekTexts.summaryLabel(state), style: AppTextStyles.cardTitle),
          SizedBox(height: AppSizes.weekValueTop),
          Text.rich(
            TextSpan(
              text: WeekTexts.summaryValue(state),
              style: AppTextStyles.weekValue,
              children: [if (goal.isNotEmpty) TextSpan(text: ' $goal', style: AppTextStyles.weekGoal)],
            ),
          ),
          if (detail.isNotEmpty) ...[
            SizedBox(height: AppSizes.weekReasonTop),
            Text(detail, style: AppTextStyles.weekReason),
          ],
          if (progress != null) ...[
            SizedBox(height: AppSizes.weekBarTop),
            ProgressBar(value: progress),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../domain/rules/work_rules.dart';
import '../../../ui/app_colors.dart';
import '../../../ui/app_decorations.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';
import '../today_state.dart';
import '../today_texts.dart';

class HeroCard extends StatelessWidget {
  const HeroCard({super.key, required this.state, required this.rules});

  final TodayState state;
  final WorkRules rules;

  @override
  Widget build(BuildContext context) {
    final progress = TodayTexts.progress(state);
    return Container(
      width: double.infinity,
      padding: AppSizes.heroPadding,
      decoration: AppDecorations.card,
      child: Column(
        children: [
          // 히어로 카드 높이가 문구 길이에 따라 변하면 아래 버튼이 움직인다. 전부 한 줄로 고정.
          Text(TodayTexts.heroLabel(state), style: AppTextStyles.label, textAlign: TextAlign.center, maxLines: 1),
          SizedBox(height: AppSizes.heroValueTop),
          Text(TodayTexts.heroValue(state), style: AppTextStyles.heroValue, textAlign: TextAlign.center, maxLines: 1),
          SizedBox(height: AppSizes.heroReasonTop),
          Text(
            TodayTexts.heroReason(state, rules),
            style: AppTextStyles.reason,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: AppSizes.progressBarTop),
          // 첫 주 예외에서는 바를 그리지 않지만 같은 높이를 유지한다 — 아래 버튼이 움직이지 않도록.
          SizedBox(
            height: AppSizes.progressBar,
            child: progress == null ? null : _ProgressBar(value: progress),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.pill),
      child: Stack(
        children: [
          Container(color: AppColors.divider),
          AnimatedFractionallySizedBox(
            duration: AppDurations.progressBar,
            curve: Curves.ease,
            alignment: Alignment.centerLeft,
            widthFactor: value,
            child: Container(
              decoration: BoxDecoration(color: AppColors.brand, borderRadius: BorderRadius.circular(AppSizes.pill)),
            ),
          ),
        ],
      ),
    );
  }
}

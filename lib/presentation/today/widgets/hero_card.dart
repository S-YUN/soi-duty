import 'package:flutter/material.dart';

import '../../../ui/app_decorations.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';
import '../../shared/progress_bar.dart';
import '../today_state.dart';
import '../today_texts.dart';

/// 제목 → 이번 주 잔여 → 진행 바. 실적/목표 같은 세부는 주간 탭에 있으니 여기서는 숫자 하나에 집중한다.
class HeroCard extends StatelessWidget {
  const HeroCard({super.key, required this.state});

  final TodayState state;

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
          Text(TodayTexts.heroLabel(state), style: AppTextStyles.cardTitle, textAlign: TextAlign.center, maxLines: 1),
          SizedBox(height: AppSizes.heroValueTop),
          Text(TodayTexts.heroValue(state), style: AppTextStyles.heroValue, textAlign: TextAlign.center, maxLines: 1),
          SizedBox(height: AppSizes.progressBarTop),
          // 첫 주 예외에서는 바를 그리지 않지만 같은 높이를 유지한다 — 아래 버튼이 움직이지 않도록.
          SizedBox(
            height: AppSizes.progressBar,
            child: progress == null ? null : ProgressBar(value: progress),
          ),
        ],
      ),
    );
  }
}

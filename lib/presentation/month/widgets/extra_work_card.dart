import 'package:flutter/material.dart';

import '../../../ui/app_colors.dart';
import '../../../ui/app_decorations.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';
import '../month_state.dart';
import '../month_texts.dart';
import 'nudge_row.dart';

/// 그 달 주말·공휴일 근무 카드. 시간 행(0인 쪽은 생략) → 구분선 → 예상 금액 또는 시급 유도 줄.
class ExtraWorkCard extends StatelessWidget {
  const ExtraWorkCard({super.key, required this.extraWork, required this.title, required this.onTapNudge});

  final MonthExtraWork extraWork;
  final String title;
  final VoidCallback onTapNudge;

  @override
  Widget build(BuildContext context) {
    final rows = [
      if (extraWork.weekendMinutes > 0) (MonthTexts.weekendLabel, MonthTexts.minutes(extraWork.weekendMinutes)),
      if (extraWork.holidayMinutes > 0) (MonthTexts.holidayLabel, MonthTexts.minutes(extraWork.holidayMinutes)),
    ];
    final pay = extraWork.payWon;
    return Container(
      decoration: AppDecorations.card,
      padding: AppSizes.weekCardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: AppTextStyles.cardTitle),
          SizedBox(height: AppSizes.extraRowsTop),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) SizedBox(height: AppSizes.extraRowGap),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(child: Text(rows[i].$1, style: AppTextStyles.extraRowLabel)),
                Text(rows[i].$2, style: AppTextStyles.extraRowValue),
              ],
            ),
          ],
          Container(margin: AppSizes.extraDividerMargin, height: AppSizes.summaryDivider, color: AppColors.rowDivider),
          if (pay != null)
            Padding(
              padding: EdgeInsets.only(top: AppSizes.amountRowTop),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(child: Text(MonthTexts.amountLabel, style: AppTextStyles.extraRowLabel)),
                  Text(MonthTexts.amount(pay), style: AppTextStyles.extraAmount),
                ],
              ),
            )
          else
            NudgeRow(text: MonthTexts.wageNudge, onTap: onTapNudge),
        ],
      ),
    );
  }
}

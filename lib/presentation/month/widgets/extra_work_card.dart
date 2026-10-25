import 'package:flutter/material.dart';

import '../../../ui/app_colors.dart';
import '../../../ui/app_decorations.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';
import '../month_state.dart';
import '../month_texts.dart';
import 'nudge_row.dart';

/// 그 달 주말·공휴일 근무 카드(항상). 주말·공휴일 두 행(0이면 "기록 없음") → 구분선 → 예상 금액(시급 없으면 "—") → 시급 없으면 유도 줄.
class ExtraWorkCard extends StatelessWidget {
  const ExtraWorkCard({super.key, required this.extraWork, required this.title, required this.onTapNudge});

  final MonthExtraWork extraWork;
  final String title;
  final VoidCallback onTapNudge;

  @override
  Widget build(BuildContext context) {
    final rows = [
      (MonthTexts.weekendLabel, extraWork.weekendMinutes),
      (MonthTexts.holidayLabel, extraWork.holidayMinutes),
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
                if (rows[i].$2 > 0)
                  Text(MonthTexts.minutes(rows[i].$2), style: AppTextStyles.extraRowValue)
                else
                  Text(MonthTexts.noRecord, style: AppTextStyles.extraRowNone),
              ],
            ),
          ],
          Container(margin: AppSizes.extraDividerMargin, height: AppSizes.summaryDivider, color: AppColors.rowDivider),
          Padding(
            padding: EdgeInsets.only(top: AppSizes.amountRowTop),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(child: Text(MonthTexts.amountLabel, style: AppTextStyles.extraRowLabel)),
                if (pay != null)
                  Text(MonthTexts.amount(pay), style: AppTextStyles.extraAmount)
                else
                  Text(MonthTexts.none, style: AppTextStyles.valueNone),
              ],
            ),
          ),
          if (pay == null) NudgeRow(text: MonthTexts.wageNudge, onTap: onTapNudge),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../ui/app_colors.dart';
import '../../../ui/app_decorations.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';
import '../month_state.dart';
import '../month_texts.dart';
import 'nudge_row.dart';

/// 그 해 연차 카드(항상). 총 연차 | 사용(+예정 줄) | 잔여/초과 3칸. 총 연차가 없으면 "미입력" · 잔여 "—" · 유도 줄. 사용 0은 "0일".
/// 퇴근 완료 요약(SummaryRow)과 같은 모양이지만 사용 칸 아래 줄이 붙어 따로 그린다 — 값 줄의 y는 세 칸이 같다.
class LeaveCard extends StatelessWidget {
  const LeaveCard({super.key, required this.leave, required this.onTapNudge});

  final MonthLeave leave;
  final VoidCallback onTapNudge;

  @override
  Widget build(BuildContext context) {
    final total = leave.totalDays;
    final remaining = leave.remainingHalfDays;
    final over = remaining != null && remaining < 0;
    final noneStyle = AppTextStyles.leaveValueNone;
    final cells = [
      (MonthTexts.leaveTotalLabel, total == null ? MonthTexts.notEntered : MonthTexts.days(total * 2), total == null ? AppTextStyles.leaveTotalNotEntered : AppTextStyles.summaryValue, null),
      (MonthTexts.leaveUsedLabel, MonthTexts.days(leave.usedHalfDays), AppTextStyles.summaryValue, leave.plannedHalfDays > 0 ? MonthTexts.plannedLine(leave.plannedHalfDays) : null),
      (
        over ? MonthTexts.leaveOverLabel : MonthTexts.leaveRemainLabel,
        remaining == null ? MonthTexts.none : MonthTexts.days(remaining.abs()),
        remaining == null ? noneStyle : AppTextStyles.summaryValue.copyWith(color: over ? AppColors.minus : AppColors.brand),
        null,
      ),
    ];
    return Container(
      decoration: AppDecorations.card,
      padding: AppSizes.weekCardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(MonthTexts.leaveTitle(leave.year), style: AppTextStyles.cardTitle),
          SizedBox(height: AppSizes.leaveCellsTop),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < cells.length; i++) ...[
                  if (i > 0) Container(width: AppSizes.summaryDivider, color: AppColors.divider),
                  Expanded(
                    child: Padding(
                      padding: AppSizes.leaveCellPadding,
                      child: Column(
                        children: [
                          Text(cells[i].$1, style: AppTextStyles.summaryLabel),
                          SizedBox(height: i == 0 && total == null ? AppSizes.leaveNotEnteredTop : AppSizes.leaveValueTop),
                          Text(cells[i].$2, style: cells[i].$3),
                          if (cells[i].$4 != null) ...[
                            SizedBox(height: AppSizes.plannedLineTop),
                            Text(cells[i].$4!, style: AppTextStyles.plannedLine, textAlign: TextAlign.center),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (total == null) ...[
            Container(margin: AppSizes.leaveDividerMargin, height: AppSizes.summaryDivider, color: AppColors.rowDivider),
            NudgeRow(text: MonthTexts.leaveNudge, onTap: onTapNudge),
          ],
        ],
      ),
    );
  }
}

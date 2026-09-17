import 'package:flutter/material.dart';

import '../../../core/presentation/format/time_format.dart';
import '../../../domain/rules/work_rules.dart';
import '../../../ui/app_colors.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';
import '../today_state.dart';
import '../today_texts.dart';
import 'summary_row.dart';
import 'type_badge.dart';

/// 상태 카드 상단 블록. 높이 104 고정, 내용만 상태별로 바뀐다.
class StatusBlock extends StatelessWidget {
  const StatusBlock({super.key, required this.state, required this.rules});

  final TodayState state;
  final WorkRules rules;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.statusBlock,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _children(),
      ),
    );
  }

  List<Widget> _children() {
    final gap = SizedBox(height: AppSizes.statusBlockGap);
    switch (state.screenState) {
      case TodayScreenState.beforeWork:
        return [
          _DotLine(active: false, text: TodayTexts.beforeWork, style: AppTextStyles.body),
          gap,
          Text(TodayTexts.encouragement(state, rules), style: AppTextStyles.caption, textAlign: TextAlign.center, maxLines: 1),
        ];
      case TodayScreenState.working:
        return [
          _DotLine(active: true, text: TodayTexts.clockInLine(state), style: AppTextStyles.statusClock),
          gap,
          Text(TodayTexts.workingLine(state), style: AppTextStyles.body, textAlign: TextAlign.center, maxLines: 1),
          gap,
          Text(TodayTexts.encouragement(state, rules), style: AppTextStyles.caption, textAlign: TextAlign.center, maxLines: 1),
        ];
      case TodayScreenState.done:
        final delta = state.todayDelta;
        return [
          Text(TodayTexts.doneTitle, style: AppTextStyles.reason, textAlign: TextAlign.center),
          gap,
          SummaryRow(
            labels: TodayTexts.summaryLabels,
            values: [
              state.clockIn == null ? '' : formatClock(state.clockIn!),
              state.clockOut == null ? '' : formatClock(state.clockOut!),
              state.todayActual == null ? '' : formatHm(state.todayActual!),
              delta == null ? '—' : formatSignedHm(delta),
            ],
            valueColor: (i) => i != 3
                ? null
                : delta == null || delta == 0
                    ? AppColors.subtle
                    : delta < 0
                        ? AppColors.minus
                        : AppColors.brand,
          ),
        ];
      case TodayScreenState.dayType:
        final type = state.dayType!;
        return [
          TypeBadge(type: type),
          gap,
          Text(TodayTexts.dayTypeMessage(type), style: AppTextStyles.bodyParagraph, textAlign: TextAlign.center),
        ];
    }
  }
}

class _DotLine extends StatelessWidget {
  const _DotLine({required this.active, required this.text, required this.style});

  final bool active;
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppSizes.dot,
          height: AppSizes.dot,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? AppColors.brand : AppColors.dotInactive,
            boxShadow: active ? [BoxShadow(color: AppColors.dotGlow, spreadRadius: AppSizes.dotGlow)] : null,
          ),
        ),
        SizedBox(width: AppSizes.dotGap),
        Text(text, style: style),
      ],
    );
  }
}

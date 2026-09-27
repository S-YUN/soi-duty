import 'package:flutter/material.dart';

import '../../../core/presentation/format/time_format.dart';
import '../../../domain/rules/work_rules.dart';
import '../../../ui/app_colors.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';
import '../today_state.dart';
import '../today_texts.dart';
import 'soi_checkbox.dart';
import 'summary_row.dart';
import 'type_badge.dart';

/// 상태 카드 상단 블록. 최소 높이 104, 내용만 상태별로 바뀐다.
/// 평일 근무 중엔 "남은 시간 공제하고 퇴근" 줄이 붙어 그만큼 늘어날 수 있다 (2026-09-27).
class StatusBlock extends StatelessWidget {
  const StatusBlock({
    super.key,
    required this.state,
    required this.rules,
    this.deductRemaining = false,
    this.onDeductRemainingChanged,
  });

  final TodayState state;
  final WorkRules rules;
  final bool deductRemaining;
  final ValueChanged<bool>? onDeductRemainingChanged;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: AppSizes.statusBlock, minWidth: double.infinity),
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
          _DotLine(active: false, text: TodayTexts.beforeWork, style: AppTextStyles.statusLine),
          gap,
          Text(TodayTexts.encouragement(state, rules), style: AppTextStyles.statusNote, textAlign: TextAlign.center, maxLines: 1),
        ];
      case TodayScreenState.working:
        return [
          _DotLine(active: true, text: TodayTexts.clockInLine(state), style: AppTextStyles.statusClock),
          gap,
          Text(TodayTexts.workingLine(state), style: AppTextStyles.statusLine, textAlign: TextAlign.center, maxLines: 1),
          if (state.canDeductOnClockOut && onDeductRemainingChanged != null)
            SoiCheckbox(
              label: TodayTexts.deductRemaining,
              checked: deductRemaining,
              onChanged: onDeductRemainingChanged!,
              shape: SoiCheckShape.square,
            ),
        ];
      case TodayScreenState.done:
        // 제목 없이 요약만 — "오늘 퇴근 완료"는 아래 버튼이 이미 말한다.
        final delta = state.todayDelta;
        return [
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

import 'package:flutter/material.dart';

import '../../../ui/app_colors.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';

/// 퇴근 완료 상태의 4칸 요약. 배경 없이 칸 사이 1px 구분선만 — 카드 안에서 한 겹 덜 무겁게.
/// 값은 한 줄·가운데 — "−7h 44m"처럼 긴 값은 줄을 꺾지 않고 칸에 맞게 살짝 줄인다(밤에 짧게 일한 날, 2026-10-27).
class SummaryRow extends StatelessWidget {
  const SummaryRow({super.key, required this.labels, required this.values, this.valueColor})
      : assert(labels.length == values.length);

  final List<String> labels;
  final List<String> values;
  final Color? Function(int index)? valueColor;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0) Container(width: AppSizes.summaryDivider, color: AppColors.divider),
            Expanded(
              child: Padding(
                padding: AppSizes.summaryCellPadding,
                child: Column(
                  children: [
                    Text(labels[i], style: AppTextStyles.summaryLabel, textAlign: TextAlign.center),
                    SizedBox(height: AppSizes.summaryValueTop),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        values[i],
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.summaryValue.copyWith(color: valueColor?.call(i)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

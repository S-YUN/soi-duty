import 'package:flutter/material.dart';

import '../../../ui/app_colors.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';
import '../month_texts.dart';

/// 캘린더 아래 범례: 반차 / 연차 / 공휴일 색상 칩.
class Legend extends StatelessWidget {
  const Legend({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSizes.legendPadding,
      child: Wrap(
        spacing: AppSizes.legendItemGap,
        runSpacing: AppSizes.legendRunGap,
        children: [
          for (final (type, label) in MonthTexts.legend)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: AppSizes.legendChip,
                  height: AppSizes.legendChip,
                  decoration: BoxDecoration(color: AppColors.typeColors(type).$1, shape: BoxShape.circle),
                ),
                SizedBox(width: AppSizes.legendChipGap),
                Text(label, style: AppTextStyles.legend),
              ],
            ),
        ],
      ),
    );
  }
}

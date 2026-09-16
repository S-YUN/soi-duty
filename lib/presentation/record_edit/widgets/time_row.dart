import 'package:flutter/material.dart';

import '../../../ui/app_colors.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';

/// 출근/퇴근 행. 행 전체가 탭 영역. 선택되면 배경 cardInner, 값 brand w600. 아래에 1px 구분선.
class TimeRow extends StatelessWidget {
  const TimeRow({super.key, required this.label, required this.value, required this.selected, required this.onTap});

  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: AppDurations.checkbox,
            padding: AppSizes.timeRowPadding,
            decoration: BoxDecoration(
              color: selected ? AppColors.cardInner : Colors.transparent,
              borderRadius: BorderRadius.circular(AppSizes.timeRowRadius),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: AppTextStyles.timeLabel),
                Text(value, style: AppTextStyles.timeValue(selected: selected)),
              ],
            ),
          ),
          Container(height: AppSizes.rowDivider, color: AppColors.rowDivider),
        ],
      ),
    );
  }
}

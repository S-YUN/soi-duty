import 'package:flutter/material.dart';

import '../../../ui/app_colors.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';

enum SoiCheckShape { square, round }

/// 반차(square, 19) / 연차·공휴일(round, 18) 공용 체크. 행 전체가 탭 영역, 세로 44 확보.
class SoiCheckbox extends StatelessWidget {
  const SoiCheckbox({
    super.key,
    required this.label,
    required this.checked,
    required this.onChanged,
    required this.shape,
  });

  final String label;
  final bool checked;
  final ValueChanged<bool> onChanged;
  final SoiCheckShape shape;

  @override
  Widget build(BuildContext context) {
    final isSquare = shape == SoiCheckShape.square;
    final boxSize = isSquare ? AppSizes.checkboxSquare : AppSizes.checkboxRound;
    final boxRadius = isSquare ? AppSizes.checkboxSquareRadius : AppSizes.pill;
    final rowRadius = isSquare ? AppSizes.checkRowRadius : AppSizes.dayTypeRowRadius;
    final labelStyle = isSquare
        ? AppTextStyles.checkLabel(checked: checked)
        : AppTextStyles.dayTypeLabel(checked: checked);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!checked),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: AppSizes.minTapHeight),
        child: Center(
          child: AnimatedContainer(
            duration: AppDurations.checkbox,
            padding: AppSizes.checkRowPadding,
            decoration: BoxDecoration(
              color: checked ? AppColors.cardInner : Colors.transparent,
              borderRadius: BorderRadius.circular(rowRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: AppDurations.checkbox,
                  width: boxSize,
                  height: boxSize,
                  decoration: BoxDecoration(
                    color: checked ? AppColors.brand : AppColors.card,
                    borderRadius: BorderRadius.circular(boxRadius),
                    border: Border.all(
                      color: checked ? AppColors.brand : AppColors.checkboxBorder,
                      width: checked ? AppSizes.checkboxBorderOn : AppSizes.checkboxBorderOff,
                    ),
                  ),
                  child: checked ? Icon(Icons.check, size: AppSizes.checkboxIcon, color: AppColors.onBrand) : null,
                ),
                SizedBox(width: AppSizes.checkboxGap),
                Text(label, style: labelStyle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

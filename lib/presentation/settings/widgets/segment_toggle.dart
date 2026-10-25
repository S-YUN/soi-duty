import 'package:flutter/material.dart';

import '../../../ui/app_colors.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';

/// 두 칸 세그먼트(월 | 일). 탭 알약과 같은 컨테이너, 선택 칸은 브랜드색 채움.
class SegmentToggle<T> extends StatelessWidget {
  const SegmentToggle({super.key, required this.options, required this.value, required this.onChanged});

  final List<(T, String)> options;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.segmentPadding),
      decoration: BoxDecoration(color: AppColors.tabContainer, borderRadius: BorderRadius.circular(AppSizes.pill)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < options.length; i++) ...[
            if (i > 0) SizedBox(width: AppSizes.segmentGap),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(options[i].$1),
              child: AnimatedContainer(
                duration: AppDurations.buttonColor,
                padding: AppSizes.segmentItemPadding,
                decoration: BoxDecoration(
                  color: options[i].$1 == value ? AppColors.brand : null,
                  borderRadius: BorderRadius.circular(AppSizes.pill),
                ),
                child: Text(
                  options[i].$2,
                  style: options[i].$1 == value ? AppTextStyles.segmentOn : AppTextStyles.segmentOff,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

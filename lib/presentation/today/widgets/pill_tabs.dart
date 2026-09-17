import 'package:flutter/material.dart';

import '../../../ui/app_colors.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';

/// 가운데 정렬된 세그먼트. 폭은 내용만큼 — 화면을 가로지르지 않는다.
class PillTabs extends StatelessWidget {
  const PillTabs({super.key, required this.labels, required this.selectedIndex, this.onSelected});

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int>? onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.tabPadding),
      decoration: BoxDecoration(
        color: AppColors.tabContainer,
        borderRadius: BorderRadius.circular(AppSizes.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0) SizedBox(width: AppSizes.tabGap),
            _Tab(label: labels[i], selected: i == selectedIndex, onTap: () => onSelected?.call(i)),
          ],
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppSizes.tabItemVPadding, horizontal: AppSizes.tabItemHPadding),
        alignment: Alignment.center,
        decoration: selected
            ? BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppSizes.pill),
                boxShadow: [
                  BoxShadow(color: AppColors.tabShadow, offset: AppSizes.shadowOffset, blurRadius: AppSizes.shadowBlur),
                ],
              )
            : null,
        child: Text(label, style: selected ? AppTextStyles.tabSelected : AppTextStyles.tabUnselected),
      ),
    );
  }
}

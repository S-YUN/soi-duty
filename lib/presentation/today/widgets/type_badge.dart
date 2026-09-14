import 'package:flutter/material.dart';

import '../../../domain/model/work_type.dart';
import '../../../ui/app_colors.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';
import '../today_texts.dart';

class TypeBadge extends StatelessWidget {
  const TypeBadge({super.key, required this.type});

  final WorkType type;

  @override
  Widget build(BuildContext context) {
    final isDayOff = type == WorkType.dayOff;
    return Container(
      padding: AppSizes.badgePadding,
      decoration: BoxDecoration(
        color: isDayOff ? AppColors.dayOffBackground : AppColors.holidayBackground,
        borderRadius: BorderRadius.circular(AppSizes.pill),
        border: Border.all(
          color: isDayOff ? AppColors.dayOffBorder : AppColors.holidayBorder,
          width: AppSizes.badgeBorder,
        ),
      ),
      child: Text(
        TodayTexts.badgeLabel(type),
        style: AppTextStyles.badge.copyWith(color: isDayOff ? AppColors.dayOffText : AppColors.holidayText),
      ),
    );
  }
}

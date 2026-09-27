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
    final (background, foreground) = AppColors.typeColors(type);
    return Container(
      padding: AppSizes.badgePadding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSizes.pill),
        border: Border.all(color: AppColors.typeBorder(type), width: AppSizes.badgeBorder),
      ),
      child: Text(TodayTexts.badgeLabel(type), style: AppTextStyles.badge.copyWith(color: foreground)),
    );
  }
}

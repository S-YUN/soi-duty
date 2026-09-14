import 'package:flutter/painting.dart';

import 'app_colors.dart';
import 'app_sizes.dart';

abstract final class AppDecorations {
  static BoxDecoration get card => BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        boxShadow: [
          BoxShadow(color: AppColors.cardShadow, offset: AppSizes.shadowOffset, blurRadius: AppSizes.shadowBlur),
        ],
      );
}

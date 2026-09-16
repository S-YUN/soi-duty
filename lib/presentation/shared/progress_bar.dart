import 'package:flutter/material.dart';

import '../../ui/app_colors.dart';
import '../../ui/app_sizes.dart';

/// 높이 6 진행 바. 트랙 divider, 채움 brand, 너비 .4s ease. 오늘 히어로·주간 누적 카드 공용.
class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.value});

  /// 0..1
  final double value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.progressBar,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.pill),
        child: Stack(
          children: [
            Container(color: AppColors.divider),
            AnimatedFractionallySizedBox(
              duration: AppDurations.progressBar,
              curve: Curves.ease,
              alignment: Alignment.centerLeft,
              widthFactor: value,
              child: Container(
                decoration: BoxDecoration(color: AppColors.brand, borderRadius: BorderRadius.circular(AppSizes.pill)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../ui/app_colors.dart';
import '../../../ui/app_sizes.dart';

/// 앱 토큰으로 그린 토글 — 설정의 "퇴근 알림" (핸드오프 6 §9, 이 앱의 첫 토글).
/// 직접 탭을 받지 않는다: 행 어디를 눌러도 바뀌도록 행(`SettingsRow.onTap`)이 탭을 받고, 이 위젯은 상태만 그린다.
class SoiSwitch extends StatelessWidget {
  const SoiSwitch({super.key, required this.value});

  final bool value;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      child: AnimatedContainer(
        duration: AppDurations.switchSlide,
        width: AppSizes.switchWidth,
        height: AppSizes.switchHeight,
        padding: EdgeInsets.all(AppSizes.switchPadding),
        decoration: BoxDecoration(
          color: value ? AppColors.brand : AppColors.checkboxBorder,
          borderRadius: BorderRadius.circular(AppSizes.pill),
        ),
        child: AnimatedAlign(
          duration: AppDurations.switchSlide,
          curve: Curves.easeOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: AppSizes.switchKnob,
            height: AppSizes.switchKnob,
            decoration: BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: AppColors.switchKnobShadow, offset: AppSizes.switchKnobShadowOffset, blurRadius: AppSizes.switchKnobShadowBlur),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

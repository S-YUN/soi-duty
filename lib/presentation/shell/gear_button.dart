import 'package:flutter/material.dart';

import '../../ui/app_colors.dart';
import '../../ui/app_sizes.dart';

/// 설정 진입 톱니. 44×44 원형 히트 영역, 눌리면 탭 컨테이너 색이 깔린다.
class GearButton extends StatefulWidget {
  const GearButton({super.key, required this.onTap, required this.tooltip});

  final VoidCallback onTap;
  final String tooltip;

  @override
  State<GearButton> createState() => _GearButtonState();
}

class _GearButtonState extends State<GearButton> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppDurations.pressedOpacity,
          width: AppSizes.gearSize,
          height: AppSizes.gearSize,
          alignment: Alignment.center,
          decoration: BoxDecoration(shape: BoxShape.circle, color: _pressed ? AppColors.tabContainer : null),
          child: Icon(Icons.settings_outlined, size: AppSizes.gearIcon, color: AppColors.subtle),
        ),
      ),
    );
  }
}

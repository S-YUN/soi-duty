import 'package:flutter/material.dart';

import '../../ui/app_colors.dart';
import '../../ui/app_sizes.dart';

/// 설정 진입 톱니. 44×44 원형 히트 영역, 눌리면 탭 컨테이너 색이 깔린다.
/// 아이콘은 머티리얼 `settings_outlined`로 확정 — 디자인의 선 톱니와 거의 같고 경로를 직접 그릴 가치가 없다 (2026-10-25).
class GearButton extends StatefulWidget {
  const GearButton({super.key, required this.onTap, required this.label});

  final VoidCallback onTap;
  /// 접근성·드라이버용 라벨. 툴팁 풍선은 띄우지 않는다.
  final String label;

  @override
  State<GearButton> createState() => _GearButtonState();
}

class _GearButtonState extends State<GearButton> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.label,
      button: true,
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

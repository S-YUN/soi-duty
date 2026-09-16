import 'package:flutter/material.dart';

import '../../ui/app_colors.dart';
import '../../ui/app_sizes.dart';
import '../../ui/app_text_styles.dart';

/// 보조 슬롯의 박스 없는 텍스트 버튼. 13/w500 brand, pressed opacity .55, 세로 44 히트 영역.
class QuietTextButton extends StatefulWidget {
  const QuietTextButton({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<QuietTextButton> createState() => _QuietTextButtonState();
}

class _QuietTextButtonState extends State<QuietTextButton> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: AppSizes.minTapHeight),
        child: Center(
          child: AnimatedOpacity(
            duration: AppDurations.pressedOpacity,
            opacity: _pressed ? AppOpacities.quietPressed : 1,
            child: Padding(
              padding: AppSizes.quietButtonPadding,
              child: Text(widget.label, style: AppTextStyles.quietButton),
            ),
          ),
        ),
      ),
    );
  }
}

/// 보조 슬롯에서 두 항목 사이에 서는 1×11 구분선.
class SlotDivider extends StatelessWidget {
  const SlotDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(width: AppSizes.slotDividerWidth, height: AppSizes.slotDividerHeight, color: AppColors.hairline);
  }
}

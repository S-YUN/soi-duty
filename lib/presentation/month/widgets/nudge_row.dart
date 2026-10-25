import 'package:flutter/material.dart';

import '../../../ui/app_colors.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';
import '../../shared/stroke_icons.dart';

/// 카드 안의 유도 줄 — "시급을 알려주시면 …" + 꺾쇠. 누르면 입력 시트.
class NudgeRow extends StatefulWidget {
  const NudgeRow({super.key, required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  State<NudgeRow> createState() => _NudgeRowState();
}

class _NudgeRowState extends State<NudgeRow> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedOpacity(
        duration: AppDurations.pressedOpacity,
        opacity: _pressed ? AppOpacities.cellPressed : 1,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: AppSizes.nudgeMinHeight),
          child: Row(
            children: [
              Expanded(child: Text(widget.text, style: AppTextStyles.nudge)),
              SizedBox(width: AppSizes.nudgeGap),
              ChevronIcon(size: AppSizes.chevron, color: AppColors.brand, stroke: AppSizes.chevronStroke),
            ],
          ),
        ),
      ),
    );
  }
}

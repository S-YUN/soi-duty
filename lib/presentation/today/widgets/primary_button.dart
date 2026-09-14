import 'package:flutter/material.dart';

import '../../../ui/app_colors.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';

/// 주 버튼. 높이 고정(AppSizes.primaryButton). onPressed가 null이면 비활성.
class PrimaryButton extends StatefulWidget {
  const PrimaryButton({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  var _pressed = false;

  bool get _enabled => widget.onPressed != null;

  void _setPressed(bool v) {
    if (_enabled && _pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final color = !_enabled
        ? AppColors.buttonDisabled
        : _pressed
            ? AppColors.brandPressed
            : AppColors.brand;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? AppScales.buttonPressed : 1,
        duration: AppDurations.buttonScale,
        child: AnimatedContainer(
          duration: AppDurations.buttonColor,
          height: AppSizes.primaryButton,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(AppSizes.buttonRadius)),
          child: Text(
            widget.label,
            style: _enabled ? AppTextStyles.primaryButton : AppTextStyles.primaryButtonDisabled,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../ui/app_colors.dart';
import '../../ui/app_sizes.dart';
import '../../ui/app_text_styles.dart';

/// ◀ · 라벨(min-width 186) · ▶. 비활성 화살표는 hairline 색 + 무반응.
class PeriodNavigator extends StatelessWidget {
  const PeriodNavigator({
    super.key,
    required this.label,
    required this.canGoPrev,
    required this.canGoNext,
    required this.onPrev,
    required this.onNext,
  });

  final String label;
  final bool canGoPrev;
  final bool canGoNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSizes.navPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Arrow(glyph: '◀', enabled: canGoPrev, onTap: onPrev),
          SizedBox(width: AppSizes.navGap),
          ConstrainedBox(
            constraints: BoxConstraints(minWidth: AppSizes.navLabelMinWidth),
            child: Text(label, style: AppTextStyles.navLabel, textAlign: TextAlign.center, maxLines: 1),
          ),
          SizedBox(width: AppSizes.navGap),
          _Arrow(glyph: '▶', enabled: canGoNext, onTap: onNext),
        ],
      ),
    );
  }
}

class _Arrow extends StatefulWidget {
  const _Arrow({required this.glyph, required this.enabled, required this.onTap});

  final String glyph;
  final bool enabled;
  final VoidCallback onTap;

  @override
  State<_Arrow> createState() => _ArrowState();
}

class _ArrowState extends State<_Arrow> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: widget.enabled ? () => setState(() => _pressed = false) : null,
      onTap: widget.enabled ? widget.onTap : null,
      child: SizedBox(
        width: AppSizes.minTapHeight,
        height: AppSizes.minTapHeight,
        child: Center(
          child: Container(
            width: AppSizes.navArrow,
            height: AppSizes.navArrow,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _pressed ? AppColors.tabContainer : Colors.transparent,
            ),
            child: Text(widget.glyph, style: widget.enabled ? AppTextStyles.navArrow : AppTextStyles.navArrowDisabled),
          ),
        ),
      ),
    );
  }
}

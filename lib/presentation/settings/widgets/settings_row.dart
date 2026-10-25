import 'package:flutter/material.dart';

import '../../../ui/app_colors.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';
import '../../shared/stroke_icons.dart';

/// 설정 카드 안의 한 행: 라벨(+보조 설명) · 오른쪽 값 · 꺾쇠. 탭 가능하면 눌림에 투명도.
class SettingsRow extends StatefulWidget {
  const SettingsRow({
    super.key,
    required this.label,
    this.sub,
    this.value,
    this.valueSet = false,
    this.trailing,
    this.chevron = false,
    this.onTap,
    this.padding,
  });

  final String label;
  final String? sub;
  final String? value;
  /// 값이 설정된 상태(브랜드색 굵게)인지, "사용 안 함"(회색)인지.
  final bool valueSet;
  final Widget? trailing;
  final bool chevron;
  final VoidCallback? onTap;
  final EdgeInsets? padding;

  @override
  State<SettingsRow> createState() => _SettingsRowState();
}

class _SettingsRowState extends State<SettingsRow> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    final tappable = widget.onTap != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: tappable ? (_) => setState(() => _pressed = true) : null,
      onTapUp: tappable ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: tappable ? () => setState(() => _pressed = false) : null,
      onTap: widget.onTap,
      child: AnimatedOpacity(
        duration: AppDurations.pressedOpacity,
        opacity: _pressed ? AppOpacities.cellPressed : 1,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: AppSizes.settingsRowMinHeight),
          child: Padding(
            padding: widget.padding ?? AppSizes.settingsRowPadding,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.label, style: AppTextStyles.settingsRowLabel),
                      if (widget.sub != null) ...[
                        SizedBox(height: AppSizes.settingsSubTop),
                        Text(widget.sub!, style: AppTextStyles.settingsRowSub),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: AppSizes.settingsRowGap),
                if (widget.value != null)
                  Text(
                    widget.value!,
                    style: widget.valueSet ? AppTextStyles.settingsValueSet : AppTextStyles.settingsValueUnset,
                    softWrap: false,
                  ),
                if (widget.trailing != null) widget.trailing!,
                if (widget.chevron) ...[
                  SizedBox(width: AppSizes.settingsRowGap),
                  ChevronIcon(size: AppSizes.chevron, color: AppColors.wheelUnselected, stroke: AppSizes.chevronStroke),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

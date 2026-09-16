import 'package:flutter/material.dart';

import '../../ui/app_colors.dart';
import '../../ui/app_decorations.dart';
import '../../ui/app_sizes.dart';
import '../../ui/app_text_styles.dart';

/// 앱 토큰으로 만든 확인 다이얼로그. true면 확인.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = '취소',
}) async {
  final result = await showDialog<bool>(
    context: context,
    useRootNavigator: true,
    barrierColor: AppColors.scrim,
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: AppSizes.screenHPadding),
      child: Container(
        padding: AppSizes.dialogPadding,
        decoration: AppDecorations.card,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.dialogTitle),
            SizedBox(height: AppSizes.dialogMessageTop),
            Text(message, style: AppTextStyles.dialogMessage),
            SizedBox(height: AppSizes.dialogButtonsTop),
            Row(
              children: [
                Expanded(
                  child: SheetButton(
                    label: cancelLabel,
                    primary: false,
                    height: AppSizes.dialogButton,
                    onTap: () => Navigator.of(dialogContext).pop(false),
                  ),
                ),
                SizedBox(width: AppSizes.sheetButtonGap),
                Expanded(
                  child: SheetButton(
                    label: confirmLabel,
                    primary: true,
                    height: AppSizes.dialogButton,
                    onTap: () => Navigator.of(dialogContext).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}

/// 시트·다이얼로그 공용 버튼. primary(brand) / secondary(chipNeutral). onTap null이면 비활성.
class SheetButton extends StatefulWidget {
  const SheetButton({super.key, required this.label, required this.primary, required this.onTap, this.height});

  final String label;
  final bool primary;
  final VoidCallback? onTap;
  final double? height;

  @override
  State<SheetButton> createState() => _SheetButtonState();
}

class _SheetButtonState extends State<SheetButton> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final Color color;
    final TextStyle style;
    if (!enabled) {
      color = AppColors.buttonDisabled;
      style = AppTextStyles.sheetButtonSecondary;
    } else if (widget.primary) {
      color = _pressed ? AppColors.brandPressed : AppColors.brand;
      style = AppTextStyles.sheetButtonPrimary;
    } else {
      color = _pressed ? AppColors.listRowPressed : AppColors.chipNeutral;
      style = AppTextStyles.sheetButtonSecondary;
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: AppDurations.buttonColor,
        height: widget.height ?? AppSizes.sheetButton,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(AppSizes.sheetButtonRadius)),
        child: Text(widget.label, style: style),
      ),
    );
  }
}

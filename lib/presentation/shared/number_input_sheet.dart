import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/presentation/format/number_format.dart';
import '../../ui/app_colors.dart';
import '../../ui/app_sizes.dart';
import '../../ui/app_text_styles.dart';
import 'confirm_dialog.dart';

/// 총 연차·시급 공용 숫자 입력 시트. OS 숫자 키패드를 쓰고(앱이 그리지 않음) 시트는 키보드 위에 뜬다.
/// 저장은 값이 1 이상일 때만. [initial]이 있으면 채워서 열리고 [onClear] 링크("사용 안 함으로 되돌리기")가 보인다.
/// 바깥 탭·내리기는 아무것도 저장하지 않는다.
Future<void> showNumberInputSheet(
  BuildContext context, {
  required String title,
  required String unit,
  required String note,
  bool lockIcon = false,
  required int maxDigits,
  bool grouping = false,
  int? initial,
  required String saveLabel,
  required String clearLabel,
  required ValueChanged<int> onSave,
  VoidCallback? onClear,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.scrim,
    sheetAnimationStyle: AnimationStyle(duration: AppDurations.sheetSlide, curve: AppCurves.sheet),
    builder: (_) => NumberInputSheet(
      title: title,
      unit: unit,
      note: note,
      lockIcon: lockIcon,
      maxDigits: maxDigits,
      grouping: grouping,
      initial: initial,
      saveLabel: saveLabel,
      clearLabel: clearLabel,
      onSave: onSave,
      onClear: onClear,
    ),
  );
}

class NumberInputSheet extends StatefulWidget {
  const NumberInputSheet({
    super.key,
    required this.title,
    required this.unit,
    required this.note,
    required this.lockIcon,
    required this.maxDigits,
    required this.grouping,
    required this.initial,
    required this.saveLabel,
    required this.clearLabel,
    required this.onSave,
    required this.onClear,
  });

  final String title;
  final String unit;
  final String note;
  final bool lockIcon;
  final int maxDigits;
  final bool grouping;
  final int? initial;
  final String saveLabel;
  final String clearLabel;
  final ValueChanged<int> onSave;
  final VoidCallback? onClear;

  @override
  State<NumberInputSheet> createState() => _NumberInputSheetState();
}

class _NumberInputSheetState extends State<NumberInputSheet> {
  late final _controller = TextEditingController(
    text: widget.initial == null ? '' : _format(widget.initial.toString()),
  );

  String _format(String digits) => widget.grouping && digits.isNotEmpty ? formatThousands(int.parse(digits)) : digits;

  int get _value {
    final digits = _controller.text.replaceAll(',', '');
    return digits.isEmpty ? 0 : int.parse(digits);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _close() => Navigator.of(context, rootNavigator: true).pop();

  void _save() {
    widget.onSave(_value);
    _close();
  }

  void _clear() {
    widget.onClear?.call();
    _close();
  }

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final safe = MediaQuery.viewPaddingOf(context).bottom;
    final inset = EdgeInsets.symmetric(horizontal: AppSizes.sheetPadding.left);
    final valid = _value > 0;
    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.sheetRadius)),
          boxShadow: [
            BoxShadow(color: AppColors.sheetShadow, offset: AppSizes.sheetShadowOffset, blurRadius: AppSizes.sheetShadowBlur),
          ],
        ),
        padding: EdgeInsets.only(
          top: AppSizes.sheetPadding.top,
          bottom: AppSizes.numberSheetBottom + (keyboard > 0 ? 0 : safe),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: AppSizes.sheetHandleWidth,
                height: AppSizes.sheetHandleHeight,
                margin: EdgeInsets.only(bottom: AppSizes.sheetHandleBottom),
                decoration: BoxDecoration(color: AppColors.hairline, borderRadius: BorderRadius.circular(AppSizes.pill)),
              ),
            ),
            Padding(padding: inset, child: Text(widget.title, style: AppTextStyles.sheetTitle)),
            Padding(
              padding: inset.copyWith(top: AppSizes.numberFieldTop),
              child: Container(
                padding: AppSizes.numberFieldPadding,
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.brand, width: AppSizes.numberFieldUnderline)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _DigitsFormatter(maxDigits: widget.maxDigits, grouping: widget.grouping),
                        ],
                        onChanged: (_) => setState(() {}),
                        style: AppTextStyles.numberField,
                        cursorColor: AppColors.brand,
                        cursorWidth: AppSizes.numberFieldUnderline,
                        decoration: InputDecoration.collapsed(
                          hintText: '0',
                          hintStyle: AppTextStyles.numberFieldEmpty,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSizes.numberFieldGap),
                    Text(widget.unit, style: AppTextStyles.numberUnit),
                  ],
                ),
              ),
            ),
            Padding(
              padding: inset.copyWith(top: AppSizes.numberNoteTop),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.lockIcon) ...[
                    Padding(
                      padding: EdgeInsets.only(top: AppSizes.plannedLineTop),
                      child: Icon(Icons.lock_outline_rounded, size: AppSizes.lockIcon, color: AppColors.subtle),
                    ),
                    SizedBox(width: AppSizes.lockIconGap),
                  ],
                  Expanded(child: Text(widget.note, style: AppTextStyles.settingsNote)),
                ],
              ),
            ),
            Padding(
              padding: inset.copyWith(top: AppSizes.numberSaveTop),
              child: SheetButton(label: widget.saveLabel, primary: true, onTap: valid ? _save : null),
            ),
            if (widget.initial != null && widget.onClear != null)
              Padding(
                padding: EdgeInsets.only(top: AppSizes.clearLinkTop),
                child: Center(child: _ClearLink(label: widget.clearLabel, onTap: _clear)),
              ),
          ],
        ),
      ),
    );
  }
}

/// 숫자만, 앞자리 0 제거, 자릿수 한도, (선택) 천 단위 콤마. 커서는 항상 끝.
class _DigitsFormatter extends TextInputFormatter {
  const _DigitsFormatter({required this.maxDigits, required this.grouping});

  final int maxDigits;
  final bool grouping;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = newValue.text.replaceAll(',', '').replaceFirst(RegExp(r'^0+(?=\d)'), '');
    // 한도를 넘는 자리는 잘라낸다 — 한 글자씩 칠 때는 "8번째 숫자 무시"와 같다.
    if (digits.length > maxDigits) digits = digits.substring(0, maxDigits);
    final text = grouping && digits.isNotEmpty ? formatThousands(int.parse(digits)) : digits;
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}

class _ClearLink extends StatefulWidget {
  const _ClearLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_ClearLink> createState() => _ClearLinkState();
}

class _ClearLinkState extends State<_ClearLink> {
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
        constraints: BoxConstraints(minHeight: AppSizes.clearLinkMinHeight),
        child: Center(
          child: AnimatedOpacity(
            duration: AppDurations.pressedOpacity,
            opacity: _pressed ? AppOpacities.quietPressed : 1,
            child: Padding(
              padding: AppSizes.clearLinkPadding,
              child: Text(widget.label, style: AppTextStyles.clearLink),
            ),
          ),
        ),
      ),
    );
  }
}

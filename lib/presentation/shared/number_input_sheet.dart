import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/presentation/format/number_format.dart';
import '../../ui/app_colors.dart';
import '../../ui/app_sizes.dart';
import '../../ui/app_text_styles.dart';
import 'confirm_dialog.dart';

/// 남은 연차·시급 공용 숫자 입력 시트. OS 숫자 키패드를 쓰고(앱이 그리지 않음) 시트는 키보드 위에 뜬다.
///
/// - [decimalPlaces] > 0이면 소수점 키패드. 정수 [maxDigits]자리 · 점 하나 · 소수 [decimalPlaces]자리. ","는 "."로 받는다.
/// - 저장 활성 = 비어 있지 않고 숫자로 읽히고 [isValid](기본 `> 0`). 비어 있지 않은데 점이 있고 끝이 점이 아닌 값이
///   [isValid]에 걸리면 입력줄 아래 [invalidNote]를 붉게 띄운다.
/// - [headline]은 제목 아래 한 줄, [notes]는 안내 여러 줄, [highlightNote]는 그 아래 브랜드색 한 줄(조건부).
/// - [emptyCaption]은 빈 값일 때 입력줄 안 "0" 플레이스홀더 옆에 — 저장 가능한 0과 구분.
/// - 본문은 스크롤, 저장·되돌리기는 키보드 위 고정 — 높이가 모자란 기기에서 제목이 잘리지 않게 (2026-10-27).
/// [initial]이 있으면 채워서 열리고 [onClear] 링크("사용 안 함으로 되돌리기")가 보인다. 바깥 탭·내리기는 아무것도 저장하지 않는다.
Future<void> showNumberInputSheet(
  BuildContext context, {
  required String title,
  String? headline,
  required String unit,
  required List<String> notes,
  String? highlightNote,
  bool lockIcon = false,
  required int maxDigits,
  int decimalPlaces = 0,
  bool grouping = false,
  String? emptyCaption,
  bool Function(num value)? isValid,
  String? invalidNote,
  num? initial,
  required String saveLabel,
  required String clearLabel,
  required ValueChanged<num> onSave,
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
      headline: headline,
      unit: unit,
      notes: notes,
      highlightNote: highlightNote,
      lockIcon: lockIcon,
      maxDigits: maxDigits,
      decimalPlaces: decimalPlaces,
      grouping: grouping,
      emptyCaption: emptyCaption,
      isValid: isValid ?? (v) => v > 0,
      invalidNote: invalidNote,
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
    required this.headline,
    required this.unit,
    required this.notes,
    required this.highlightNote,
    required this.lockIcon,
    required this.maxDigits,
    required this.decimalPlaces,
    required this.grouping,
    required this.emptyCaption,
    required this.isValid,
    required this.invalidNote,
    required this.initial,
    required this.saveLabel,
    required this.clearLabel,
    required this.onSave,
    required this.onClear,
  });

  final String title;
  final String? headline;
  final String unit;
  final List<String> notes;
  final String? highlightNote;
  final bool lockIcon;
  final int maxDigits;
  final int decimalPlaces;
  final bool grouping;
  final String? emptyCaption;
  final bool Function(num value) isValid;
  final String? invalidNote;
  final num? initial;
  final String saveLabel;
  final String clearLabel;
  final ValueChanged<num> onSave;
  final VoidCallback? onClear;

  @override
  State<NumberInputSheet> createState() => _NumberInputSheetState();
}

class _NumberInputSheetState extends State<NumberInputSheet> {
  late final _controller = TextEditingController(text: widget.initial == null ? '' : _initialText(widget.initial!));

  bool get _decimal => widget.decimalPlaces > 0;

  /// 15 → "15", 15.0 → "15", 8.5 → "8.5". 시급은 콤마.
  String _initialText(num v) {
    if (v == v.roundToDouble()) return widget.grouping ? formatThousands(v.toInt()) : v.toInt().toString();
    return v.toStringAsFixed(widget.decimalPlaces).replaceFirst(RegExp(r'0+$'), '');
  }

  String get _text => _controller.text.replaceAll(',', '');

  /// 비어 있거나 끝이 점이면 null — 저장할 수 없는 상태.
  num? get _value => _text.isEmpty || _text.endsWith('.') ? null : num.tryParse(_text);

  bool get _canSave {
    final v = _value;
    return v != null && widget.isValid(v);
  }

  /// 점이 있고 끝이 점이 아닌데 단위가 안 맞을 때만 — "8."은 치는 중이라 조용히 비활성.
  bool get _showInvalid {
    final v = _value;
    return widget.invalidNote != null && _text.contains('.') && v != null && !widget.isValid(v);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _close() => Navigator.of(context, rootNavigator: true).pop();

  void _save() {
    widget.onSave(_value!);
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
    final headline = widget.headline;
    final compact = headline != null;
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
            Flexible(
              child: SingleChildScrollView(
                reverse: true, // 모자랄 때 제목 쪽이 올라가고 입력줄·안내는 버튼 곁에 남는다
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
                    if (headline != null)
                      Padding(
                        padding: inset.copyWith(top: AppSizes.numberHeadlineTop),
                        child: Text(headline, style: AppTextStyles.numberHeadline),
                      ),
                    Padding(
                      padding: inset.copyWith(top: compact ? AppSizes.numberFieldTopWithHeadline : AppSizes.numberFieldTop),
                      child: Container(
                        padding: compact ? AppSizes.numberFieldPaddingCompact : AppSizes.numberFieldPadding,
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: AppColors.brand, width: AppSizes.numberFieldUnderline)),
                        ),
                        child: Row(
                          children: [
                            // flex 자식은 이 하나뿐 — 필드와 캡션을 묶어 늘리고 단위는 항상 오른쪽 끝에.
                            Expanded(
                              child: Row(
                                children: [
                                  Flexible(
                                    child: IntrinsicWidth(
                                      child: TextField(
                                        controller: _controller,
                                        autofocus: true,
                                        keyboardType: TextInputType.numberWithOptions(decimal: _decimal),
                                        inputFormatters: [
                                          if (_decimal)
                                            _DecimalFormatter(maxIntDigits: widget.maxDigits, decimalPlaces: widget.decimalPlaces)
                                          else ...[
                                            FilteringTextInputFormatter.digitsOnly,
                                            _DigitsFormatter(maxDigits: widget.maxDigits, grouping: widget.grouping),
                                          ],
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
                                  ),
                                  if (widget.emptyCaption != null && _text.isEmpty) ...[
                                    SizedBox(width: AppSizes.numberFieldGap),
                                    Text(widget.emptyCaption!, style: AppTextStyles.numberEmptyCaption),
                                  ],
                                ],
                              ),
                            ),
                            SizedBox(width: AppSizes.numberFieldGap),
                            Text(widget.unit, style: AppTextStyles.numberUnit),
                          ],
                        ),
                      ),
                    ),
                    if (_showInvalid)
                      Padding(
                        padding: inset.copyWith(top: AppSizes.numberInvalidTop),
                        child: Text(widget.invalidNote!, style: AppTextStyles.numberInvalid),
                      ),
                    Padding(
                      padding: inset.copyWith(top: compact ? AppSizes.numberNotesTop : AppSizes.numberNoteTop),
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                for (final n in widget.notes) Text(n, style: compact ? AppTextStyles.numberNotes : AppTextStyles.settingsNote),
                                if (widget.highlightNote != null) Text(widget.highlightNote!, style: AppTextStyles.numberHighlightNote),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: inset.copyWith(top: compact ? AppSizes.numberSaveTopCompact : AppSizes.numberSaveTop),
              child: SheetButton(label: widget.saveLabel, primary: true, onTap: _canSave ? _save : null),
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

/// 소수점 입력: ","는 ".", 숫자와 첫 "."만, 정수 [maxIntDigits]자리, 소수 [decimalPlaces]자리, 앞자리 0은 하나로("08"→"8"),
/// "."부터 치면 "0.". 커서는 항상 끝.
class _DecimalFormatter extends TextInputFormatter {
  const _DecimalFormatter({required this.maxIntDigits, required this.decimalPlaces});

  final int maxIntDigits;
  final int decimalPlaces;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final raw = newValue.text.replaceAll(',', '.');
    var intPart = '';
    String? fracPart;
    for (final ch in raw.split('')) {
      if (ch == '.') {
        fracPart ??= '';
      } else if (RegExp(r'\d').hasMatch(ch)) {
        if (fracPart == null) {
          intPart += ch;
        } else {
          fracPart += ch;
        }
      }
    }
    intPart = intPart.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    if (intPart.length > maxIntDigits) intPart = intPart.substring(0, maxIntDigits);
    if (fracPart != null) {
      if (intPart.isEmpty) intPart = '0';
      if (fracPart.length > decimalPlaces) fracPart = fracPart.substring(0, decimalPlaces);
    }
    final text = fracPart == null ? intPart : '$intPart.$fracPart';
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

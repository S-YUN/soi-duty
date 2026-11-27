import 'package:flutter/material.dart';

import '../../../domain/rules/work_calculator.dart';
import '../../../ui/app_colors.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';
import '../../shared/confirm_dialog.dart';
import '../record_edit_texts.dart';
import 'time_wheel.dart';

/// "몇 시부터 몇 시까지"를 고르는 작은 시트의 골격 — 제목 · 설명 · 칸 둘 · 휠 하나 · 안내 줄 · 버튼 · (링크).
/// 시간 출장 시트(핸드오프 6 §3)와 기본 출퇴근 시각 시트(핸드오프 7 §4)가 문구만 바꿔 쓴다.
/// 검증은 "끝이 시작보다 늦을 것" 하나. 열면 늘 앞 칸이 선택돼 있다.
class TimeRangeSheet extends StatefulWidget {
  const TimeRangeSheet({
    super.key,
    required this.title,
    required this.help,
    required this.startLabel,
    required this.endLabel,
    required this.start,
    required this.end,
    required this.validNote,
    required this.validNoteStyle,
    required this.invalidNote,
    required this.confirmLabel,
    required this.onConfirm,
    this.noteMinHeight = 0,
    this.linkLabel,
    this.onLink,
  });

  final String title;
  final String help;
  final String startLabel;
  final String endLabel;

  /// 같은 날의 두 시각. 휠이 고친 값도 이 날짜에 붙는다.
  final DateTime start;
  final DateTime end;

  /// 범위가 맞을 때 휠 아래 한 줄.
  final String Function(DateTime start, DateTime end) validNote;
  final TextStyle validNoteStyle;

  /// 끝 ≤ 시작일 때 같은 자리에 뜨는 줄 — 버튼이 꺼진다.
  final String invalidNote;
  final double noteMinHeight;
  final String confirmLabel;
  final void Function(DateTime start, DateTime end) onConfirm;

  /// 버튼 아래 조용한 링크. [onLink]가 없으면 그리지 않는다.
  final String? linkLabel;
  final VoidCallback? onLink;

  @override
  State<TimeRangeSheet> createState() => _TimeRangeSheetState();
}

class _TimeRangeSheetState extends State<TimeRangeSheet> {
  late DateTime _start = widget.start;
  late DateTime _end = widget.end;

  /// 휠이 고치는 칸. 처음엔 앞 칸.
  var _editingEnd = false;

  bool get _valid => minuteOnly(_end).isAfter(minuteOnly(_start));
  DateTime get _editing => _editingEnd ? _end : _start;

  void _onWheel(int hour, int minute) {
    final day = widget.start;
    final t = DateTime(day.year, day.month, day.day, hour, minute);
    setState(() => _editingEnd ? _end = t : _start = t);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final inset = EdgeInsets.symmetric(horizontal: AppSizes.sheetPadding.left);

    return ConstrainedBox(
      // 작은 기기(SE 320×568)에서 화면을 넘지 않게 — 넘치면 시트 안에서 스크롤한다.
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height - AppSizes.rangeSheetTopMargin),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.sheetRadius)),
          boxShadow: [
            BoxShadow(
              color: AppColors.sheetShadow,
              offset: AppSizes.sheetShadowOffset,
              blurRadius: AppSizes.sheetShadowBlur,
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(top: AppSizes.sheetPadding.top, bottom: AppSizes.sheetPadding.bottom + bottomInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: AppSizes.sheetHandleWidth,
                  height: AppSizes.sheetHandleHeight,
                  margin: EdgeInsets.only(bottom: AppSizes.sheetHandleBottom),
                  decoration: BoxDecoration(
                    color: AppColors.hairline,
                    borderRadius: BorderRadius.circular(AppSizes.pill),
                  ),
                ),
              ),
              Padding(
                padding: inset,
                child: Text(widget.title, style: AppTextStyles.sheetTitle),
              ),
              SizedBox(height: AppSizes.sheetSubtitleTop),
              Padding(
                padding: inset,
                child: Text(widget.help, style: AppTextStyles.sheetSubtitle),
              ),
              SizedBox(height: AppSizes.rangeCellsTop),
              Padding(
                padding: inset,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: _Cell(
                        label: widget.startLabel,
                        value: RecordEditTexts.time(_start),
                        selected: !_editingEnd,
                        onTap: () => setState(() => _editingEnd = false),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSizes.rangeDashGap,
                        0,
                        AppSizes.rangeDashGap,
                        AppSizes.rangeCellUnderlineTop,
                      ),
                      child: Text(RecordEditTexts.rangeDash, style: AppTextStyles.rangeDash),
                    ),
                    Expanded(
                      child: _Cell(
                        label: widget.endLabel,
                        value: RecordEditTexts.time(_end),
                        selected: _editingEnd,
                        onTap: () => setState(() => _editingEnd = true),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: inset,
                child: Container(
                  margin: EdgeInsets.only(top: AppSizes.wheelBoxTop),
                  padding: AppSizes.wheelBoxPadding,
                  decoration: BoxDecoration(
                    color: AppColors.cardInner,
                    borderRadius: BorderRadius.circular(AppSizes.wheelBoxRadius),
                  ),
                  // 칸을 바꾸면 휠을 새로 만든다 — 스크롤 위치가 그 칸의 값에서 시작하게.
                  child: TimeWheel(
                    key: ValueKey(_editingEnd),
                    hour: _editing.hour,
                    minute: _editing.minute,
                    onChanged: _onWheel,
                  ),
                ),
              ),
              SizedBox(height: AppSizes.rangeNoteTop),
              Padding(
                padding: inset,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: widget.noteMinHeight),
                  child: Center(
                    heightFactor: 1,
                    child: _valid
                        ? Text(widget.validNote(_start, _end), style: widget.validNoteStyle, textAlign: TextAlign.center)
                        : Text(widget.invalidNote, style: AppTextStyles.rangeInvalid, textAlign: TextAlign.center),
                  ),
                ),
              ),
              SizedBox(height: AppSizes.rangeSheetButtonTop),
              Padding(
                padding: inset,
                child: SheetButton(
                  label: widget.confirmLabel,
                  primary: true,
                  onTap: _valid ? () => widget.onConfirm(_start, _end) : null,
                ),
              ),
              if (widget.onLink != null)
                Center(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: widget.onLink,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: AppSizes.minTapHeight),
                      child: Padding(
                        padding: AppSizes.clearLinkPadding,
                        child: Center(
                          widthFactor: 1,
                          child: Text(widget.linkLabel ?? '', style: AppTextStyles.deleteLink),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 칸 하나 — 라벨 위, 값 아래, 밑줄. 고른 칸은 값이 브랜드색 굵게 + 밑줄 2px.
class _Cell extends StatelessWidget {
  const _Cell({required this.label, required this.value, required this.selected, required this.onTap});

  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.timeLabel),
            SizedBox(height: AppSizes.rangeCellValueTop),
            Text(value, style: AppTextStyles.timeValue(selected: selected)),
            // 밑줄 두께가 달라도 칸 높이는 같게 — 값이 위아래로 흔들리지 않는다.
            Container(
              height: AppSizes.rangeCellUnderlineOn,
              margin: EdgeInsets.only(top: AppSizes.rangeCellUnderlineTop),
              alignment: Alignment.bottomCenter,
              child: Container(
                height: selected ? AppSizes.rangeCellUnderlineOn : AppSizes.rangeCellUnderlineOff,
                color: selected ? AppColors.brand : AppColors.rowDivider,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

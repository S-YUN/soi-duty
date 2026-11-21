import 'package:flutter/material.dart';

import '../../../domain/rules/work_calculator.dart';
import '../../../ui/app_colors.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';
import '../../shared/confirm_dialog.dart';
import '../record_edit_texts.dart';
import 'time_wheel.dart';

/// 시간 출장 작은 시트의 결과. 바깥 탭·아래로 내리기면 null — 아무것도 바꾸지 않는다.
sealed class TripSheetResult {
  const TripSheetResult();
}

/// "확인"/"저장" — 이 범위로 남긴다.
class TripSheetSet extends TripSheetResult {
  const TripSheetSet(this.start, this.end);

  final DateTime start;
  final DateTime end;
}

/// "출장 지우기"
class TripSheetCleared extends TripSheetResult {
  const TripSheetCleared();
}

/// "몇 시부터 몇 시까지 출장"을 고르는 작은 시트 — 시간공제 시트처럼 큰 시트(또는 오늘 화면) 위에 겹쳐 뜬다.
/// 기록만 남기는 값이라 검증은 "끝이 시작보다 늦을 것" 하나다 (핸드오프 6 §3).
/// [existing]이면 이미 있는 범위를 고치는 중 — "출장 지우기"가 보인다.
Future<TripSheetResult?> showTripSheet(
  BuildContext context, {
  required DateTime start,
  required DateTime end,
  required bool existing,
  required String confirmLabel,
}) {
  return showModalBottomSheet<TripSheetResult>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.scrim,
    sheetAnimationStyle: AnimationStyle(duration: AppDurations.sheetSlide, curve: AppCurves.sheet),
    builder: (_) => TripSheet(start: start, end: end, existing: existing, confirmLabel: confirmLabel),
  );
}

class TripSheet extends StatefulWidget {
  const TripSheet({
    super.key,
    required this.start,
    required this.end,
    required this.existing,
    required this.confirmLabel,
  });

  final DateTime start;
  final DateTime end;
  final bool existing;
  final String confirmLabel;

  @override
  State<TripSheet> createState() => _TripSheetState();
}

class _TripSheetState extends State<TripSheet> {
  late DateTime _start = widget.start;
  late DateTime _end = widget.end;

  /// 휠이 고치는 칸. 처음엔 "시작".
  var _editingEnd = false;

  bool get _valid => isValidTripRange(_start, _end);
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
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height - AppSizes.tripSheetTopMargin),
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
                child: Text(RecordEditTexts.tripSheetTitle, style: AppTextStyles.sheetTitle),
              ),
              SizedBox(height: AppSizes.sheetSubtitleTop),
              Padding(
                padding: inset,
                child: Text(RecordEditTexts.tripSheetHelp, style: AppTextStyles.sheetSubtitle),
              ),
              SizedBox(height: AppSizes.tripCellsTop),
              Padding(
                padding: inset,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: _Cell(
                        label: RecordEditTexts.tripStart,
                        value: RecordEditTexts.time(_start),
                        selected: !_editingEnd,
                        onTap: () => setState(() => _editingEnd = false),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSizes.tripDashGap,
                        0,
                        AppSizes.tripDashGap,
                        AppSizes.tripCellUnderlineTop,
                      ),
                      child: Text(RecordEditTexts.tripDash, style: AppTextStyles.tripDash),
                    ),
                    Expanded(
                      child: _Cell(
                        label: RecordEditTexts.tripEnd,
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
              SizedBox(height: AppSizes.tripResultTop),
              Padding(
                padding: inset,
                child: _valid
                    ? Text(
                        RecordEditTexts.tripResult(_start, _end),
                        style: AppTextStyles.tripResult,
                        textAlign: TextAlign.center,
                      )
                    : Text(RecordEditTexts.tripInvalid, style: AppTextStyles.tripInvalid, textAlign: TextAlign.center),
              ),
              SizedBox(height: AppSizes.tripSheetButtonTop),
              Padding(
                padding: inset,
                child: SheetButton(
                  label: widget.confirmLabel,
                  primary: true,
                  onTap: _valid ? () => Navigator.of(context).pop(TripSheetSet(_start, _end)) : null,
                ),
              ),
              if (widget.existing)
                Center(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).pop(const TripSheetCleared()),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: AppSizes.minTapHeight),
                      child: Padding(
                        padding: AppSizes.clearLinkPadding,
                        child: Center(
                          widthFactor: 1,
                          child: Text(RecordEditTexts.tripClear, style: AppTextStyles.deleteLink),
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

/// "시작"/"끝" 칸 — 라벨 위, 값 아래, 밑줄. 고른 칸은 값이 브랜드색 굵게 + 밑줄 2px.
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
            SizedBox(height: AppSizes.tripCellValueTop),
            Text(value, style: AppTextStyles.timeValue(selected: selected)),
            // 밑줄 두께가 달라도 칸 높이는 같게 — 값이 위아래로 흔들리지 않는다.
            Container(
              height: AppSizes.tripCellUnderlineOn,
              margin: EdgeInsets.only(top: AppSizes.tripCellUnderlineTop),
              alignment: Alignment.bottomCenter,
              child: Container(
                height: selected ? AppSizes.tripCellUnderlineOn : AppSizes.tripCellUnderlineOff,
                color: selected ? AppColors.brand : AppColors.rowDivider,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

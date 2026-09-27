import 'package:flutter/material.dart';

import '../../../ui/app_colors.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';
import '../../shared/confirm_dialog.dart';
import '../record_edit_texts.dart';
import 'duration_wheel.dart';

/// 시간공제만 고르는 작은 시트 — 시간 수정 시트 위에 겹쳐 뜬다. 큰 시트 안에 휠을 펼치면 화면을 넘어
/// 바텀시트가 닫히지 않아서 따로 뺐다 (2026-09-27). 고른 분을 돌려주고, 바깥 탭·아래로 내리기면 null.
Future<int?> showDeductionSheet(
  BuildContext context, {
  required int minutes,
  required int maxHours,
  required int stepMinutes,
  required String confirmLabel,
}) {
  return showModalBottomSheet<int>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.scrim,
    sheetAnimationStyle: AnimationStyle(duration: AppDurations.sheetSlide, curve: AppCurves.sheet),
    builder: (_) =>
        DeductionSheet(minutes: minutes, maxHours: maxHours, stepMinutes: stepMinutes, confirmLabel: confirmLabel),
  );
}

class DeductionSheet extends StatefulWidget {
  const DeductionSheet({
    super.key,
    required this.minutes,
    required this.maxHours,
    required this.stepMinutes,
    required this.confirmLabel,
  });

  final int minutes;
  final int maxHours;
  final int stepMinutes;
  final String confirmLabel;

  @override
  State<DeductionSheet> createState() => _DeductionSheetState();
}

class _DeductionSheetState extends State<DeductionSheet> {
  /// 휠을 돌리기 전엔 받은 값 그대로 — 퇴근 시 자동 공제된 2h 47m이 10분 단위로 깎이지 않게.
  late int _minutes = widget.minutes;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final inset = EdgeInsets.symmetric(horizontal: AppSizes.sheetPadding.left);

    return Container(
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
              decoration: BoxDecoration(color: AppColors.hairline, borderRadius: BorderRadius.circular(AppSizes.pill)),
            ),
          ),
          Padding(
            padding: inset,
            child: Text(RecordEditTexts.deductionLabel, style: AppTextStyles.sheetTitle),
          ),
          SizedBox(height: AppSizes.sheetSubtitleTop),
          Padding(
            padding: inset,
            child: Text(RecordEditTexts.deductionHelp, style: AppTextStyles.deductionHelp),
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
              child: DurationWheel(
                // 휠 위치는 단위로 내림 — 값은 돌렸을 때만 바뀐다.
                minutes: widget.minutes - widget.minutes % widget.stepMinutes,
                maxHours: widget.maxHours,
                stepMinutes: widget.stepMinutes,
                onChanged: (m) => _minutes = m,
              ),
            ),
          ),
          SizedBox(height: AppSizes.sheetButtonsTop),
          Padding(
            padding: inset,
            child: SheetButton(
              label: widget.confirmLabel,
              primary: true,
              onTap: () => Navigator.of(context).pop(_minutes),
            ),
          ),
        ],
      ),
    );
  }
}

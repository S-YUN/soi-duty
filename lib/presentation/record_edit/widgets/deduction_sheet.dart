import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../ui/app_colors.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';
import '../../shared/confirm_dialog.dart';
import '../record_edit_texts.dart';
import 'duration_wheel.dart';
import 'reason_field.dart';

/// 작은 시트가 돌려주는 값.
class DeductionInput {
  const DeductionInput(this.minutes, this.reason);

  final int minutes;
  final String reason;
}

/// 시간공제만 고르는 작은 시트 — 시간 수정 시트 위에 겹쳐 뜬다. 큰 시트 안에 휠·사유를 펼치면 화면을 넘어
/// 바텀시트가 닫히지 않고 키보드에 가려져서 따로 뺐다 (2026-09-27). 바깥 탭·아래로 내리기면 아무것도 바꾸지 않는다.
Future<DeductionInput?> showDeductionSheet(
  BuildContext context, {
  required int minutes,
  required String reason,
  required int maxHours,
  required int stepMinutes,
  required String confirmLabel,
}) {
  return showModalBottomSheet<DeductionInput>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.scrim,
    sheetAnimationStyle: AnimationStyle(duration: AppDurations.sheetSlide, curve: AppCurves.sheet),
    builder: (_) => DeductionSheet(
      minutes: minutes,
      reason: reason,
      maxHours: maxHours,
      stepMinutes: stepMinutes,
      confirmLabel: confirmLabel,
    ),
  );
}

class DeductionSheet extends StatefulWidget {
  const DeductionSheet({
    super.key,
    required this.minutes,
    required this.reason,
    required this.maxHours,
    required this.stepMinutes,
    required this.confirmLabel,
  });

  final int minutes;
  final String reason;
  final int maxHours;
  final int stepMinutes;
  final String confirmLabel;

  @override
  State<DeductionSheet> createState() => _DeductionSheetState();
}

class _DeductionSheetState extends State<DeductionSheet> {
  /// 휠을 돌리기 전엔 받은 값 그대로 — 퇴근 시 자동 공제된 2h 47m이 10분 단위로 깎이지 않게.
  late int _minutes = widget.minutes;
  late String _reason = widget.reason;

  void _confirm() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop(DeductionInput(_minutes, _reason));
  }

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final bottomInset = math.max(MediaQuery.viewPaddingOf(context).bottom, keyboard);
    final inset = EdgeInsets.symmetric(horizontal: AppSizes.sheetPadding.left);
    // 사유를 쓰는 동안엔 휠을 접는다 — 작은 화면에서도 입력칸과 확인 버튼이 키보드 위에 남게.
    final typing = keyboard > 0;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
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
        // 휠이 접히는 애니메이션 도중에도 넘치지 않게 스크롤로 감싼다.
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
                child: Text(RecordEditTexts.deductionLabel, style: AppTextStyles.sheetTitle),
              ),
              if (!typing) ...[
                SizedBox(height: AppSizes.sheetSubtitleTop),
                Padding(
                  padding: inset,
                  child: Text(RecordEditTexts.deductionHelp, style: AppTextStyles.sheetSubtitle),
                ),
              ],
              AnimatedSize(
                duration: AppDurations.sheetSlide,
                curve: AppCurves.sheet,
                alignment: Alignment.topCenter,
                child: typing
                    ? const SizedBox(width: double.infinity)
                    : Padding(
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
                            minutes: _minutes - _minutes % widget.stepMinutes,
                            maxHours: widget.maxHours,
                            stepMinutes: widget.stepMinutes,
                            onChanged: (m) => setState(() => _minutes = m),
                          ),
                        ),
                      ),
              ),
              SizedBox(height: AppSizes.reasonFieldTop),
              Padding(
                padding: inset,
                child: ReasonField(initial: widget.reason, onChanged: (t) => _reason = t),
              ),
              SizedBox(height: AppSizes.sheetButtonsTop),
              Padding(
                padding: inset,
                child: SheetButton(label: widget.confirmLabel, primary: true, onTap: _confirm),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

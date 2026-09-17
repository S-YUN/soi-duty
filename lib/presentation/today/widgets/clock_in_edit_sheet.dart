import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/clock_provider.dart';
import '../../../ui/app_colors.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';
import '../../record_edit/widgets/time_wheel.dart';
import '../../shared/confirm_dialog.dart';
import '../today_controller.dart';
import '../today_texts.dart';

/// 근무 중에 출근 시각만 고치는 작은 시트 — 출근하고 한참 뒤에 찍은 걸 바로잡는 용도.
/// 퇴근 행·계산 내역은 없다. 오늘의 나머지는 오늘 화면 버튼과 퇴근 후 전체 시트가 맡는다.
Future<void> showClockInEditSheet(BuildContext context, DateTime clockIn, Clock clock) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.scrim,
    sheetAnimationStyle: AnimationStyle(duration: AppDurations.sheetSlide, curve: AppCurves.sheet),
    builder: (_) => ClockInEditSheet(initial: clockIn, clock: clock),
  );
}

class ClockInEditSheet extends ConsumerStatefulWidget {
  const ClockInEditSheet({super.key, required this.initial, required this.clock});

  final DateTime initial;
  final Clock clock;

  @override
  ConsumerState<ClockInEditSheet> createState() => _ClockInEditSheetState();
}

class _ClockInEditSheetState extends ConsumerState<ClockInEditSheet> {
  late DateTime _value = widget.initial;

  /// 지금보다 늦은 출근은 말이 안 된다 — 경과가 음수가 되고 주간 실적이 줄어든다.
  bool get _tooLate => _value.isAfter(widget.clock());

  Future<void> _save() async {
    await ref.read(todayControllerProvider.notifier).setClockIn(_value);
    if (mounted) Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    // 시트가 떠 있는 동안 컨트롤러(autoDispose)를 붙잡아 둔다 — 저장 중에 사라지면 안 된다.
    ref.watch(todayControllerProvider);
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final inset = EdgeInsets.symmetric(horizontal: AppSizes.sheetPadding.left);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.sheetRadius)),
        boxShadow: [
          BoxShadow(color: AppColors.sheetShadow, offset: AppSizes.sheetShadowOffset, blurRadius: AppSizes.sheetShadowBlur),
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
          Padding(padding: inset, child: Text(TodayTexts.clockInSheetTitle, style: AppTextStyles.sheetTitle)),
          Padding(
            padding: inset,
            child: Container(
              margin: EdgeInsets.only(top: AppSizes.wheelBoxTop),
              padding: AppSizes.wheelBoxPadding,
              decoration: BoxDecoration(
                color: AppColors.cardInner,
                borderRadius: BorderRadius.circular(AppSizes.wheelBoxRadius),
              ),
              child: TimeWheel(
                hour: widget.initial.hour,
                minute: widget.initial.minute,
                onChanged: (h, m) => setState(
                  () => _value = DateTime(widget.initial.year, widget.initial.month, widget.initial.day, h, m),
                ),
              ),
            ),
          ),
          if (_tooLate)
            Padding(
              padding: inset.copyWith(top: AppSizes.calcTop),
              child: Text(TodayTexts.clockInTooLate, style: AppTextStyles.calcError),
            ),
          SizedBox(height: AppSizes.sheetButtonsTop),
          Padding(
            padding: inset,
            child: SheetButton(label: TodayTexts.save, primary: true, onTap: _tooLate ? null : _save),
          ),
        ],
      ),
    );
  }
}

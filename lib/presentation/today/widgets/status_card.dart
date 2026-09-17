import 'package:flutter/material.dart';

import '../../../domain/model/work_type.dart';
import '../../../domain/rules/work_rules.dart';
import '../../../ui/app_decorations.dart';
import '../../../ui/app_sizes.dart';
import '../today_state.dart';
import '../today_texts.dart';
import '../../shared/quiet_text_button.dart';
import 'primary_button.dart';
import 'soi_checkbox.dart';
import 'status_block.dart';

/// 화면이 컨트롤러에 넘기는 콜백 묶음. TodayView는 프로바이더를 모른다.
class TodayCallbacks {
  const TodayCallbacks({
    required this.onClockIn,
    required this.onClockOut,
    required this.onHalfDayChanged,
    required this.onDayTypeChanged,
    required this.onRevert,
    required this.onEditTime,
    required this.onCancelClockIn,
    required this.onCancelClockOut,
    required this.onUnrecordedTap,
    required this.onDateLongPress,
  });

  final VoidCallback onClockIn;
  final VoidCallback onClockOut;
  final ValueChanged<bool> onHalfDayChanged;
  final ValueChanged<WorkType?> onDayTypeChanged;
  final VoidCallback onRevert;
  final VoidCallback onEditTime;
  final VoidCallback onCancelClockIn;
  final VoidCallback onCancelClockOut;
  final ValueChanged<DateTime> onUnrecordedTap;
  /// 디버그 시드 트리거. 릴리즈에서는 null.
  final VoidCallback? onDateLongPress;
}

/// 상태 블록(104) + 주 버튼(56) + 보조 슬롯. 다섯 상태에서 높이가 같다.
/// 보조 슬롯은 시각적으로는 높이 40·위 간격 10이지만, 텍스트 버튼(시간 수정·되돌리기 등)의
/// 탭 영역을 44(minTapHeight)까지 확보하기 위해 레이아웃 박스 자체를 44로 잡고
/// 위 간격과 카드 하단 패딩을 각각 2씩 줄여 총 높이는 그대로 유지한다.
class StatusCard extends StatelessWidget {
  const StatusCard({super.key, required this.state, required this.rules, required this.callbacks});

  final TodayState state;
  final WorkRules rules;
  final TodayCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSizes.statusCardPadding.copyWith(
        bottom: AppSizes.statusCardPadding.bottom - AppSizes.secondarySlotHitInset,
      ),
      decoration: AppDecorations.card,
      child: Column(
        children: [
          StatusBlock(state: state, rules: rules),
          PrimaryButton(label: TodayTexts.buttonLabel(state), onPressed: _primaryAction),
          SizedBox(height: AppSizes.secondarySlotGap - AppSizes.secondarySlotHitInset),
          // 레이아웃 높이 자체를 44(minTapHeight)로 잡아 히트 영역을 진짜로 확보한다.
          // 위 gap과 아래 카드 패딩에서 각각 인셋만큼 빼서 슬롯의 시각적 중심은 그대로 둔다.
          SizedBox(height: AppSizes.minTapHeight, child: Center(child: _secondary())),
        ],
      ),
    );
  }

  VoidCallback? get _primaryAction => switch (state.screenState) {
        TodayScreenState.beforeWork => callbacks.onClockIn,
        TodayScreenState.working => callbacks.onClockOut,
        TodayScreenState.done || TodayScreenState.dayType => null,
      };

  Widget _secondary() {
    switch (state.screenState) {
      case TodayScreenState.beforeWork:
        if (state.isWeekend) return const SizedBox.shrink();
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SoiCheckbox(
              label: TodayTexts.dayOff,
              checked: false,
              onChanged: (_) => callbacks.onDayTypeChanged(WorkType.dayOff),
              shape: SoiCheckShape.round,
            ),
            SizedBox(width: AppSizes.dayTypeGap),
            SoiCheckbox(
              label: TodayTexts.holiday,
              checked: false,
              onChanged: (_) => callbacks.onDayTypeChanged(WorkType.holiday),
              shape: SoiCheckShape.round,
            ),
          ],
        );
      case TodayScreenState.working:
        final cancel = QuietTextButton(label: TodayTexts.cancelClockIn, onTap: callbacks.onCancelClockIn);
        if (state.isWeekend) return cancel;
        return _pair(
          SoiCheckbox(
            label: TodayTexts.halfDay,
            checked: state.isHalfDay,
            onChanged: callbacks.onHalfDayChanged,
            shape: SoiCheckShape.square,
          ),
          cancel,
        );
      case TodayScreenState.done:
        return _pair(
          QuietTextButton(label: TodayTexts.editTime, onTap: callbacks.onEditTime),
          QuietTextButton(label: TodayTexts.cancelClockOut, onTap: callbacks.onCancelClockOut),
        );
      case TodayScreenState.dayType:
        return QuietTextButton(label: TodayTexts.revert, onTap: callbacks.onRevert);
    }
  }

  Widget _pair(Widget left, Widget right) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          left,
          SizedBox(width: AppSizes.slotItemGap),
          const SlotDivider(),
          SizedBox(width: AppSizes.slotItemGap),
          right,
        ],
      );
}

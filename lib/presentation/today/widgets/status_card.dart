import 'package:flutter/material.dart';

import '../../../domain/model/work_type.dart';
import '../../../ui/app_decorations.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';
import '../today_state.dart';
import '../today_texts.dart';
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
    required this.onUnrecordedTap,
    required this.onDateLongPress,
  });

  final VoidCallback onClockIn;
  final VoidCallback onClockOut;
  final ValueChanged<bool> onHalfDayChanged;
  final ValueChanged<WorkType?> onDayTypeChanged;
  final VoidCallback onRevert;
  final VoidCallback onEditTime;
  final ValueChanged<DateTime> onUnrecordedTap;
  /// 디버그 시드 트리거. 릴리즈에서는 null.
  final VoidCallback? onDateLongPress;
}

/// 상태 블록(104) + 주 버튼(56) + 보조 슬롯(38, 위 12). 다섯 상태에서 높이가 같다.
class StatusCard extends StatelessWidget {
  const StatusCard({super.key, required this.state, required this.callbacks});

  final TodayState state;
  final TodayCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSizes.statusCardPadding,
      decoration: AppDecorations.card,
      child: Column(
        children: [
          StatusBlock(state: state),
          PrimaryButton(label: TodayTexts.buttonLabel(state), onPressed: _primaryAction),
          SizedBox(height: AppSizes.secondarySlotGap),
          SizedBox(
            height: AppSizes.secondarySlot,
            child: OverflowBox(
              // 체크박스 히트 영역(44)이 슬롯(38)보다 커도 레이아웃 높이는 38로 유지한다.
              maxHeight: AppSizes.minTapHeight,
              child: Center(child: _secondary()),
            ),
          ),
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
        if (state.isWeekend) return const SizedBox.shrink();
        return SoiCheckbox(
          label: TodayTexts.halfDay,
          checked: state.isHalfDay,
          onChanged: callbacks.onHalfDayChanged,
          shape: SoiCheckShape.square,
        );
      case TodayScreenState.done:
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: callbacks.onEditTime,
          child: Text(TodayTexts.editTime, style: AppTextStyles.link),
        );
      case TodayScreenState.dayType:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(TodayTexts.revertPrefix, style: AppTextStyles.caption),
            SizedBox(width: AppSizes.linkGap),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: callbacks.onRevert,
              child: Text(TodayTexts.revert, style: AppTextStyles.linkBrand),
            ),
          ],
        );
    }
  }
}

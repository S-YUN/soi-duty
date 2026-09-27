import 'package:flutter/material.dart';

import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';
import '../record_edit_texts.dart';
import 'wheel_column.dart';

/// 시간공제 휠 — 시간(0–[maxHours]) · 분(0–50, [stepMinutes] 단위). [onChanged]는 합친 분을 돌려준다.
/// 한도를 넘는 값은 고를 수 없다 — 시간이 [maxHours]면 분은 00으로 돌아간다 (8시간 50분 같은 값을 막는다).
/// [minutes]가 단위에 안 맞으면(퇴근 시 자동 공제 등) 내림한 위치에서 열리지만, 돌리기 전엔 [onChanged]를 부르지 않는다.
class DurationWheel extends StatefulWidget {
  const DurationWheel({
    super.key,
    required this.minutes,
    required this.maxHours,
    required this.stepMinutes,
    required this.onChanged,
  });

  final int minutes;
  final int maxHours;
  final int stepMinutes;
  final ValueChanged<int> onChanged;

  @override
  State<DurationWheel> createState() => _DurationWheelState();
}

class _DurationWheelState extends State<DurationWheel> {
  late int _hour = (widget.minutes ~/ 60).clamp(0, widget.maxHours);
  late int _step = (widget.minutes % 60) ~/ widget.stepMinutes;
  late final _hourController = FixedExtentScrollController(initialItem: _hour);
  late final _minuteController = FixedExtentScrollController(initialItem: _step);

  int get _stepCount => 60 ~/ widget.stepMinutes;

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  void _select(VoidCallback change) {
    setState(change);
    if (_hour == widget.maxHours && _step != 0) {
      _step = 0;
      // 스크롤 콜백 안에서 바로 옮기면 피커가 꼬인다 — 다음 프레임에 00으로 되돌린다.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_minuteController.hasClients) {
          _minuteController.animateToItem(0, duration: AppDurations.wheelItem, curve: Curves.easeOut);
        }
      });
    }
    widget.onChanged(_hour * 60 + _step * widget.stepMinutes);
  }

  @override
  Widget build(BuildContext context) {
    return WheelFrame(
      child: Row(
        children: [
          Expanded(
            child: WheelColumn(
              labels: [for (var h = 0; h <= widget.maxHours; h++) '$h'],
              selected: _hour,
              controller: _hourController,
              onSelected: (i) => _select(() => _hour = i),
            ),
          ),
          Text(RecordEditTexts.hourUnit, style: AppTextStyles.wheelUnit),
          SizedBox(width: AppSizes.wheelPeriodGap),
          Expanded(
            child: WheelColumn(
              labels: [for (var i = 0; i < _stepCount; i++) (i * widget.stepMinutes).toString().padLeft(2, '0')],
              selected: _step,
              controller: _minuteController,
              onSelected: (i) => _select(() => _step = i),
            ),
          ),
          Text(RecordEditTexts.minuteUnit, style: AppTextStyles.wheelUnit),
        ],
      ),
    );
  }
}

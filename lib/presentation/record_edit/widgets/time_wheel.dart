import 'package:flutter/material.dart';

import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';
import '../record_edit_texts.dart';
import 'wheel_column.dart';

/// 오전/오후 · 시(1–12) · 분(0–59) 휠. 높이 176, 항목 44, 가운데 흰 띠, 위아래 페이드.
/// 입력만 12시간제이고 [onChanged]로는 0–23시를 돌려준다.
class TimeWheel extends StatefulWidget {
  const TimeWheel({super.key, required this.hour, required this.minute, required this.onChanged});

  /// 0–23
  final int hour;
  final int minute;
  final void Function(int hour, int minute) onChanged;

  @override
  State<TimeWheel> createState() => _TimeWheelState();
}

class _TimeWheelState extends State<TimeWheel> {
  static const _periods = [RecordEditTexts.am, RecordEditTexts.pm];

  late int _period = widget.hour < 12 ? 0 : 1; // 0 오전 · 1 오후
  late int _hour12 = _to12(widget.hour); // 1–12
  late int _minute = widget.minute;
  late final _periodController = FixedExtentScrollController(initialItem: _period);
  late final _hourController = FixedExtentScrollController(initialItem: _hour12 - 1);
  late final _minuteController = FixedExtentScrollController(initialItem: widget.minute);

  static int _to12(int hour24) => hour24 % 12 == 0 ? 12 : hour24 % 12;
  int get _hour24 => _hour12 % 12 + _period * 12;

  @override
  void dispose() {
    _periodController.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  void _emit() => widget.onChanged(_hour24, _minute);

  @override
  Widget build(BuildContext context) {
    return WheelFrame(
      child: Row(
        children: [
          Expanded(
            child: WheelColumn(
              labels: _periods,
              selected: _period,
              controller: _periodController,
              onSelected: (i) => _select(() => _period = i),
            ),
          ),
          SizedBox(width: AppSizes.wheelPeriodGap),
          Expanded(
            child: WheelColumn(
              labels: [for (var h = 1; h <= 12; h++) '$h'],
              selected: _hour12 - 1,
              controller: _hourController,
              onSelected: (i) => _select(() => _hour12 = i + 1),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.wheelColonPadding),
            child: Text(':', style: AppTextStyles.wheelColon),
          ),
          Expanded(
            child: WheelColumn(
              labels: [for (var m = 0; m < 60; m++) m.toString().padLeft(2, '0')],
              selected: _minute,
              controller: _minuteController,
              onSelected: (i) => _select(() => _minute = i),
            ),
          ),
        ],
      ),
    );
  }

  void _select(VoidCallback change) {
    setState(change);
    _emit();
  }
}

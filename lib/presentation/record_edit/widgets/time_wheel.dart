import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../ui/app_colors.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';

/// 시(0–23) · 분(0–59) 휠. 높이 176, 항목 44, 가운데 흰 띠, 위아래 페이드.
class TimeWheel extends StatefulWidget {
  const TimeWheel({super.key, required this.hour, required this.minute, required this.onChanged});

  final int hour;
  final int minute;
  final void Function(int hour, int minute) onChanged;

  @override
  State<TimeWheel> createState() => _TimeWheelState();
}

class _TimeWheelState extends State<TimeWheel> {
  late int _hour = widget.hour;
  late int _minute = widget.minute;
  late final _hourController = FixedExtentScrollController(initialItem: widget.hour);
  late final _minuteController = FixedExtentScrollController(initialItem: widget.minute);

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.wheelHeight,
      child: Stack(
        children: [
          Center(
            child: Container(
              height: AppSizes.wheelItem,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppSizes.wheelBandRadius),
              ),
            ),
          ),
          ShaderMask(
            shaderCallback: (rect) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black, Colors.black, Colors.transparent],
              stops: [0, 0.32, 0.68, 1],
            ).createShader(rect),
            blendMode: BlendMode.dstIn,
            child: Row(
              children: [
                Expanded(child: _column(24, _hour, _hourController, (v) => _hour = v)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSizes.wheelColonPadding),
                  child: Text(':', style: AppTextStyles.wheelColon),
                ),
                Expanded(child: _column(60, _minute, _minuteController, (v) => _minute = v)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _column(int count, int selected, FixedExtentScrollController controller, ValueChanged<int> assign) {
    return CupertinoPicker(
      scrollController: controller,
      itemExtent: AppSizes.wheelItem,
      useMagnifier: false,
      squeeze: 1,
      diameterRatio: 100,
      selectionOverlay: const SizedBox.shrink(),
      onSelectedItemChanged: (i) {
        setState(() => assign(i));
        widget.onChanged(_hour, _minute);
      },
      children: [
        for (var i = 0; i < count; i++)
          Center(
            child: AnimatedDefaultTextStyle(
              duration: AppDurations.wheelItem,
              style: i == selected ? AppTextStyles.wheelSelected : AppTextStyles.wheelItem,
              child: Text(i.toString().padLeft(2, '0')),
            ),
          ),
      ],
    );
  }
}

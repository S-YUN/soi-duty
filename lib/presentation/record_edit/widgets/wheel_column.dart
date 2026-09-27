import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../ui/app_colors.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';

/// 휠 공용 틀 — 높이 176, 가운데 흰 띠, 위아래 페이드. 시각 휠·시간공제 휠이 같이 쓴다.
/// 휠을 돌리기 시작하면 키보드(사유 입력)를 내린다.
class WheelFrame extends StatelessWidget {
  const WheelFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollStartNotification>(
      onNotification: (_) {
        FocusManager.instance.primaryFocus?.unfocus();
        return false;
      },
      child: SizedBox(
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
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

/// 휠 한 열. 선택된 항목만 진하게.
class WheelColumn extends StatelessWidget {
  const WheelColumn({
    super.key,
    required this.labels,
    required this.selected,
    required this.controller,
    required this.onSelected,
  });

  final List<String> labels;
  final int selected;
  final FixedExtentScrollController controller;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return CupertinoPicker(
      scrollController: controller,
      itemExtent: AppSizes.wheelItem,
      useMagnifier: false,
      squeeze: 1,
      diameterRatio: 100,
      selectionOverlay: const SizedBox.shrink(),
      onSelectedItemChanged: onSelected,
      children: [
        for (var i = 0; i < labels.length; i++)
          Center(
            child: AnimatedDefaultTextStyle(
              duration: AppDurations.wheelItem,
              style: i == selected ? AppTextStyles.wheelSelected : AppTextStyles.wheelItem,
              child: Text(labels[i]),
            ),
          ),
      ],
    );
  }
}

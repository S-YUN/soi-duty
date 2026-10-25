import 'package:flutter/material.dart';

import '../../../ui/app_colors.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';

/// 두 칸 세그먼트(월 | 일). 탭 알약과 같은 컨테이너. 선택 배경(브랜드색 알약)이 **토글처럼 미끄러져** 옮겨간다 —
/// 칸마다 색만 바뀌니 토글 느낌이 안 난다는 실기기 피드백 (2026-10-25). 칸 폭은 가장 넓은 라벨 기준으로 모두 같다.
class SegmentToggle<T> extends StatelessWidget {
  const SegmentToggle({super.key, required this.options, required this.value, required this.onChanged});

  final List<(T, String)> options;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final count = options.length;
    final index = options.indexWhere((o) => o.$1 == value).clamp(0, count - 1);
    // 칸 i의 가운데에 배경을 놓는 정렬값: 첫 칸 -1, 마지막 칸 +1.
    final alignX = count == 1 ? 0.0 : -1 + 2 * index / (count - 1);
    return Container(
      padding: EdgeInsets.all(AppSizes.segmentPadding),
      decoration: BoxDecoration(color: AppColors.tabContainer, borderRadius: BorderRadius.circular(AppSizes.pill)),
      child: IntrinsicWidth(
        child: IntrinsicHeight(
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedAlign(
                  duration: AppDurations.buttonColor,
                  curve: Curves.easeOut,
                  alignment: Alignment(alignX, 0),
                  child: FractionallySizedBox(
                    widthFactor: 1 / count,
                    heightFactor: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: AppColors.brand, borderRadius: BorderRadius.circular(AppSizes.pill)),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < count; i++)
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onChanged(options[i].$1),
                        child: Padding(
                          padding: AppSizes.segmentItemPadding,
                          child: AnimatedDefaultTextStyle(
                            duration: AppDurations.buttonColor,
                            style: i == index ? AppTextStyles.segmentOn : AppTextStyles.segmentOff,
                            textAlign: TextAlign.center,
                            child: Text(options[i].$2),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

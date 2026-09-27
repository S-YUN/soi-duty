import 'package:flutter/material.dart';

import '../../../ui/app_colors.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';

/// 출근/퇴근/시간공제 행. 행 전체가 탭 영역. 선택되면 값만 brand w600 — 배경은 칠하지 않는다
/// (바로 아래 휠 박스와 같은 회색이 겹쳐 여러 개가 눌린 것처럼 보였다, 2026-09-27). 아래에 1px 구분선.
class TimeRow extends StatelessWidget {
  const TimeRow({super.key, required this.label, required this.value, required this.selected, required this.onTap});

  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: AppSizes.timeRowPadding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: AppTextStyles.timeLabel),
                Text(value, style: AppTextStyles.timeValue(selected: selected)),
              ],
            ),
          ),
          Container(height: AppSizes.rowDivider, color: AppColors.rowDivider),
        ],
      ),
    );
  }
}

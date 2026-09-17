import 'package:flutter/material.dart';

import '../../../domain/model/work_type.dart';
import '../../../ui/app_colors.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';
import '../record_edit_texts.dart';

/// 미래 날짜 시트의 유형 목록 — 색 점 · 라벨 · 체크가 있는 전체 너비 행 3개. 상호배타, 같은 행 재탭이면 null.
class TypeRows extends StatelessWidget {
  const TypeRows({super.key, required this.selected, required this.onChanged});

  final WorkType selected;
  final ValueChanged<WorkType?> onChanged;

  static const _types = [WorkType.halfDay, WorkType.dayOff, WorkType.holiday];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < _types.length; i++) ...[
          if (i > 0) SizedBox(height: AppSizes.typeRowGap),
          _Row(
            type: _types[i],
            selected: selected == _types[i],
            onTap: () => onChanged(selected == _types[i] ? null : _types[i]),
          ),
        ],
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.type, required this.selected, required this.onTap});

  final WorkType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.checkbox,
        height: AppSizes.typeRow,
        padding: AppSizes.typeRowPadding,
        decoration: BoxDecoration(
          color: selected ? AppColors.typeRowSelected : AppColors.cardInner,
          borderRadius: BorderRadius.circular(AppSizes.typeRowRadius),
        ),
        child: Row(
          children: [
            Container(
              width: AppSizes.typeRowDot,
              height: AppSizes.typeRowDot,
              decoration: BoxDecoration(color: AppColors.typeColors(type).$1, shape: BoxShape.circle),
            ),
            SizedBox(width: AppSizes.typeRowDotGap),
            Expanded(child: Text(RecordEditTexts.chipLabel(type), style: AppTextStyles.typeRowLabel)),
            // 자리를 유지한 채 켜고 끈다 — 라벨이 움직이지 않도록.
            AnimatedOpacity(
              duration: AppDurations.checkbox,
              opacity: selected ? 1 : 0,
              child: Icon(Icons.check_rounded, size: AppSizes.typeRowCheck, color: AppColors.brand),
            ),
          ],
        ),
      ),
    );
  }
}

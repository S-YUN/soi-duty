import 'package:flutter/material.dart';

import '../../../domain/model/work_type.dart';
import '../../../ui/app_colors.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';
import '../record_edit_texts.dart';

/// 미래 날짜 시트의 유형 목록 — 색 점 · 라벨 · 체크가 있는 전체 너비 행 4개. 반차·연차·공휴일은 상호배타, 같은 행 재탭이면 null.
/// 출장 행은 누르면 "종일 / 시간" 패널이 열리고([onTripTap]), 시간 출장이 있으면 라벨 옆에 범위를 보인다.
class TypeRows extends StatelessWidget {
  const TypeRows({
    super.key,
    required this.selected,
    required this.tripSelected,
    required this.tripRange,
    required this.onChanged,
    required this.onTripTap,
  });

  final WorkType selected;
  final bool tripSelected;

  /// 시간 출장 범위 "09:00–12:00". 없으면(종일 출장 포함) null.
  final String? tripRange;
  final ValueChanged<WorkType?> onChanged;
  final VoidCallback onTripTap;

  static const _types = [WorkType.halfDay, WorkType.dayOff, WorkType.holiday, WorkType.businessTrip];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < _types.length; i++) ...[
          if (i > 0) SizedBox(height: AppSizes.typeRowGap),
          _Row(
            type: _types[i],
            selected: _types[i] == WorkType.businessTrip ? tripSelected : selected == _types[i],
            trailingText: _types[i] == WorkType.businessTrip ? tripRange : null,
            onTap: _types[i] == WorkType.businessTrip
                ? onTripTap
                : () => onChanged(selected == _types[i] ? null : _types[i]),
          ),
        ],
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.type, required this.selected, required this.onTap, this.trailingText});

  final WorkType type;
  final bool selected;
  final VoidCallback onTap;

  /// 라벨 옆 작은 글씨 — 출장 행의 범위
  final String? trailingText;

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
            Text(RecordEditTexts.chipLabel(type), style: AppTextStyles.typeRowLabel),
            if (trailingText != null) ...[
              SizedBox(width: AppSizes.typeRowRangeGap),
              Text(trailingText!, style: AppTextStyles.typeRowRange, maxLines: 1, softWrap: false),
            ],
            const Spacer(),
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

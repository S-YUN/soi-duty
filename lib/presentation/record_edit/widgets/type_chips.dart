import 'package:flutter/material.dart';

import '../../../domain/model/work_type.dart';
import '../../../ui/app_colors.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';
import '../record_edit_texts.dart';

/// 반차 / 연차 / 공휴일 / 출장 4열. 반차·연차·공휴일은 상호배타, 같은 칩 재탭이면 null.
/// 출장 칩은 유형을 바로 바꾸지 않는다 — 누르면 "종일 / 시간" 패널이 열린다([onTripTap]).
/// 시간 출장은 유형이 아니라 그날에 붙는 범위라 반차·공휴일과 함께 칠해질 수 있다([tripSelected]).
class TypeChips extends StatelessWidget {
  const TypeChips({
    super.key,
    required this.selected,
    required this.tripSelected,
    required this.onChanged,
    required this.onTripTap,
  });

  final WorkType selected;

  /// 종일 출장이거나 시간 출장 범위가 있음
  final bool tripSelected;
  final ValueChanged<WorkType?> onChanged;
  final VoidCallback onTripTap;

  static const _types = [WorkType.halfDay, WorkType.dayOff, WorkType.holiday, WorkType.businessTrip];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < _types.length; i++) ...[
          if (i > 0) SizedBox(width: AppSizes.chipGap),
          Expanded(
            child: _Chip(
              type: _types[i],
              selected: _types[i] == WorkType.businessTrip ? tripSelected : selected == _types[i],
              onTap: _types[i] == WorkType.businessTrip
                  ? onTripTap
                  : () => onChanged(selected == _types[i] ? null : _types[i]),
            ),
          ),
        ],
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.type, required this.selected, required this.onTap});

  final WorkType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = AppColors.typeColors(type);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: AppSizes.minTapHeight),
        child: Center(
          child: AnimatedContainer(
            duration: AppDurations.checkbox,
            width: double.infinity,
            padding: AppSizes.chipPadding,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? bg : AppColors.chipNeutral,
              borderRadius: BorderRadius.circular(AppSizes.chipRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selected) ...[
                  Icon(Icons.check_rounded, size: AppSizes.chipCheck, color: fg),
                  SizedBox(width: AppSizes.chipCheckGap),
                ],
                Text(
                  RecordEditTexts.chipLabel(type),
                  style: AppTextStyles.chip(selected: selected, selectedColor: fg),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../domain/model/work_type.dart';
import '../../../ui/app_colors.dart';
import '../../../ui/app_decorations.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';
import '../../shared/type_tag.dart';
import '../month_state.dart';
import '../month_texts.dart';

/// 카드 A — 캘린더. 월요일 시작 7열, 셀 높이 58 위 정렬.
class CalendarCard extends StatelessWidget {
  const CalendarCard({super.key, required this.state, required this.onCellTap});

  final MonthState state;
  final ValueChanged<DateTime> onCellTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSizes.calendarPadding,
      decoration: AppDecorations.card,
      child: Column(
        children: [
          Padding(
            padding: AppSizes.calendarHeaderPadding,
            child: Row(
              children: [
                for (final w in MonthTexts.weekdays)
                  Expanded(child: Text(w, style: AppTextStyles.calendarHeader, textAlign: TextAlign.center)),
              ],
            ),
          ),
          Padding(
            padding: AppSizes.calendarGridPadding,
            child: Column(
              children: [
                for (var r = 0; r < state.weeks.length; r++) ...[
                  if (r > 0) SizedBox(height: AppSizes.calendarRowGap),
                  Row(
                    children: [
                      for (var c = 0; c < 7; c++) ...[
                        if (c > 0) SizedBox(width: AppSizes.calendarColGap),
                        Expanded(
                          child: _Cell(cell: state.weeks[r][c], onTap: () => onCellTap(state.weeks[r][c].date)),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Cell extends StatefulWidget {
  const _Cell({required this.cell, required this.onTap});

  final MonthCell cell;
  final VoidCallback onTap;

  @override
  State<_Cell> createState() => _CellState();
}

class _CellState extends State<_Cell> {
  var _pressed = false;

  Widget _badge(WorkType type) => Padding(
        padding: EdgeInsets.only(top: AppSizes.calendarCellGap),
        child: TypeTag(
          type: type,
          label: MonthTexts.badge(type),
          padding: AppSizes.calendarBadgePadding,
          radius: AppSizes.calendarBadgeRadius,
          style: AppTextStyles.calendarBadge,
        ),
      );

  Widget _value(String text, TextStyle style) => Padding(
        padding: EdgeInsets.only(top: AppSizes.calendarCellGap),
        child: Text(text, style: style, maxLines: 1, overflow: TextOverflow.clip, softWrap: false),
      );

  @override
  Widget build(BuildContext context) {
    final cell = widget.cell;
    final dim = !cell.isCurrentMonth || cell.isWeekend || cell.isFuture || cell.isBeforeFirstWeek;
    final enabled = !cell.isBeforeFirstWeek;
    final text = MonthTexts.value(cell.value);
    final valueStyle = switch (cell.value) {
      MonthCellDelta(:final minutes) => AppTextStyles.calendarValue(
          minutes > 0
              ? AppColors.brand
              : minutes < 0
                  ? AppColors.minus
                  : AppColors.ink,
        ),
      MonthCellWeekendActual() => AppTextStyles.calendarWeekendValue,
      MonthCellNone() || MonthCellWorking() || MonthCellUnrecorded() => AppTextStyles.calendarValue(AppColors.faint),
    };

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      onTap: enabled ? widget.onTap : null,
      child: AnimatedOpacity(
        duration: AppDurations.pressedOpacity,
        opacity: _pressed ? AppOpacities.cellPressed : 1,
        child: Container(
          height: AppSizes.calendarCell,
          padding: EdgeInsets.only(top: AppSizes.calendarCellTop),
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: cell.hasBackground ? AppColors.cardInner : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.calendarCellRadius),
          ),
          // 세로 중앙 정렬 금지 — 값이 없는 날의 숫자가 내려와 같은 행과 어긋난다. 위 고정.
          // 반차는 값이 일반 날과 같은 자리에 오고 배지가 그 아래. 연차·공휴일은 값이 없어 배지가 바로 온다.
          child: Column(
            children: [
              Text('${cell.date.day}', style: AppTextStyles.calendarNum(dim: dim)),
              if (cell.type == WorkType.halfDay) ...[
                if (text.isNotEmpty) _value(text, valueStyle),
                _badge(cell.type!),
              ] else ...[
                if (cell.type != null) _badge(cell.type!),
                if (text.isNotEmpty) _value(text, valueStyle),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

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
          Text(MonthTexts.calendarTitle, style: AppTextStyles.calendarTitle),
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

  @override
  Widget build(BuildContext context) {
    final cell = widget.cell;
    final dim = !cell.isCurrentMonth || cell.isWeekend || cell.isFuture;
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
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
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
          child: Column(
            children: [
              Text('${cell.date.day}', style: AppTextStyles.calendarNum(dim: dim)),
              if (cell.type != null) ...[
                SizedBox(height: AppSizes.calendarCellGap),
                TypeTag(
                  type: cell.type!,
                  label: MonthTexts.badge(cell.type!),
                  padding: AppSizes.calendarBadgePadding,
                  radius: AppSizes.calendarBadgeRadius,
                  style: AppTextStyles.calendarBadge,
                ),
              ],
              if (text.isNotEmpty) ...[
                SizedBox(height: AppSizes.calendarCellGap),
                Text(text, style: valueStyle, maxLines: 1, overflow: TextOverflow.clip, softWrap: false),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

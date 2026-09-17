import 'package:flutter/material.dart';

import '../../../ui/app_colors.dart';
import '../../../ui/app_decorations.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';
import '../month_state.dart';
import '../month_texts.dart';

/// 카드 A — 캘린더. 월요일 시작 7열. 날짜 숫자 뒤 원 색이 곧 유형(범례와 같은 색). 오늘 표시는 따로 없다.
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
                for (var i = 0; i < MonthTexts.weekdays.length; i++)
                  Expanded(
                    child: Text(
                      MonthTexts.weekdays[i],
                      style: i >= DateTime.saturday - 1 ? AppTextStyles.calendarHeaderWeekend : AppTextStyles.calendarHeader,
                      textAlign: TextAlign.center,
                    ),
                  ),
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

  /// 원 색. 유형이 있으면 그 색, 일반 근무일(주말 포함)은 하나로, 나머지는 없음.
  Color? _circleColor(MonthCell cell) {
    if (cell.type != null) return AppColors.typeColors(cell.type!).$1;
    return switch (cell.value) {
      MonthCellDelta() || MonthCellWeekendActual() || MonthCellWorking() => AppColors.calendarWorked,
      MonthCellNone() || MonthCellUnrecorded() => null,
    };
  }

  /// 숫자 색. 원 위에서는 유형 글자색/잉크, 아니면 평일 subtle · 주말 적갈색. 미래도 같은 색 — 원 유무로 충분히 구분된다.
  /// (다른 달·설치 전은 셀 전체 투명도로 흐려진다.)
  Color _numColor(MonthCell cell, {required bool onCircle}) {
    if (onCircle && cell.type != null) return AppColors.typeColors(cell.type!).$2;
    if (onCircle) return AppColors.ink;
    return cell.isWeekend ? AppColors.calendarWeekendNum : AppColors.subtle;
  }

  @override
  Widget build(BuildContext context) {
    final cell = widget.cell;
    final enabled = !cell.isBeforeFirstWeek;
    final faded = !cell.isCurrentMonth || cell.isBeforeFirstWeek;
    final circle = _circleColor(cell);
    final onCircle = circle != null;
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
        opacity: _pressed
            ? AppOpacities.cellPressed
            : faded
                ? AppOpacities.calendarOtherMonth
                : 1,
        child: SizedBox(
          height: AppSizes.calendarCell,
          // 세로 중앙 정렬 금지 — 값이 없는 날의 원이 내려와 같은 행과 어긋난다. 위 고정.
          child: Column(
            children: [
              SizedBox(height: AppSizes.calendarCellTop),
              Container(
                width: AppSizes.calendarCircle,
                height: AppSizes.calendarCircle,
                alignment: Alignment.center,
                decoration: BoxDecoration(shape: BoxShape.circle, color: circle),
                child: Text(
                  '${cell.date.day}',
                  style: AppTextStyles.calendarNum(_numColor(cell, onCircle: onCircle), onCircle: onCircle),
                ),
              ),
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

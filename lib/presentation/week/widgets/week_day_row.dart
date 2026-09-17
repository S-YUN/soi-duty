import 'package:flutter/material.dart';

import '../../../ui/app_colors.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';
import '../../shared/type_tag.dart';
import '../week_state.dart';
import '../week_texts.dart';

/// 일별 행. 날짜 폭 30 가운데 · 내용 Expanded · 값 폭 58 우측. 보조 min-height 16으로 7행 높이가 같다.
class WeekDayRow extends StatefulWidget {
  const WeekDayRow({super.key, required this.day, required this.onTap});

  final WeekDay day;
  final VoidCallback onTap;

  @override
  State<WeekDayRow> createState() => _WeekDayRowState();
}

class _WeekDayRowState extends State<WeekDayRow> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    final day = widget.day;
    final weekend = day.date.weekday >= DateTime.saturday;
    final badge = WeekTexts.badge(day);
    final main = WeekTexts.main(day);
    final delta = day.deltaMinutes;

    final mainStyle = switch (day.kind) {
      WeekDayKind.weekendEmpty || WeekDayKind.future => AppTextStyles.rowMainNone,
      WeekDayKind.unrecorded ||
      WeekDayKind.partial ||
      WeekDayKind.beforeWork ||
      WeekDayKind.off =>
        AppTextStyles.rowMainDim,
      WeekDayKind.recorded || WeekDayKind.working || WeekDayKind.weekendRecorded => AppTextStyles.rowMain,
    };
    final valueColor = delta == null
        ? AppColors.subtle
        : delta > 0
            ? AppColors.brand
            : delta < 0
                ? AppColors.minus
                : AppColors.subtle;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: AppDurations.checkbox,
        padding: AppSizes.rowPadding,
        color: _pressed
            ? AppColors.listRow
            : day.isToday
                ? AppColors.todayRow
                : Colors.transparent,
        child: Row(
          children: [
            SizedBox(
              width: AppSizes.rowDateWidth,
              child: Column(
                children: [
                  Text('${day.date.day}', style: weekend ? AppTextStyles.rowNumWeekend : AppTextStyles.rowNum),
                  SizedBox(height: AppSizes.rowDowTop),
                  Text(WeekTexts.dow(day.date), style: weekend ? AppTextStyles.rowDowWeekend : AppTextStyles.rowDow),
                ],
              ),
            ),
            SizedBox(width: AppSizes.rowGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // 비어 있어도 그려서 줄 높이를 유지한다 — 배지만 있는 연차·공휴일 행이 낮아지지 않게.
                      Text(main, style: mainStyle, maxLines: 1),
                      if (badge != null) ...[
                        if (main.isNotEmpty) SizedBox(width: AppSizes.rowBadgeGap),
                        TypeTag(
                          type: badge,
                          label: WeekTexts.badgeLabel(badge),
                          padding: AppSizes.rowBadgePadding,
                          radius: AppSizes.rowBadgeRadius,
                          style: AppTextStyles.rowBadge,
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: AppSizes.rowNoteTop),
                  ConstrainedBox(
                    constraints: BoxConstraints(minHeight: AppSizes.rowNoteMinHeight),
                    child: Text(WeekTexts.note(day), style: AppTextStyles.rowNote, maxLines: 1),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSizes.rowGap),
            SizedBox(
              width: AppSizes.rowValueWidth,
              child: Text(
                WeekTexts.value(day),
                style: AppTextStyles.rowValue(valueColor),
                textAlign: TextAlign.right,
                maxLines: 1,
                softWrap: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

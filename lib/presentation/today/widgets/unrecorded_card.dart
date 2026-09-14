import 'package:flutter/material.dart';

import '../../../core/presentation/format/date_format.dart';
import '../../../ui/app_colors.dart';
import '../../../ui/app_decorations.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';
import '../today_texts.dart';

/// 기록 안 된 날 리스트. 0개면 호출부가 아예 그리지 않는다.
class UnrecordedCard extends StatelessWidget {
  const UnrecordedCard({super.key, required this.days, required this.onTap});

  final List<DateTime> days;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSizes.unrecordedCardPadding,
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: AppSizes.unrecordedTitlePadding,
            child: Text(TodayTexts.unrecordedTitle(days.length), style: AppTextStyles.captionMedium),
          ),
          for (var i = 0; i < days.length; i++) ...[
            if (i > 0) SizedBox(height: AppSizes.unrecordedRowGap),
            _Row(day: days[i], onTap: () => onTap(days[i])),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatefulWidget {
  const _Row({required this.day, required this.onTap});

  final DateTime day;
  final VoidCallback onTap;

  @override
  State<_Row> createState() => _RowState();
}

class _RowState extends State<_Row> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: AppDurations.checkbox,
        padding: AppSizes.unrecordedRowPadding,
        decoration: BoxDecoration(
          color: _pressed ? AppColors.listRowPressed : AppColors.listRow,
          borderRadius: BorderRadius.circular(AppSizes.unrecordedRowRadius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(formatDateShort(widget.day), style: AppTextStyles.bodyInk),
            Text(TodayTexts.record, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

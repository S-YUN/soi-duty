import 'package:flutter/material.dart';

import '../../../ui/app_colors.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';
import '../today_texts.dart';

enum TodayTripChoice { fullDay, timed }

/// 출근 전 "출장" 라디오를 누르면 뜨는 작은 시트 — 종일 출장(출근 없이 8h 인정)인지,
/// 시간 출장(출퇴근은 그대로 찍고 범위만 남김)인지 고른다 (핸드오프 6 §4). 바깥 탭·내리기면 null.
/// [tripRange]: 이미 넣어둔 시간 출장 범위 "09:00–12:00".
Future<TodayTripChoice?> showTodayTripSheet(BuildContext context, {required String? tripRange}) {
  return showModalBottomSheet<TodayTripChoice>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.scrim,
    sheetAnimationStyle: AnimationStyle(duration: AppDurations.sheetSlide, curve: AppCurves.sheet),
    builder: (_) => TodayTripSheet(tripRange: tripRange),
  );
}

class TodayTripSheet extends StatelessWidget {
  const TodayTripSheet({super.key, required this.tripRange});

  final String? tripRange;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.sheetRadius)),
        boxShadow: [
          BoxShadow(color: AppColors.sheetShadow, offset: AppSizes.sheetShadowOffset, blurRadius: AppSizes.sheetShadowBlur),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        AppSizes.sheetPadding.left,
        AppSizes.sheetPadding.top,
        AppSizes.sheetPadding.right,
        AppSizes.sheetPadding.bottom + bottomInset,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: AppSizes.sheetHandleWidth,
              height: AppSizes.sheetHandleHeight,
              margin: EdgeInsets.only(bottom: AppSizes.sheetHandleBottom),
              decoration: BoxDecoration(color: AppColors.hairline, borderRadius: BorderRadius.circular(AppSizes.pill)),
            ),
          ),
          Text(TodayTexts.todayTripTitle, style: AppTextStyles.sheetTitle),
          SizedBox(height: AppSizes.typeRowsTop),
          _Row(
            title: TodayTexts.todayTripFullDay,
            sub: TodayTexts.todayTripFullDaySub,
            trailing: null,
            selected: false,
            onTap: () => Navigator.of(context).pop(TodayTripChoice.fullDay),
          ),
          SizedBox(height: AppSizes.typeRowGap),
          _Row(
            title: TodayTexts.todayTripTimed,
            sub: TodayTexts.todayTripTimedSub,
            trailing: tripRange,
            selected: tripRange != null,
            onTap: () => Navigator.of(context).pop(TodayTripChoice.timed),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.title,
    required this.sub,
    required this.trailing,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String sub;

  /// 오른쪽 범위. 없으면 비움.
  final String? trailing;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          constraints: BoxConstraints(minHeight: AppSizes.todayTripRowMinHeight),
          padding: AppSizes.todayTripRowPadding,
          decoration: BoxDecoration(
            color: selected ? AppColors.typeRowSelected : AppColors.cardInner,
            borderRadius: BorderRadius.circular(AppSizes.typeRowRadius),
          ),
          child: Row(
            children: [
              Container(
                width: AppSizes.typeRowDot,
                height: AppSizes.typeRowDot,
                decoration: const BoxDecoration(color: AppColors.tripBackground, shape: BoxShape.circle),
              ),
              SizedBox(width: AppSizes.typeRowDotGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title, style: AppTextStyles.typeRowLabel),
                    SizedBox(height: AppSizes.todayTripRowSubTop),
                    Text(sub, style: AppTextStyles.sheetSubtitle),
                  ],
                ),
              ),
              if (trailing != null) ...[
                SizedBox(width: AppSizes.typeRowRangeGap),
                Text(trailing!, style: AppTextStyles.todayTripRange, maxLines: 1, softWrap: false),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

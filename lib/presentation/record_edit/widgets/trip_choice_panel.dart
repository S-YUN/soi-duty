import 'package:flutter/material.dart';

import '../../../ui/app_colors.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';
import '../record_edit_texts.dart';

/// 출장 칩(행)을 누르면 그 아래에 열리는 "종일 출장 / 시간 출장" 선택 (핸드오프 6 §2).
/// 종일 = 쉬는 날 유형(8h 인정), 시간 = 근무일에 붙는 기록용 범위 — 둘은 한 날에 같이 있을 수 없다.
class TripChoicePanel extends StatelessWidget {
  const TripChoicePanel({
    super.key,
    required this.fullDaySelected,
    required this.timedSelected,
    required this.fullDayEnabled,
    required this.timedRange,
    required this.onFullDay,
    required this.onTimed,
    required this.onRemove,
  });

  final bool fullDaySelected;
  final bool timedSelected;

  /// 반차인 날은 종일 출장을 고를 수 없다 — 반차 + 종일 출장은 없다.
  final bool fullDayEnabled;

  /// 넣어둔 범위 "09:20–12:30". 없으면 null — 보조 줄이 "시간 직접 입력".
  final String? timedRange;
  final VoidCallback onFullDay;
  final VoidCallback onTimed;

  /// 출장(종일이든 시간이든)이 있을 때만 — "출장 빼기".
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: AppSizes.tripPanelTop),
      padding: EdgeInsets.all(AppSizes.tripPanelPadding),
      decoration: BoxDecoration(
        color: AppColors.cardInner,
        borderRadius: BorderRadius.circular(AppSizes.tripPanelRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(RecordEditTexts.tripPanelNote, style: AppTextStyles.sheetSubtitle),
          SizedBox(height: AppSizes.tripPanelNoteBottom),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _Choice(
                    title: RecordEditTexts.tripFullDay,
                    sub: fullDayEnabled ? RecordEditTexts.tripFullDaySub : RecordEditTexts.tripFullDayHalfDay,
                    selected: fullDaySelected,
                    enabled: fullDayEnabled,
                    onTap: onFullDay,
                  ),
                ),
                SizedBox(width: AppSizes.tripPanelButtonGap),
                Expanded(
                  child: _Choice(
                    title: RecordEditTexts.tripTimed,
                    sub: timedRange ?? RecordEditTexts.tripTimedSub,
                    selected: timedSelected,
                    enabled: true,
                    onTap: onTimed,
                  ),
                ),
              ],
            ),
          ),
          if (onRemove != null)
            Center(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onRemove,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: AppSizes.minTapHeight),
                  child: Padding(
                    padding: AppSizes.clearLinkPadding,
                    child: Center(
                      widthFactor: 1,
                      child: Text(RecordEditTexts.tripRemove, style: AppTextStyles.deleteLink),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.title,
    required this.sub,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String title;
  final String sub;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
        child: Container(
          constraints: BoxConstraints(minHeight: AppSizes.tripPanelButtonMinHeight),
          padding: AppSizes.tripPanelButtonPadding,
          // 테두리는 안쪽에 그린다 — 고른 쪽과 안 고른 쪽의 크기가 같게.
          foregroundDecoration: selected
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizes.tripPanelButtonRadius),
                  border: Border.all(color: AppColors.brand, width: AppSizes.tripPanelBorder),
                )
              : null,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppSizes.tripPanelButtonRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                selected ? '$title${RecordEditTexts.tripSelectedMark}' : title,
                style: AppTextStyles.tripPanelTitle(selected: selected, enabled: enabled),
                maxLines: 1,
                softWrap: false,
              ),
              SizedBox(height: AppSizes.tripPanelSubTop),
              // 보조는 한 줄 고정 — 폭 320에서 꺾이지 않게 넘치면 살짝 줄인다.
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(sub, style: AppTextStyles.tripPanelSub, maxLines: 1, softWrap: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

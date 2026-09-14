import 'package:flutter/material.dart';

import '../../core/presentation/format/date_format.dart';
import '../../domain/rules/work_rules.dart';
import '../../ui/app_colors.dart';
import '../../ui/app_sizes.dart';
import '../../ui/app_text_styles.dart';
import 'today_state.dart';
import 'today_texts.dart';
import 'widgets/first_week_card.dart';
import 'widgets/hero_card.dart';
import 'widgets/pill_tabs.dart';
import 'widgets/status_card.dart';
import 'widgets/unrecorded_card.dart';

export 'widgets/status_card.dart' show TodayCallbacks;

/// 오늘 화면의 순수 UI. 상태와 콜백만 받고 프로바이더를 모른다.
class TodayView extends StatelessWidget {
  const TodayView({super.key, required this.state, required this.rules, required this.callbacks});

  final TodayState state;
  final WorkRules rules;
  final TodayCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(AppSizes.screenHPadding, AppSizes.topInset, AppSizes.screenHPadding, 0),
              child: PillTabs(labels: TodayTexts.tabs, selectedIndex: 0),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onLongPress: callbacks.onDateLongPress,
              child: Padding(
                padding: AppSizes.datePadding,
                child: Text(formatDateTitle(state.date), style: AppTextStyles.dateTitle, textAlign: TextAlign.center),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: AppSizes.bodyPadding.copyWith(bottom: AppSizes.bodyPadding.bottom + bottomInset),
                child: Column(
                  children: [
                    HeroCard(state: state, rules: rules),
                    SizedBox(height: AppSizes.cardGap),
                    StatusCard(state: state, callbacks: callbacks),
                    if (state.isFirstWeek) ...[
                      SizedBox(height: AppSizes.cardGap),
                      const FirstWeekCard(),
                    ],
                    if (state.unrecordedDays.isNotEmpty) ...[
                      SizedBox(height: AppSizes.cardGap),
                      UnrecordedCard(days: state.unrecordedDays, onTap: callbacks.onUnrecordedTap),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

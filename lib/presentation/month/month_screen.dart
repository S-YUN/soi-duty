import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/clock_provider.dart';
import '../../core/providers/database_providers.dart';
import '../../domain/rules/navigation_bounds.dart';
import '../../ui/app_colors.dart';
import '../../ui/app_sizes.dart';
import '../../ui/app_text_styles.dart';
import '../../domain/model/app_settings.dart';
import '../record_edit/record_edit_sheet.dart';
import '../settings/settings_controller.dart';
import '../settings/settings_texts.dart';
import '../shared/app_toast.dart';
import '../shared/number_input_sheet.dart';
import '../shared/period_navigator.dart';
import 'month_provider.dart';
import 'month_state.dart';
import 'month_texts.dart';
import 'selected_month.dart';
import 'widgets/calendar_card.dart';
import 'widgets/extra_work_card.dart';
import 'widgets/leave_card.dart';
import 'widgets/legend.dart';

class MonthScreen extends ConsumerWidget {
  const MonthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(monthStateProvider);
    final notifier = ref.watch(selectedMonthProvider.notifier);
    final first = ref.watch(firstRecordDateProvider).value;
    final today = ref.watch(clockProvider)();
    final settings = ref.watch(appSettingsProvider).value ?? const AppSettings();
    ref.watch(settingsControllerProvider); // autoDispose — 시트 저장이 끝날 때까지 붙잡아 둔다
    final controller = ref.read(settingsControllerProvider.notifier);
    return async.when(
      loading: () => const ColoredBox(color: AppColors.screenBackground, child: SizedBox.expand()),
      error: (e, _) => Center(child: Text('$e', style: AppTextStyles.caption)),
      data: (state) => MonthView(
        state: state,
        canGoPrev: state.month.isAfter(earliestMonth(first, today)),
        canGoNext: state.month.isBefore(latestMonth(today)),
        onCellTap: (date) {
          final cell = state.weeks.expand((w) => w).firstWhere((c) => c.date == date);
          // 오늘은 오늘 화면 버튼이 찍는다. 퇴근까지 찍히기 전엔 시트 대신 안내만.
          if (cell.isTodayWorking) return showAppToast(context, MonthTexts.todayInProgressToast);
          showRecordEditSheet(context, date);
        },
        onPrev: notifier.prev,
        onNext: notifier.next,
        onOpenWage: () => showNumberInputSheet(
          context,
          title: SettingsTexts.wageLabel,
          unit: SettingsTexts.wageUnit,
          note: SettingsTexts.wagePrivacyNote,
          lockIcon: true,
          maxDigits: SettingsTexts.wageMaxDigits,
          grouping: true,
          initial: settings.hourlyWage,
          saveLabel: SettingsTexts.save,
          clearLabel: SettingsTexts.clearLink,
          onSave: controller.setHourlyWage,
          onClear: () => controller.setHourlyWage(null),
        ),
        // 카드의 해에 저장 — 1월 카드에서 누르면 새해 값
        onOpenAnnual: () => showNumberInputSheet(
          context,
          title: SettingsTexts.annualLabel,
          unit: SettingsTexts.annualUnit,
          note: SettingsTexts.annualNote,
          maxDigits: SettingsTexts.annualMaxDigits,
          initial: settings.annualLeaveDaysOf(state.month.year),
          saveLabel: SettingsTexts.save,
          clearLabel: SettingsTexts.clearLink,
          onSave: (v) => controller.setAnnualLeaveDays(state.month.year, v),
          onClear: () => controller.setAnnualLeaveDays(state.month.year, null),
        ),
      ),
    );
  }
}

/// 월간 화면의 순수 UI. 기간 네비게이터 → 캘린더 → 범례 → (있으면) 수당 카드 → 연차 카드. 달 이동은 화살표로만.
class MonthView extends StatelessWidget {
  const MonthView({
    super.key,
    required this.state,
    required this.canGoPrev,
    required this.canGoNext,
    required this.onCellTap,
    required this.onPrev,
    required this.onNext,
    required this.onOpenWage,
    required this.onOpenAnnual,
  });

  final MonthState state;
  final bool canGoPrev;
  final bool canGoNext;
  final ValueChanged<DateTime> onCellTap;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  /// 카드의 유도 줄 — 시급 / 그 해 총 연차 입력 시트.
  final VoidCallback onOpenWage;
  final VoidCallback onOpenAnnual;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Column(
      children: [
        PeriodNavigator(
          label: MonthTexts.title(state.month),
          canGoPrev: canGoPrev,
          canGoNext: canGoNext,
          onPrev: onPrev,
          onNext: onNext,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: AppSizes.bodyPadding.copyWith(bottom: AppSizes.bodyPadding.bottom + bottomInset),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CalendarCard(state: state, onCellTap: onCellTap),
                SizedBox(height: AppSizes.cardGap),
                const Legend(),
                if (state.extraWork != null) ...[
                  SizedBox(height: AppSizes.cardGap),
                  ExtraWorkCard(
                    extraWork: state.extraWork!,
                    title: MonthTexts.extraWorkTitle(state.month),
                    onTapNudge: onOpenWage,
                  ),
                ],
                if (state.leave != null) ...[
                  SizedBox(height: AppSizes.cardGap),
                  LeaveCard(leave: state.leave!, onTapNudge: onOpenAnnual),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

import '../../core/debug_tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/clock_provider.dart';
import '../../core/providers/database_providers.dart';
import '../../ui/app_colors.dart';
import '../../ui/app_text_styles.dart';
import '../debug/seed_picker_sheet.dart';
import '../notification/notification_prompt.dart';
import '../../domain/model/work_type.dart';
import '../../domain/rules/work_calculator.dart';
import '../../domain/rules/work_rules.dart';
import '../record_edit/record_edit_sheet.dart';
import '../record_edit/record_edit_texts.dart';
import '../record_edit/widgets/trip_sheet.dart';
import 'today_state.dart';
import 'today_texts.dart';
import 'widgets/today_trip_sheet.dart';
import 'today_controller.dart';
import 'today_view.dart';
import 'widgets/clock_in_edit_sheet.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rules = ref.watch(workRulesProvider);
    final controller = ref.watch(todayControllerProvider.notifier);
    final async = ref.watch(todayControllerProvider);

    return async.when(
      // Drift는 로컬이라 첫 프레임 직후 바로 도착한다. 배경색만 보여준다.
      loading: () => const ColoredBox(color: AppColors.screenBackground, child: SizedBox.expand()),
      error: (e, _) => Center(child: Text('$e', style: AppTextStyles.caption)),
      data: (state) => TodayView(
        state: state,
        rules: rules,
        callbacks: TodayCallbacks(
          onClockIn: () async {
            // 주말·공휴일 근무는 그날 알림이 없다 — 권한은 다음 평일 출근 때 묻는다.
            final countsAsWorkday = !state.isWeekend && !state.isHoliday;
            await controller.clockIn();
            if (context.mounted) {
              await maybePromptClockOutNotification(context, ref, countsAsWorkday: countsAsWorkday);
            }
          },
          onClockOut: (deduct) => controller.clockOut(deductRemaining: deduct),
          onHalfDayChanged: controller.setHalfDay,
          onDayTypeChanged: controller.setDayType,
          onRevert: controller.revert,
          onCancelClockIn: controller.cancelClockIn,
          onCancelClockOut: controller.cancelClockOut,
          onEditTime: () => showRecordEditSheet(context, state.date),
          onEditClockIn: () => showClockInEditSheet(context, state.clockIn!, ref.read(clockProvider)),
          onUnrecordedTap: (date) => showRecordEditSheet(context, date),
          onTripTap: () => _editTrip(context, ref, state, rules),
          onTripRadioTap: () => _chooseTrip(context, ref, state, rules),
          onDateLongPress: kDebugTools ? () => showSeedPicker(context, ref) : null,
        ),
      ),
    );
  }
}

/// 출장 칩 — 시간 출장 작은 시트. 근무 중에도 남길 수 있게 오늘 화면이 직접 저장한다("저장").
/// 처음 값은 출근 시각부터 3시간("출근 = 출장 출발"이 흔하다).
Future<void> _editTrip(BuildContext context, WidgetRef ref, TodayState state, WorkRules rules) async {
  final record = state.record;
  final existing = hasTrip(record);
  final (start, end) =
      existing ? (record!.tripStart!, record.tripEnd!) : defaultTripRange(state.date, state.clockIn, rules);
  final result = await showTripSheet(context, start: start, end: end, existing: existing, confirmLabel: TodayTexts.save);
  if (result == null || !context.mounted) return;
  final controller = ref.read(todayControllerProvider.notifier);
  switch (result) {
    case TripSheetSet(:final start, :final end):
      await controller.setTrip(start, end);
    case TripSheetCleared():
      await controller.clearTrip();
  }
}

/// 출근 전 "출장" 라디오 — 종일 출장(지금의 출장 유형)인지 시간 출장인지 먼저 묻는다.
Future<void> _chooseTrip(BuildContext context, WidgetRef ref, TodayState state, WorkRules rules) async {
  final record = state.record;
  final choice = await showTodayTripSheet(
    context,
    tripRange: hasTrip(record) ? RecordEditTexts.tripRange(record!.tripStart, record.tripEnd) : null,
  );
  if (choice == null || !context.mounted) return;
  switch (choice) {
    case TodayTripChoice.fullDay:
      await ref.read(todayControllerProvider.notifier).setDayType(WorkType.businessTrip);
    case TodayTripChoice.timed:
      await _editTrip(context, ref, state, rules);
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/database_providers.dart';
import '../../ui/app_colors.dart';
import '../../ui/app_text_styles.dart';
import '../debug/seed_picker_sheet.dart';
import '../record_edit/record_edit_sheet.dart';
import 'today_controller.dart';
import 'today_view.dart';

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
          onClockIn: controller.clockIn,
          onClockOut: controller.clockOut,
          onHalfDayChanged: controller.setHalfDay,
          onDayTypeChanged: controller.setDayType,
          onRevert: controller.revert,
          onCancelClockIn: controller.cancelClockIn,
          onCancelClockOut: controller.cancelClockOut,
          onEditTime: () => showRecordEditSheet(context, state.date),
          onUnrecordedTap: (date) => showRecordEditSheet(context, date),
          onDateLongPress: kDebugMode ? () => showSeedPicker(context, ref) : null,
        ),
      ),
    );
  }
}

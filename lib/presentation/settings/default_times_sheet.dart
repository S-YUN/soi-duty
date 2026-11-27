import 'package:flutter/material.dart';

import '../../ui/app_colors.dart';
import '../../ui/app_sizes.dart';
import '../../ui/app_text_styles.dart';
import '../record_edit/widgets/time_range_sheet.dart';
import 'settings_texts.dart';

/// "기본 출퇴근 시각" 시트 (핸드오프 7 §4) — 시간 출장 시트와 같은 골격에 문구만 다르다.
/// 저장하면 [onSave](출근 분, 퇴근 분)를 부르고 닫는다. 바깥 탭·아래로 내리기는 아무것도 바꾸지 않는다. 토스트 없음.
Future<void> showDefaultTimesSheet(
  BuildContext context, {
  required int clockInMinutes,
  required int clockOutMinutes,
  required Future<void> Function(int clockInMinutes, int clockOutMinutes) onSave,
}) async {
  final picked = await showModalBottomSheet<(int, int)>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.scrim,
    sheetAnimationStyle: AnimationStyle(duration: AppDurations.sheetSlide, curve: AppCurves.sheet),
    builder: (_) => DefaultTimesSheet(clockInMinutes: clockInMinutes, clockOutMinutes: clockOutMinutes),
  );
  if (picked != null) await onSave(picked.$1, picked.$2);
}

class DefaultTimesSheet extends StatelessWidget {
  const DefaultTimesSheet({super.key, required this.clockInMinutes, required this.clockOutMinutes});

  final int clockInMinutes;
  final int clockOutMinutes;

  /// 휠은 시각만 본다 — 날짜는 아무 날이나.
  static DateTime _at(int minutes) => DateTime(2000, 1, 1, 0, minutes);
  static int _minutes(DateTime t) => t.hour * 60 + t.minute;

  @override
  Widget build(BuildContext context) {
    return TimeRangeSheet(
      title: SettingsTexts.defaultTimesLabel,
      help: SettingsTexts.defaultTimesHelp,
      startLabel: SettingsTexts.defaultTimesClockIn,
      endLabel: SettingsTexts.defaultTimesClockOut,
      start: _at(clockInMinutes),
      end: _at(clockOutMinutes),
      validNote: (_, _) => SettingsTexts.defaultTimesKeptNote,
      validNoteStyle: AppTextStyles.rangeSheetNote,
      invalidNote: SettingsTexts.defaultTimesInvalid,
      noteMinHeight: AppSizes.rangeSheetNoteMinHeight,
      confirmLabel: SettingsTexts.save,
      onConfirm: (start, end) => Navigator.of(context).pop((_minutes(start), _minutes(end))),
    );
  }
}

import 'package:flutter/widgets.dart';

import '../../domain/model/leave_balance.dart';
import '../../domain/model/work_record.dart';
import '../../domain/rules/work_calculator.dart';
import '../../domain/rules/work_rules.dart';
import '../shared/number_input_sheet.dart';
import 'settings_controller.dart';
import 'settings_texts.dart';

/// "남은 연차" 시트 — 설정 행과 월간 연차 카드 유도 줄이 같이 부른다 (2026-10-27).
/// 저장 = 입력한 일수 × 하루 분, 기준일 = [today]. 되돌리기 = 그 해 값 삭제.
/// [year]는 저장할 해(설정은 올해, 월간은 카드의 해). [records]는 "이 뒤로 찍어둔 연차" 강조 줄을 위해 — 그 해에 오늘보다 뒤인 연차·반차 합.
Future<void> showLeaveBalanceSheet(
  BuildContext context, {
  required int year,
  required DateTime today,
  required LeaveBalance? current,
  required List<WorkRecord> records,
  required WorkRules rules,
  required SettingsController controller,
}) {
  final day = rules.dayOffCreditMinutes;
  final future = leaveMinutesUsed(records, year, rules, after: today);
  return showNumberInputSheet(
    context,
    title: SettingsTexts.annualLabel,
    headline: SettingsTexts.annualHeadline(today),
    unit: SettingsTexts.annualUnit,
    notes: SettingsTexts.annualNotes,
    highlightNote: future > 0 ? SettingsTexts.annualFutureNote(future, day) : null,
    maxDigits: SettingsTexts.annualMaxDigits,
    decimalPlaces: SettingsTexts.annualDecimalPlaces,
    emptyCaption: SettingsTexts.annualEmptyCaption,
    isValid: (v) => isValidLeaveMinutes((v * day).round(), rules),
    invalidNote: SettingsTexts.annualInvalidNote(rules),
    initial: current == null ? null : current.remainingMinutes / day,
    saveLabel: SettingsTexts.save,
    clearLabel: SettingsTexts.clearLink,
    onSave: (v) => controller.setLeaveBalance(
      year,
      LeaveBalance(remainingMinutes: (v * day).round(), baseDate: dateOnly(today)),
    ),
    onClear: () => controller.setLeaveBalance(year, null),
  );
}

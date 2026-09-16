import '../../core/presentation/format/date_format.dart';
import '../../core/presentation/format/time_format.dart';
import '../../domain/model/work_type.dart';
import '../../domain/rules/work_calculator.dart';
import '../../domain/rules/work_rules.dart';
import 'record_draft.dart';

enum CalcKind { value, note, sum }

class CalcLine {
  const CalcLine(this.label, this.value, this.kind);
  final String label;
  final String value;
  final CalcKind kind;
}

/// 시간 수정 시트의 모든 문구.
abstract final class RecordEditTexts {
  static const weekendNote = '주말 근무는 주 40시간에 포함되지 않아요';
  static const clockIn = '출근';
  static const clockOut = '퇴근';
  static const clockInTitle = '출근 시각';
  static const clockOutTitle = '퇴근 시각';
  static const empty = '--:--';
  static const invalidRange = '퇴근이 출근보다 빨라요';
  static const cancel = '취소';
  static const save = '저장';
  static const deleteLink = '이 날 기록 지우기';
  static const deleteTitle = '이 날 기록을 지울까요?';
  static const deleteMessage = '출퇴근 시각과 유형이 모두 사라져요.';
  static const deleteConfirm = '지우기';
  static const dash = '—';

  static String title(RecordDraft d) => formatDateTitle(d.date);

  static String chipLabel(WorkType t) => switch (t) {
        WorkType.halfDay => '반차',
        WorkType.dayOff => '연차',
        WorkType.holiday => '공휴일',
        WorkType.normal => '',
      };

  static String time(DateTime? t) => t == null ? empty : formatClock(t);

  static String wheelTitle(EditingRow row) => row == EditingRow.clockIn ? clockInTitle : clockOutTitle;
}

/// 계산 내역. 주말은 근무·점심 공제 두 줄.
List<CalcLine> calcLines(RecordDraft d, WorkRules rules) {
  final record = d.toRecord();
  final actual = actualMinutes(record, rules);
  final lunch = d.isWeekend
      ? '없음'
      : d.type == WorkType.halfDay
          ? '없음 (반차)'
          : formatHm(rules.lunchBreakMinutes);
  final lines = [
    CalcLine('근무', actual == null ? RecordEditTexts.dash : formatHm(actual), CalcKind.value),
    CalcLine('점심 공제', lunch, CalcKind.note),
  ];
  if (d.isWeekend) return lines;
  final delta = deltaMinutes(record, rules);
  return [
    ...lines,
    CalcLine('기준', formatHm(standardMinutes(d.type, rules)), CalcKind.note),
    CalcLine('기준 대비', delta == null ? RecordEditTexts.dash : formatSignedHm(delta), CalcKind.sum),
  ];
}

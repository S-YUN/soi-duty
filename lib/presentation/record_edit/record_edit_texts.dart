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
  static const futureNote = '미리 지정해두면 그 주 목표 시간이 자동으로 계산돼요';
  static const clockIn = '출근';
  static const clockOut = '퇴근';
  static const clockInTitle = '출근 시각';
  static const clockOutTitle = '퇴근 시각';
  static const empty = '--:--';
  static const invalidRange = '퇴근이 출근보다 빨라요';
  static const save = '저장';
  static const deleteLink = '이 날 기록 지우기';
  static const deleteTitle = '이 날 기록을 지울까요?';
  static const deleteMessage = '출퇴근 시각과 유형이 모두 사라져요.';
  static const deleteConfirm = '지우기';
  static const replaceTimesMessage = '입력한 출퇴근 시각이 지워져요.';
  static const replaceTimesConfirm = '바꾸기';
  static const am = '오전';
  static const pm = '오후';
  static const dash = '—';
  static const deductionLabel = '시간공제';
  static const deductionWheelTitle = '뺄 시간';
  static const deductionNone = '없음';
  static const reasonHint = '사유 (선택) 예: 조기퇴근 공문';
  static const deductionHelp = '연차·반차로 안 되는 시간을 직접 넣어 이 날 기준시간에서 빼요';
  static const halfDayDeductionTooLong = '반차인 날은 4시간까지 뺄 수 있어요';
  static const holidayWorkButton = '+ 이 날 근무한 시간 입력';
  static const holidayNote = '공휴일 근무는 주 40시간에 포함되지 않아요';
  static const hourUnit = '시간';
  static const minuteUnit = '분';

  /// 미래는 "9월 17일", 나머지는 "9월 17일 목요일".
  static String title(RecordDraft d) => d.isFuture ? formatMonthDay(d.date) : formatDateTitle(d.date);

  static String chipLabel(WorkType t) => switch (t) {
        WorkType.halfDay => '반차',
        WorkType.dayOff => '연차',
        WorkType.holiday => '공휴일',
        WorkType.businessTrip => '출장',
        WorkType.normal => '',
      };

  static String time(DateTime? t) => t == null ? empty : formatClock(t);

  /// "연차로 바꿀까요?" / "공휴일로 바꿀까요?"
  static String replaceTimesTitle(WorkType t) => '${chipLabel(t)}로 바꿀까요?';

  static String wheelTitle(EditingRow row) => switch (row) {
        EditingRow.clockIn => clockInTitle,
        EditingRow.clockOut => clockOutTitle,
        EditingRow.deduction => deductionWheelTitle,
      };

  /// "2시간 30분" / "30분" / "없음"
  static String deduction(int minutes) => minutes == 0 ? deductionNone : formatKoreanDuration(minutes);
}

/// 계산 내역. 주말·공휴일은 근무·점심 공제 두 줄. 시간공제가 있으면 기준 위에 한 줄.
List<CalcLine> calcLines(RecordDraft d, WorkRules rules) {
  final record = d.toRecord();
  final actual = actualMinutes(record, rules);
  final noBaseline = d.isWeekend || d.type == WorkType.holiday;
  final lunch = d.isWeekend
      ? '없음'
      : d.type == WorkType.halfDay
          ? '없음 (반차)'
          : d.type == WorkType.holiday
              ? '없음 (공휴일)'
              : formatHm(rules.lunchBreakMinutes);
  final lines = [
    CalcLine('근무', actual == null ? RecordEditTexts.dash : formatHm(actual), CalcKind.value),
    CalcLine('점심 공제', lunch, CalcKind.note),
  ];
  if (noBaseline) return lines;
  final delta = deltaMinutes(record, rules);
  return [
    ...lines,
    if (record.deductionMinutes > 0) CalcLine('시간공제', formatHm(-record.deductionMinutes), CalcKind.note),
    CalcLine('기준', formatHm(dayStandardMinutes(record, rules)), CalcKind.note),
    CalcLine('기준 대비', delta == null ? RecordEditTexts.dash : formatSignedHm(delta), CalcKind.sum),
  ];
}

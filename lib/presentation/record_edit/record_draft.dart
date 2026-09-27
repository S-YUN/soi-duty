import '../../domain/model/work_record.dart';
import '../../domain/model/work_type.dart';
import '../../domain/rules/work_calculator.dart' as calc;
import '../../domain/rules/work_rules.dart';

enum EditingRow { clockIn, clockOut, deduction }

/// nullable 필드의 copyWith 센티널.
enum _Keep { time, editing }

/// 시간 수정 시트가 저장 전까지 들고 있는 초안. 불변, 순수 Dart.
class RecordDraft {
  const RecordDraft({
    required this.date,
    required this.today,
    required this.existing,
    this.hasClockIn = false,
    this.type = WorkType.normal,
    this.clockIn,
    this.clockOut,
    this.deductionMinutes = 0,
    this.deductionReason = '',
    this.showsHolidayWork = false,
    this.editing,
  });

  factory RecordDraft.fromRecord({required DateTime date, required DateTime today, required WorkRecord? record}) {
    final hasTime = record?.clockIn != null || record?.clockOut != null;
    return RecordDraft(
      date: calc.dateOnly(date),
      today: calc.dateOnly(today),
      existing: record != null,
      hasClockIn: record?.clockIn != null,
      type: record?.type ?? WorkType.normal,
      clockIn: record?.clockIn,
      clockOut: record?.clockOut,
      deductionMinutes: record?.deductionMinutes ?? 0,
      deductionReason: record?.deductionReason ?? '',
      showsHolidayWork: hasTime,
    );
  }

  final DateTime date;
  final DateTime today;

  /// 기존 기록이 있었는지 — "이 날 기록 지우기" 노출 여부
  final bool existing;

  /// 열 때 저장돼 있던 기록에 출근이 찍혀 있었는지 — 출근 전 오늘을 유형 전용으로 여는 판정
  final bool hasClockIn;
  final WorkType type;
  final DateTime? clockIn;
  final DateTime? clockOut;

  /// 시간공제(분). 0이면 없음
  final int deductionMinutes;

  /// 시간공제 사유. ''이면 없음
  final String deductionReason;

  /// 공휴일에 "이 날 근무한 시간 입력"을 펼쳤는지. 초안 상태일 뿐 저장값이 아니다.
  final bool showsHolidayWork;

  /// 휠이 펼쳐진 행
  final EditingRow? editing;

  bool get isWeekend => calc.isWeekend(date);
  bool get isFuture => date.isAfter(today);

  /// 시각 없이 유형·시간공제만 고르는 모드 — 미래, 그리고 출근 전인 오늘.
  bool get isTypeOnly => isFuture || (date == today && !hasClockIn);
  bool get isOff => calc.isOffType(type);

  bool get showsTypeChips => !isWeekend;
  bool get showsTimeRows =>
      !isTypeOnly &&
      (type == WorkType.normal || type == WorkType.halfDay || (type == WorkType.holiday && showsHolidayWork));

  /// 공휴일은 대부분 쉬는 날이라 시각 행 대신 이 버튼 하나만 둔다.
  bool get showsHolidayWorkButton => !isTypeOnly && type == WorkType.holiday && !showsHolidayWork;
  bool get showsDeductionRow => calc.canDeduct(date, type);

  bool isDeductionValid(WorkRules rules) =>
      !showsDeductionRow || calc.isValidDeduction(type, deductionMinutes, rules);
  bool isValid(WorkRules rules) => calc.isValidClockRange(clockIn, clockOut) && isDeductionValid(rules);

  /// 유형 전용 모드는 유형 탭이 곧 저장이라 버튼이 없지만, 공제를 편집할 때는 저장이 필요하다.
  bool get showsSaveButton => showsTimeRows || (isTypeOnly && editing == EditingRow.deduction);
  bool get hasAnyTime => clockIn != null || clockOut != null;

  DateTime? timeOf(EditingRow row) => switch (row) {
        EditingRow.clockIn => clockIn,
        EditingRow.clockOut => clockOut,
        EditingRow.deduction => null,
      };

  /// 공제 휠이 열리는 위치 — 휠 단위(10분)로 내림. 퇴근 시 자동 공제된 2h 47m도 돌리기 전엔 그대로 둔다.
  int deductionWheelStart(WorkRules rules) => deductionMinutes - deductionMinutes % rules.deductionStepMinutes;

  /// 저장할 기록. 시각 행이 없으면 시각을 비우고, 공제 행이 없으면 공제를 비운다. 나머지 정리는 [calc.sanitizeRecord].
  WorkRecord toRecord() => calc.sanitizeRecord(WorkRecord(
        date: date,
        type: type,
        clockIn: showsTimeRows ? clockIn : null,
        clockOut: showsTimeRows ? clockOut : null,
        deductionMinutes: showsDeductionRow ? deductionMinutes : 0,
        deductionReason: deductionReason,
      ));

  /// 시각·공제 없는 normal — 저장 대신 삭제한다.
  bool get isEmptyNormal {
    final r = toRecord();
    return r.type == WorkType.normal && r.clockIn == null && r.clockOut == null && r.deductionMinutes == 0;
  }

  RecordDraft withType(WorkType? next) => _copy(type: next ?? WorkType.normal);
  RecordDraft withDeduction(int minutes) => _copy(deductionMinutes: minutes);
  RecordDraft withReason(String text) => _copy(deductionReason: text);
  RecordDraft expandHolidayWork() => _copy(showsHolidayWork: true);

  /// 행 탭. 같은 행이면 접고, 다른 행이면 편다. 시각 행을 펼 때 값이 없으면 [WorkRules]의 기본 시각(출근 08:00 · 퇴근 17:00).
  RecordDraft toggleEditing(EditingRow row, WorkRules rules) {
    if (editing == row) return _copy(editing: null);
    if (row == EditingRow.deduction) return _copy(editing: row);
    final defaultMinutes = row == EditingRow.clockIn ? rules.defaultClockInMinutes : rules.defaultClockOutMinutes;
    final current = timeOf(row) ?? DateTime(date.year, date.month, date.day, 0, defaultMinutes);
    return _copy(
      editing: row,
      clockIn: row == EditingRow.clockIn ? current : _Keep.time,
      clockOut: row == EditingRow.clockOut ? current : _Keep.time,
    );
  }

  RecordDraft withTime(EditingRow row, int hour, int minute) {
    final t = DateTime(date.year, date.month, date.day, hour, minute);
    return _copy(
      clockIn: row == EditingRow.clockIn ? t : _Keep.time,
      clockOut: row == EditingRow.clockOut ? t : _Keep.time,
    );
  }

  RecordDraft _copy({
    WorkType? type,
    Object? clockIn = _Keep.time,
    Object? clockOut = _Keep.time,
    int? deductionMinutes,
    String? deductionReason,
    bool? showsHolidayWork,
    Object? editing = _Keep.editing,
  }) =>
      RecordDraft(
        date: date,
        today: today,
        existing: existing,
        hasClockIn: hasClockIn,
        type: type ?? this.type,
        clockIn: identical(clockIn, _Keep.time) ? this.clockIn : clockIn as DateTime?,
        clockOut: identical(clockOut, _Keep.time) ? this.clockOut : clockOut as DateTime?,
        deductionMinutes: deductionMinutes ?? this.deductionMinutes,
        deductionReason: deductionReason ?? this.deductionReason,
        showsHolidayWork: showsHolidayWork ?? this.showsHolidayWork,
        editing: identical(editing, _Keep.editing) ? this.editing : editing as EditingRow?,
      );
}

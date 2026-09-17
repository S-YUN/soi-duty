import '../../domain/model/work_record.dart';
import '../../domain/model/work_type.dart';
import '../../domain/rules/work_calculator.dart' as calc;

enum EditingRow { clockIn, clockOut }

/// nullable 필드의 copyWith 센티널.
enum _Keep { time, editing }

/// 시간 수정 시트가 저장 전까지 들고 있는 초안. 불변, 순수 Dart.
class RecordDraft {
  const RecordDraft({
    required this.date,
    required this.today,
    required this.existing,
    this.type = WorkType.normal,
    this.clockIn,
    this.clockOut,
    this.editing,
  });

  factory RecordDraft.fromRecord({required DateTime date, required DateTime today, required WorkRecord? record}) =>
      RecordDraft(
        date: calc.dateOnly(date),
        today: calc.dateOnly(today),
        existing: record != null,
        type: record?.type ?? WorkType.normal,
        clockIn: record?.clockIn,
        clockOut: record?.clockOut,
      );

  final DateTime date;
  final DateTime today;

  /// 기존 기록이 있었는지 — "이 날 기록 지우기" 노출 여부
  final bool existing;
  final WorkType type;
  final DateTime? clockIn;
  final DateTime? clockOut;

  /// 휠이 펼쳐진 행
  final EditingRow? editing;

  bool get isWeekend => calc.isWeekend(date);
  bool get isFuture => date.isAfter(today);
  bool get isOff => type == WorkType.dayOff || type == WorkType.holiday;

  bool get showsTypeChips => !isWeekend;
  bool get showsTimeRows => !isFuture && !isOff;
  bool get isValid => calc.isValidClockRange(clockIn, clockOut);
  bool get hasAnyTime => clockIn != null || clockOut != null;

  DateTime? timeOf(EditingRow row) => row == EditingRow.clockIn ? clockIn : clockOut;

  /// 저장할 기록. 연차·공휴일·미래는 시각을 비운다.
  WorkRecord toRecord() => WorkRecord(
        date: date,
        type: type,
        clockIn: showsTimeRows ? clockIn : null,
        clockOut: showsTimeRows ? clockOut : null,
      );

  /// 시각 둘 다 없는 normal — 저장 대신 삭제한다.
  bool get isEmptyNormal {
    final r = toRecord();
    return r.type == WorkType.normal && r.clockIn == null && r.clockOut == null;
  }

  RecordDraft withType(WorkType? next) => _copy(type: next ?? WorkType.normal);

  /// 빈 행을 펼 때 휠이 시작하는 시각. 시트 안에서만 쓰이고 행 표시(--:--)나 저장값에는 관여하지 않는다.
  static const defaultClockInHour = 8;
  static const defaultClockOutHour = 17;

  /// 행 탭. 같은 행이면 접고, 다른 행이면 편다. 펼 때 값이 없으면 기본 시각(출근 08:00 · 퇴근 17:00).
  RecordDraft toggleEditing(EditingRow row) {
    if (editing == row) return _copy(editing: null);
    final defaultHour = row == EditingRow.clockIn ? defaultClockInHour : defaultClockOutHour;
    final current = timeOf(row) ?? DateTime(date.year, date.month, date.day, defaultHour);
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
    Object? editing = _Keep.editing,
  }) =>
      RecordDraft(
        date: date,
        today: today,
        existing: existing,
        type: type ?? this.type,
        clockIn: identical(clockIn, _Keep.time) ? this.clockIn : clockIn as DateTime?,
        clockOut: identical(clockOut, _Keep.time) ? this.clockOut : clockOut as DateTime?,
        editing: identical(editing, _Keep.editing) ? this.editing : editing as EditingRow?,
      );
}

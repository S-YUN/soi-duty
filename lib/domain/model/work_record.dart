import 'package:freezed_annotation/freezed_annotation.dart';

import 'work_type.dart';

part 'work_record.freezed.dart';
part 'work_record.g.dart';

@freezed
abstract class WorkRecord with _$WorkRecord {
  const factory WorkRecord({
    /// 날짜만. 시분초 0, local.
    required DateTime date,
    DateTime? clockIn,
    DateTime? clockOut,
    @Default(WorkType.normal) WorkType type,
    /// 시간공제(분). 그날 기준시간에서 뺀다. 평일 일반·반차에만 의미가 있다 — sanitizeRecord.
    @Default(0) int deductionMinutes,
    /// 시간공제 사유. 선택. 공제가 0이면 null.
    String? deductionReason,
  }) = _WorkRecord;

  factory WorkRecord.fromJson(Map<String, Object?> json) => _$WorkRecordFromJson(json);
}

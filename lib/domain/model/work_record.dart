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
  }) = _WorkRecord;

  factory WorkRecord.fromJson(Map<String, Object?> json) => _$WorkRecordFromJson(json);
}

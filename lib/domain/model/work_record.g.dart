// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorkRecord _$WorkRecordFromJson(Map<String, dynamic> json) => _WorkRecord(
  date: DateTime.parse(json['date'] as String),
  clockIn: json['clockIn'] == null
      ? null
      : DateTime.parse(json['clockIn'] as String),
  clockOut: json['clockOut'] == null
      ? null
      : DateTime.parse(json['clockOut'] as String),
  type: $enumDecodeNullable(_$WorkTypeEnumMap, json['type']) ?? WorkType.normal,
);

Map<String, dynamic> _$WorkRecordToJson(_WorkRecord instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'clockIn': instance.clockIn?.toIso8601String(),
      'clockOut': instance.clockOut?.toIso8601String(),
      'type': _$WorkTypeEnumMap[instance.type]!,
    };

const _$WorkTypeEnumMap = {
  WorkType.normal: 'normal',
  WorkType.halfDay: 'halfDay',
  WorkType.dayOff: 'dayOff',
  WorkType.holiday: 'holiday',
};

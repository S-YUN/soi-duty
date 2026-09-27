// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'work_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WorkRecord {

/// 날짜만. 시분초 0, local.
 DateTime get date; DateTime? get clockIn; DateTime? get clockOut; WorkType get type;/// 시간공제(분). 그날 기준시간에서 뺀다. 평일 일반·반차에만 의미가 있다 — sanitizeRecord.
 int get deductionMinutes;/// 시간공제 사유. 선택. 공제가 0이면 null.
 String? get deductionReason;
/// Create a copy of WorkRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkRecordCopyWith<WorkRecord> get copyWith => _$WorkRecordCopyWithImpl<WorkRecord>(this as WorkRecord, _$identity);

  /// Serializes this WorkRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as WorkRecord;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkRecord&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.clockIn, _this.clockIn) || other.clockIn == _this.clockIn)&&(identical(other.clockOut, _this.clockOut) || other.clockOut == _this.clockOut)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.deductionMinutes, _this.deductionMinutes) || other.deductionMinutes == _this.deductionMinutes)&&(identical(other.deductionReason, _this.deductionReason) || other.deductionReason == _this.deductionReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WorkRecord;
  return Object.hash(runtimeType,_this.date,_this.clockIn,_this.clockOut,_this.type,_this.deductionMinutes,_this.deductionReason);
}

@override
String toString() {
  final _this = this as WorkRecord;
  return 'WorkRecord(date: ${_this.date}, clockIn: ${_this.clockIn}, clockOut: ${_this.clockOut}, type: ${_this.type}, deductionMinutes: ${_this.deductionMinutes}, deductionReason: ${_this.deductionReason})';
}


}

/// @nodoc
abstract mixin class $WorkRecordCopyWith<$Res>  {
  factory $WorkRecordCopyWith(WorkRecord value, $Res Function(WorkRecord) _then) = _$WorkRecordCopyWithImpl;
@useResult
$Res call({
 DateTime date, DateTime? clockIn, DateTime? clockOut, WorkType type, int deductionMinutes, String? deductionReason
});




}
/// @nodoc
class _$WorkRecordCopyWithImpl<$Res>
    implements $WorkRecordCopyWith<$Res> {
  _$WorkRecordCopyWithImpl(this._self, this._then);

  final WorkRecord _self;
  final $Res Function(WorkRecord) _then;

/// Create a copy of WorkRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? clockIn = freezed,Object? clockOut = freezed,Object? type = null,Object? deductionMinutes = null,Object? deductionReason = freezed,}) {
  return _then(WorkRecord(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,clockIn: freezed == clockIn ? _self.clockIn : clockIn // ignore: cast_nullable_to_non_nullable
as DateTime?,clockOut: freezed == clockOut ? _self.clockOut : clockOut // ignore: cast_nullable_to_non_nullable
as DateTime?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as WorkType,deductionMinutes: null == deductionMinutes ? _self.deductionMinutes : deductionMinutes // ignore: cast_nullable_to_non_nullable
as int,deductionReason: freezed == deductionReason ? _self.deductionReason : deductionReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkRecord].
extension WorkRecordPatterns on WorkRecord {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkRecord() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkRecord value)  $default,){
final _that = this;
switch (_that) {
case _WorkRecord():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkRecord value)?  $default,){
final _that = this;
switch (_that) {
case _WorkRecord() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  DateTime? clockIn,  DateTime? clockOut,  WorkType type,  int deductionMinutes,  String? deductionReason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkRecord() when $default != null:
return $default(_that.date,_that.clockIn,_that.clockOut,_that.type,_that.deductionMinutes,_that.deductionReason);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  DateTime? clockIn,  DateTime? clockOut,  WorkType type,  int deductionMinutes,  String? deductionReason)  $default,) {final _that = this;
switch (_that) {
case _WorkRecord():
return $default(_that.date,_that.clockIn,_that.clockOut,_that.type,_that.deductionMinutes,_that.deductionReason);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  DateTime? clockIn,  DateTime? clockOut,  WorkType type,  int deductionMinutes,  String? deductionReason)?  $default,) {final _that = this;
switch (_that) {
case _WorkRecord() when $default != null:
return $default(_that.date,_that.clockIn,_that.clockOut,_that.type,_that.deductionMinutes,_that.deductionReason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkRecord implements WorkRecord {
  const _WorkRecord({required this.date, this.clockIn, this.clockOut, this.type = WorkType.normal, this.deductionMinutes = 0, this.deductionReason});
  factory _WorkRecord.fromJson(Map<String, dynamic> json) => _$WorkRecordFromJson(json);

/// 날짜만. 시분초 0, local.
@override final  DateTime date;
@override final  DateTime? clockIn;
@override final  DateTime? clockOut;
@override@JsonKey() final  WorkType type;
/// 시간공제(분). 그날 기준시간에서 뺀다. 평일 일반·반차에만 의미가 있다 — sanitizeRecord.
@override@JsonKey() final  int deductionMinutes;
/// 시간공제 사유. 선택. 공제가 0이면 null.
@override final  String? deductionReason;

/// Create a copy of WorkRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkRecordCopyWith<_WorkRecord> get copyWith => __$WorkRecordCopyWithImpl<_WorkRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkRecordToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkRecord&&(identical(other.date, date) || other.date == date)&&(identical(other.clockIn, clockIn) || other.clockIn == clockIn)&&(identical(other.clockOut, clockOut) || other.clockOut == clockOut)&&(identical(other.type, type) || other.type == type)&&(identical(other.deductionMinutes, deductionMinutes) || other.deductionMinutes == deductionMinutes)&&(identical(other.deductionReason, deductionReason) || other.deductionReason == deductionReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,date,clockIn,clockOut,type,deductionMinutes,deductionReason);
}

@override
String toString() {
    return 'WorkRecord(date: $date, clockIn: $clockIn, clockOut: $clockOut, type: $type, deductionMinutes: $deductionMinutes, deductionReason: $deductionReason)';
}


}

/// @nodoc
abstract mixin class _$WorkRecordCopyWith<$Res> implements $WorkRecordCopyWith<$Res> {
  factory _$WorkRecordCopyWith(_WorkRecord value, $Res Function(_WorkRecord) _then) = __$WorkRecordCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, DateTime? clockIn, DateTime? clockOut, WorkType type, int deductionMinutes, String? deductionReason
});




}
/// @nodoc
class __$WorkRecordCopyWithImpl<$Res>
    implements _$WorkRecordCopyWith<$Res> {
  __$WorkRecordCopyWithImpl(this._self, this._then);

  final _WorkRecord _self;
  final $Res Function(_WorkRecord) _then;

/// Create a copy of WorkRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? clockIn = freezed,Object? clockOut = freezed,Object? type = null,Object? deductionMinutes = null,Object? deductionReason = freezed,}) {
  return _then(_WorkRecord(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,clockIn: freezed == clockIn ? _self.clockIn : clockIn // ignore: cast_nullable_to_non_nullable
as DateTime?,clockOut: freezed == clockOut ? _self.clockOut : clockOut // ignore: cast_nullable_to_non_nullable
as DateTime?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as WorkType,deductionMinutes: null == deductionMinutes ? _self.deductionMinutes : deductionMinutes // ignore: cast_nullable_to_non_nullable
as int,deductionReason: freezed == deductionReason ? _self.deductionReason : deductionReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'backup_snapshot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BackupSnapshot {

 DateTime get exportedAt; DateTime? get firstRecordDate; WeekStart get weekStart; Map<int, LeaveBalance> get leaveBalanceByYear; int? get hourlyWage; List<WorkRecord> get records;
/// Create a copy of BackupSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BackupSnapshotCopyWith<BackupSnapshot> get copyWith => _$BackupSnapshotCopyWithImpl<BackupSnapshot>(this as BackupSnapshot, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as BackupSnapshot;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BackupSnapshot&&(identical(other.exportedAt, _this.exportedAt) || other.exportedAt == _this.exportedAt)&&(identical(other.firstRecordDate, _this.firstRecordDate) || other.firstRecordDate == _this.firstRecordDate)&&(identical(other.weekStart, _this.weekStart) || other.weekStart == _this.weekStart)&&const DeepCollectionEquality().equals(other.leaveBalanceByYear, _this.leaveBalanceByYear)&&(identical(other.hourlyWage, _this.hourlyWage) || other.hourlyWage == _this.hourlyWage)&&const DeepCollectionEquality().equals(other.records, _this.records));
}


@override
int get hashCode {
  final _this = this as BackupSnapshot;
  return Object.hash(runtimeType,_this.exportedAt,_this.firstRecordDate,_this.weekStart,const DeepCollectionEquality().hash(_this.leaveBalanceByYear),_this.hourlyWage,const DeepCollectionEquality().hash(_this.records));
}

@override
String toString() {
  final _this = this as BackupSnapshot;
  return 'BackupSnapshot(exportedAt: ${_this.exportedAt}, firstRecordDate: ${_this.firstRecordDate}, weekStart: ${_this.weekStart}, leaveBalanceByYear: ${_this.leaveBalanceByYear}, hourlyWage: ${_this.hourlyWage}, records: ${_this.records})';
}


}

/// @nodoc
abstract mixin class $BackupSnapshotCopyWith<$Res>  {
  factory $BackupSnapshotCopyWith(BackupSnapshot value, $Res Function(BackupSnapshot) _then) = _$BackupSnapshotCopyWithImpl;
@useResult
$Res call({
 DateTime exportedAt, DateTime? firstRecordDate, WeekStart weekStart, Map<int, LeaveBalance> leaveBalanceByYear, int? hourlyWage, List<WorkRecord> records
});




}
/// @nodoc
class _$BackupSnapshotCopyWithImpl<$Res>
    implements $BackupSnapshotCopyWith<$Res> {
  _$BackupSnapshotCopyWithImpl(this._self, this._then);

  final BackupSnapshot _self;
  final $Res Function(BackupSnapshot) _then;

/// Create a copy of BackupSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? exportedAt = null,Object? firstRecordDate = freezed,Object? weekStart = null,Object? leaveBalanceByYear = null,Object? hourlyWage = freezed,Object? records = null,}) {
  return _then(BackupSnapshot(
exportedAt: null == exportedAt ? _self.exportedAt : exportedAt // ignore: cast_nullable_to_non_nullable
as DateTime,firstRecordDate: freezed == firstRecordDate ? _self.firstRecordDate : firstRecordDate // ignore: cast_nullable_to_non_nullable
as DateTime?,weekStart: null == weekStart ? _self.weekStart : weekStart // ignore: cast_nullable_to_non_nullable
as WeekStart,leaveBalanceByYear: null == leaveBalanceByYear ? _self.leaveBalanceByYear : leaveBalanceByYear // ignore: cast_nullable_to_non_nullable
as Map<int, LeaveBalance>,hourlyWage: freezed == hourlyWage ? _self.hourlyWage : hourlyWage // ignore: cast_nullable_to_non_nullable
as int?,records: null == records ? _self.records : records // ignore: cast_nullable_to_non_nullable
as List<WorkRecord>,
  ));
}

}


/// Adds pattern-matching-related methods to [BackupSnapshot].
extension BackupSnapshotPatterns on BackupSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BackupSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BackupSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BackupSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _BackupSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BackupSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _BackupSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime exportedAt,  DateTime? firstRecordDate,  WeekStart weekStart,  Map<int, LeaveBalance> leaveBalanceByYear,  int? hourlyWage,  List<WorkRecord> records)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BackupSnapshot() when $default != null:
return $default(_that.exportedAt,_that.firstRecordDate,_that.weekStart,_that.leaveBalanceByYear,_that.hourlyWage,_that.records);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime exportedAt,  DateTime? firstRecordDate,  WeekStart weekStart,  Map<int, LeaveBalance> leaveBalanceByYear,  int? hourlyWage,  List<WorkRecord> records)  $default,) {final _that = this;
switch (_that) {
case _BackupSnapshot():
return $default(_that.exportedAt,_that.firstRecordDate,_that.weekStart,_that.leaveBalanceByYear,_that.hourlyWage,_that.records);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime exportedAt,  DateTime? firstRecordDate,  WeekStart weekStart,  Map<int, LeaveBalance> leaveBalanceByYear,  int? hourlyWage,  List<WorkRecord> records)?  $default,) {final _that = this;
switch (_that) {
case _BackupSnapshot() when $default != null:
return $default(_that.exportedAt,_that.firstRecordDate,_that.weekStart,_that.leaveBalanceByYear,_that.hourlyWage,_that.records);case _:
  return null;

}
}

}

/// @nodoc


class _BackupSnapshot implements BackupSnapshot {
  const _BackupSnapshot({required this.exportedAt, this.firstRecordDate, required this.weekStart, required  Map<int, LeaveBalance> leaveBalanceByYear, this.hourlyWage, required  List<WorkRecord> records}): _leaveBalanceByYear = leaveBalanceByYear,_records = records;
  

@override final  DateTime exportedAt;
@override final  DateTime? firstRecordDate;
@override final  WeekStart weekStart;
 final  Map<int, LeaveBalance> _leaveBalanceByYear;
@override Map<int, LeaveBalance> get leaveBalanceByYear {
  if (_leaveBalanceByYear is EqualUnmodifiableMapView) return _leaveBalanceByYear;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_leaveBalanceByYear);
}

@override final  int? hourlyWage;
 final  List<WorkRecord> _records;
@override List<WorkRecord> get records {
  if (_records is EqualUnmodifiableListView) return _records;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_records);
}


/// Create a copy of BackupSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BackupSnapshotCopyWith<_BackupSnapshot> get copyWith => __$BackupSnapshotCopyWithImpl<_BackupSnapshot>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BackupSnapshot&&(identical(other.exportedAt, exportedAt) || other.exportedAt == exportedAt)&&(identical(other.firstRecordDate, firstRecordDate) || other.firstRecordDate == firstRecordDate)&&(identical(other.weekStart, weekStart) || other.weekStart == weekStart)&&const DeepCollectionEquality().equals(other.leaveBalanceByYear, _leaveBalanceByYear)&&(identical(other.hourlyWage, hourlyWage) || other.hourlyWage == hourlyWage)&&const DeepCollectionEquality().equals(other.records, _records));
}


@override
int get hashCode {
    return Object.hash(runtimeType,exportedAt,firstRecordDate,weekStart,const DeepCollectionEquality().hash(_leaveBalanceByYear),hourlyWage,const DeepCollectionEquality().hash(_records));
}

@override
String toString() {
    return 'BackupSnapshot(exportedAt: $exportedAt, firstRecordDate: $firstRecordDate, weekStart: $weekStart, leaveBalanceByYear: $leaveBalanceByYear, hourlyWage: $hourlyWage, records: $records)';
}


}

/// @nodoc
abstract mixin class _$BackupSnapshotCopyWith<$Res> implements $BackupSnapshotCopyWith<$Res> {
  factory _$BackupSnapshotCopyWith(_BackupSnapshot value, $Res Function(_BackupSnapshot) _then) = __$BackupSnapshotCopyWithImpl;
@override @useResult
$Res call({
 DateTime exportedAt, DateTime? firstRecordDate, WeekStart weekStart, Map<int, LeaveBalance> leaveBalanceByYear, int? hourlyWage, List<WorkRecord> records
});




}
/// @nodoc
class __$BackupSnapshotCopyWithImpl<$Res>
    implements _$BackupSnapshotCopyWith<$Res> {
  __$BackupSnapshotCopyWithImpl(this._self, this._then);

  final _BackupSnapshot _self;
  final $Res Function(_BackupSnapshot) _then;

/// Create a copy of BackupSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? exportedAt = null,Object? firstRecordDate = freezed,Object? weekStart = null,Object? leaveBalanceByYear = null,Object? hourlyWage = freezed,Object? records = null,}) {
  return _then(_BackupSnapshot(
exportedAt: null == exportedAt ? _self.exportedAt : exportedAt // ignore: cast_nullable_to_non_nullable
as DateTime,firstRecordDate: freezed == firstRecordDate ? _self.firstRecordDate : firstRecordDate // ignore: cast_nullable_to_non_nullable
as DateTime?,weekStart: null == weekStart ? _self.weekStart : weekStart // ignore: cast_nullable_to_non_nullable
as WeekStart,leaveBalanceByYear: null == leaveBalanceByYear ? _self._leaveBalanceByYear : leaveBalanceByYear // ignore: cast_nullable_to_non_nullable
as Map<int, LeaveBalance>,hourlyWage: freezed == hourlyWage ? _self.hourlyWage : hourlyWage // ignore: cast_nullable_to_non_nullable
as int?,records: null == records ? _self._records : records // ignore: cast_nullable_to_non_nullable
as List<WorkRecord>,
  ));
}


}

// dart format on

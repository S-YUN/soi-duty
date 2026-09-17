// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'today_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TodayState {

 DateTime get date; WorkRecord? get record; TodayPhase get phase; WorkType? get dayType; bool get isHalfDay; DateTime? get clockIn; DateTime? get clockOut;/// working일 때 now − clockIn (점심 미공제)
 int? get elapsedMinutes;/// working일 때만. 첫 주 예외·주말·연차·이미 채움이면 null
 DateTime? get expectedClockOut;/// 출근 전·근무 중일 때 오늘 몫 (남은 시간 ÷ 남은 근무일). 반차는 4h 고정. 첫 주 예외·주말·연차면 null
 int? get todayShareMinutes;/// 이번 주 남은 시간 (오늘 진행분 제외). 0 이하면 이미 채움
 int? get weekRemainingBeforeToday; bool get isFirstWorkday; bool get isLastWorkday; int? get todayActual; int? get todayDelta; WeekSummary get week; List<DateTime> get unrecordedDays; DateTime? get firstRecordDate;
/// Create a copy of TodayState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodayStateCopyWith<TodayState> get copyWith => _$TodayStateCopyWithImpl<TodayState>(this as TodayState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TodayState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodayState&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.record, _this.record) || other.record == _this.record)&&(identical(other.phase, _this.phase) || other.phase == _this.phase)&&(identical(other.dayType, _this.dayType) || other.dayType == _this.dayType)&&(identical(other.isHalfDay, _this.isHalfDay) || other.isHalfDay == _this.isHalfDay)&&(identical(other.clockIn, _this.clockIn) || other.clockIn == _this.clockIn)&&(identical(other.clockOut, _this.clockOut) || other.clockOut == _this.clockOut)&&(identical(other.elapsedMinutes, _this.elapsedMinutes) || other.elapsedMinutes == _this.elapsedMinutes)&&(identical(other.expectedClockOut, _this.expectedClockOut) || other.expectedClockOut == _this.expectedClockOut)&&(identical(other.todayShareMinutes, _this.todayShareMinutes) || other.todayShareMinutes == _this.todayShareMinutes)&&(identical(other.weekRemainingBeforeToday, _this.weekRemainingBeforeToday) || other.weekRemainingBeforeToday == _this.weekRemainingBeforeToday)&&(identical(other.isFirstWorkday, _this.isFirstWorkday) || other.isFirstWorkday == _this.isFirstWorkday)&&(identical(other.isLastWorkday, _this.isLastWorkday) || other.isLastWorkday == _this.isLastWorkday)&&(identical(other.todayActual, _this.todayActual) || other.todayActual == _this.todayActual)&&(identical(other.todayDelta, _this.todayDelta) || other.todayDelta == _this.todayDelta)&&(identical(other.week, _this.week) || other.week == _this.week)&&const DeepCollectionEquality().equals(other.unrecordedDays, _this.unrecordedDays)&&(identical(other.firstRecordDate, _this.firstRecordDate) || other.firstRecordDate == _this.firstRecordDate));
}


@override
int get hashCode {
  final _this = this as TodayState;
  return Object.hash(runtimeType,_this.date,_this.record,_this.phase,_this.dayType,_this.isHalfDay,_this.clockIn,_this.clockOut,_this.elapsedMinutes,_this.expectedClockOut,_this.todayShareMinutes,_this.weekRemainingBeforeToday,_this.isFirstWorkday,_this.isLastWorkday,_this.todayActual,_this.todayDelta,_this.week,const DeepCollectionEquality().hash(_this.unrecordedDays),_this.firstRecordDate);
}

@override
String toString() {
  final _this = this as TodayState;
  return 'TodayState(date: ${_this.date}, record: ${_this.record}, phase: ${_this.phase}, dayType: ${_this.dayType}, isHalfDay: ${_this.isHalfDay}, clockIn: ${_this.clockIn}, clockOut: ${_this.clockOut}, elapsedMinutes: ${_this.elapsedMinutes}, expectedClockOut: ${_this.expectedClockOut}, todayShareMinutes: ${_this.todayShareMinutes}, weekRemainingBeforeToday: ${_this.weekRemainingBeforeToday}, isFirstWorkday: ${_this.isFirstWorkday}, isLastWorkday: ${_this.isLastWorkday}, todayActual: ${_this.todayActual}, todayDelta: ${_this.todayDelta}, week: ${_this.week}, unrecordedDays: ${_this.unrecordedDays}, firstRecordDate: ${_this.firstRecordDate})';
}


}

/// @nodoc
abstract mixin class $TodayStateCopyWith<$Res>  {
  factory $TodayStateCopyWith(TodayState value, $Res Function(TodayState) _then) = _$TodayStateCopyWithImpl;
@useResult
$Res call({
 DateTime date, WorkRecord? record, TodayPhase phase, WorkType? dayType, bool isHalfDay, DateTime? clockIn, DateTime? clockOut, int? elapsedMinutes, DateTime? expectedClockOut, int? todayShareMinutes, int? weekRemainingBeforeToday, bool isFirstWorkday, bool isLastWorkday, int? todayActual, int? todayDelta, WeekSummary week, List<DateTime> unrecordedDays, DateTime? firstRecordDate
});


$WorkRecordCopyWith<$Res>? get record;$WeekSummaryCopyWith<$Res> get week;

}
/// @nodoc
class _$TodayStateCopyWithImpl<$Res>
    implements $TodayStateCopyWith<$Res> {
  _$TodayStateCopyWithImpl(this._self, this._then);

  final TodayState _self;
  final $Res Function(TodayState) _then;

/// Create a copy of TodayState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? record = freezed,Object? phase = null,Object? dayType = freezed,Object? isHalfDay = null,Object? clockIn = freezed,Object? clockOut = freezed,Object? elapsedMinutes = freezed,Object? expectedClockOut = freezed,Object? todayShareMinutes = freezed,Object? weekRemainingBeforeToday = freezed,Object? isFirstWorkday = null,Object? isLastWorkday = null,Object? todayActual = freezed,Object? todayDelta = freezed,Object? week = null,Object? unrecordedDays = null,Object? firstRecordDate = freezed,}) {
  return _then(TodayState(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,record: freezed == record ? _self.record : record // ignore: cast_nullable_to_non_nullable
as WorkRecord?,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as TodayPhase,dayType: freezed == dayType ? _self.dayType : dayType // ignore: cast_nullable_to_non_nullable
as WorkType?,isHalfDay: null == isHalfDay ? _self.isHalfDay : isHalfDay // ignore: cast_nullable_to_non_nullable
as bool,clockIn: freezed == clockIn ? _self.clockIn : clockIn // ignore: cast_nullable_to_non_nullable
as DateTime?,clockOut: freezed == clockOut ? _self.clockOut : clockOut // ignore: cast_nullable_to_non_nullable
as DateTime?,elapsedMinutes: freezed == elapsedMinutes ? _self.elapsedMinutes : elapsedMinutes // ignore: cast_nullable_to_non_nullable
as int?,expectedClockOut: freezed == expectedClockOut ? _self.expectedClockOut : expectedClockOut // ignore: cast_nullable_to_non_nullable
as DateTime?,todayShareMinutes: freezed == todayShareMinutes ? _self.todayShareMinutes : todayShareMinutes // ignore: cast_nullable_to_non_nullable
as int?,weekRemainingBeforeToday: freezed == weekRemainingBeforeToday ? _self.weekRemainingBeforeToday : weekRemainingBeforeToday // ignore: cast_nullable_to_non_nullable
as int?,isFirstWorkday: null == isFirstWorkday ? _self.isFirstWorkday : isFirstWorkday // ignore: cast_nullable_to_non_nullable
as bool,isLastWorkday: null == isLastWorkday ? _self.isLastWorkday : isLastWorkday // ignore: cast_nullable_to_non_nullable
as bool,todayActual: freezed == todayActual ? _self.todayActual : todayActual // ignore: cast_nullable_to_non_nullable
as int?,todayDelta: freezed == todayDelta ? _self.todayDelta : todayDelta // ignore: cast_nullable_to_non_nullable
as int?,week: null == week ? _self.week : week // ignore: cast_nullable_to_non_nullable
as WeekSummary,unrecordedDays: null == unrecordedDays ? _self.unrecordedDays : unrecordedDays // ignore: cast_nullable_to_non_nullable
as List<DateTime>,firstRecordDate: freezed == firstRecordDate ? _self.firstRecordDate : firstRecordDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of TodayState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WorkRecordCopyWith<$Res>? get record {
    if (_self.record == null) {
    return null;
  }

  return $WorkRecordCopyWith<$Res>(_self.record!, (value) {
    return _then(_self.copyWith(record: value));
  });
}/// Create a copy of TodayState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WeekSummaryCopyWith<$Res> get week {
  
  return $WeekSummaryCopyWith<$Res>(_self.week, (value) {
    return _then(_self.copyWith(week: value));
  });
}
}


/// Adds pattern-matching-related methods to [TodayState].
extension TodayStatePatterns on TodayState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TodayState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TodayState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TodayState value)  $default,){
final _that = this;
switch (_that) {
case _TodayState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TodayState value)?  $default,){
final _that = this;
switch (_that) {
case _TodayState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  WorkRecord? record,  TodayPhase phase,  WorkType? dayType,  bool isHalfDay,  DateTime? clockIn,  DateTime? clockOut,  int? elapsedMinutes,  DateTime? expectedClockOut,  int? todayShareMinutes,  int? weekRemainingBeforeToday,  bool isFirstWorkday,  bool isLastWorkday,  int? todayActual,  int? todayDelta,  WeekSummary week,  List<DateTime> unrecordedDays,  DateTime? firstRecordDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TodayState() when $default != null:
return $default(_that.date,_that.record,_that.phase,_that.dayType,_that.isHalfDay,_that.clockIn,_that.clockOut,_that.elapsedMinutes,_that.expectedClockOut,_that.todayShareMinutes,_that.weekRemainingBeforeToday,_that.isFirstWorkday,_that.isLastWorkday,_that.todayActual,_that.todayDelta,_that.week,_that.unrecordedDays,_that.firstRecordDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  WorkRecord? record,  TodayPhase phase,  WorkType? dayType,  bool isHalfDay,  DateTime? clockIn,  DateTime? clockOut,  int? elapsedMinutes,  DateTime? expectedClockOut,  int? todayShareMinutes,  int? weekRemainingBeforeToday,  bool isFirstWorkday,  bool isLastWorkday,  int? todayActual,  int? todayDelta,  WeekSummary week,  List<DateTime> unrecordedDays,  DateTime? firstRecordDate)  $default,) {final _that = this;
switch (_that) {
case _TodayState():
return $default(_that.date,_that.record,_that.phase,_that.dayType,_that.isHalfDay,_that.clockIn,_that.clockOut,_that.elapsedMinutes,_that.expectedClockOut,_that.todayShareMinutes,_that.weekRemainingBeforeToday,_that.isFirstWorkday,_that.isLastWorkday,_that.todayActual,_that.todayDelta,_that.week,_that.unrecordedDays,_that.firstRecordDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  WorkRecord? record,  TodayPhase phase,  WorkType? dayType,  bool isHalfDay,  DateTime? clockIn,  DateTime? clockOut,  int? elapsedMinutes,  DateTime? expectedClockOut,  int? todayShareMinutes,  int? weekRemainingBeforeToday,  bool isFirstWorkday,  bool isLastWorkday,  int? todayActual,  int? todayDelta,  WeekSummary week,  List<DateTime> unrecordedDays,  DateTime? firstRecordDate)?  $default,) {final _that = this;
switch (_that) {
case _TodayState() when $default != null:
return $default(_that.date,_that.record,_that.phase,_that.dayType,_that.isHalfDay,_that.clockIn,_that.clockOut,_that.elapsedMinutes,_that.expectedClockOut,_that.todayShareMinutes,_that.weekRemainingBeforeToday,_that.isFirstWorkday,_that.isLastWorkday,_that.todayActual,_that.todayDelta,_that.week,_that.unrecordedDays,_that.firstRecordDate);case _:
  return null;

}
}

}

/// @nodoc


class _TodayState extends TodayState {
  const _TodayState({required this.date, this.record, required this.phase, this.dayType, required this.isHalfDay, this.clockIn, this.clockOut, this.elapsedMinutes, this.expectedClockOut, this.todayShareMinutes, this.weekRemainingBeforeToday, required this.isFirstWorkday, required this.isLastWorkday, this.todayActual, this.todayDelta, required this.week, required  List<DateTime> unrecordedDays, this.firstRecordDate}): _unrecordedDays = unrecordedDays,super._();
  

@override final  DateTime date;
@override final  WorkRecord? record;
@override final  TodayPhase phase;
@override final  WorkType? dayType;
@override final  bool isHalfDay;
@override final  DateTime? clockIn;
@override final  DateTime? clockOut;
/// working일 때 now − clockIn (점심 미공제)
@override final  int? elapsedMinutes;
/// working일 때만. 첫 주 예외·주말·연차·이미 채움이면 null
@override final  DateTime? expectedClockOut;
/// 출근 전·근무 중일 때 오늘 몫 (남은 시간 ÷ 남은 근무일). 반차는 4h 고정. 첫 주 예외·주말·연차면 null
@override final  int? todayShareMinutes;
/// 이번 주 남은 시간 (오늘 진행분 제외). 0 이하면 이미 채움
@override final  int? weekRemainingBeforeToday;
@override final  bool isFirstWorkday;
@override final  bool isLastWorkday;
@override final  int? todayActual;
@override final  int? todayDelta;
@override final  WeekSummary week;
 final  List<DateTime> _unrecordedDays;
@override List<DateTime> get unrecordedDays {
  if (_unrecordedDays is EqualUnmodifiableListView) return _unrecordedDays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_unrecordedDays);
}

@override final  DateTime? firstRecordDate;

/// Create a copy of TodayState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TodayStateCopyWith<_TodayState> get copyWith => __$TodayStateCopyWithImpl<_TodayState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TodayState&&(identical(other.date, date) || other.date == date)&&(identical(other.record, record) || other.record == record)&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.dayType, dayType) || other.dayType == dayType)&&(identical(other.isHalfDay, isHalfDay) || other.isHalfDay == isHalfDay)&&(identical(other.clockIn, clockIn) || other.clockIn == clockIn)&&(identical(other.clockOut, clockOut) || other.clockOut == clockOut)&&(identical(other.elapsedMinutes, elapsedMinutes) || other.elapsedMinutes == elapsedMinutes)&&(identical(other.expectedClockOut, expectedClockOut) || other.expectedClockOut == expectedClockOut)&&(identical(other.todayShareMinutes, todayShareMinutes) || other.todayShareMinutes == todayShareMinutes)&&(identical(other.weekRemainingBeforeToday, weekRemainingBeforeToday) || other.weekRemainingBeforeToday == weekRemainingBeforeToday)&&(identical(other.isFirstWorkday, isFirstWorkday) || other.isFirstWorkday == isFirstWorkday)&&(identical(other.isLastWorkday, isLastWorkday) || other.isLastWorkday == isLastWorkday)&&(identical(other.todayActual, todayActual) || other.todayActual == todayActual)&&(identical(other.todayDelta, todayDelta) || other.todayDelta == todayDelta)&&(identical(other.week, week) || other.week == week)&&const DeepCollectionEquality().equals(other.unrecordedDays, _unrecordedDays)&&(identical(other.firstRecordDate, firstRecordDate) || other.firstRecordDate == firstRecordDate));
}


@override
int get hashCode {
    return Object.hash(runtimeType,date,record,phase,dayType,isHalfDay,clockIn,clockOut,elapsedMinutes,expectedClockOut,todayShareMinutes,weekRemainingBeforeToday,isFirstWorkday,isLastWorkday,todayActual,todayDelta,week,const DeepCollectionEquality().hash(_unrecordedDays),firstRecordDate);
}

@override
String toString() {
    return 'TodayState(date: $date, record: $record, phase: $phase, dayType: $dayType, isHalfDay: $isHalfDay, clockIn: $clockIn, clockOut: $clockOut, elapsedMinutes: $elapsedMinutes, expectedClockOut: $expectedClockOut, todayShareMinutes: $todayShareMinutes, weekRemainingBeforeToday: $weekRemainingBeforeToday, isFirstWorkday: $isFirstWorkday, isLastWorkday: $isLastWorkday, todayActual: $todayActual, todayDelta: $todayDelta, week: $week, unrecordedDays: $unrecordedDays, firstRecordDate: $firstRecordDate)';
}


}

/// @nodoc
abstract mixin class _$TodayStateCopyWith<$Res> implements $TodayStateCopyWith<$Res> {
  factory _$TodayStateCopyWith(_TodayState value, $Res Function(_TodayState) _then) = __$TodayStateCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, WorkRecord? record, TodayPhase phase, WorkType? dayType, bool isHalfDay, DateTime? clockIn, DateTime? clockOut, int? elapsedMinutes, DateTime? expectedClockOut, int? todayShareMinutes, int? weekRemainingBeforeToday, bool isFirstWorkday, bool isLastWorkday, int? todayActual, int? todayDelta, WeekSummary week, List<DateTime> unrecordedDays, DateTime? firstRecordDate
});


@override $WorkRecordCopyWith<$Res>? get record;@override $WeekSummaryCopyWith<$Res> get week;

}
/// @nodoc
class __$TodayStateCopyWithImpl<$Res>
    implements _$TodayStateCopyWith<$Res> {
  __$TodayStateCopyWithImpl(this._self, this._then);

  final _TodayState _self;
  final $Res Function(_TodayState) _then;

/// Create a copy of TodayState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? record = freezed,Object? phase = null,Object? dayType = freezed,Object? isHalfDay = null,Object? clockIn = freezed,Object? clockOut = freezed,Object? elapsedMinutes = freezed,Object? expectedClockOut = freezed,Object? todayShareMinutes = freezed,Object? weekRemainingBeforeToday = freezed,Object? isFirstWorkday = null,Object? isLastWorkday = null,Object? todayActual = freezed,Object? todayDelta = freezed,Object? week = null,Object? unrecordedDays = null,Object? firstRecordDate = freezed,}) {
  return _then(_TodayState(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,record: freezed == record ? _self.record : record // ignore: cast_nullable_to_non_nullable
as WorkRecord?,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as TodayPhase,dayType: freezed == dayType ? _self.dayType : dayType // ignore: cast_nullable_to_non_nullable
as WorkType?,isHalfDay: null == isHalfDay ? _self.isHalfDay : isHalfDay // ignore: cast_nullable_to_non_nullable
as bool,clockIn: freezed == clockIn ? _self.clockIn : clockIn // ignore: cast_nullable_to_non_nullable
as DateTime?,clockOut: freezed == clockOut ? _self.clockOut : clockOut // ignore: cast_nullable_to_non_nullable
as DateTime?,elapsedMinutes: freezed == elapsedMinutes ? _self.elapsedMinutes : elapsedMinutes // ignore: cast_nullable_to_non_nullable
as int?,expectedClockOut: freezed == expectedClockOut ? _self.expectedClockOut : expectedClockOut // ignore: cast_nullable_to_non_nullable
as DateTime?,todayShareMinutes: freezed == todayShareMinutes ? _self.todayShareMinutes : todayShareMinutes // ignore: cast_nullable_to_non_nullable
as int?,weekRemainingBeforeToday: freezed == weekRemainingBeforeToday ? _self.weekRemainingBeforeToday : weekRemainingBeforeToday // ignore: cast_nullable_to_non_nullable
as int?,isFirstWorkday: null == isFirstWorkday ? _self.isFirstWorkday : isFirstWorkday // ignore: cast_nullable_to_non_nullable
as bool,isLastWorkday: null == isLastWorkday ? _self.isLastWorkday : isLastWorkday // ignore: cast_nullable_to_non_nullable
as bool,todayActual: freezed == todayActual ? _self.todayActual : todayActual // ignore: cast_nullable_to_non_nullable
as int?,todayDelta: freezed == todayDelta ? _self.todayDelta : todayDelta // ignore: cast_nullable_to_non_nullable
as int?,week: null == week ? _self.week : week // ignore: cast_nullable_to_non_nullable
as WeekSummary,unrecordedDays: null == unrecordedDays ? _self._unrecordedDays : unrecordedDays // ignore: cast_nullable_to_non_nullable
as List<DateTime>,firstRecordDate: freezed == firstRecordDate ? _self.firstRecordDate : firstRecordDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of TodayState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WorkRecordCopyWith<$Res>? get record {
    if (_self.record == null) {
    return null;
  }

  return $WorkRecordCopyWith<$Res>(_self.record!, (value) {
    return _then(_self.copyWith(record: value));
  });
}/// Create a copy of TodayState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WeekSummaryCopyWith<$Res> get week {
  
  return $WeekSummaryCopyWith<$Res>(_self.week, (value) {
    return _then(_self.copyWith(week: value));
  });
}
}

// dart format on

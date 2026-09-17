// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'week_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WeekDay {

 DateTime get date; WorkRecord? get record; WeekDayKind get kind; int? get actualMinutes; int? get deltaMinutes; bool get isToday;/// 오늘인데 출퇴근이 덜 찍힘 — 탭해도 시트 대신 안내만.
 bool get isTodayInProgress;
/// Create a copy of WeekDay
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeekDayCopyWith<WeekDay> get copyWith => _$WeekDayCopyWithImpl<WeekDay>(this as WeekDay, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as WeekDay;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeekDay&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.record, _this.record) || other.record == _this.record)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.actualMinutes, _this.actualMinutes) || other.actualMinutes == _this.actualMinutes)&&(identical(other.deltaMinutes, _this.deltaMinutes) || other.deltaMinutes == _this.deltaMinutes)&&(identical(other.isToday, _this.isToday) || other.isToday == _this.isToday)&&(identical(other.isTodayInProgress, _this.isTodayInProgress) || other.isTodayInProgress == _this.isTodayInProgress));
}


@override
int get hashCode {
  final _this = this as WeekDay;
  return Object.hash(runtimeType,_this.date,_this.record,_this.kind,_this.actualMinutes,_this.deltaMinutes,_this.isToday,_this.isTodayInProgress);
}

@override
String toString() {
  final _this = this as WeekDay;
  return 'WeekDay(date: ${_this.date}, record: ${_this.record}, kind: ${_this.kind}, actualMinutes: ${_this.actualMinutes}, deltaMinutes: ${_this.deltaMinutes}, isToday: ${_this.isToday}, isTodayInProgress: ${_this.isTodayInProgress})';
}


}

/// @nodoc
abstract mixin class $WeekDayCopyWith<$Res>  {
  factory $WeekDayCopyWith(WeekDay value, $Res Function(WeekDay) _then) = _$WeekDayCopyWithImpl;
@useResult
$Res call({
 DateTime date, WorkRecord? record, WeekDayKind kind, int? actualMinutes, int? deltaMinutes, bool isToday, bool isTodayInProgress
});


$WorkRecordCopyWith<$Res>? get record;

}
/// @nodoc
class _$WeekDayCopyWithImpl<$Res>
    implements $WeekDayCopyWith<$Res> {
  _$WeekDayCopyWithImpl(this._self, this._then);

  final WeekDay _self;
  final $Res Function(WeekDay) _then;

/// Create a copy of WeekDay
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? record = freezed,Object? kind = null,Object? actualMinutes = freezed,Object? deltaMinutes = freezed,Object? isToday = null,Object? isTodayInProgress = null,}) {
  return _then(WeekDay(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,record: freezed == record ? _self.record : record // ignore: cast_nullable_to_non_nullable
as WorkRecord?,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as WeekDayKind,actualMinutes: freezed == actualMinutes ? _self.actualMinutes : actualMinutes // ignore: cast_nullable_to_non_nullable
as int?,deltaMinutes: freezed == deltaMinutes ? _self.deltaMinutes : deltaMinutes // ignore: cast_nullable_to_non_nullable
as int?,isToday: null == isToday ? _self.isToday : isToday // ignore: cast_nullable_to_non_nullable
as bool,isTodayInProgress: null == isTodayInProgress ? _self.isTodayInProgress : isTodayInProgress // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of WeekDay
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
}
}


/// Adds pattern-matching-related methods to [WeekDay].
extension WeekDayPatterns on WeekDay {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WeekDay value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WeekDay() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WeekDay value)  $default,){
final _that = this;
switch (_that) {
case _WeekDay():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WeekDay value)?  $default,){
final _that = this;
switch (_that) {
case _WeekDay() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  WorkRecord? record,  WeekDayKind kind,  int? actualMinutes,  int? deltaMinutes,  bool isToday,  bool isTodayInProgress)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeekDay() when $default != null:
return $default(_that.date,_that.record,_that.kind,_that.actualMinutes,_that.deltaMinutes,_that.isToday,_that.isTodayInProgress);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  WorkRecord? record,  WeekDayKind kind,  int? actualMinutes,  int? deltaMinutes,  bool isToday,  bool isTodayInProgress)  $default,) {final _that = this;
switch (_that) {
case _WeekDay():
return $default(_that.date,_that.record,_that.kind,_that.actualMinutes,_that.deltaMinutes,_that.isToday,_that.isTodayInProgress);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  WorkRecord? record,  WeekDayKind kind,  int? actualMinutes,  int? deltaMinutes,  bool isToday,  bool isTodayInProgress)?  $default,) {final _that = this;
switch (_that) {
case _WeekDay() when $default != null:
return $default(_that.date,_that.record,_that.kind,_that.actualMinutes,_that.deltaMinutes,_that.isToday,_that.isTodayInProgress);case _:
  return null;

}
}

}

/// @nodoc


class _WeekDay implements WeekDay {
  const _WeekDay({required this.date, this.record, required this.kind, this.actualMinutes, this.deltaMinutes, required this.isToday, required this.isTodayInProgress});
  

@override final  DateTime date;
@override final  WorkRecord? record;
@override final  WeekDayKind kind;
@override final  int? actualMinutes;
@override final  int? deltaMinutes;
@override final  bool isToday;
/// 오늘인데 출퇴근이 덜 찍힘 — 탭해도 시트 대신 안내만.
@override final  bool isTodayInProgress;

/// Create a copy of WeekDay
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeekDayCopyWith<_WeekDay> get copyWith => __$WeekDayCopyWithImpl<_WeekDay>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeekDay&&(identical(other.date, date) || other.date == date)&&(identical(other.record, record) || other.record == record)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.actualMinutes, actualMinutes) || other.actualMinutes == actualMinutes)&&(identical(other.deltaMinutes, deltaMinutes) || other.deltaMinutes == deltaMinutes)&&(identical(other.isToday, isToday) || other.isToday == isToday)&&(identical(other.isTodayInProgress, isTodayInProgress) || other.isTodayInProgress == isTodayInProgress));
}


@override
int get hashCode {
    return Object.hash(runtimeType,date,record,kind,actualMinutes,deltaMinutes,isToday,isTodayInProgress);
}

@override
String toString() {
    return 'WeekDay(date: $date, record: $record, kind: $kind, actualMinutes: $actualMinutes, deltaMinutes: $deltaMinutes, isToday: $isToday, isTodayInProgress: $isTodayInProgress)';
}


}

/// @nodoc
abstract mixin class _$WeekDayCopyWith<$Res> implements $WeekDayCopyWith<$Res> {
  factory _$WeekDayCopyWith(_WeekDay value, $Res Function(_WeekDay) _then) = __$WeekDayCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, WorkRecord? record, WeekDayKind kind, int? actualMinutes, int? deltaMinutes, bool isToday, bool isTodayInProgress
});


@override $WorkRecordCopyWith<$Res>? get record;

}
/// @nodoc
class __$WeekDayCopyWithImpl<$Res>
    implements _$WeekDayCopyWith<$Res> {
  __$WeekDayCopyWithImpl(this._self, this._then);

  final _WeekDay _self;
  final $Res Function(_WeekDay) _then;

/// Create a copy of WeekDay
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? record = freezed,Object? kind = null,Object? actualMinutes = freezed,Object? deltaMinutes = freezed,Object? isToday = null,Object? isTodayInProgress = null,}) {
  return _then(_WeekDay(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,record: freezed == record ? _self.record : record // ignore: cast_nullable_to_non_nullable
as WorkRecord?,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as WeekDayKind,actualMinutes: freezed == actualMinutes ? _self.actualMinutes : actualMinutes // ignore: cast_nullable_to_non_nullable
as int?,deltaMinutes: freezed == deltaMinutes ? _self.deltaMinutes : deltaMinutes // ignore: cast_nullable_to_non_nullable
as int?,isToday: null == isToday ? _self.isToday : isToday // ignore: cast_nullable_to_non_nullable
as bool,isTodayInProgress: null == isTodayInProgress ? _self.isTodayInProgress : isTodayInProgress // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of WeekDay
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
}
}

/// @nodoc
mixin _$WeekState {

 DateTime get monday; bool get isCurrentWeek; bool get canGoPrev; bool get canGoNext; WeekSummary get summary; int get weekendMinutes; List<WeekDay> get days; DateTime? get firstRecordDate;
/// Create a copy of WeekState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeekStateCopyWith<WeekState> get copyWith => _$WeekStateCopyWithImpl<WeekState>(this as WeekState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as WeekState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeekState&&(identical(other.monday, _this.monday) || other.monday == _this.monday)&&(identical(other.isCurrentWeek, _this.isCurrentWeek) || other.isCurrentWeek == _this.isCurrentWeek)&&(identical(other.canGoPrev, _this.canGoPrev) || other.canGoPrev == _this.canGoPrev)&&(identical(other.canGoNext, _this.canGoNext) || other.canGoNext == _this.canGoNext)&&(identical(other.summary, _this.summary) || other.summary == _this.summary)&&(identical(other.weekendMinutes, _this.weekendMinutes) || other.weekendMinutes == _this.weekendMinutes)&&const DeepCollectionEquality().equals(other.days, _this.days)&&(identical(other.firstRecordDate, _this.firstRecordDate) || other.firstRecordDate == _this.firstRecordDate));
}


@override
int get hashCode {
  final _this = this as WeekState;
  return Object.hash(runtimeType,_this.monday,_this.isCurrentWeek,_this.canGoPrev,_this.canGoNext,_this.summary,_this.weekendMinutes,const DeepCollectionEquality().hash(_this.days),_this.firstRecordDate);
}

@override
String toString() {
  final _this = this as WeekState;
  return 'WeekState(monday: ${_this.monday}, isCurrentWeek: ${_this.isCurrentWeek}, canGoPrev: ${_this.canGoPrev}, canGoNext: ${_this.canGoNext}, summary: ${_this.summary}, weekendMinutes: ${_this.weekendMinutes}, days: ${_this.days}, firstRecordDate: ${_this.firstRecordDate})';
}


}

/// @nodoc
abstract mixin class $WeekStateCopyWith<$Res>  {
  factory $WeekStateCopyWith(WeekState value, $Res Function(WeekState) _then) = _$WeekStateCopyWithImpl;
@useResult
$Res call({
 DateTime monday, bool isCurrentWeek, bool canGoPrev, bool canGoNext, WeekSummary summary, int weekendMinutes, List<WeekDay> days, DateTime? firstRecordDate
});


$WeekSummaryCopyWith<$Res> get summary;

}
/// @nodoc
class _$WeekStateCopyWithImpl<$Res>
    implements $WeekStateCopyWith<$Res> {
  _$WeekStateCopyWithImpl(this._self, this._then);

  final WeekState _self;
  final $Res Function(WeekState) _then;

/// Create a copy of WeekState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? monday = null,Object? isCurrentWeek = null,Object? canGoPrev = null,Object? canGoNext = null,Object? summary = null,Object? weekendMinutes = null,Object? days = null,Object? firstRecordDate = freezed,}) {
  return _then(WeekState(
monday: null == monday ? _self.monday : monday // ignore: cast_nullable_to_non_nullable
as DateTime,isCurrentWeek: null == isCurrentWeek ? _self.isCurrentWeek : isCurrentWeek // ignore: cast_nullable_to_non_nullable
as bool,canGoPrev: null == canGoPrev ? _self.canGoPrev : canGoPrev // ignore: cast_nullable_to_non_nullable
as bool,canGoNext: null == canGoNext ? _self.canGoNext : canGoNext // ignore: cast_nullable_to_non_nullable
as bool,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as WeekSummary,weekendMinutes: null == weekendMinutes ? _self.weekendMinutes : weekendMinutes // ignore: cast_nullable_to_non_nullable
as int,days: null == days ? _self.days : days // ignore: cast_nullable_to_non_nullable
as List<WeekDay>,firstRecordDate: freezed == firstRecordDate ? _self.firstRecordDate : firstRecordDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of WeekState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WeekSummaryCopyWith<$Res> get summary {
  
  return $WeekSummaryCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}


/// Adds pattern-matching-related methods to [WeekState].
extension WeekStatePatterns on WeekState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WeekState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WeekState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WeekState value)  $default,){
final _that = this;
switch (_that) {
case _WeekState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WeekState value)?  $default,){
final _that = this;
switch (_that) {
case _WeekState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime monday,  bool isCurrentWeek,  bool canGoPrev,  bool canGoNext,  WeekSummary summary,  int weekendMinutes,  List<WeekDay> days,  DateTime? firstRecordDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeekState() when $default != null:
return $default(_that.monday,_that.isCurrentWeek,_that.canGoPrev,_that.canGoNext,_that.summary,_that.weekendMinutes,_that.days,_that.firstRecordDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime monday,  bool isCurrentWeek,  bool canGoPrev,  bool canGoNext,  WeekSummary summary,  int weekendMinutes,  List<WeekDay> days,  DateTime? firstRecordDate)  $default,) {final _that = this;
switch (_that) {
case _WeekState():
return $default(_that.monday,_that.isCurrentWeek,_that.canGoPrev,_that.canGoNext,_that.summary,_that.weekendMinutes,_that.days,_that.firstRecordDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime monday,  bool isCurrentWeek,  bool canGoPrev,  bool canGoNext,  WeekSummary summary,  int weekendMinutes,  List<WeekDay> days,  DateTime? firstRecordDate)?  $default,) {final _that = this;
switch (_that) {
case _WeekState() when $default != null:
return $default(_that.monday,_that.isCurrentWeek,_that.canGoPrev,_that.canGoNext,_that.summary,_that.weekendMinutes,_that.days,_that.firstRecordDate);case _:
  return null;

}
}

}

/// @nodoc


class _WeekState implements WeekState {
  const _WeekState({required this.monday, required this.isCurrentWeek, required this.canGoPrev, required this.canGoNext, required this.summary, required this.weekendMinutes, required  List<WeekDay> days, this.firstRecordDate}): _days = days;
  

@override final  DateTime monday;
@override final  bool isCurrentWeek;
@override final  bool canGoPrev;
@override final  bool canGoNext;
@override final  WeekSummary summary;
@override final  int weekendMinutes;
 final  List<WeekDay> _days;
@override List<WeekDay> get days {
  if (_days is EqualUnmodifiableListView) return _days;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_days);
}

@override final  DateTime? firstRecordDate;

/// Create a copy of WeekState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeekStateCopyWith<_WeekState> get copyWith => __$WeekStateCopyWithImpl<_WeekState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeekState&&(identical(other.monday, monday) || other.monday == monday)&&(identical(other.isCurrentWeek, isCurrentWeek) || other.isCurrentWeek == isCurrentWeek)&&(identical(other.canGoPrev, canGoPrev) || other.canGoPrev == canGoPrev)&&(identical(other.canGoNext, canGoNext) || other.canGoNext == canGoNext)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.weekendMinutes, weekendMinutes) || other.weekendMinutes == weekendMinutes)&&const DeepCollectionEquality().equals(other.days, _days)&&(identical(other.firstRecordDate, firstRecordDate) || other.firstRecordDate == firstRecordDate));
}


@override
int get hashCode {
    return Object.hash(runtimeType,monday,isCurrentWeek,canGoPrev,canGoNext,summary,weekendMinutes,const DeepCollectionEquality().hash(_days),firstRecordDate);
}

@override
String toString() {
    return 'WeekState(monday: $monday, isCurrentWeek: $isCurrentWeek, canGoPrev: $canGoPrev, canGoNext: $canGoNext, summary: $summary, weekendMinutes: $weekendMinutes, days: $days, firstRecordDate: $firstRecordDate)';
}


}

/// @nodoc
abstract mixin class _$WeekStateCopyWith<$Res> implements $WeekStateCopyWith<$Res> {
  factory _$WeekStateCopyWith(_WeekState value, $Res Function(_WeekState) _then) = __$WeekStateCopyWithImpl;
@override @useResult
$Res call({
 DateTime monday, bool isCurrentWeek, bool canGoPrev, bool canGoNext, WeekSummary summary, int weekendMinutes, List<WeekDay> days, DateTime? firstRecordDate
});


@override $WeekSummaryCopyWith<$Res> get summary;

}
/// @nodoc
class __$WeekStateCopyWithImpl<$Res>
    implements _$WeekStateCopyWith<$Res> {
  __$WeekStateCopyWithImpl(this._self, this._then);

  final _WeekState _self;
  final $Res Function(_WeekState) _then;

/// Create a copy of WeekState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? monday = null,Object? isCurrentWeek = null,Object? canGoPrev = null,Object? canGoNext = null,Object? summary = null,Object? weekendMinutes = null,Object? days = null,Object? firstRecordDate = freezed,}) {
  return _then(_WeekState(
monday: null == monday ? _self.monday : monday // ignore: cast_nullable_to_non_nullable
as DateTime,isCurrentWeek: null == isCurrentWeek ? _self.isCurrentWeek : isCurrentWeek // ignore: cast_nullable_to_non_nullable
as bool,canGoPrev: null == canGoPrev ? _self.canGoPrev : canGoPrev // ignore: cast_nullable_to_non_nullable
as bool,canGoNext: null == canGoNext ? _self.canGoNext : canGoNext // ignore: cast_nullable_to_non_nullable
as bool,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as WeekSummary,weekendMinutes: null == weekendMinutes ? _self.weekendMinutes : weekendMinutes // ignore: cast_nullable_to_non_nullable
as int,days: null == days ? _self._days : days // ignore: cast_nullable_to_non_nullable
as List<WeekDay>,firstRecordDate: freezed == firstRecordDate ? _self.firstRecordDate : firstRecordDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of WeekState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WeekSummaryCopyWith<$Res> get summary {
  
  return $WeekSummaryCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}

// dart format on

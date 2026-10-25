// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'month_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MonthCellValue {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthCellValue);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'MonthCellValue()';
}


}

/// @nodoc
class $MonthCellValueCopyWith<$Res>  {
$MonthCellValueCopyWith(MonthCellValue _, $Res Function(MonthCellValue) __);
}


/// Adds pattern-matching-related methods to [MonthCellValue].
extension MonthCellValuePatterns on MonthCellValue {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( MonthCellNone value)?  none,TResult Function( MonthCellDelta value)?  delta,TResult Function( MonthCellWeekendActual value)?  weekendActual,TResult Function( MonthCellWorking value)?  working,TResult Function( MonthCellUnrecorded value)?  unrecorded,required TResult orElse(),}){
final _that = this;
switch (_that) {
case MonthCellNone() when none != null:
return none(_that);case MonthCellDelta() when delta != null:
return delta(_that);case MonthCellWeekendActual() when weekendActual != null:
return weekendActual(_that);case MonthCellWorking() when working != null:
return working(_that);case MonthCellUnrecorded() when unrecorded != null:
return unrecorded(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( MonthCellNone value)  none,required TResult Function( MonthCellDelta value)  delta,required TResult Function( MonthCellWeekendActual value)  weekendActual,required TResult Function( MonthCellWorking value)  working,required TResult Function( MonthCellUnrecorded value)  unrecorded,}){
final _that = this;
switch (_that) {
case MonthCellNone():
return none(_that);case MonthCellDelta():
return delta(_that);case MonthCellWeekendActual():
return weekendActual(_that);case MonthCellWorking():
return working(_that);case MonthCellUnrecorded():
return unrecorded(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( MonthCellNone value)?  none,TResult? Function( MonthCellDelta value)?  delta,TResult? Function( MonthCellWeekendActual value)?  weekendActual,TResult? Function( MonthCellWorking value)?  working,TResult? Function( MonthCellUnrecorded value)?  unrecorded,}){
final _that = this;
switch (_that) {
case MonthCellNone() when none != null:
return none(_that);case MonthCellDelta() when delta != null:
return delta(_that);case MonthCellWeekendActual() when weekendActual != null:
return weekendActual(_that);case MonthCellWorking() when working != null:
return working(_that);case MonthCellUnrecorded() when unrecorded != null:
return unrecorded(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  none,TResult Function( int minutes)?  delta,TResult Function( int minutes)?  weekendActual,TResult Function()?  working,TResult Function()?  unrecorded,required TResult orElse(),}) {final _that = this;
switch (_that) {
case MonthCellNone() when none != null:
return none();case MonthCellDelta() when delta != null:
return delta(_that.minutes);case MonthCellWeekendActual() when weekendActual != null:
return weekendActual(_that.minutes);case MonthCellWorking() when working != null:
return working();case MonthCellUnrecorded() when unrecorded != null:
return unrecorded();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  none,required TResult Function( int minutes)  delta,required TResult Function( int minutes)  weekendActual,required TResult Function()  working,required TResult Function()  unrecorded,}) {final _that = this;
switch (_that) {
case MonthCellNone():
return none();case MonthCellDelta():
return delta(_that.minutes);case MonthCellWeekendActual():
return weekendActual(_that.minutes);case MonthCellWorking():
return working();case MonthCellUnrecorded():
return unrecorded();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  none,TResult? Function( int minutes)?  delta,TResult? Function( int minutes)?  weekendActual,TResult? Function()?  working,TResult? Function()?  unrecorded,}) {final _that = this;
switch (_that) {
case MonthCellNone() when none != null:
return none();case MonthCellDelta() when delta != null:
return delta(_that.minutes);case MonthCellWeekendActual() when weekendActual != null:
return weekendActual(_that.minutes);case MonthCellWorking() when working != null:
return working();case MonthCellUnrecorded() when unrecorded != null:
return unrecorded();case _:
  return null;

}
}

}

/// @nodoc


class MonthCellNone implements MonthCellValue {
  const MonthCellNone();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthCellNone);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'MonthCellValue.none()';
}


}




/// @nodoc


class MonthCellDelta implements MonthCellValue {
  const MonthCellDelta(this.minutes);
  

 final  int minutes;

/// Create a copy of MonthCellValue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MonthCellDeltaCopyWith<MonthCellDelta> get copyWith => _$MonthCellDeltaCopyWithImpl<MonthCellDelta>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthCellDelta&&(identical(other.minutes, minutes) || other.minutes == minutes));
}


@override
int get hashCode {
    return Object.hash(runtimeType,minutes);
}

@override
String toString() {
    return 'MonthCellValue.delta(minutes: $minutes)';
}


}

/// @nodoc
abstract mixin class $MonthCellDeltaCopyWith<$Res> implements $MonthCellValueCopyWith<$Res> {
  factory $MonthCellDeltaCopyWith(MonthCellDelta value, $Res Function(MonthCellDelta) _then) = _$MonthCellDeltaCopyWithImpl;
@useResult
$Res call({
 int minutes
});




}
/// @nodoc
class _$MonthCellDeltaCopyWithImpl<$Res>
    implements $MonthCellDeltaCopyWith<$Res> {
  _$MonthCellDeltaCopyWithImpl(this._self, this._then);

  final MonthCellDelta _self;
  final $Res Function(MonthCellDelta) _then;

/// Create a copy of MonthCellValue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? minutes = null,}) {
  return _then(MonthCellDelta(
null == minutes ? _self.minutes : minutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class MonthCellWeekendActual implements MonthCellValue {
  const MonthCellWeekendActual(this.minutes);
  

 final  int minutes;

/// Create a copy of MonthCellValue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MonthCellWeekendActualCopyWith<MonthCellWeekendActual> get copyWith => _$MonthCellWeekendActualCopyWithImpl<MonthCellWeekendActual>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthCellWeekendActual&&(identical(other.minutes, minutes) || other.minutes == minutes));
}


@override
int get hashCode {
    return Object.hash(runtimeType,minutes);
}

@override
String toString() {
    return 'MonthCellValue.weekendActual(minutes: $minutes)';
}


}

/// @nodoc
abstract mixin class $MonthCellWeekendActualCopyWith<$Res> implements $MonthCellValueCopyWith<$Res> {
  factory $MonthCellWeekendActualCopyWith(MonthCellWeekendActual value, $Res Function(MonthCellWeekendActual) _then) = _$MonthCellWeekendActualCopyWithImpl;
@useResult
$Res call({
 int minutes
});




}
/// @nodoc
class _$MonthCellWeekendActualCopyWithImpl<$Res>
    implements $MonthCellWeekendActualCopyWith<$Res> {
  _$MonthCellWeekendActualCopyWithImpl(this._self, this._then);

  final MonthCellWeekendActual _self;
  final $Res Function(MonthCellWeekendActual) _then;

/// Create a copy of MonthCellValue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? minutes = null,}) {
  return _then(MonthCellWeekendActual(
null == minutes ? _self.minutes : minutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class MonthCellWorking implements MonthCellValue {
  const MonthCellWorking();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthCellWorking);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'MonthCellValue.working()';
}


}




/// @nodoc


class MonthCellUnrecorded implements MonthCellValue {
  const MonthCellUnrecorded();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthCellUnrecorded);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'MonthCellValue.unrecorded()';
}


}




/// @nodoc
mixin _$MonthCell {

 DateTime get date; bool get isCurrentMonth; bool get isToday;/// 오늘 근무 중(출근만 찍힘) — 탭해도 시트 대신 안내만.
 bool get isTodayWorking; bool get isWeekend; bool get isFuture;/// 첫 기록 주의 월요일보다 앞 — 앱 설치 전. 흐리게만 보이고 탭해도 열리지 않는다.
 bool get isBeforeFirstWeek;/// 배지. normal이면 null
 WorkType? get type; MonthCellValue get value;
/// Create a copy of MonthCell
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MonthCellCopyWith<MonthCell> get copyWith => _$MonthCellCopyWithImpl<MonthCell>(this as MonthCell, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MonthCell;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthCell&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.isCurrentMonth, _this.isCurrentMonth) || other.isCurrentMonth == _this.isCurrentMonth)&&(identical(other.isToday, _this.isToday) || other.isToday == _this.isToday)&&(identical(other.isTodayWorking, _this.isTodayWorking) || other.isTodayWorking == _this.isTodayWorking)&&(identical(other.isWeekend, _this.isWeekend) || other.isWeekend == _this.isWeekend)&&(identical(other.isFuture, _this.isFuture) || other.isFuture == _this.isFuture)&&(identical(other.isBeforeFirstWeek, _this.isBeforeFirstWeek) || other.isBeforeFirstWeek == _this.isBeforeFirstWeek)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.value, _this.value) || other.value == _this.value));
}


@override
int get hashCode {
  final _this = this as MonthCell;
  return Object.hash(runtimeType,_this.date,_this.isCurrentMonth,_this.isToday,_this.isTodayWorking,_this.isWeekend,_this.isFuture,_this.isBeforeFirstWeek,_this.type,_this.value);
}

@override
String toString() {
  final _this = this as MonthCell;
  return 'MonthCell(date: ${_this.date}, isCurrentMonth: ${_this.isCurrentMonth}, isToday: ${_this.isToday}, isTodayWorking: ${_this.isTodayWorking}, isWeekend: ${_this.isWeekend}, isFuture: ${_this.isFuture}, isBeforeFirstWeek: ${_this.isBeforeFirstWeek}, type: ${_this.type}, value: ${_this.value})';
}


}

/// @nodoc
abstract mixin class $MonthCellCopyWith<$Res>  {
  factory $MonthCellCopyWith(MonthCell value, $Res Function(MonthCell) _then) = _$MonthCellCopyWithImpl;
@useResult
$Res call({
 DateTime date, bool isCurrentMonth, bool isToday, bool isTodayWorking, bool isWeekend, bool isFuture, bool isBeforeFirstWeek, WorkType? type, MonthCellValue value
});


$MonthCellValueCopyWith<$Res> get value;

}
/// @nodoc
class _$MonthCellCopyWithImpl<$Res>
    implements $MonthCellCopyWith<$Res> {
  _$MonthCellCopyWithImpl(this._self, this._then);

  final MonthCell _self;
  final $Res Function(MonthCell) _then;

/// Create a copy of MonthCell
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? isCurrentMonth = null,Object? isToday = null,Object? isTodayWorking = null,Object? isWeekend = null,Object? isFuture = null,Object? isBeforeFirstWeek = null,Object? type = freezed,Object? value = null,}) {
  return _then(MonthCell(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,isCurrentMonth: null == isCurrentMonth ? _self.isCurrentMonth : isCurrentMonth // ignore: cast_nullable_to_non_nullable
as bool,isToday: null == isToday ? _self.isToday : isToday // ignore: cast_nullable_to_non_nullable
as bool,isTodayWorking: null == isTodayWorking ? _self.isTodayWorking : isTodayWorking // ignore: cast_nullable_to_non_nullable
as bool,isWeekend: null == isWeekend ? _self.isWeekend : isWeekend // ignore: cast_nullable_to_non_nullable
as bool,isFuture: null == isFuture ? _self.isFuture : isFuture // ignore: cast_nullable_to_non_nullable
as bool,isBeforeFirstWeek: null == isBeforeFirstWeek ? _self.isBeforeFirstWeek : isBeforeFirstWeek // ignore: cast_nullable_to_non_nullable
as bool,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as WorkType?,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as MonthCellValue,
  ));
}
/// Create a copy of MonthCell
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MonthCellValueCopyWith<$Res> get value {
  
  return $MonthCellValueCopyWith<$Res>(_self.value, (value) {
    return _then(_self.copyWith(value: value));
  });
}
}


/// Adds pattern-matching-related methods to [MonthCell].
extension MonthCellPatterns on MonthCell {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MonthCell value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MonthCell() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MonthCell value)  $default,){
final _that = this;
switch (_that) {
case _MonthCell():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MonthCell value)?  $default,){
final _that = this;
switch (_that) {
case _MonthCell() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  bool isCurrentMonth,  bool isToday,  bool isTodayWorking,  bool isWeekend,  bool isFuture,  bool isBeforeFirstWeek,  WorkType? type,  MonthCellValue value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MonthCell() when $default != null:
return $default(_that.date,_that.isCurrentMonth,_that.isToday,_that.isTodayWorking,_that.isWeekend,_that.isFuture,_that.isBeforeFirstWeek,_that.type,_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  bool isCurrentMonth,  bool isToday,  bool isTodayWorking,  bool isWeekend,  bool isFuture,  bool isBeforeFirstWeek,  WorkType? type,  MonthCellValue value)  $default,) {final _that = this;
switch (_that) {
case _MonthCell():
return $default(_that.date,_that.isCurrentMonth,_that.isToday,_that.isTodayWorking,_that.isWeekend,_that.isFuture,_that.isBeforeFirstWeek,_that.type,_that.value);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  bool isCurrentMonth,  bool isToday,  bool isTodayWorking,  bool isWeekend,  bool isFuture,  bool isBeforeFirstWeek,  WorkType? type,  MonthCellValue value)?  $default,) {final _that = this;
switch (_that) {
case _MonthCell() when $default != null:
return $default(_that.date,_that.isCurrentMonth,_that.isToday,_that.isTodayWorking,_that.isWeekend,_that.isFuture,_that.isBeforeFirstWeek,_that.type,_that.value);case _:
  return null;

}
}

}

/// @nodoc


class _MonthCell implements MonthCell {
  const _MonthCell({required this.date, required this.isCurrentMonth, required this.isToday, required this.isTodayWorking, required this.isWeekend, required this.isFuture, required this.isBeforeFirstWeek, this.type, required this.value});
  

@override final  DateTime date;
@override final  bool isCurrentMonth;
@override final  bool isToday;
/// 오늘 근무 중(출근만 찍힘) — 탭해도 시트 대신 안내만.
@override final  bool isTodayWorking;
@override final  bool isWeekend;
@override final  bool isFuture;
/// 첫 기록 주의 월요일보다 앞 — 앱 설치 전. 흐리게만 보이고 탭해도 열리지 않는다.
@override final  bool isBeforeFirstWeek;
/// 배지. normal이면 null
@override final  WorkType? type;
@override final  MonthCellValue value;

/// Create a copy of MonthCell
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MonthCellCopyWith<_MonthCell> get copyWith => __$MonthCellCopyWithImpl<_MonthCell>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MonthCell&&(identical(other.date, date) || other.date == date)&&(identical(other.isCurrentMonth, isCurrentMonth) || other.isCurrentMonth == isCurrentMonth)&&(identical(other.isToday, isToday) || other.isToday == isToday)&&(identical(other.isTodayWorking, isTodayWorking) || other.isTodayWorking == isTodayWorking)&&(identical(other.isWeekend, isWeekend) || other.isWeekend == isWeekend)&&(identical(other.isFuture, isFuture) || other.isFuture == isFuture)&&(identical(other.isBeforeFirstWeek, isBeforeFirstWeek) || other.isBeforeFirstWeek == isBeforeFirstWeek)&&(identical(other.type, type) || other.type == type)&&(identical(other.value, value) || other.value == value));
}


@override
int get hashCode {
    return Object.hash(runtimeType,date,isCurrentMonth,isToday,isTodayWorking,isWeekend,isFuture,isBeforeFirstWeek,type,value);
}

@override
String toString() {
    return 'MonthCell(date: $date, isCurrentMonth: $isCurrentMonth, isToday: $isToday, isTodayWorking: $isTodayWorking, isWeekend: $isWeekend, isFuture: $isFuture, isBeforeFirstWeek: $isBeforeFirstWeek, type: $type, value: $value)';
}


}

/// @nodoc
abstract mixin class _$MonthCellCopyWith<$Res> implements $MonthCellCopyWith<$Res> {
  factory _$MonthCellCopyWith(_MonthCell value, $Res Function(_MonthCell) _then) = __$MonthCellCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, bool isCurrentMonth, bool isToday, bool isTodayWorking, bool isWeekend, bool isFuture, bool isBeforeFirstWeek, WorkType? type, MonthCellValue value
});


@override $MonthCellValueCopyWith<$Res> get value;

}
/// @nodoc
class __$MonthCellCopyWithImpl<$Res>
    implements _$MonthCellCopyWith<$Res> {
  __$MonthCellCopyWithImpl(this._self, this._then);

  final _MonthCell _self;
  final $Res Function(_MonthCell) _then;

/// Create a copy of MonthCell
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? isCurrentMonth = null,Object? isToday = null,Object? isTodayWorking = null,Object? isWeekend = null,Object? isFuture = null,Object? isBeforeFirstWeek = null,Object? type = freezed,Object? value = null,}) {
  return _then(_MonthCell(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,isCurrentMonth: null == isCurrentMonth ? _self.isCurrentMonth : isCurrentMonth // ignore: cast_nullable_to_non_nullable
as bool,isToday: null == isToday ? _self.isToday : isToday // ignore: cast_nullable_to_non_nullable
as bool,isTodayWorking: null == isTodayWorking ? _self.isTodayWorking : isTodayWorking // ignore: cast_nullable_to_non_nullable
as bool,isWeekend: null == isWeekend ? _self.isWeekend : isWeekend // ignore: cast_nullable_to_non_nullable
as bool,isFuture: null == isFuture ? _self.isFuture : isFuture // ignore: cast_nullable_to_non_nullable
as bool,isBeforeFirstWeek: null == isBeforeFirstWeek ? _self.isBeforeFirstWeek : isBeforeFirstWeek // ignore: cast_nullable_to_non_nullable
as bool,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as WorkType?,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as MonthCellValue,
  ));
}

/// Create a copy of MonthCell
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MonthCellValueCopyWith<$Res> get value {
  
  return $MonthCellValueCopyWith<$Res>(_self.value, (value) {
    return _then(_self.copyWith(value: value));
  });
}
}

/// @nodoc
mixin _$MonthExtraWork {

 int get weekendMinutes; int get holidayMinutes;/// 시급이 있을 때만. 없으면 유도 줄.
 int? get payWon;
/// Create a copy of MonthExtraWork
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MonthExtraWorkCopyWith<MonthExtraWork> get copyWith => _$MonthExtraWorkCopyWithImpl<MonthExtraWork>(this as MonthExtraWork, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MonthExtraWork;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthExtraWork&&(identical(other.weekendMinutes, _this.weekendMinutes) || other.weekendMinutes == _this.weekendMinutes)&&(identical(other.holidayMinutes, _this.holidayMinutes) || other.holidayMinutes == _this.holidayMinutes)&&(identical(other.payWon, _this.payWon) || other.payWon == _this.payWon));
}


@override
int get hashCode {
  final _this = this as MonthExtraWork;
  return Object.hash(runtimeType,_this.weekendMinutes,_this.holidayMinutes,_this.payWon);
}

@override
String toString() {
  final _this = this as MonthExtraWork;
  return 'MonthExtraWork(weekendMinutes: ${_this.weekendMinutes}, holidayMinutes: ${_this.holidayMinutes}, payWon: ${_this.payWon})';
}


}

/// @nodoc
abstract mixin class $MonthExtraWorkCopyWith<$Res>  {
  factory $MonthExtraWorkCopyWith(MonthExtraWork value, $Res Function(MonthExtraWork) _then) = _$MonthExtraWorkCopyWithImpl;
@useResult
$Res call({
 int weekendMinutes, int holidayMinutes, int? payWon
});




}
/// @nodoc
class _$MonthExtraWorkCopyWithImpl<$Res>
    implements $MonthExtraWorkCopyWith<$Res> {
  _$MonthExtraWorkCopyWithImpl(this._self, this._then);

  final MonthExtraWork _self;
  final $Res Function(MonthExtraWork) _then;

/// Create a copy of MonthExtraWork
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? weekendMinutes = null,Object? holidayMinutes = null,Object? payWon = freezed,}) {
  return _then(MonthExtraWork(
weekendMinutes: null == weekendMinutes ? _self.weekendMinutes : weekendMinutes // ignore: cast_nullable_to_non_nullable
as int,holidayMinutes: null == holidayMinutes ? _self.holidayMinutes : holidayMinutes // ignore: cast_nullable_to_non_nullable
as int,payWon: freezed == payWon ? _self.payWon : payWon // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [MonthExtraWork].
extension MonthExtraWorkPatterns on MonthExtraWork {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MonthExtraWork value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MonthExtraWork() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MonthExtraWork value)  $default,){
final _that = this;
switch (_that) {
case _MonthExtraWork():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MonthExtraWork value)?  $default,){
final _that = this;
switch (_that) {
case _MonthExtraWork() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int weekendMinutes,  int holidayMinutes,  int? payWon)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MonthExtraWork() when $default != null:
return $default(_that.weekendMinutes,_that.holidayMinutes,_that.payWon);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int weekendMinutes,  int holidayMinutes,  int? payWon)  $default,) {final _that = this;
switch (_that) {
case _MonthExtraWork():
return $default(_that.weekendMinutes,_that.holidayMinutes,_that.payWon);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int weekendMinutes,  int holidayMinutes,  int? payWon)?  $default,) {final _that = this;
switch (_that) {
case _MonthExtraWork() when $default != null:
return $default(_that.weekendMinutes,_that.holidayMinutes,_that.payWon);case _:
  return null;

}
}

}

/// @nodoc


class _MonthExtraWork implements MonthExtraWork {
  const _MonthExtraWork({required this.weekendMinutes, required this.holidayMinutes, this.payWon});
  

@override final  int weekendMinutes;
@override final  int holidayMinutes;
/// 시급이 있을 때만. 없으면 유도 줄.
@override final  int? payWon;

/// Create a copy of MonthExtraWork
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MonthExtraWorkCopyWith<_MonthExtraWork> get copyWith => __$MonthExtraWorkCopyWithImpl<_MonthExtraWork>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MonthExtraWork&&(identical(other.weekendMinutes, weekendMinutes) || other.weekendMinutes == weekendMinutes)&&(identical(other.holidayMinutes, holidayMinutes) || other.holidayMinutes == holidayMinutes)&&(identical(other.payWon, payWon) || other.payWon == payWon));
}


@override
int get hashCode {
    return Object.hash(runtimeType,weekendMinutes,holidayMinutes,payWon);
}

@override
String toString() {
    return 'MonthExtraWork(weekendMinutes: $weekendMinutes, holidayMinutes: $holidayMinutes, payWon: $payWon)';
}


}

/// @nodoc
abstract mixin class _$MonthExtraWorkCopyWith<$Res> implements $MonthExtraWorkCopyWith<$Res> {
  factory _$MonthExtraWorkCopyWith(_MonthExtraWork value, $Res Function(_MonthExtraWork) _then) = __$MonthExtraWorkCopyWithImpl;
@override @useResult
$Res call({
 int weekendMinutes, int holidayMinutes, int? payWon
});




}
/// @nodoc
class __$MonthExtraWorkCopyWithImpl<$Res>
    implements _$MonthExtraWorkCopyWith<$Res> {
  __$MonthExtraWorkCopyWithImpl(this._self, this._then);

  final _MonthExtraWork _self;
  final $Res Function(_MonthExtraWork) _then;

/// Create a copy of MonthExtraWork
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? weekendMinutes = null,Object? holidayMinutes = null,Object? payWon = freezed,}) {
  return _then(_MonthExtraWork(
weekendMinutes: null == weekendMinutes ? _self.weekendMinutes : weekendMinutes // ignore: cast_nullable_to_non_nullable
as int,holidayMinutes: null == holidayMinutes ? _self.holidayMinutes : holidayMinutes // ignore: cast_nullable_to_non_nullable
as int,payWon: freezed == payWon ? _self.payWon : payWon // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$MonthLeave {

 int get year;/// 그 해 총 연차(일). 없으면 "—" + 유도 줄.
 int? get totalDays;/// 반일 단위. 미리 찍은 미래 날짜 포함.
 int get usedHalfDays;/// 사용 중 오늘보다 뒤인 것(반일 단위). 0보다 크면 "예정 n일 포함".
 int get plannedHalfDays;/// total×2 − used. 음수면 초과. total 없으면 null.
 int? get remainingHalfDays;
/// Create a copy of MonthLeave
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MonthLeaveCopyWith<MonthLeave> get copyWith => _$MonthLeaveCopyWithImpl<MonthLeave>(this as MonthLeave, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MonthLeave;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthLeave&&(identical(other.year, _this.year) || other.year == _this.year)&&(identical(other.totalDays, _this.totalDays) || other.totalDays == _this.totalDays)&&(identical(other.usedHalfDays, _this.usedHalfDays) || other.usedHalfDays == _this.usedHalfDays)&&(identical(other.plannedHalfDays, _this.plannedHalfDays) || other.plannedHalfDays == _this.plannedHalfDays)&&(identical(other.remainingHalfDays, _this.remainingHalfDays) || other.remainingHalfDays == _this.remainingHalfDays));
}


@override
int get hashCode {
  final _this = this as MonthLeave;
  return Object.hash(runtimeType,_this.year,_this.totalDays,_this.usedHalfDays,_this.plannedHalfDays,_this.remainingHalfDays);
}

@override
String toString() {
  final _this = this as MonthLeave;
  return 'MonthLeave(year: ${_this.year}, totalDays: ${_this.totalDays}, usedHalfDays: ${_this.usedHalfDays}, plannedHalfDays: ${_this.plannedHalfDays}, remainingHalfDays: ${_this.remainingHalfDays})';
}


}

/// @nodoc
abstract mixin class $MonthLeaveCopyWith<$Res>  {
  factory $MonthLeaveCopyWith(MonthLeave value, $Res Function(MonthLeave) _then) = _$MonthLeaveCopyWithImpl;
@useResult
$Res call({
 int year, int? totalDays, int usedHalfDays, int plannedHalfDays, int? remainingHalfDays
});




}
/// @nodoc
class _$MonthLeaveCopyWithImpl<$Res>
    implements $MonthLeaveCopyWith<$Res> {
  _$MonthLeaveCopyWithImpl(this._self, this._then);

  final MonthLeave _self;
  final $Res Function(MonthLeave) _then;

/// Create a copy of MonthLeave
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? year = null,Object? totalDays = freezed,Object? usedHalfDays = null,Object? plannedHalfDays = null,Object? remainingHalfDays = freezed,}) {
  return _then(MonthLeave(
year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,totalDays: freezed == totalDays ? _self.totalDays : totalDays // ignore: cast_nullable_to_non_nullable
as int?,usedHalfDays: null == usedHalfDays ? _self.usedHalfDays : usedHalfDays // ignore: cast_nullable_to_non_nullable
as int,plannedHalfDays: null == plannedHalfDays ? _self.plannedHalfDays : plannedHalfDays // ignore: cast_nullable_to_non_nullable
as int,remainingHalfDays: freezed == remainingHalfDays ? _self.remainingHalfDays : remainingHalfDays // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [MonthLeave].
extension MonthLeavePatterns on MonthLeave {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MonthLeave value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MonthLeave() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MonthLeave value)  $default,){
final _that = this;
switch (_that) {
case _MonthLeave():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MonthLeave value)?  $default,){
final _that = this;
switch (_that) {
case _MonthLeave() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int year,  int? totalDays,  int usedHalfDays,  int plannedHalfDays,  int? remainingHalfDays)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MonthLeave() when $default != null:
return $default(_that.year,_that.totalDays,_that.usedHalfDays,_that.plannedHalfDays,_that.remainingHalfDays);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int year,  int? totalDays,  int usedHalfDays,  int plannedHalfDays,  int? remainingHalfDays)  $default,) {final _that = this;
switch (_that) {
case _MonthLeave():
return $default(_that.year,_that.totalDays,_that.usedHalfDays,_that.plannedHalfDays,_that.remainingHalfDays);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int year,  int? totalDays,  int usedHalfDays,  int plannedHalfDays,  int? remainingHalfDays)?  $default,) {final _that = this;
switch (_that) {
case _MonthLeave() when $default != null:
return $default(_that.year,_that.totalDays,_that.usedHalfDays,_that.plannedHalfDays,_that.remainingHalfDays);case _:
  return null;

}
}

}

/// @nodoc


class _MonthLeave implements MonthLeave {
  const _MonthLeave({required this.year, this.totalDays, required this.usedHalfDays, required this.plannedHalfDays, this.remainingHalfDays});
  

@override final  int year;
/// 그 해 총 연차(일). 없으면 "—" + 유도 줄.
@override final  int? totalDays;
/// 반일 단위. 미리 찍은 미래 날짜 포함.
@override final  int usedHalfDays;
/// 사용 중 오늘보다 뒤인 것(반일 단위). 0보다 크면 "예정 n일 포함".
@override final  int plannedHalfDays;
/// total×2 − used. 음수면 초과. total 없으면 null.
@override final  int? remainingHalfDays;

/// Create a copy of MonthLeave
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MonthLeaveCopyWith<_MonthLeave> get copyWith => __$MonthLeaveCopyWithImpl<_MonthLeave>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MonthLeave&&(identical(other.year, year) || other.year == year)&&(identical(other.totalDays, totalDays) || other.totalDays == totalDays)&&(identical(other.usedHalfDays, usedHalfDays) || other.usedHalfDays == usedHalfDays)&&(identical(other.plannedHalfDays, plannedHalfDays) || other.plannedHalfDays == plannedHalfDays)&&(identical(other.remainingHalfDays, remainingHalfDays) || other.remainingHalfDays == remainingHalfDays));
}


@override
int get hashCode {
    return Object.hash(runtimeType,year,totalDays,usedHalfDays,plannedHalfDays,remainingHalfDays);
}

@override
String toString() {
    return 'MonthLeave(year: $year, totalDays: $totalDays, usedHalfDays: $usedHalfDays, plannedHalfDays: $plannedHalfDays, remainingHalfDays: $remainingHalfDays)';
}


}

/// @nodoc
abstract mixin class _$MonthLeaveCopyWith<$Res> implements $MonthLeaveCopyWith<$Res> {
  factory _$MonthLeaveCopyWith(_MonthLeave value, $Res Function(_MonthLeave) _then) = __$MonthLeaveCopyWithImpl;
@override @useResult
$Res call({
 int year, int? totalDays, int usedHalfDays, int plannedHalfDays, int? remainingHalfDays
});




}
/// @nodoc
class __$MonthLeaveCopyWithImpl<$Res>
    implements _$MonthLeaveCopyWith<$Res> {
  __$MonthLeaveCopyWithImpl(this._self, this._then);

  final _MonthLeave _self;
  final $Res Function(_MonthLeave) _then;

/// Create a copy of MonthLeave
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? year = null,Object? totalDays = freezed,Object? usedHalfDays = null,Object? plannedHalfDays = null,Object? remainingHalfDays = freezed,}) {
  return _then(_MonthLeave(
year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,totalDays: freezed == totalDays ? _self.totalDays : totalDays // ignore: cast_nullable_to_non_nullable
as int?,usedHalfDays: null == usedHalfDays ? _self.usedHalfDays : usedHalfDays // ignore: cast_nullable_to_non_nullable
as int,plannedHalfDays: null == plannedHalfDays ? _self.plannedHalfDays : plannedHalfDays // ignore: cast_nullable_to_non_nullable
as int,remainingHalfDays: freezed == remainingHalfDays ? _self.remainingHalfDays : remainingHalfDays // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$MonthState {

 DateTime get month; List<List<MonthCell>> get weeks; MonthExtraWork? get extraWork; MonthLeave? get leave;
/// Create a copy of MonthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MonthStateCopyWith<MonthState> get copyWith => _$MonthStateCopyWithImpl<MonthState>(this as MonthState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MonthState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthState&&(identical(other.month, _this.month) || other.month == _this.month)&&const DeepCollectionEquality().equals(other.weeks, _this.weeks)&&(identical(other.extraWork, _this.extraWork) || other.extraWork == _this.extraWork)&&(identical(other.leave, _this.leave) || other.leave == _this.leave));
}


@override
int get hashCode {
  final _this = this as MonthState;
  return Object.hash(runtimeType,_this.month,const DeepCollectionEquality().hash(_this.weeks),_this.extraWork,_this.leave);
}

@override
String toString() {
  final _this = this as MonthState;
  return 'MonthState(month: ${_this.month}, weeks: ${_this.weeks}, extraWork: ${_this.extraWork}, leave: ${_this.leave})';
}


}

/// @nodoc
abstract mixin class $MonthStateCopyWith<$Res>  {
  factory $MonthStateCopyWith(MonthState value, $Res Function(MonthState) _then) = _$MonthStateCopyWithImpl;
@useResult
$Res call({
 DateTime month, List<List<MonthCell>> weeks, MonthExtraWork? extraWork, MonthLeave? leave
});


$MonthExtraWorkCopyWith<$Res>? get extraWork;$MonthLeaveCopyWith<$Res>? get leave;

}
/// @nodoc
class _$MonthStateCopyWithImpl<$Res>
    implements $MonthStateCopyWith<$Res> {
  _$MonthStateCopyWithImpl(this._self, this._then);

  final MonthState _self;
  final $Res Function(MonthState) _then;

/// Create a copy of MonthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? month = null,Object? weeks = null,Object? extraWork = freezed,Object? leave = freezed,}) {
  return _then(MonthState(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as DateTime,weeks: null == weeks ? _self.weeks : weeks // ignore: cast_nullable_to_non_nullable
as List<List<MonthCell>>,extraWork: freezed == extraWork ? _self.extraWork : extraWork // ignore: cast_nullable_to_non_nullable
as MonthExtraWork?,leave: freezed == leave ? _self.leave : leave // ignore: cast_nullable_to_non_nullable
as MonthLeave?,
  ));
}
/// Create a copy of MonthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MonthExtraWorkCopyWith<$Res>? get extraWork {
    if (_self.extraWork == null) {
    return null;
  }

  return $MonthExtraWorkCopyWith<$Res>(_self.extraWork!, (value) {
    return _then(_self.copyWith(extraWork: value));
  });
}/// Create a copy of MonthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MonthLeaveCopyWith<$Res>? get leave {
    if (_self.leave == null) {
    return null;
  }

  return $MonthLeaveCopyWith<$Res>(_self.leave!, (value) {
    return _then(_self.copyWith(leave: value));
  });
}
}


/// Adds pattern-matching-related methods to [MonthState].
extension MonthStatePatterns on MonthState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MonthState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MonthState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MonthState value)  $default,){
final _that = this;
switch (_that) {
case _MonthState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MonthState value)?  $default,){
final _that = this;
switch (_that) {
case _MonthState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime month,  List<List<MonthCell>> weeks,  MonthExtraWork? extraWork,  MonthLeave? leave)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MonthState() when $default != null:
return $default(_that.month,_that.weeks,_that.extraWork,_that.leave);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime month,  List<List<MonthCell>> weeks,  MonthExtraWork? extraWork,  MonthLeave? leave)  $default,) {final _that = this;
switch (_that) {
case _MonthState():
return $default(_that.month,_that.weeks,_that.extraWork,_that.leave);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime month,  List<List<MonthCell>> weeks,  MonthExtraWork? extraWork,  MonthLeave? leave)?  $default,) {final _that = this;
switch (_that) {
case _MonthState() when $default != null:
return $default(_that.month,_that.weeks,_that.extraWork,_that.leave);case _:
  return null;

}
}

}

/// @nodoc


class _MonthState implements MonthState {
  const _MonthState({required this.month, required  List<List<MonthCell>> weeks, this.extraWork, this.leave}): _weeks = weeks;
  

@override final  DateTime month;
 final  List<List<MonthCell>> _weeks;
@override List<List<MonthCell>> get weeks {
  if (_weeks is EqualUnmodifiableListView) return _weeks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_weeks);
}

@override final  MonthExtraWork? extraWork;
@override final  MonthLeave? leave;

/// Create a copy of MonthState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MonthStateCopyWith<_MonthState> get copyWith => __$MonthStateCopyWithImpl<_MonthState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MonthState&&(identical(other.month, month) || other.month == month)&&const DeepCollectionEquality().equals(other.weeks, _weeks)&&(identical(other.extraWork, extraWork) || other.extraWork == extraWork)&&(identical(other.leave, leave) || other.leave == leave));
}


@override
int get hashCode {
    return Object.hash(runtimeType,month,const DeepCollectionEquality().hash(_weeks),extraWork,leave);
}

@override
String toString() {
    return 'MonthState(month: $month, weeks: $weeks, extraWork: $extraWork, leave: $leave)';
}


}

/// @nodoc
abstract mixin class _$MonthStateCopyWith<$Res> implements $MonthStateCopyWith<$Res> {
  factory _$MonthStateCopyWith(_MonthState value, $Res Function(_MonthState) _then) = __$MonthStateCopyWithImpl;
@override @useResult
$Res call({
 DateTime month, List<List<MonthCell>> weeks, MonthExtraWork? extraWork, MonthLeave? leave
});


@override $MonthExtraWorkCopyWith<$Res>? get extraWork;@override $MonthLeaveCopyWith<$Res>? get leave;

}
/// @nodoc
class __$MonthStateCopyWithImpl<$Res>
    implements _$MonthStateCopyWith<$Res> {
  __$MonthStateCopyWithImpl(this._self, this._then);

  final _MonthState _self;
  final $Res Function(_MonthState) _then;

/// Create a copy of MonthState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? month = null,Object? weeks = null,Object? extraWork = freezed,Object? leave = freezed,}) {
  return _then(_MonthState(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as DateTime,weeks: null == weeks ? _self._weeks : weeks // ignore: cast_nullable_to_non_nullable
as List<List<MonthCell>>,extraWork: freezed == extraWork ? _self.extraWork : extraWork // ignore: cast_nullable_to_non_nullable
as MonthExtraWork?,leave: freezed == leave ? _self.leave : leave // ignore: cast_nullable_to_non_nullable
as MonthLeave?,
  ));
}

/// Create a copy of MonthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MonthExtraWorkCopyWith<$Res>? get extraWork {
    if (_self.extraWork == null) {
    return null;
  }

  return $MonthExtraWorkCopyWith<$Res>(_self.extraWork!, (value) {
    return _then(_self.copyWith(extraWork: value));
  });
}/// Create a copy of MonthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MonthLeaveCopyWith<$Res>? get leave {
    if (_self.leave == null) {
    return null;
  }

  return $MonthLeaveCopyWith<$Res>(_self.leave!, (value) {
    return _then(_self.copyWith(leave: value));
  });
}
}

// dart format on

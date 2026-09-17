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

 DateTime get date; bool get isCurrentMonth; bool get isToday; bool get isWeekend; bool get isFuture;/// 첫 기록 주의 월요일보다 앞 — 앱 설치 전. 흐리게만 보이고 탭해도 열리지 않는다.
 bool get isBeforeFirstWeek;/// 배지. normal이면 null
 WorkType? get type; MonthCellValue get value; bool get hasBackground;
/// Create a copy of MonthCell
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MonthCellCopyWith<MonthCell> get copyWith => _$MonthCellCopyWithImpl<MonthCell>(this as MonthCell, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MonthCell;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthCell&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.isCurrentMonth, _this.isCurrentMonth) || other.isCurrentMonth == _this.isCurrentMonth)&&(identical(other.isToday, _this.isToday) || other.isToday == _this.isToday)&&(identical(other.isWeekend, _this.isWeekend) || other.isWeekend == _this.isWeekend)&&(identical(other.isFuture, _this.isFuture) || other.isFuture == _this.isFuture)&&(identical(other.isBeforeFirstWeek, _this.isBeforeFirstWeek) || other.isBeforeFirstWeek == _this.isBeforeFirstWeek)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.value, _this.value) || other.value == _this.value)&&(identical(other.hasBackground, _this.hasBackground) || other.hasBackground == _this.hasBackground));
}


@override
int get hashCode {
  final _this = this as MonthCell;
  return Object.hash(runtimeType,_this.date,_this.isCurrentMonth,_this.isToday,_this.isWeekend,_this.isFuture,_this.isBeforeFirstWeek,_this.type,_this.value,_this.hasBackground);
}

@override
String toString() {
  final _this = this as MonthCell;
  return 'MonthCell(date: ${_this.date}, isCurrentMonth: ${_this.isCurrentMonth}, isToday: ${_this.isToday}, isWeekend: ${_this.isWeekend}, isFuture: ${_this.isFuture}, isBeforeFirstWeek: ${_this.isBeforeFirstWeek}, type: ${_this.type}, value: ${_this.value}, hasBackground: ${_this.hasBackground})';
}


}

/// @nodoc
abstract mixin class $MonthCellCopyWith<$Res>  {
  factory $MonthCellCopyWith(MonthCell value, $Res Function(MonthCell) _then) = _$MonthCellCopyWithImpl;
@useResult
$Res call({
 DateTime date, bool isCurrentMonth, bool isToday, bool isWeekend, bool isFuture, bool isBeforeFirstWeek, WorkType? type, MonthCellValue value, bool hasBackground
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
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? isCurrentMonth = null,Object? isToday = null,Object? isWeekend = null,Object? isFuture = null,Object? isBeforeFirstWeek = null,Object? type = freezed,Object? value = null,Object? hasBackground = null,}) {
  return _then(MonthCell(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,isCurrentMonth: null == isCurrentMonth ? _self.isCurrentMonth : isCurrentMonth // ignore: cast_nullable_to_non_nullable
as bool,isToday: null == isToday ? _self.isToday : isToday // ignore: cast_nullable_to_non_nullable
as bool,isWeekend: null == isWeekend ? _self.isWeekend : isWeekend // ignore: cast_nullable_to_non_nullable
as bool,isFuture: null == isFuture ? _self.isFuture : isFuture // ignore: cast_nullable_to_non_nullable
as bool,isBeforeFirstWeek: null == isBeforeFirstWeek ? _self.isBeforeFirstWeek : isBeforeFirstWeek // ignore: cast_nullable_to_non_nullable
as bool,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as WorkType?,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as MonthCellValue,hasBackground: null == hasBackground ? _self.hasBackground : hasBackground // ignore: cast_nullable_to_non_nullable
as bool,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  bool isCurrentMonth,  bool isToday,  bool isWeekend,  bool isFuture,  bool isBeforeFirstWeek,  WorkType? type,  MonthCellValue value,  bool hasBackground)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MonthCell() when $default != null:
return $default(_that.date,_that.isCurrentMonth,_that.isToday,_that.isWeekend,_that.isFuture,_that.isBeforeFirstWeek,_that.type,_that.value,_that.hasBackground);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  bool isCurrentMonth,  bool isToday,  bool isWeekend,  bool isFuture,  bool isBeforeFirstWeek,  WorkType? type,  MonthCellValue value,  bool hasBackground)  $default,) {final _that = this;
switch (_that) {
case _MonthCell():
return $default(_that.date,_that.isCurrentMonth,_that.isToday,_that.isWeekend,_that.isFuture,_that.isBeforeFirstWeek,_that.type,_that.value,_that.hasBackground);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  bool isCurrentMonth,  bool isToday,  bool isWeekend,  bool isFuture,  bool isBeforeFirstWeek,  WorkType? type,  MonthCellValue value,  bool hasBackground)?  $default,) {final _that = this;
switch (_that) {
case _MonthCell() when $default != null:
return $default(_that.date,_that.isCurrentMonth,_that.isToday,_that.isWeekend,_that.isFuture,_that.isBeforeFirstWeek,_that.type,_that.value,_that.hasBackground);case _:
  return null;

}
}

}

/// @nodoc


class _MonthCell implements MonthCell {
  const _MonthCell({required this.date, required this.isCurrentMonth, required this.isToday, required this.isWeekend, required this.isFuture, required this.isBeforeFirstWeek, this.type, required this.value, required this.hasBackground});
  

@override final  DateTime date;
@override final  bool isCurrentMonth;
@override final  bool isToday;
@override final  bool isWeekend;
@override final  bool isFuture;
/// 첫 기록 주의 월요일보다 앞 — 앱 설치 전. 흐리게만 보이고 탭해도 열리지 않는다.
@override final  bool isBeforeFirstWeek;
/// 배지. normal이면 null
@override final  WorkType? type;
@override final  MonthCellValue value;
@override final  bool hasBackground;

/// Create a copy of MonthCell
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MonthCellCopyWith<_MonthCell> get copyWith => __$MonthCellCopyWithImpl<_MonthCell>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MonthCell&&(identical(other.date, date) || other.date == date)&&(identical(other.isCurrentMonth, isCurrentMonth) || other.isCurrentMonth == isCurrentMonth)&&(identical(other.isToday, isToday) || other.isToday == isToday)&&(identical(other.isWeekend, isWeekend) || other.isWeekend == isWeekend)&&(identical(other.isFuture, isFuture) || other.isFuture == isFuture)&&(identical(other.isBeforeFirstWeek, isBeforeFirstWeek) || other.isBeforeFirstWeek == isBeforeFirstWeek)&&(identical(other.type, type) || other.type == type)&&(identical(other.value, value) || other.value == value)&&(identical(other.hasBackground, hasBackground) || other.hasBackground == hasBackground));
}


@override
int get hashCode {
    return Object.hash(runtimeType,date,isCurrentMonth,isToday,isWeekend,isFuture,isBeforeFirstWeek,type,value,hasBackground);
}

@override
String toString() {
    return 'MonthCell(date: $date, isCurrentMonth: $isCurrentMonth, isToday: $isToday, isWeekend: $isWeekend, isFuture: $isFuture, isBeforeFirstWeek: $isBeforeFirstWeek, type: $type, value: $value, hasBackground: $hasBackground)';
}


}

/// @nodoc
abstract mixin class _$MonthCellCopyWith<$Res> implements $MonthCellCopyWith<$Res> {
  factory _$MonthCellCopyWith(_MonthCell value, $Res Function(_MonthCell) _then) = __$MonthCellCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, bool isCurrentMonth, bool isToday, bool isWeekend, bool isFuture, bool isBeforeFirstWeek, WorkType? type, MonthCellValue value, bool hasBackground
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
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? isCurrentMonth = null,Object? isToday = null,Object? isWeekend = null,Object? isFuture = null,Object? isBeforeFirstWeek = null,Object? type = freezed,Object? value = null,Object? hasBackground = null,}) {
  return _then(_MonthCell(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,isCurrentMonth: null == isCurrentMonth ? _self.isCurrentMonth : isCurrentMonth // ignore: cast_nullable_to_non_nullable
as bool,isToday: null == isToday ? _self.isToday : isToday // ignore: cast_nullable_to_non_nullable
as bool,isWeekend: null == isWeekend ? _self.isWeekend : isWeekend // ignore: cast_nullable_to_non_nullable
as bool,isFuture: null == isFuture ? _self.isFuture : isFuture // ignore: cast_nullable_to_non_nullable
as bool,isBeforeFirstWeek: null == isBeforeFirstWeek ? _self.isBeforeFirstWeek : isBeforeFirstWeek // ignore: cast_nullable_to_non_nullable
as bool,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as WorkType?,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as MonthCellValue,hasBackground: null == hasBackground ? _self.hasBackground : hasBackground // ignore: cast_nullable_to_non_nullable
as bool,
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
mixin _$MonthState {

 DateTime get month; bool get canGoPrev; bool get canGoNext; List<List<MonthCell>> get weeks;
/// Create a copy of MonthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MonthStateCopyWith<MonthState> get copyWith => _$MonthStateCopyWithImpl<MonthState>(this as MonthState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MonthState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthState&&(identical(other.month, _this.month) || other.month == _this.month)&&(identical(other.canGoPrev, _this.canGoPrev) || other.canGoPrev == _this.canGoPrev)&&(identical(other.canGoNext, _this.canGoNext) || other.canGoNext == _this.canGoNext)&&const DeepCollectionEquality().equals(other.weeks, _this.weeks));
}


@override
int get hashCode {
  final _this = this as MonthState;
  return Object.hash(runtimeType,_this.month,_this.canGoPrev,_this.canGoNext,const DeepCollectionEquality().hash(_this.weeks));
}

@override
String toString() {
  final _this = this as MonthState;
  return 'MonthState(month: ${_this.month}, canGoPrev: ${_this.canGoPrev}, canGoNext: ${_this.canGoNext}, weeks: ${_this.weeks})';
}


}

/// @nodoc
abstract mixin class $MonthStateCopyWith<$Res>  {
  factory $MonthStateCopyWith(MonthState value, $Res Function(MonthState) _then) = _$MonthStateCopyWithImpl;
@useResult
$Res call({
 DateTime month, bool canGoPrev, bool canGoNext, List<List<MonthCell>> weeks
});




}
/// @nodoc
class _$MonthStateCopyWithImpl<$Res>
    implements $MonthStateCopyWith<$Res> {
  _$MonthStateCopyWithImpl(this._self, this._then);

  final MonthState _self;
  final $Res Function(MonthState) _then;

/// Create a copy of MonthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? month = null,Object? canGoPrev = null,Object? canGoNext = null,Object? weeks = null,}) {
  return _then(MonthState(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as DateTime,canGoPrev: null == canGoPrev ? _self.canGoPrev : canGoPrev // ignore: cast_nullable_to_non_nullable
as bool,canGoNext: null == canGoNext ? _self.canGoNext : canGoNext // ignore: cast_nullable_to_non_nullable
as bool,weeks: null == weeks ? _self.weeks : weeks // ignore: cast_nullable_to_non_nullable
as List<List<MonthCell>>,
  ));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime month,  bool canGoPrev,  bool canGoNext,  List<List<MonthCell>> weeks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MonthState() when $default != null:
return $default(_that.month,_that.canGoPrev,_that.canGoNext,_that.weeks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime month,  bool canGoPrev,  bool canGoNext,  List<List<MonthCell>> weeks)  $default,) {final _that = this;
switch (_that) {
case _MonthState():
return $default(_that.month,_that.canGoPrev,_that.canGoNext,_that.weeks);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime month,  bool canGoPrev,  bool canGoNext,  List<List<MonthCell>> weeks)?  $default,) {final _that = this;
switch (_that) {
case _MonthState() when $default != null:
return $default(_that.month,_that.canGoPrev,_that.canGoNext,_that.weeks);case _:
  return null;

}
}

}

/// @nodoc


class _MonthState implements MonthState {
  const _MonthState({required this.month, required this.canGoPrev, required this.canGoNext, required  List<List<MonthCell>> weeks}): _weeks = weeks;
  

@override final  DateTime month;
@override final  bool canGoPrev;
@override final  bool canGoNext;
 final  List<List<MonthCell>> _weeks;
@override List<List<MonthCell>> get weeks {
  if (_weeks is EqualUnmodifiableListView) return _weeks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_weeks);
}


/// Create a copy of MonthState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MonthStateCopyWith<_MonthState> get copyWith => __$MonthStateCopyWithImpl<_MonthState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MonthState&&(identical(other.month, month) || other.month == month)&&(identical(other.canGoPrev, canGoPrev) || other.canGoPrev == canGoPrev)&&(identical(other.canGoNext, canGoNext) || other.canGoNext == canGoNext)&&const DeepCollectionEquality().equals(other.weeks, _weeks));
}


@override
int get hashCode {
    return Object.hash(runtimeType,month,canGoPrev,canGoNext,const DeepCollectionEquality().hash(_weeks));
}

@override
String toString() {
    return 'MonthState(month: $month, canGoPrev: $canGoPrev, canGoNext: $canGoNext, weeks: $weeks)';
}


}

/// @nodoc
abstract mixin class _$MonthStateCopyWith<$Res> implements $MonthStateCopyWith<$Res> {
  factory _$MonthStateCopyWith(_MonthState value, $Res Function(_MonthState) _then) = __$MonthStateCopyWithImpl;
@override @useResult
$Res call({
 DateTime month, bool canGoPrev, bool canGoNext, List<List<MonthCell>> weeks
});




}
/// @nodoc
class __$MonthStateCopyWithImpl<$Res>
    implements _$MonthStateCopyWith<$Res> {
  __$MonthStateCopyWithImpl(this._self, this._then);

  final _MonthState _self;
  final $Res Function(_MonthState) _then;

/// Create a copy of MonthState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? month = null,Object? canGoPrev = null,Object? canGoNext = null,Object? weeks = null,}) {
  return _then(_MonthState(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as DateTime,canGoPrev: null == canGoPrev ? _self.canGoPrev : canGoPrev // ignore: cast_nullable_to_non_nullable
as bool,canGoNext: null == canGoNext ? _self.canGoNext : canGoNext // ignore: cast_nullable_to_non_nullable
as bool,weeks: null == weeks ? _self._weeks : weeks // ignore: cast_nullable_to_non_nullable
as List<List<MonthCell>>,
  ));
}


}

// dart format on

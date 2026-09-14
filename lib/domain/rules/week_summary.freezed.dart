// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'week_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WeekSummary {

/// 첫 주 예외면 null
 int? get targetMinutes; int get workedMinutes;/// target − worked. target이 null이면 null
 int? get remainingMinutes; int get halfDayCount; int get dayOffCount; int get holidayCount; bool get isFirstWeekException;
/// Create a copy of WeekSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeekSummaryCopyWith<WeekSummary> get copyWith => _$WeekSummaryCopyWithImpl<WeekSummary>(this as WeekSummary, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as WeekSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeekSummary&&(identical(other.targetMinutes, _this.targetMinutes) || other.targetMinutes == _this.targetMinutes)&&(identical(other.workedMinutes, _this.workedMinutes) || other.workedMinutes == _this.workedMinutes)&&(identical(other.remainingMinutes, _this.remainingMinutes) || other.remainingMinutes == _this.remainingMinutes)&&(identical(other.halfDayCount, _this.halfDayCount) || other.halfDayCount == _this.halfDayCount)&&(identical(other.dayOffCount, _this.dayOffCount) || other.dayOffCount == _this.dayOffCount)&&(identical(other.holidayCount, _this.holidayCount) || other.holidayCount == _this.holidayCount)&&(identical(other.isFirstWeekException, _this.isFirstWeekException) || other.isFirstWeekException == _this.isFirstWeekException));
}


@override
int get hashCode {
  final _this = this as WeekSummary;
  return Object.hash(runtimeType,_this.targetMinutes,_this.workedMinutes,_this.remainingMinutes,_this.halfDayCount,_this.dayOffCount,_this.holidayCount,_this.isFirstWeekException);
}

@override
String toString() {
  final _this = this as WeekSummary;
  return 'WeekSummary(targetMinutes: ${_this.targetMinutes}, workedMinutes: ${_this.workedMinutes}, remainingMinutes: ${_this.remainingMinutes}, halfDayCount: ${_this.halfDayCount}, dayOffCount: ${_this.dayOffCount}, holidayCount: ${_this.holidayCount}, isFirstWeekException: ${_this.isFirstWeekException})';
}


}

/// @nodoc
abstract mixin class $WeekSummaryCopyWith<$Res>  {
  factory $WeekSummaryCopyWith(WeekSummary value, $Res Function(WeekSummary) _then) = _$WeekSummaryCopyWithImpl;
@useResult
$Res call({
 int? targetMinutes, int workedMinutes, int? remainingMinutes, int halfDayCount, int dayOffCount, int holidayCount, bool isFirstWeekException
});




}
/// @nodoc
class _$WeekSummaryCopyWithImpl<$Res>
    implements $WeekSummaryCopyWith<$Res> {
  _$WeekSummaryCopyWithImpl(this._self, this._then);

  final WeekSummary _self;
  final $Res Function(WeekSummary) _then;

/// Create a copy of WeekSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? targetMinutes = freezed,Object? workedMinutes = null,Object? remainingMinutes = freezed,Object? halfDayCount = null,Object? dayOffCount = null,Object? holidayCount = null,Object? isFirstWeekException = null,}) {
  return _then(WeekSummary(
targetMinutes: freezed == targetMinutes ? _self.targetMinutes : targetMinutes // ignore: cast_nullable_to_non_nullable
as int?,workedMinutes: null == workedMinutes ? _self.workedMinutes : workedMinutes // ignore: cast_nullable_to_non_nullable
as int,remainingMinutes: freezed == remainingMinutes ? _self.remainingMinutes : remainingMinutes // ignore: cast_nullable_to_non_nullable
as int?,halfDayCount: null == halfDayCount ? _self.halfDayCount : halfDayCount // ignore: cast_nullable_to_non_nullable
as int,dayOffCount: null == dayOffCount ? _self.dayOffCount : dayOffCount // ignore: cast_nullable_to_non_nullable
as int,holidayCount: null == holidayCount ? _self.holidayCount : holidayCount // ignore: cast_nullable_to_non_nullable
as int,isFirstWeekException: null == isFirstWeekException ? _self.isFirstWeekException : isFirstWeekException // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [WeekSummary].
extension WeekSummaryPatterns on WeekSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WeekSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WeekSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WeekSummary value)  $default,){
final _that = this;
switch (_that) {
case _WeekSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WeekSummary value)?  $default,){
final _that = this;
switch (_that) {
case _WeekSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? targetMinutes,  int workedMinutes,  int? remainingMinutes,  int halfDayCount,  int dayOffCount,  int holidayCount,  bool isFirstWeekException)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeekSummary() when $default != null:
return $default(_that.targetMinutes,_that.workedMinutes,_that.remainingMinutes,_that.halfDayCount,_that.dayOffCount,_that.holidayCount,_that.isFirstWeekException);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? targetMinutes,  int workedMinutes,  int? remainingMinutes,  int halfDayCount,  int dayOffCount,  int holidayCount,  bool isFirstWeekException)  $default,) {final _that = this;
switch (_that) {
case _WeekSummary():
return $default(_that.targetMinutes,_that.workedMinutes,_that.remainingMinutes,_that.halfDayCount,_that.dayOffCount,_that.holidayCount,_that.isFirstWeekException);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? targetMinutes,  int workedMinutes,  int? remainingMinutes,  int halfDayCount,  int dayOffCount,  int holidayCount,  bool isFirstWeekException)?  $default,) {final _that = this;
switch (_that) {
case _WeekSummary() when $default != null:
return $default(_that.targetMinutes,_that.workedMinutes,_that.remainingMinutes,_that.halfDayCount,_that.dayOffCount,_that.holidayCount,_that.isFirstWeekException);case _:
  return null;

}
}

}

/// @nodoc


class _WeekSummary implements WeekSummary {
  const _WeekSummary({this.targetMinutes, required this.workedMinutes, this.remainingMinutes, required this.halfDayCount, required this.dayOffCount, required this.holidayCount, required this.isFirstWeekException});
  

/// 첫 주 예외면 null
@override final  int? targetMinutes;
@override final  int workedMinutes;
/// target − worked. target이 null이면 null
@override final  int? remainingMinutes;
@override final  int halfDayCount;
@override final  int dayOffCount;
@override final  int holidayCount;
@override final  bool isFirstWeekException;

/// Create a copy of WeekSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeekSummaryCopyWith<_WeekSummary> get copyWith => __$WeekSummaryCopyWithImpl<_WeekSummary>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeekSummary&&(identical(other.targetMinutes, targetMinutes) || other.targetMinutes == targetMinutes)&&(identical(other.workedMinutes, workedMinutes) || other.workedMinutes == workedMinutes)&&(identical(other.remainingMinutes, remainingMinutes) || other.remainingMinutes == remainingMinutes)&&(identical(other.halfDayCount, halfDayCount) || other.halfDayCount == halfDayCount)&&(identical(other.dayOffCount, dayOffCount) || other.dayOffCount == dayOffCount)&&(identical(other.holidayCount, holidayCount) || other.holidayCount == holidayCount)&&(identical(other.isFirstWeekException, isFirstWeekException) || other.isFirstWeekException == isFirstWeekException));
}


@override
int get hashCode {
    return Object.hash(runtimeType,targetMinutes,workedMinutes,remainingMinutes,halfDayCount,dayOffCount,holidayCount,isFirstWeekException);
}

@override
String toString() {
    return 'WeekSummary(targetMinutes: $targetMinutes, workedMinutes: $workedMinutes, remainingMinutes: $remainingMinutes, halfDayCount: $halfDayCount, dayOffCount: $dayOffCount, holidayCount: $holidayCount, isFirstWeekException: $isFirstWeekException)';
}


}

/// @nodoc
abstract mixin class _$WeekSummaryCopyWith<$Res> implements $WeekSummaryCopyWith<$Res> {
  factory _$WeekSummaryCopyWith(_WeekSummary value, $Res Function(_WeekSummary) _then) = __$WeekSummaryCopyWithImpl;
@override @useResult
$Res call({
 int? targetMinutes, int workedMinutes, int? remainingMinutes, int halfDayCount, int dayOffCount, int holidayCount, bool isFirstWeekException
});




}
/// @nodoc
class __$WeekSummaryCopyWithImpl<$Res>
    implements _$WeekSummaryCopyWith<$Res> {
  __$WeekSummaryCopyWithImpl(this._self, this._then);

  final _WeekSummary _self;
  final $Res Function(_WeekSummary) _then;

/// Create a copy of WeekSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? targetMinutes = freezed,Object? workedMinutes = null,Object? remainingMinutes = freezed,Object? halfDayCount = null,Object? dayOffCount = null,Object? holidayCount = null,Object? isFirstWeekException = null,}) {
  return _then(_WeekSummary(
targetMinutes: freezed == targetMinutes ? _self.targetMinutes : targetMinutes // ignore: cast_nullable_to_non_nullable
as int?,workedMinutes: null == workedMinutes ? _self.workedMinutes : workedMinutes // ignore: cast_nullable_to_non_nullable
as int,remainingMinutes: freezed == remainingMinutes ? _self.remainingMinutes : remainingMinutes // ignore: cast_nullable_to_non_nullable
as int?,halfDayCount: null == halfDayCount ? _self.halfDayCount : halfDayCount // ignore: cast_nullable_to_non_nullable
as int,dayOffCount: null == dayOffCount ? _self.dayOffCount : dayOffCount // ignore: cast_nullable_to_non_nullable
as int,holidayCount: null == holidayCount ? _self.holidayCount : holidayCount // ignore: cast_nullable_to_non_nullable
as int,isFirstWeekException: null == isFirstWeekException ? _self.isFirstWeekException : isFirstWeekException // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'leave_balance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LeaveBalance {

 int get remainingMinutes;/// 저장한 날(날짜만). 당일 연차는 회사 숫자에 이미 반영된 것으로 보고 빼지 않는다.
 DateTime get baseDate;
/// Create a copy of LeaveBalance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeaveBalanceCopyWith<LeaveBalance> get copyWith => _$LeaveBalanceCopyWithImpl<LeaveBalance>(this as LeaveBalance, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LeaveBalance;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeaveBalance&&(identical(other.remainingMinutes, _this.remainingMinutes) || other.remainingMinutes == _this.remainingMinutes)&&(identical(other.baseDate, _this.baseDate) || other.baseDate == _this.baseDate));
}


@override
int get hashCode {
  final _this = this as LeaveBalance;
  return Object.hash(runtimeType,_this.remainingMinutes,_this.baseDate);
}

@override
String toString() {
  final _this = this as LeaveBalance;
  return 'LeaveBalance(remainingMinutes: ${_this.remainingMinutes}, baseDate: ${_this.baseDate})';
}


}

/// @nodoc
abstract mixin class $LeaveBalanceCopyWith<$Res>  {
  factory $LeaveBalanceCopyWith(LeaveBalance value, $Res Function(LeaveBalance) _then) = _$LeaveBalanceCopyWithImpl;
@useResult
$Res call({
 int remainingMinutes, DateTime baseDate
});




}
/// @nodoc
class _$LeaveBalanceCopyWithImpl<$Res>
    implements $LeaveBalanceCopyWith<$Res> {
  _$LeaveBalanceCopyWithImpl(this._self, this._then);

  final LeaveBalance _self;
  final $Res Function(LeaveBalance) _then;

/// Create a copy of LeaveBalance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? remainingMinutes = null,Object? baseDate = null,}) {
  return _then(LeaveBalance(
remainingMinutes: null == remainingMinutes ? _self.remainingMinutes : remainingMinutes // ignore: cast_nullable_to_non_nullable
as int,baseDate: null == baseDate ? _self.baseDate : baseDate // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [LeaveBalance].
extension LeaveBalancePatterns on LeaveBalance {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeaveBalance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeaveBalance() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeaveBalance value)  $default,){
final _that = this;
switch (_that) {
case _LeaveBalance():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeaveBalance value)?  $default,){
final _that = this;
switch (_that) {
case _LeaveBalance() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int remainingMinutes,  DateTime baseDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeaveBalance() when $default != null:
return $default(_that.remainingMinutes,_that.baseDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int remainingMinutes,  DateTime baseDate)  $default,) {final _that = this;
switch (_that) {
case _LeaveBalance():
return $default(_that.remainingMinutes,_that.baseDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int remainingMinutes,  DateTime baseDate)?  $default,) {final _that = this;
switch (_that) {
case _LeaveBalance() when $default != null:
return $default(_that.remainingMinutes,_that.baseDate);case _:
  return null;

}
}

}

/// @nodoc


class _LeaveBalance implements LeaveBalance {
  const _LeaveBalance({required this.remainingMinutes, required this.baseDate});
  

@override final  int remainingMinutes;
/// 저장한 날(날짜만). 당일 연차는 회사 숫자에 이미 반영된 것으로 보고 빼지 않는다.
@override final  DateTime baseDate;

/// Create a copy of LeaveBalance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeaveBalanceCopyWith<_LeaveBalance> get copyWith => __$LeaveBalanceCopyWithImpl<_LeaveBalance>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeaveBalance&&(identical(other.remainingMinutes, remainingMinutes) || other.remainingMinutes == remainingMinutes)&&(identical(other.baseDate, baseDate) || other.baseDate == baseDate));
}


@override
int get hashCode {
    return Object.hash(runtimeType,remainingMinutes,baseDate);
}

@override
String toString() {
    return 'LeaveBalance(remainingMinutes: $remainingMinutes, baseDate: $baseDate)';
}


}

/// @nodoc
abstract mixin class _$LeaveBalanceCopyWith<$Res> implements $LeaveBalanceCopyWith<$Res> {
  factory _$LeaveBalanceCopyWith(_LeaveBalance value, $Res Function(_LeaveBalance) _then) = __$LeaveBalanceCopyWithImpl;
@override @useResult
$Res call({
 int remainingMinutes, DateTime baseDate
});




}
/// @nodoc
class __$LeaveBalanceCopyWithImpl<$Res>
    implements _$LeaveBalanceCopyWith<$Res> {
  __$LeaveBalanceCopyWithImpl(this._self, this._then);

  final _LeaveBalance _self;
  final $Res Function(_LeaveBalance) _then;

/// Create a copy of LeaveBalance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? remainingMinutes = null,Object? baseDate = null,}) {
  return _then(_LeaveBalance(
remainingMinutes: null == remainingMinutes ? _self.remainingMinutes : remainingMinutes // ignore: cast_nullable_to_non_nullable
as int,baseDate: null == baseDate ? _self.baseDate : baseDate // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on

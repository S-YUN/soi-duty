// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppSettings {

 WeekStart get weekStart;/// 해 → 그 해 총 연차(정수 일). 해마다 따로 — 새해에 고친 값이 지난해 카드를 바꾸지 않게.
 Map<int, int> get annualLeaveDaysByYear;/// 시급(원). null = 사용 안 함
 int? get hourlyWage;/// 마지막 내보내기 날짜(날짜만). null = 아직 내보낸 적 없음. 백업 파일에는 넣지 않는다 — 기기별 값.
 DateTime? get lastExportDate;
/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppSettingsCopyWith<AppSettings> get copyWith => _$AppSettingsCopyWithImpl<AppSettings>(this as AppSettings, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AppSettings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppSettings&&(identical(other.weekStart, _this.weekStart) || other.weekStart == _this.weekStart)&&const DeepCollectionEquality().equals(other.annualLeaveDaysByYear, _this.annualLeaveDaysByYear)&&(identical(other.hourlyWage, _this.hourlyWage) || other.hourlyWage == _this.hourlyWage)&&(identical(other.lastExportDate, _this.lastExportDate) || other.lastExportDate == _this.lastExportDate));
}


@override
int get hashCode {
  final _this = this as AppSettings;
  return Object.hash(runtimeType,_this.weekStart,const DeepCollectionEquality().hash(_this.annualLeaveDaysByYear),_this.hourlyWage,_this.lastExportDate);
}

@override
String toString() {
  final _this = this as AppSettings;
  return 'AppSettings(weekStart: ${_this.weekStart}, annualLeaveDaysByYear: ${_this.annualLeaveDaysByYear}, hourlyWage: ${_this.hourlyWage}, lastExportDate: ${_this.lastExportDate})';
}


}

/// @nodoc
abstract mixin class $AppSettingsCopyWith<$Res>  {
  factory $AppSettingsCopyWith(AppSettings value, $Res Function(AppSettings) _then) = _$AppSettingsCopyWithImpl;
@useResult
$Res call({
 WeekStart weekStart, Map<int, int> annualLeaveDaysByYear, int? hourlyWage, DateTime? lastExportDate
});




}
/// @nodoc
class _$AppSettingsCopyWithImpl<$Res>
    implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._self, this._then);

  final AppSettings _self;
  final $Res Function(AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? weekStart = null,Object? annualLeaveDaysByYear = null,Object? hourlyWage = freezed,Object? lastExportDate = freezed,}) {
  return _then(AppSettings(
weekStart: null == weekStart ? _self.weekStart : weekStart // ignore: cast_nullable_to_non_nullable
as WeekStart,annualLeaveDaysByYear: null == annualLeaveDaysByYear ? _self.annualLeaveDaysByYear : annualLeaveDaysByYear // ignore: cast_nullable_to_non_nullable
as Map<int, int>,hourlyWage: freezed == hourlyWage ? _self.hourlyWage : hourlyWage // ignore: cast_nullable_to_non_nullable
as int?,lastExportDate: freezed == lastExportDate ? _self.lastExportDate : lastExportDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AppSettings].
extension AppSettingsPatterns on AppSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppSettings value)  $default,){
final _that = this;
switch (_that) {
case _AppSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppSettings value)?  $default,){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( WeekStart weekStart,  Map<int, int> annualLeaveDaysByYear,  int? hourlyWage,  DateTime? lastExportDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.weekStart,_that.annualLeaveDaysByYear,_that.hourlyWage,_that.lastExportDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( WeekStart weekStart,  Map<int, int> annualLeaveDaysByYear,  int? hourlyWage,  DateTime? lastExportDate)  $default,) {final _that = this;
switch (_that) {
case _AppSettings():
return $default(_that.weekStart,_that.annualLeaveDaysByYear,_that.hourlyWage,_that.lastExportDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( WeekStart weekStart,  Map<int, int> annualLeaveDaysByYear,  int? hourlyWage,  DateTime? lastExportDate)?  $default,) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.weekStart,_that.annualLeaveDaysByYear,_that.hourlyWage,_that.lastExportDate);case _:
  return null;

}
}

}

/// @nodoc


class _AppSettings extends AppSettings {
  const _AppSettings({this.weekStart = WeekStart.monday,  Map<int, int> annualLeaveDaysByYear = const {}, this.hourlyWage, this.lastExportDate}): _annualLeaveDaysByYear = annualLeaveDaysByYear,super._();
  

@override@JsonKey() final  WeekStart weekStart;
/// 해 → 그 해 총 연차(정수 일). 해마다 따로 — 새해에 고친 값이 지난해 카드를 바꾸지 않게.
 final  Map<int, int> _annualLeaveDaysByYear;
/// 해 → 그 해 총 연차(정수 일). 해마다 따로 — 새해에 고친 값이 지난해 카드를 바꾸지 않게.
@override@JsonKey() Map<int, int> get annualLeaveDaysByYear {
  if (_annualLeaveDaysByYear is EqualUnmodifiableMapView) return _annualLeaveDaysByYear;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_annualLeaveDaysByYear);
}

/// 시급(원). null = 사용 안 함
@override final  int? hourlyWage;
/// 마지막 내보내기 날짜(날짜만). null = 아직 내보낸 적 없음. 백업 파일에는 넣지 않는다 — 기기별 값.
@override final  DateTime? lastExportDate;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppSettingsCopyWith<_AppSettings> get copyWith => __$AppSettingsCopyWithImpl<_AppSettings>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppSettings&&(identical(other.weekStart, weekStart) || other.weekStart == weekStart)&&const DeepCollectionEquality().equals(other.annualLeaveDaysByYear, _annualLeaveDaysByYear)&&(identical(other.hourlyWage, hourlyWage) || other.hourlyWage == hourlyWage)&&(identical(other.lastExportDate, lastExportDate) || other.lastExportDate == lastExportDate));
}


@override
int get hashCode {
    return Object.hash(runtimeType,weekStart,const DeepCollectionEquality().hash(_annualLeaveDaysByYear),hourlyWage,lastExportDate);
}

@override
String toString() {
    return 'AppSettings(weekStart: $weekStart, annualLeaveDaysByYear: $annualLeaveDaysByYear, hourlyWage: $hourlyWage, lastExportDate: $lastExportDate)';
}


}

/// @nodoc
abstract mixin class _$AppSettingsCopyWith<$Res> implements $AppSettingsCopyWith<$Res> {
  factory _$AppSettingsCopyWith(_AppSettings value, $Res Function(_AppSettings) _then) = __$AppSettingsCopyWithImpl;
@override @useResult
$Res call({
 WeekStart weekStart, Map<int, int> annualLeaveDaysByYear, int? hourlyWage, DateTime? lastExportDate
});




}
/// @nodoc
class __$AppSettingsCopyWithImpl<$Res>
    implements _$AppSettingsCopyWith<$Res> {
  __$AppSettingsCopyWithImpl(this._self, this._then);

  final _AppSettings _self;
  final $Res Function(_AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? weekStart = null,Object? annualLeaveDaysByYear = null,Object? hourlyWage = freezed,Object? lastExportDate = freezed,}) {
  return _then(_AppSettings(
weekStart: null == weekStart ? _self.weekStart : weekStart // ignore: cast_nullable_to_non_nullable
as WeekStart,annualLeaveDaysByYear: null == annualLeaveDaysByYear ? _self._annualLeaveDaysByYear : annualLeaveDaysByYear // ignore: cast_nullable_to_non_nullable
as Map<int, int>,hourlyWage: freezed == hourlyWage ? _self.hourlyWage : hourlyWage // ignore: cast_nullable_to_non_nullable
as int?,lastExportDate: freezed == lastExportDate ? _self.lastExportDate : lastExportDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on

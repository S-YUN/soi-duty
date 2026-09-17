// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'month_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// [month]의 1일을 키로 하는 family. 페이저가 이웃 달을 미리 그리므로 달마다 따로 계산한다.

@ProviderFor(monthState)
final monthStateProvider = MonthStateFamily._();

/// [month]의 1일을 키로 하는 family. 페이저가 이웃 달을 미리 그리므로 달마다 따로 계산한다.

final class MonthStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<MonthState>,
          MonthState,
          FutureOr<MonthState>
        >
    with $FutureModifier<MonthState>, $FutureProvider<MonthState> {
  /// [month]의 1일을 키로 하는 family. 페이저가 이웃 달을 미리 그리므로 달마다 따로 계산한다.
  MonthStateProvider._({
    required MonthStateFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'monthStateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$monthStateHash();

  @override
  String toString() {
    return r'monthStateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<MonthState> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<MonthState> create(Ref ref) {
    final argument = this.argument as DateTime;
    return monthState(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthStateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$monthStateHash() => r'4d2ea6a8f97f42fa52c754f9e344962be8d7acf2';

/// [month]의 1일을 키로 하는 family. 페이저가 이웃 달을 미리 그리므로 달마다 따로 계산한다.

final class MonthStateFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<MonthState>, DateTime> {
  MonthStateFamily._()
    : super(
        retry: null,
        name: r'monthStateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// [month]의 1일을 키로 하는 family. 페이저가 이웃 달을 미리 그리므로 달마다 따로 계산한다.

  MonthStateProvider call(DateTime month) =>
      MonthStateProvider._(argument: month, from: this);

  @override
  String toString() => r'monthStateProvider';
}

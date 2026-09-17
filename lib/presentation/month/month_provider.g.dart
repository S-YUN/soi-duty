// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'month_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(monthState)
final monthStateProvider = MonthStateProvider._();

final class MonthStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<MonthState>,
          MonthState,
          FutureOr<MonthState>
        >
    with $FutureModifier<MonthState>, $FutureProvider<MonthState> {
  MonthStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'monthStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$monthStateHash();

  @$internal
  @override
  $FutureProviderElement<MonthState> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<MonthState> create(Ref ref) {
    return monthState(ref);
  }
}

String _$monthStateHash() => r'4e7463a7d293afa5b291b210462add0ec54c46df';

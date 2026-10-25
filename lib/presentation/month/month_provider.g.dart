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

String _$monthStateHash() => r'249ed9a1d52e6355c7d63c49a8cbc4accbace2fc';

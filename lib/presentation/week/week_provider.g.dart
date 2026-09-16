// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'week_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(weekState)
final weekStateProvider = WeekStateProvider._();

final class WeekStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<WeekState>,
          WeekState,
          FutureOr<WeekState>
        >
    with $FutureModifier<WeekState>, $FutureProvider<WeekState> {
  WeekStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weekStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weekStateHash();

  @$internal
  @override
  $FutureProviderElement<WeekState> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<WeekState> create(Ref ref) {
    return weekState(ref);
  }
}

String _$weekStateHash() => r'4dcb27508f16fffe1849b21cb5a82ae8405d6d0c';

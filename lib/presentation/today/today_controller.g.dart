// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TodayController)
final todayControllerProvider = TodayControllerProvider._();

final class TodayControllerProvider
    extends $AsyncNotifierProvider<TodayController, TodayState> {
  TodayControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayControllerHash();

  @$internal
  @override
  TodayController create() => TodayController();
}

String _$todayControllerHash() => r'ea5a5447cd61db3f252cdfdc39576c2165b64981';

abstract class _$TodayController extends $AsyncNotifier<TodayState> {
  FutureOr<TodayState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<TodayState>, TodayState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TodayState>, TodayState>,
              AsyncValue<TodayState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

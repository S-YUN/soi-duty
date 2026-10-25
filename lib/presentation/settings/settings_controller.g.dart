// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 설정값 변경. 현재 값을 읽어 한 필드만 바꿔 저장한다 — 스트림이 화면들을 갱신한다.

@ProviderFor(SettingsController)
final settingsControllerProvider = SettingsControllerProvider._();

/// 설정값 변경. 현재 값을 읽어 한 필드만 바꿔 저장한다 — 스트림이 화면들을 갱신한다.
final class SettingsControllerProvider
    extends $AsyncNotifierProvider<SettingsController, AppSettings> {
  /// 설정값 변경. 현재 값을 읽어 한 필드만 바꿔 저장한다 — 스트림이 화면들을 갱신한다.
  SettingsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsControllerHash();

  @$internal
  @override
  SettingsController create() => SettingsController();
}

String _$settingsControllerHash() =>
    r'7e380f1bcdca698176e975337dc3d42275188a6a';

/// 설정값 변경. 현재 값을 읽어 한 필드만 바꿔 저장한다 — 스트림이 화면들을 갱신한다.

abstract class _$SettingsController extends $AsyncNotifier<AppSettings> {
  FutureOr<AppSettings> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AppSettings>, AppSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AppSettings>, AppSettings>,
              AsyncValue<AppSettings>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

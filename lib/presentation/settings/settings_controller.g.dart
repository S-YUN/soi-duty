// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 설정값 변경과 백업 동작. 상태가 없는 액션 모음이라 keepAlive — 화면이 붙잡아 둘 필요가 없다.
/// 현재 값을 읽어 한 필드만 바꿔 저장한다 — 스트림이 화면들을 갱신한다.

@ProviderFor(SettingsController)
final settingsControllerProvider = SettingsControllerProvider._();

/// 설정값 변경과 백업 동작. 상태가 없는 액션 모음이라 keepAlive — 화면이 붙잡아 둘 필요가 없다.
/// 현재 값을 읽어 한 필드만 바꿔 저장한다 — 스트림이 화면들을 갱신한다.
final class SettingsControllerProvider
    extends $NotifierProvider<SettingsController, void> {
  /// 설정값 변경과 백업 동작. 상태가 없는 액션 모음이라 keepAlive — 화면이 붙잡아 둘 필요가 없다.
  /// 현재 값을 읽어 한 필드만 바꿔 저장한다 — 스트림이 화면들을 갱신한다.
  SettingsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsControllerHash();

  @$internal
  @override
  SettingsController create() => SettingsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$settingsControllerHash() =>
    r'3e228fb71a5d2a91b61850676b118e9e23caeeab';

/// 설정값 변경과 백업 동작. 상태가 없는 액션 모음이라 keepAlive — 화면이 붙잡아 둘 필요가 없다.
/// 현재 값을 읽어 한 필드만 바꿔 저장한다 — 스트림이 화면들을 갱신한다.

abstract class _$SettingsController extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

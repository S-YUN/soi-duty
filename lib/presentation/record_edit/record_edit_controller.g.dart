// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record_edit_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 시트의 저장·삭제. 저장되면 allRecords 스트림이 돌아 모든 화면이 갱신된다.

@ProviderFor(RecordEditController)
final recordEditControllerProvider = RecordEditControllerProvider._();

/// 시트의 저장·삭제. 저장되면 allRecords 스트림이 돌아 모든 화면이 갱신된다.
final class RecordEditControllerProvider
    extends $NotifierProvider<RecordEditController, void> {
  /// 시트의 저장·삭제. 저장되면 allRecords 스트림이 돌아 모든 화면이 갱신된다.
  RecordEditControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recordEditControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recordEditControllerHash();

  @$internal
  @override
  RecordEditController create() => RecordEditController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$recordEditControllerHash() =>
    r'c2ff5286b39333c656fdb9705b8296a68fc1eb0e';

/// 시트의 저장·삭제. 저장되면 allRecords 스트림이 돌아 모든 화면이 갱신된다.

abstract class _$RecordEditController extends $Notifier<void> {
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

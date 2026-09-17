// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_week.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 주간 탭이 보고 있는 주의 월요일. 탭을 오가도 유지되고, 앱을 다시 켜면 이번 주.

@ProviderFor(SelectedWeek)
final selectedWeekProvider = SelectedWeekProvider._();

/// 주간 탭이 보고 있는 주의 월요일. 탭을 오가도 유지되고, 앱을 다시 켜면 이번 주.
final class SelectedWeekProvider
    extends $NotifierProvider<SelectedWeek, DateTime> {
  /// 주간 탭이 보고 있는 주의 월요일. 탭을 오가도 유지되고, 앱을 다시 켜면 이번 주.
  SelectedWeekProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedWeekProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedWeekHash();

  @$internal
  @override
  SelectedWeek create() => SelectedWeek();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$selectedWeekHash() => r'348f1bec6205890827f73f2b8a098577b6606d38';

/// 주간 탭이 보고 있는 주의 월요일. 탭을 오가도 유지되고, 앱을 다시 켜면 이번 주.

abstract class _$SelectedWeek extends $Notifier<DateTime> {
  DateTime build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DateTime, DateTime>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateTime, DateTime>,
              DateTime,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

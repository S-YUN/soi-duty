// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_month.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 월간 탭이 보고 있는 달의 1일. 탭을 오가도 유지되고, 앱을 다시 켜면 이번 달.
/// 범위는 첫 기록 달(없으면 이번 달)부터 올해 12월까지 — [earliestMonth]·[latestMonth].

@ProviderFor(SelectedMonth)
final selectedMonthProvider = SelectedMonthProvider._();

/// 월간 탭이 보고 있는 달의 1일. 탭을 오가도 유지되고, 앱을 다시 켜면 이번 달.
/// 범위는 첫 기록 달(없으면 이번 달)부터 올해 12월까지 — [earliestMonth]·[latestMonth].
final class SelectedMonthProvider
    extends $NotifierProvider<SelectedMonth, DateTime> {
  /// 월간 탭이 보고 있는 달의 1일. 탭을 오가도 유지되고, 앱을 다시 켜면 이번 달.
  /// 범위는 첫 기록 달(없으면 이번 달)부터 올해 12월까지 — [earliestMonth]·[latestMonth].
  SelectedMonthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedMonthProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedMonthHash();

  @$internal
  @override
  SelectedMonth create() => SelectedMonth();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$selectedMonthHash() => r'1d8681d31c928b938601e481471a7fa16297745b';

/// 월간 탭이 보고 있는 달의 1일. 탭을 오가도 유지되고, 앱을 다시 켜면 이번 달.
/// 범위는 첫 기록 달(없으면 이번 달)부터 올해 12월까지 — [earliestMonth]·[latestMonth].

abstract class _$SelectedMonth extends $Notifier<DateTime> {
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

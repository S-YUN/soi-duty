// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clock_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 액션이 시각을 찍을 때 쓰는 시계. 테스트에서 고정값으로 오버라이드한다.

@ProviderFor(clock)
final clockProvider = ClockProvider._();

/// 액션이 시각을 찍을 때 쓰는 시계. 테스트에서 고정값으로 오버라이드한다.

final class ClockProvider extends $FunctionalProvider<Clock, Clock, Clock>
    with $Provider<Clock> {
  /// 액션이 시각을 찍을 때 쓰는 시계. 테스트에서 고정값으로 오버라이드한다.
  ClockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clockProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clockHash();

  @$internal
  @override
  $ProviderElement<Clock> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Clock create(Ref ref) {
    return clock(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Clock value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Clock>(value),
    );
  }
}

String _$clockHash() => r'ce4c8073e4878f6859ed9a59fae2c1819b4179af';

/// 즉시 1회, 이후 매 분 정각에 방출. 자정 넘김·경과 시간·퇴근 예상 갱신은 전부 이걸로.

@ProviderFor(now)
final nowProvider = NowProvider._();

/// 즉시 1회, 이후 매 분 정각에 방출. 자정 넘김·경과 시간·퇴근 예상 갱신은 전부 이걸로.

final class NowProvider
    extends
        $FunctionalProvider<AsyncValue<DateTime>, DateTime, Stream<DateTime>>
    with $FutureModifier<DateTime>, $StreamProvider<DateTime> {
  /// 즉시 1회, 이후 매 분 정각에 방출. 자정 넘김·경과 시간·퇴근 예상 갱신은 전부 이걸로.
  NowProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nowProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nowHash();

  @$internal
  @override
  $StreamProviderElement<DateTime> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<DateTime> create(Ref ref) {
    return now(ref);
  }
}

String _$nowHash() => r'2da9364ff04cb2a01b500e9a49969cfac5d23c49';

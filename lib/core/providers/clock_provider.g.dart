// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clock_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 디버그 전용 시계 이동. 실제 시각에 이 오프셋을 더한 값이 앱의 "지금"이 된다.
/// 릴리즈에서는 [clock]이 이 값을 읽지 않는다.

@ProviderFor(DebugClockOffset)
final debugClockOffsetProvider = DebugClockOffsetProvider._();

/// 디버그 전용 시계 이동. 실제 시각에 이 오프셋을 더한 값이 앱의 "지금"이 된다.
/// 릴리즈에서는 [clock]이 이 값을 읽지 않는다.
final class DebugClockOffsetProvider
    extends $NotifierProvider<DebugClockOffset, Duration> {
  /// 디버그 전용 시계 이동. 실제 시각에 이 오프셋을 더한 값이 앱의 "지금"이 된다.
  /// 릴리즈에서는 [clock]이 이 값을 읽지 않는다.
  DebugClockOffsetProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'debugClockOffsetProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$debugClockOffsetHash();

  @$internal
  @override
  DebugClockOffset create() => DebugClockOffset();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Duration value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Duration>(value),
    );
  }
}

String _$debugClockOffsetHash() => r'6276f0830dce1f60792a5dd7c5d6db7ead58449b';

/// 디버그 전용 시계 이동. 실제 시각에 이 오프셋을 더한 값이 앱의 "지금"이 된다.
/// 릴리즈에서는 [clock]이 이 값을 읽지 않는다.

abstract class _$DebugClockOffset extends $Notifier<Duration> {
  Duration build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Duration, Duration>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Duration, Duration>,
              Duration,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

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

String _$clockHash() => r'7b4d545aaf46fc6cd9f47ca3608587338a5e1516';

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

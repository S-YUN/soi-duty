// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// OS 로컬 알림으로 가는 길. 테스트는 Fake로 오버라이드한다 — 플러그인은 테스트 환경에 없다.

@ProviderFor(notificationScheduler)
final notificationSchedulerProvider = NotificationSchedulerProvider._();

/// OS 로컬 알림으로 가는 길. 테스트는 Fake로 오버라이드한다 — 플러그인은 테스트 환경에 없다.

final class NotificationSchedulerProvider
    extends
        $FunctionalProvider<
          NotificationScheduler,
          NotificationScheduler,
          NotificationScheduler
        >
    with $Provider<NotificationScheduler> {
  /// OS 로컬 알림으로 가는 길. 테스트는 Fake로 오버라이드한다 — 플러그인은 테스트 환경에 없다.
  NotificationSchedulerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationSchedulerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationSchedulerHash();

  @$internal
  @override
  $ProviderElement<NotificationScheduler> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationScheduler create(Ref ref) {
    return notificationScheduler(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationScheduler value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationScheduler>(value),
    );
  }
}

String _$notificationSchedulerHash() =>
    r'26a9acca0fced6195c2a07802d812a98c8f830c6';

@ProviderFor(notificationStateRepository)
final notificationStateRepositoryProvider =
    NotificationStateRepositoryProvider._();

final class NotificationStateRepositoryProvider
    extends
        $FunctionalProvider<
          NotificationStateRepository,
          NotificationStateRepository,
          NotificationStateRepository
        >
    with $Provider<NotificationStateRepository> {
  NotificationStateRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationStateRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationStateRepositoryHash();

  @$internal
  @override
  $ProviderElement<NotificationStateRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationStateRepository create(Ref ref) {
    return notificationStateRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationStateRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationStateRepository>(value),
    );
  }
}

String _$notificationStateRepositoryHash() =>
    r'02988e83a6581135315e736a15b2c100d260babf';

/// 오늘 날짜(시분 0). 시계가 매 분 돌 때마다 다시 계산되지만 값은 날짜가 바뀔 때만 달라진다 —
/// 동기화는 계획이 실제로 달라졌을 때만 움직인다(`ClockOutNotificationSync.build`의 비교).

@ProviderFor(todayDate)
final todayDateProvider = TodayDateProvider._();

/// 오늘 날짜(시분 0). 시계가 매 분 돌 때마다 다시 계산되지만 값은 날짜가 바뀔 때만 달라진다 —
/// 동기화는 계획이 실제로 달라졌을 때만 움직인다(`ClockOutNotificationSync.build`의 비교).

final class TodayDateProvider
    extends
        $FunctionalProvider<AsyncValue<DateTime>, DateTime, FutureOr<DateTime>>
    with $FutureModifier<DateTime>, $FutureProvider<DateTime> {
  /// 오늘 날짜(시분 0). 시계가 매 분 돌 때마다 다시 계산되지만 값은 날짜가 바뀔 때만 달라진다 —
  /// 동기화는 계획이 실제로 달라졌을 때만 움직인다(`ClockOutNotificationSync.build`의 비교).
  TodayDateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayDateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayDateHash();

  @$internal
  @override
  $FutureProviderElement<DateTime> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<DateTime> create(Ref ref) {
    return todayDate(ref);
  }
}

String _$todayDateHash() => r'cc9edafbade8affa0132a8924908498e0acf3fb5';

/// 오늘 보낼 퇴근 알림(무엇을 언제). 근무 중이 아니거나 보낼 게 없으면 null.
/// 동기화에는 **다시 맞출 때를 알리는 신호**로만 쓰인다 — 실제 예약에 쓰는 계획은 동기화가 그 순간의 시각으로 다시 센다.
/// 기록·첫 기록일이 아직 안 온 동안은 loading — "없음"과 구분해야 시작할 때 예약을 지우지 않는다.

@ProviderFor(clockOutNoticePlan)
final clockOutNoticePlanProvider = ClockOutNoticePlanProvider._();

/// 오늘 보낼 퇴근 알림(무엇을 언제). 근무 중이 아니거나 보낼 게 없으면 null.
/// 동기화에는 **다시 맞출 때를 알리는 신호**로만 쓰인다 — 실제 예약에 쓰는 계획은 동기화가 그 순간의 시각으로 다시 센다.
/// 기록·첫 기록일이 아직 안 온 동안은 loading — "없음"과 구분해야 시작할 때 예약을 지우지 않는다.

final class ClockOutNoticePlanProvider
    extends
        $FunctionalProvider<
          AsyncValue<ClockOutNotice?>,
          ClockOutNotice?,
          FutureOr<ClockOutNotice?>
        >
    with $FutureModifier<ClockOutNotice?>, $FutureProvider<ClockOutNotice?> {
  /// 오늘 보낼 퇴근 알림(무엇을 언제). 근무 중이 아니거나 보낼 게 없으면 null.
  /// 동기화에는 **다시 맞출 때를 알리는 신호**로만 쓰인다 — 실제 예약에 쓰는 계획은 동기화가 그 순간의 시각으로 다시 센다.
  /// 기록·첫 기록일이 아직 안 온 동안은 loading — "없음"과 구분해야 시작할 때 예약을 지우지 않는다.
  ClockOutNoticePlanProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clockOutNoticePlanProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clockOutNoticePlanHash();

  @$internal
  @override
  $FutureProviderElement<ClockOutNotice?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ClockOutNotice?> create(Ref ref) {
    return clockOutNoticePlan(ref);
  }
}

String _$clockOutNoticePlanHash() =>
    r'ca05048c96d84d894b882ef08a37da335b9dae14';

/// 앱으로 돌아올 때(OS 설정에서 바꾸고 옴)와 권한 창 뒤에 invalidate한다.

@ProviderFor(notificationPermission)
final notificationPermissionProvider = NotificationPermissionProvider._();

/// 앱으로 돌아올 때(OS 설정에서 바꾸고 옴)와 권한 창 뒤에 invalidate한다.

final class NotificationPermissionProvider
    extends
        $FunctionalProvider<
          AsyncValue<NotificationPermission>,
          NotificationPermission,
          FutureOr<NotificationPermission>
        >
    with
        $FutureModifier<NotificationPermission>,
        $FutureProvider<NotificationPermission> {
  /// 앱으로 돌아올 때(OS 설정에서 바꾸고 옴)와 권한 창 뒤에 invalidate한다.
  NotificationPermissionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationPermissionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationPermissionHash();

  @$internal
  @override
  $FutureProviderElement<NotificationPermission> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<NotificationPermission> create(Ref ref) {
    return notificationPermission(ref);
  }
}

String _$notificationPermissionHash() =>
    r'93969a2b15af6f1a1a1199005f3ae959f86c1605';

/// 예약한 시각에 정시로 울릴 수 있는지 (Android "알람 및 리마인더"). 확인에 실패하면 true로 본다 — 없는 문제를 경고하지 않는다.
/// 앱으로 돌아올 때 invalidate한다.

@ProviderFor(exactAlarmAllowed)
final exactAlarmAllowedProvider = ExactAlarmAllowedProvider._();

/// 예약한 시각에 정시로 울릴 수 있는지 (Android "알람 및 리마인더"). 확인에 실패하면 true로 본다 — 없는 문제를 경고하지 않는다.
/// 앱으로 돌아올 때 invalidate한다.

final class ExactAlarmAllowedProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// 예약한 시각에 정시로 울릴 수 있는지 (Android "알람 및 리마인더"). 확인에 실패하면 true로 본다 — 없는 문제를 경고하지 않는다.
  /// 앱으로 돌아올 때 invalidate한다.
  ExactAlarmAllowedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exactAlarmAllowedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exactAlarmAllowedHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return exactAlarmAllowed(ref);
  }
}

String _$exactAlarmAllowedHash() => r'0ef71e6626869be55080381a9fc96a3d592f357e';

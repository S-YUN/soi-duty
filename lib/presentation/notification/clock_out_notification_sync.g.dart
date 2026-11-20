// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clock_out_notification_sync.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// OS에 걸어둔 퇴근 알림 예약을 지금 상태에 맞춘다 — **예약을 건드리는 곳은 여기 하나뿐이다.**
///
/// 출근·퇴근·반차·출근 변경 버튼이 각자 예약을 고치면 빠지는 경우가 생긴다. 대신 "오늘의 계획"(`clockOutNoticePlan`)이나
/// 알림 설정이 바뀔 때마다, 그리고 앱으로 돌아올 때마다 [sync]가 계획과 OS 예약을 다시 맞춘다.
///
/// ```
/// 알림 꺼짐 · OS 권한 없음 · 계획 없음   → 예약 취소, 저장된 알림 지움
/// 계획 시각이 아직 안 옴                 → 같은 알림이 이미 예약돼 있으면 그대로, 아니면 예약(대체) + 저장
/// 계획 시각이 이미 지남 (N3)             → 오늘 이미 전달됐으면 아무것도 안 함, 아니면 지금 띄우고 저장
/// ```
///
/// "저장된 알림"(`NotificationStateRepository.lastNotice`)의 시각이 지났으면 OS가 이미 띄운 것으로 본다.
/// 그래서 퇴근 시각이 지난 뒤 앱을 다시 켜거나 지난 기록을 고쳐도 같은 알림이 또 울리지 않는다.
/// 계획이 **미래로 옮겨가면**(반차 해제, 출근 시각을 늦춤) 이미 울렸어도 새로 예약한다 — 앞의 알림이 틀린 데이터로 울린 것이다.

@ProviderFor(ClockOutNotificationSync)
final clockOutNotificationSyncProvider = ClockOutNotificationSyncProvider._();

/// OS에 걸어둔 퇴근 알림 예약을 지금 상태에 맞춘다 — **예약을 건드리는 곳은 여기 하나뿐이다.**
///
/// 출근·퇴근·반차·출근 변경 버튼이 각자 예약을 고치면 빠지는 경우가 생긴다. 대신 "오늘의 계획"(`clockOutNoticePlan`)이나
/// 알림 설정이 바뀔 때마다, 그리고 앱으로 돌아올 때마다 [sync]가 계획과 OS 예약을 다시 맞춘다.
///
/// ```
/// 알림 꺼짐 · OS 권한 없음 · 계획 없음   → 예약 취소, 저장된 알림 지움
/// 계획 시각이 아직 안 옴                 → 같은 알림이 이미 예약돼 있으면 그대로, 아니면 예약(대체) + 저장
/// 계획 시각이 이미 지남 (N3)             → 오늘 이미 전달됐으면 아무것도 안 함, 아니면 지금 띄우고 저장
/// ```
///
/// "저장된 알림"(`NotificationStateRepository.lastNotice`)의 시각이 지났으면 OS가 이미 띄운 것으로 본다.
/// 그래서 퇴근 시각이 지난 뒤 앱을 다시 켜거나 지난 기록을 고쳐도 같은 알림이 또 울리지 않는다.
/// 계획이 **미래로 옮겨가면**(반차 해제, 출근 시각을 늦춤) 이미 울렸어도 새로 예약한다 — 앞의 알림이 틀린 데이터로 울린 것이다.
final class ClockOutNotificationSyncProvider
    extends $NotifierProvider<ClockOutNotificationSync, void> {
  /// OS에 걸어둔 퇴근 알림 예약을 지금 상태에 맞춘다 — **예약을 건드리는 곳은 여기 하나뿐이다.**
  ///
  /// 출근·퇴근·반차·출근 변경 버튼이 각자 예약을 고치면 빠지는 경우가 생긴다. 대신 "오늘의 계획"(`clockOutNoticePlan`)이나
  /// 알림 설정이 바뀔 때마다, 그리고 앱으로 돌아올 때마다 [sync]가 계획과 OS 예약을 다시 맞춘다.
  ///
  /// ```
  /// 알림 꺼짐 · OS 권한 없음 · 계획 없음   → 예약 취소, 저장된 알림 지움
  /// 계획 시각이 아직 안 옴                 → 같은 알림이 이미 예약돼 있으면 그대로, 아니면 예약(대체) + 저장
  /// 계획 시각이 이미 지남 (N3)             → 오늘 이미 전달됐으면 아무것도 안 함, 아니면 지금 띄우고 저장
  /// ```
  ///
  /// "저장된 알림"(`NotificationStateRepository.lastNotice`)의 시각이 지났으면 OS가 이미 띄운 것으로 본다.
  /// 그래서 퇴근 시각이 지난 뒤 앱을 다시 켜거나 지난 기록을 고쳐도 같은 알림이 또 울리지 않는다.
  /// 계획이 **미래로 옮겨가면**(반차 해제, 출근 시각을 늦춤) 이미 울렸어도 새로 예약한다 — 앞의 알림이 틀린 데이터로 울린 것이다.
  ClockOutNotificationSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clockOutNotificationSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clockOutNotificationSyncHash();

  @$internal
  @override
  ClockOutNotificationSync create() => ClockOutNotificationSync();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$clockOutNotificationSyncHash() =>
    r'a4857a97d35250eadd4f106d42717831e4c264d1';

/// OS에 걸어둔 퇴근 알림 예약을 지금 상태에 맞춘다 — **예약을 건드리는 곳은 여기 하나뿐이다.**
///
/// 출근·퇴근·반차·출근 변경 버튼이 각자 예약을 고치면 빠지는 경우가 생긴다. 대신 "오늘의 계획"(`clockOutNoticePlan`)이나
/// 알림 설정이 바뀔 때마다, 그리고 앱으로 돌아올 때마다 [sync]가 계획과 OS 예약을 다시 맞춘다.
///
/// ```
/// 알림 꺼짐 · OS 권한 없음 · 계획 없음   → 예약 취소, 저장된 알림 지움
/// 계획 시각이 아직 안 옴                 → 같은 알림이 이미 예약돼 있으면 그대로, 아니면 예약(대체) + 저장
/// 계획 시각이 이미 지남 (N3)             → 오늘 이미 전달됐으면 아무것도 안 함, 아니면 지금 띄우고 저장
/// ```
///
/// "저장된 알림"(`NotificationStateRepository.lastNotice`)의 시각이 지났으면 OS가 이미 띄운 것으로 본다.
/// 그래서 퇴근 시각이 지난 뒤 앱을 다시 켜거나 지난 기록을 고쳐도 같은 알림이 또 울리지 않는다.
/// 계획이 **미래로 옮겨가면**(반차 해제, 출근 시각을 늦춤) 이미 울렸어도 새로 예약한다 — 앞의 알림이 틀린 데이터로 울린 것이다.

abstract class _$ClockOutNotificationSync extends $Notifier<void> {
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

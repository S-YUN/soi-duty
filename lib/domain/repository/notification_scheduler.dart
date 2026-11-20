/// 지금 OS가 이 앱의 알림을 허용하는지.
enum OsNotificationStatus { granted, notGranted }

/// OS 로컬 알림으로 가는 길 — 퇴근 알림 하나만 다룬다. 구현은 data/(flutter_local_notifications), 테스트는 Fake.
/// 서버가 없으므로 예약은 OS에 맡긴다 — 앱이 꺼져 있어도 OS가 그 시각에 띄운다.
abstract interface class NotificationScheduler {
  /// 지금 허용 상태. 권한 창을 띄우지 않는다.
  Future<OsNotificationStatus> status();

  /// OS 권한 창을 띄운다. 허용되면 true. 이미 거부한 기기(iOS는 한 번뿐)에서는 창 없이 false.
  Future<bool> requestPermission();

  /// 예약한 시각에 **정시로** 울릴 수 있는지. Android는 "알람 및 리마인더" 권한이 없으면 OS가 알람을 최대 1시간 늦춘다
  /// (Android 14+는 사용자가 설정에서 직접 켜야 한다). iOS는 늘 true.
  Future<bool> canScheduleExact();

  /// OS의 "알람 및 리마인더" 설정 화면을 연다(Android). 사용자가 돌아오면 허용 여부를 돌려준다.
  Future<bool> requestExactAlarm();

  /// 퇴근 알림을 [at](실제 기기 시각)에 예약한다. 이전 예약을 대체한다 — 예약은 늘 하나뿐이다.
  /// 정시 권한이 있으면 정시로, 없으면 늦을 수 있는 방식으로 건다.
  Future<void> schedule({required DateTime at, required String title, required String body});

  /// 지금 바로 띄운다.
  Future<void> showNow({required String title, required String body});

  /// 아직 안 울린 예약을 취소한다. 이미 뜬 알림은 건드리지 않는다.
  Future<void> cancel();

  /// OS의 이 앱 알림 설정 화면을 연다.
  Future<void> openSystemSettings();
}

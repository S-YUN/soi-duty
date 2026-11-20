import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../domain/repository/notification_scheduler.dart';

/// 퇴근 알림의 플랫폼 구현 (flutter_local_notifications).
///
/// - **예약은 OS가 들고 있다.** 앱이 백그라운드든 종료됐든 그 시각에 OS가 띄운다. Android는 재부팅 뒤에도
///   플러그인의 부트 리시버가 다시 건다(manifest의 `ScheduledNotificationBootReceiver`).
/// - **앱을 보고 있을 때도 배너를 띄운다** — iOS는 기본이 "포그라운드에선 안 보임"이라 present 옵션을 켠다
///   (AppDelegate의 `UNUserNotificationCenter.delegate` 설정이 함께 있어야 한다).
/// - **워치**: 별도 처리 없음. 폰 알림을 OS가 Apple Watch·Wear OS로 넘긴다 — 넘어가는 걸 막는 옵션(local only)을 쓰지 않고,
///   손목이 울리도록 소리·진동이 있는 중요도로 보낸다.
/// - **Android는 "알람 및 리마인더" 권한이 있으면 정시로, 없으면 늦을 수 있는 방식으로 건다.** 권한 없이 걸면 OS가 알람을
///   남은 시간의 75%(상한 1시간)까지 늦춘다 — 실기기에서 5분 뒤 예약이 3분 45초, 2시간 뒤 예약은 허용 오차 1시간으로 잡혔다(2026-11-20).
///   출근 때 8시간 뒤로 거는 퇴근 알림은 늘 1시간 상한에 걸려 쓸 수 없다. 권한 안내는 화면이 한다([requestExactAlarm]).
/// - **권한은 초기화 때 묻지 않는다.** 묻는 시점은 화면이 정한다([requestPermission]).
class LocalNotificationScheduler implements NotificationScheduler {
  LocalNotificationScheduler({
    required this.channelName,
    required this.channelDescription,
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  /// 알림은 늘 하나 — 같은 id로 예약·표시하면 앞의 것을 대체한다.
  static const notificationId = 1;
  static const channelId = 'clock_out';

  /// Android OS 설정에 보이는 알림 채널 이름·설명 — 문구는 presentation의 texts가 넘긴다.
  final String channelName;
  final String channelDescription;
  static const _androidIcon = 'ic_stat_soi';

  final FlutterLocalNotificationsPlugin _plugin;
  Future<void>? _ready;

  /// 초기화는 한 번. 실패하면 다음 호출이 다시 시도한다 — 실패한 Future를 붙들고 있으면 앱을 다시 켤 때까지 알림이 죽는다.
  Future<void> _ensureReady() => _ready ??= _init().catchError((Object e) {
        _ready = null;
        throw e;
      });

  Future<void> _init() async {
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings(_androidIcon),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
          defaultPresentBadge: false,
        ),
      ),
    );
  }

  NotificationDetails get _details => NotificationDetails(
    android: AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      // 헤드업 배너 + 소리·진동. 워치로 넘어갔을 때 손목이 울린다.
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.reminder,
    ),
    iOS: const DarwinNotificationDetails(
      presentBanner: true,
      presentList: true,
      presentSound: true,
      presentBadge: false,
    ),
  );

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  IOSFlutterLocalNotificationsPlugin? get _ios =>
      _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

  @override
  Future<OsNotificationStatus> status() async {
    await _ensureReady();
    final bool enabled;
    if (defaultTargetPlatform == TargetPlatform.android) {
      enabled = await _android?.areNotificationsEnabled() ?? false;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      enabled = (await _ios?.checkPermissions())?.isEnabled ?? false;
    } else {
      enabled = false;
    }
    return enabled ? OsNotificationStatus.granted : OsNotificationStatus.notGranted;
  }

  @override
  Future<bool> requestPermission() async {
    await _ensureReady();
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Android 12 이하는 창 없이 현재 허용 여부가 돌아온다.
      return await _android?.requestNotificationsPermission() ?? false;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return await _ios?.requestPermissions(alert: true, sound: true) ?? false;
    }
    return false;
  }

  @override
  Future<bool> canScheduleExact() async {
    if (defaultTargetPlatform != TargetPlatform.android) return true;
    await _ensureReady();
    return await _android?.canScheduleExactNotifications() ?? false;
  }

  @override
  Future<bool> requestExactAlarm() async {
    if (defaultTargetPlatform != TargetPlatform.android) return true;
    await _ensureReady();
    // 시스템 설정의 "알람 및 리마인더" 화면이 열리고, 돌아오면 결과가 온다.
    return await _android?.requestExactAlarmsPermission() ?? false;
  }

  /// 정시 권한이 있으면 정시(절전 중에도), 없으면 늦을 수 있는 방식. 권한 없이 정시 방식을 부르면 플러그인이 예약을 건너뛴다.
  @visibleForTesting
  static AndroidScheduleMode scheduleModeFor({required bool exactAllowed}) =>
      exactAllowed ? AndroidScheduleMode.exactAllowWhileIdle : AndroidScheduleMode.inexactAllowWhileIdle;

  @override
  Future<void> schedule({required DateTime at, required String title, required String body}) async {
    await _ensureReady();
    // 플러그인은 과거 시각 예약을 거절한다(ArgumentError). 분 경계에서 막 지났으면 지금 띄운다 — 알림이 통째로 사라지는 것보다 낫다.
    // 이때 앞서 걸어둔 예약은 먼저 치운다 — Android는 같은 id의 "표시"가 "예약"을 대체하지 않아 나중에 한 번 더 울린다.
    Future<void> showInstead() async {
      await cancel();
      await showNow(title: title, body: body);
    }

    if (!at.isAfter(DateTime.now())) return showInstead();
    try {
      await _plugin.zonedSchedule(
        id: notificationId,
        title: title,
        body: body,
        scheduledDate: toScheduledDate(at),
        notificationDetails: _details,
        androidScheduleMode: scheduleModeFor(exactAllowed: await canScheduleExact()),
      );
    } on ArgumentError {
      // 위 확인과 플러그인의 확인 사이에 시각이 지났다.
      await showInstead();
    }
  }

  @override
  Future<void> showNow({required String title, required String body}) async {
    await _ensureReady();
    await _plugin.show(id: notificationId, title: title, body: body, notificationDetails: _details);
  }

  @override
  Future<void> cancel() async {
    await _ensureReady();
    // 예약만 지운다 — 이미 떠 있는 알림까지 지우면 퇴근 버튼을 누르는 순간 방금 온 알림이 사라진다.
    await _plugin.cancelAllPendingNotifications();
  }

  @override
  Future<void> openSystemSettings() async {
    await _ensureReady();
    await _plugin.openAppNotificationSettings();
  }

  /// 기기 시각 → 플러그인이 받는 절대 시각. UTC로 넘긴다 — 한 번 울리는 알림은 "그 순간"만 맞으면 되고,
  /// 기기의 시간대 이름을 알아낼 필요가 없어 시간대 DB 초기화·조회가 실패할 일이 없다. (매일 반복 알림을 만들게 되면 다시 본다.)
  ///
  /// 초 아래는 버린다 — 네이티브로는 ISO 문자열로 넘어가는데 마이크로초 6자리는 iOS의 날짜 파서가 못 읽을 수 있다
  /// (디버그 시계 오프셋을 빼면 마이크로초가 붙는다).
  @visibleForTesting
  static tz.TZDateTime toScheduledDate(DateTime at) => tz.TZDateTime.fromMillisecondsSinceEpoch(
        tz.UTC,
        at.millisecondsSinceEpoch - at.millisecondsSinceEpoch % Duration.millisecondsPerSecond,
      );
}

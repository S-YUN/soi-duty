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
/// - **정확한 알람 권한을 쓰지 않는다**(`inexactAllowWhileIdle`). Android 14+에서 정확한 알람은 사용자가 따로 허용해야 하고
///   Play 정책 심사 대상이다. 퇴근 알림은 몇 분 늦어도 된다.
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

  Future<void> _ensureReady() => _ready ??= _init();

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
  Future<void> schedule({required DateTime at, required String title, required String body}) async {
    await _ensureReady();
    // 플러그인은 과거 시각 예약을 거절한다. 분 경계에서 막 지났으면 지금 띄운다 — 알림이 통째로 사라지는 것보다 낫다.
    if (!at.isAfter(DateTime.now())) return showNow(title: title, body: body);
    await _plugin.zonedSchedule(
      id: notificationId,
      title: title,
      body: body,
      scheduledDate: toScheduledDate(at),
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
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
  @visibleForTesting
  static tz.TZDateTime toScheduledDate(DateTime at) => tz.TZDateTime.from(at, tz.UTC);
}

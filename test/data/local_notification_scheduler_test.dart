import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/data/notification/local_notification_scheduler.dart';

void main() {
  test('예약 시각은 기기 시각과 같은 순간의 UTC — 시간대 DB 초기화 없이 만들어진다', () {
    final at = DateTime(2026, 9, 16, 17, 30);
    final scheduled = LocalNotificationScheduler.toScheduledDate(at);
    expect(scheduled.isUtc, isTrue);
    expect(scheduled.millisecondsSinceEpoch, at.millisecondsSinceEpoch);
    // 네이티브 쪽(ZoneId.of / NSTimeZone)이 아는 이름이어야 한다
    expect(scheduled.location.name, anyOf('UTC', 'Etc/UTC'));
  });

  test('알림 id·채널은 하나 — 같은 id로 예약하면 앞의 예약을 대체한다', () {
    expect(LocalNotificationScheduler.notificationId, 1);
    expect(LocalNotificationScheduler.channelId, 'clock_out');
  });

  test('초 아래(밀리초·마이크로초)는 버린다 — 디버그 시계 오프셋을 뺀 시각도 네이티브 파서가 읽는다', () {
    final at = DateTime(2026, 9, 16, 17, 30, 12, 345, 678);
    final scheduled = LocalNotificationScheduler.toScheduledDate(at);
    expect(scheduled.millisecondsSinceEpoch, DateTime(2026, 9, 16, 17, 30, 12).millisecondsSinceEpoch);
    expect(scheduled.microsecond, 0);
    expect(scheduled.toIso8601String(), endsWith('.000Z'));
  });

  test('"알람 및 리마인더"가 허용되면 정시(절전 중에도), 아니면 늦을 수 있는 방식으로 건다', () {
    expect(LocalNotificationScheduler.scheduleModeFor(exactAllowed: true), AndroidScheduleMode.exactAllowWhileIdle);
    expect(LocalNotificationScheduler.scheduleModeFor(exactAllowed: false), AndroidScheduleMode.inexactAllowWhileIdle);
  });
}

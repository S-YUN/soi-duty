import 'package:soi_duty/domain/repository/notification_scheduler.dart';

/// OS 알림 대신 — 무엇이 언제 예약·발송·취소됐는지 적어 둔다. 플러그인은 테스트 환경에 없다.
class FakeNotificationScheduler implements NotificationScheduler {
  FakeNotificationScheduler({this.osStatus = OsNotificationStatus.granted, this.requestResult = true});

  /// 지금 OS 허용 상태 — 테스트가 바꾼다(OS 설정에서 끄고 켠 흉내).
  OsNotificationStatus osStatus;

  /// 권한 창의 결과. true면 허용으로 바뀐다.
  bool requestResult;

  /// 호출 기록: `schedule 2026-09-16 17:30 퇴근할 시간이에요` · `showNow 퇴근할 시간이에요` · `cancel`
  final log = <String>[];

  /// OS에 걸려 있는 예약(하나뿐). 없으면 null.
  DateTime? scheduledAt;
  String? scheduledTitle;
  String? scheduledBody;
  final shown = <(String title, String body)>[];
  var requestCount = 0;
  var openSettingsCount = 0;

  /// 다음 schedule 호출을 실패시킨다(플러그인·OS 오류 흉내).
  var failNextSchedule = false;

  int count(String prefix) => log.where((l) => l.startsWith(prefix)).length;

  @override
  Future<OsNotificationStatus> status() async => osStatus;

  @override
  Future<bool> requestPermission() async {
    requestCount++;
    if (requestResult) osStatus = OsNotificationStatus.granted;
    return requestResult;
  }

  @override
  Future<void> schedule({required DateTime at, required String title, required String body}) async {
    if (failNextSchedule) {
      failNextSchedule = false;
      throw StateError('schedule failed');
    }
    scheduledAt = at;
    scheduledTitle = title;
    scheduledBody = body;
    String two(int v) => v.toString().padLeft(2, '0');
    log.add('schedule ${at.year}-${two(at.month)}-${two(at.day)} ${two(at.hour)}:${two(at.minute)} $title');
  }

  @override
  Future<void> showNow({required String title, required String body}) async {
    shown.add((title, body));
    log.add('showNow $title');
  }

  @override
  Future<void> cancel() async {
    scheduledAt = null;
    scheduledTitle = null;
    scheduledBody = null;
    log.add('cancel');
  }

  @override
  Future<void> openSystemSettings() async => openSettingsCount++;
}

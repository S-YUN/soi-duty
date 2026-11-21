import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/notification/local_notification_scheduler.dart';
import '../../data/repository/drift_notification_state_repository.dart';
import '../../domain/notification/clock_out_notice.dart';
import '../../domain/repository/notification_scheduler.dart';
import '../../domain/repository/notification_state_repository.dart';
import '../../domain/rules/work_calculator.dart';
import '../../presentation/notification/notification_texts.dart';
import 'clock_provider.dart';
import 'database_providers.dart';

part 'notification_providers.g.dart';

/// OS 로컬 알림으로 가는 길. 테스트는 Fake로 오버라이드한다 — 플러그인은 테스트 환경에 없다.
@Riverpod(keepAlive: true)
NotificationScheduler notificationScheduler(Ref ref) => LocalNotificationScheduler(
      channelName: NotificationTexts.channelName,
      channelDescription: NotificationTexts.channelDescription,
    );

@Riverpod(keepAlive: true)
NotificationStateRepository notificationStateRepository(Ref ref) =>
    DriftNotificationStateRepository(ref.watch(appDatabaseProvider));

/// 오늘 날짜(시분 0). 시계가 매 분 돌 때마다 다시 계산되지만 값은 날짜가 바뀔 때만 달라진다 —
/// 동기화는 계획이 실제로 달라졌을 때만 움직인다(`ClockOutNotificationSync.build`의 비교).
@Riverpod(keepAlive: true)
Future<DateTime> todayDate(Ref ref) async => dateOnly(await ref.watch(nowProvider.future));

/// 오늘 보낼 퇴근 알림(무엇을 언제). 근무 중이 아니거나 보낼 게 없으면 null.
/// 동기화에는 **다시 맞출 때를 알리는 신호**로만 쓰인다 — 실제 예약에 쓰는 계획은 동기화가 그 순간의 시각으로 다시 센다.
/// 기록·첫 기록일이 아직 안 온 동안은 loading — "없음"과 구분해야 시작할 때 예약을 지우지 않는다.
@Riverpod(keepAlive: true)
Future<ClockOutNotice?> clockOutNoticePlan(Ref ref) async {
  final records = await ref.watch(allRecordsProvider.future);
  final firstRecordDate = await ref.watch(firstRecordDateProvider.future);
  final today = await ref.watch(todayDateProvider.future);
  final rules = ref.watch(workRulesProvider);
  return planClockOutNotice(
    records: records,
    today: today,
    rules: rules,
    firstRecordDate: effectiveFirstRecordDate(firstRecordDate, today),
  );
}

/// 화면이 보는 권한 상태. OS는 "아직 안 물어봄"과 "거부함"을 구분해 주지 않아, 우리가 OS 창을 띄운 적이 있는지로 가른다.
enum NotificationPermission {
  granted,

  /// 허용이 아니고 OS 창을 띄운 적도 없다 — 켜는 순간 OS 창이 뜬다.
  notDetermined,

  /// 허용이 아니고 이미 물어봤다(또는 OS 설정에서 껐다) — 앱에서 켤 수 없고 OS 설정으로 보내야 한다.
  denied,
}

/// 앱으로 돌아올 때(OS 설정에서 바꾸고 옴)와 권한 창 뒤에 invalidate한다.
@riverpod
Future<NotificationPermission> notificationPermission(Ref ref) async {
  final status = await ref.watch(notificationSchedulerProvider).status();
  if (status == OsNotificationStatus.granted) return NotificationPermission.granted;
  final asked = await ref.watch(notificationStateRepositoryProvider).osAsked();
  return asked ? NotificationPermission.denied : NotificationPermission.notDetermined;
}

/// 예약한 시각에 정시로 울릴 수 있는지 (Android "알람 및 리마인더"). false면 알림을 예약하지 않는다.
/// 확인에 실패하면 true로 본다 — 없는 문제를 경고하지 않는다.
/// 앱으로 돌아올 때 invalidate한다.
@riverpod
Future<bool> exactAlarmAllowed(Ref ref) async {
  try {
    return await ref.watch(notificationSchedulerProvider).canScheduleExact();
  } catch (_) {
    return true;
  }
}

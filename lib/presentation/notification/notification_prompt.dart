import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/presentation/format/time_format.dart';
import '../../core/providers/database_providers.dart';
import '../../core/providers/notification_providers.dart';
import '../../domain/repository/notification_scheduler.dart';
import '../settings/settings_controller.dart';
import '../shared/app_toast.dart';
import '../shared/confirm_dialog.dart';
import 'clock_out_notification_sync.dart';
import 'notification_texts.dart';
import 'widgets/notification_preview_card.dart';

/// 출근을 저장한 직후 오늘 화면이 부른다 — "퇴근할 때 알려드릴까요?"를 **첫 평일 출근 때 한 번만** 묻는다 (핸드오프 6 §8).
///
/// 설치 직후에 묻지 않는 이유: iOS는 한 번 거절하면 앱이 다시 물을 수 없고, 맥락 없이 물으면 거절되기 쉽다.
/// 주말·공휴일 근무 출근([countsAsWorkday] false)은 그날 알림이 없으니 건너뛰고 다음 평일 출근 때 묻는다.
/// 수락·거절·바깥 탭 모두 "물어봤다"로 남긴다 — 다시 묻지 않고, 설정 화면에서 켤 수 있다.
Future<void> maybePromptClockOutNotification(
  BuildContext context,
  WidgetRef ref, {
  required bool countsAsWorkday,
}) async {
  if (!countsAsWorkday) return;
  final settings = await ref.read(appSettingsRepositoryProvider).read();
  if (settings.notificationPrompted || !context.mounted) return;

  // 미리보기의 시각 — 방금 찍은 출근이 계획에 반영돼 있으면 그 시각, 아직이면 비운다(장식이라 기다리지 않는다).
  final plannedAt = ref.read(clockOutNoticePlanProvider).value?.at;
  final accepted = await showConfirmDialog(
    context,
    title: NotificationTexts.promptTitle,
    message: NotificationTexts.promptMessage,
    confirmLabel: NotificationTexts.promptAccept,
    cancelLabel: NotificationTexts.promptDecline,
    body: NotificationPreviewCard(time: plannedAt == null ? null : formatClock(plannedAt)),
  );
  if (!context.mounted) return;
  await ref.read(settingsControllerProvider.notifier).markNotificationPrompted();
  if (!context.mounted) return;
  if (accepted) {
    await enableClockOutNotification(context, ref);
  } else {
    showAppToast(context, NotificationTexts.declinedToast);
  }
}

/// 퇴근 알림을 켠다 — P1 수락과 설정 토글이 같이 쓴다. OS 권한이 아직이면 OS 창을 띄우고,
/// 허용을 못 받으면 "기기 설정에서 허용해야 한다"를 알린다(P5). 켬 상태는 그대로 둔다 — OS에서 허용하고 돌아오면 바로 예약된다.
Future<void> enableClockOutNotification(BuildContext context, WidgetRef ref) async {
  await ref.read(settingsControllerProvider.notifier).setClockOutNotification(true);
  final scheduler = ref.read(notificationSchedulerProvider);
  final store = ref.read(notificationStateRepositoryProvider);
  var granted = false;
  try {
    granted = await scheduler.status() == OsNotificationStatus.granted;
    // OS 창은 한 번만 띄운다. 이미 띄운 적이 있는데 허용이 아니면 거부한 것 — 다시 불러도 창이 안 뜬다(iOS).
    if (!granted && !await store.osAsked()) {
      await store.markOsAsked();
      granted = await scheduler.requestPermission();
    }
  } catch (_) {
    granted = false;
  }
  if (!context.mounted) return;
  ref.invalidate(notificationPermissionProvider);
  await ref.read(clockOutNotificationSyncProvider.notifier).sync();
  if (!context.mounted) return;
  if (!granted) return showAppToast(context, NotificationTexts.osDeniedToast);
  await maybePromptExactAlarm(context, ref);
}

/// 알림은 허용됐는데 "알람 및 리마인더"가 꺼져 있으면(Android 14+의 기본) 정시에 받는 법을 안내한다.
/// 안 켜도 알림은 간다 — 다만 OS가 최대 1시간 늦춘다.
Future<void> maybePromptExactAlarm(BuildContext context, WidgetRef ref) async {
  final scheduler = ref.read(notificationSchedulerProvider);
  try {
    if (await scheduler.canScheduleExact()) return;
  } catch (_) {
    return;
  }
  if (!context.mounted) return;
  await promptExactAlarm(context, ref);
}

/// 안내 다이얼로그 → OS의 "알람 및 리마인더" 설정. 설정 화면의 "정시에 받기" 행도 이걸 쓴다.
Future<void> promptExactAlarm(BuildContext context, WidgetRef ref) async {
  final open = await showConfirmDialog(
    context,
    title: NotificationTexts.exactTitle,
    message: NotificationTexts.exactMessage,
    confirmLabel: NotificationTexts.openSettings,
    cancelLabel: NotificationTexts.exactLater,
  );
  if (!open) return;
  try {
    await ref.read(notificationSchedulerProvider).requestExactAlarm();
  } catch (_) {
    if (context.mounted) showAppToast(context, NotificationTexts.openSettingsFailed);
    return;
  }
  if (!context.mounted) return;
  // 돌아왔다 — 허용했으면 같은 시각을 정시 방식으로 다시 건다.
  ref.invalidate(exactAlarmAllowedProvider);
  await ref.read(clockOutNotificationSyncProvider.notifier).resync();
}

/// OS 권한이 꺼진 상태에서 설정 행을 눌렀을 때 — 앱에서는 켤 수 없으니 OS 설정으로 보낸다 (P4).
Future<void> promptOpenNotificationSettings(BuildContext context, WidgetRef ref) async {
  final open = await showConfirmDialog(
    context,
    title: NotificationTexts.osOffTitle,
    message: NotificationTexts.osOffMessage,
    confirmLabel: NotificationTexts.openSettings,
  );
  if (!open) return;
  try {
    await ref.read(notificationSchedulerProvider).openSystemSettings();
  } catch (_) {
    if (context.mounted) showAppToast(context, NotificationTexts.openSettingsFailed);
  }
}

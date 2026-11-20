import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/clock_provider.dart';
import '../../core/providers/database_providers.dart';
import '../../core/providers/notification_providers.dart';
import '../../domain/notification/clock_out_notice.dart';
import '../../domain/repository/notification_scheduler.dart';
import '../../domain/rules/work_calculator.dart';
import 'notification_texts.dart';

part 'clock_out_notification_sync.g.dart';

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
@Riverpod(keepAlive: true)
class ClockOutNotificationSync extends _$ClockOutNotificationSync {
  /// 실행 중에 또 요청이 오면 끝난 뒤 한 번 더 돈다 — 겹쳐 돌지 않고, 마지막 상태가 반드시 반영된다.
  var _dirty = false;
  Future<void>? _running;

  /// 이 프로세스에서 OS 예약을 한 번이라도 확인했는지. 앱을 막 켰을 때는 OS에 무엇이 걸려 있는지 모른다 —
  /// 저장된 값만 믿지 않고 한 번은 다시 건다(강제 종료 등으로 예약이 사라졌을 수 있다).
  var _verified = false;

  @override
  void build() {
    // 계획이 실제로 달라졌을 때만 — 매 분 도는 시계 때문에 같은 값으로 다시 계산되는 것은 건너뛴다.
    ref.listen(clockOutNoticePlanProvider, (previous, next) {
      if (!next.hasValue || next.isLoading) return;
      if (previous != null && previous.hasValue && previous.value == next.value) return;
      sync();
    });
    // 알림을 켜고 끌 때만 — 연차·시급 같은 다른 설정이 바뀌는 것은 건너뛴다.
    ref.listen(appSettingsProvider, (previous, next) {
      if (!next.hasValue) return;
      if (previous?.value?.clockOutNotificationEnabled == next.value!.clockOutNotificationEnabled) return;
      sync();
    });
    // 디버그 시계를 옮기면 "실제로 언제 울릴지"가 바뀐다.
    if (kDebugMode) ref.listen(debugClockOffsetProvider, (_, _) => sync());
    sync();
  }

  /// 예약을 지금 상태에 맞춘다. 끝나면(대기 중인 요청까지) 완료되는 Future.
  Future<void> sync() {
    _dirty = true;
    return _running ??= _drain().whenComplete(() => _running = null);
  }

  Future<void> _drain() async {
    while (_dirty) {
      _dirty = false;
      try {
        await _run();
      } catch (_) {
        // 알림은 부가 기능이다 — 플러그인·OS 오류가 출퇴근 기록을 막으면 안 된다. 다음 sync가 다시 맞춘다.
      }
    }
  }

  Future<void> _run() async {
    final scheduler = ref.read(notificationSchedulerProvider);
    final store = ref.read(notificationStateRepositoryProvider);
    final settings = await ref.read(appSettingsProvider.future);
    final last = await store.lastNotice();

    Future<void> clear() async {
      // 걸어둔 게 없다는 걸 아는 동안은 OS를 다시 부르지 않는다(알림을 안 쓰는 사람의 기록 변경마다 부르지 않게).
      if (last == null && _verified) return;
      await scheduler.cancel();
      await store.saveLastNotice(null);
      _verified = true;
    }

    if (!settings.clockOutNotificationEnabled) return clear();
    if (await scheduler.status() != OsNotificationStatus.granted) return clear();
    final plan = await ref.read(clockOutNoticePlanProvider.future);
    if (plan == null) return clear();

    final now = minuteOnly(ref.read(clockProvider)());
    final (title, body) = NotificationTexts.notice(plan.kind);

    if (plan.at.isAfter(now)) {
      if (last == plan && _verified) return;
      // OS는 실제 시각으로 움직인다 — 디버그 시계를 옮겼으면 그만큼 되돌려 건다.
      await scheduler.schedule(at: plan.at.subtract(_debugOffset), title: title, body: body);
      await store.saveLastNotice(plan);
      _verified = true;
      return;
    }

    // 계획 시각이 이미 지났다 (출근 시각을 앞으로 고쳤다, 퇴근 시각 뒤에 알림을 켰다 …).
    final deliveredToday = last != null && dateOnly(last.at) == dateOnly(now) && !last.at.isAfter(now);
    _verified = true;
    if (deliveredToday) return;
    await scheduler.cancel();
    await scheduler.showNow(title: title, body: body);
    await store.saveLastNotice(ClockOutNotice(plan.kind, now));
  }

  Duration get _debugOffset => kDebugMode ? ref.read(debugClockOffsetProvider) : Duration.zero;
}

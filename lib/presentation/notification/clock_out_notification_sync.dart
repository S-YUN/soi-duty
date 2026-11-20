import 'dart:async';

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
/// 알림 꺼짐 · OS 권한 없음 · 정시 권한 없음(Android) · 계획 없음   → 예약 취소, 저장된 알림 지움
/// 계획 시각이 아직 안 옴                 → 같은 알림이 이미 예약돼 있으면 그대로, 아니면 예약(대체) + 저장
/// 계획 시각이 이미 지남 (N3)             → 오늘 이미 전달됐으면 아무것도 안 함, 아니면 지금 띄우고 저장
/// ```
///
/// "저장된 알림"(`NotificationStateRepository.lastNotice`)의 시각이 지났으면 OS가 이미 띄운 것으로 본다.
/// 그래서 퇴근 시각이 지난 뒤 앱을 다시 켜거나, 지난 기록을 고치거나, 알림을 껐다 켜거나, 퇴근을 취소해도 같은 알림이 또 울리지 않는다
/// (오늘 전달된 기록은 예약을 치울 때도 지우지 않는다).
/// 계획이 **미래로 옮겨가면**(반차 해제, 출근 시각을 늦춤) 이미 울렸어도 새로 예약한다 — 앞의 알림이 틀린 데이터로 울린 것이다.
@Riverpod(keepAlive: true)
class ClockOutNotificationSync extends _$ClockOutNotificationSync {
  /// 실행 중에 또 요청이 오면 끝난 뒤 한 번 더 돈다 — 겹쳐 돌지 않고, 마지막 상태가 반드시 반영된다.
  var _dirty = false;
  Future<void>? _running;

  /// 이 프로세스에서 OS 예약을 한 번이라도 확인했는지. 앱을 막 켰을 때는 OS에 무엇이 걸려 있는지 모른다 —
  /// 저장된 값만 믿지 않고 한 번은 다시 건다(강제 종료 등으로 예약이 사라졌을 수 있다).
  var _verified = false;

  /// 맞추다 실패하면(플러그인·OS 오류) 잠시 뒤 스스로 다시 시도한다 — 기록이 다시 바뀌거나 앱으로 돌아올 때까지 기다리면
  /// 그 사이 퇴근 시각이 지나간다. 연달아 [maxRetries]번까지만.
  @visibleForTesting
  static Duration retryDelay = const Duration(seconds: 20);
  static const maxRetries = 3;
  var _failures = 0;
  Timer? _retryTimer;

  @override
  void build() {
    ref.onDispose(() => _retryTimer?.cancel());
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

  /// 저장된 값과 같아도 OS에 다시 건다 — 앱으로 돌아왔을 때. 그 사이 "알람 및 리마인더" 권한이 회수됐다 다시 켜졌으면
  /// OS가 걸어둔 알람을 지웠을 수 있다.
  Future<void> resync() {
    _verified = false;
    return sync();
  }

  Future<void> _drain() async {
    while (_dirty) {
      _dirty = false;
      try {
        await _run();
        _failures = 0;
        _retryTimer?.cancel();
        _retryTimer = null;
      } catch (_) {
        // 알림은 부가 기능이다 — 플러그인·OS 오류가 출퇴근 기록을 막으면 안 된다. 다음 sync가 다시 맞춘다.
        // 중간에 실패했으면 OS 예약과 저장된 값이 어긋났을 수 있다 — 다음 번엔 저장된 값을 믿지 않고 다시 건다(또는 치운다).
        _verified = false;
        if (++_failures <= maxRetries) {
          _retryTimer?.cancel();
          _retryTimer = Timer(retryDelay, sync);
        }
      }
    }
  }

  Future<void> _run() async {
    final scheduler = ref.read(notificationSchedulerProvider);
    final store = ref.read(notificationStateRepositoryProvider);
    // 저장소에서 직접 읽는다 — 방금 켠 설정을 스트림이 아직 못 봤을 수 있다.
    final settings = await ref.read(appSettingsRepositoryProvider).read();
    final last = await store.lastNotice();
    final now = minuteOnly(ref.read(clockProvider)());

    /// 오늘 이미 전달된 알림 — 예약 시각이 지났거나(OS가 띄웠다) 바로 띄웠다. 하루에 "바로 띄우기"는 이것 때문에 한 번뿐이다.
    final deliveredToday = last != null && dateOnly(last.at) == dateOnly(now) && !last.at.isAfter(now);

    Future<void> clear() async {
      // 걸어둔 게 없다는 걸 아는 동안은 OS를 다시 부르지 않는다(알림을 안 쓰는 사람의 기록 변경마다 부르지 않게).
      if ((last == null || deliveredToday) && _verified) return;
      await scheduler.cancel();
      // 오늘 전달된 기록은 남긴다 — 지우면 알림을 껐다 켜거나 퇴근을 취소했을 때 같은 알림이 한 번 더 울린다.
      if (!deliveredToday) await store.saveLastNotice(null);
      _verified = true;
    }

    if (!settings.clockOutNotificationEnabled) return clear();
    if (await scheduler.status() != OsNotificationStatus.granted) return clear();
    // 정시에 못 울리면 아예 보내지 않는다 — Android는 "알람 및 리마인더" 권한이 없으면 OS가 최대 1시간 늦춘다.
    if (!await scheduler.canScheduleExact()) return clear();

    // 계획은 **지금 시각의 날짜**로 여기서 센다. 프로바이더(`clockOutNoticePlan`)의 값은 다시 맞출 때를 알려주는 신호일 뿐이다 —
    // 그 값의 "오늘"은 매 분 도는 시계에서 오는데, 앱이 밤새 멈춰 있다 돌아오면 다음 분이 돌 때까지 어제에 머문다.
    // 그 상태로 맞추면 어제의 지난 계획을 "이미 지난 시각"으로 보고 엉뚱한 알림을 바로 띄운다.
    final records = await ref.read(allRecordsProvider.future);
    final firstRecordDate = await ref.read(firstRecordDateProvider.future);
    final plan = planClockOutNotice(
      records: records,
      today: now,
      rules: ref.read(workRulesProvider),
      firstRecordDate: effectiveFirstRecordDate(firstRecordDate, now),
    );
    if (plan == null) return clear();

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
    if (deliveredToday) {
      // 미래로 걸어둔 예약은 없다(저장된 값이 과거다). 앱을 막 켰다면 한 번은 치워 둔다.
      if (!_verified) await scheduler.cancel();
      _verified = true;
      return;
    }
    await scheduler.cancel();
    await scheduler.showNow(title: title, body: body);
    await store.saveLastNotice(ClockOutNotice(plan.kind, now));
    _verified = true;
  }

  Duration get _debugOffset => kDebugMode ? ref.read(debugClockOffsetProvider) : Duration.zero;
}

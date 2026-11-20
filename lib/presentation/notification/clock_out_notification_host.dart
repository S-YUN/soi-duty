import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/clock_provider.dart';
import '../../core/providers/notification_providers.dart';
import 'clock_out_notification_sync.dart';

/// 앱이 떠 있는 동안 퇴근 알림 동기화를 살려 두고, 앱으로 돌아올 때 다시 맞춘다.
/// 돌아올 때 보는 이유: OS 설정에서 알림 권한을 바꾸고 왔을 수 있고, 백그라운드에 있는 동안 날짜가 넘어갔을 수 있다.
class ClockOutNotificationHost extends ConsumerStatefulWidget {
  const ClockOutNotificationHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ClockOutNotificationHost> createState() => _ClockOutNotificationHostState();
}

class _ClockOutNotificationHostState extends ConsumerState<ClockOutNotificationHost> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _onResume);
  }

  void _onResume() {
    // 매 분 도는 시계는 앱이 멈춰 있던 동안 같이 멈춘다 — 돌아오면 바로 지금 시각을 다시 흘려
    // 화면(경과 시간·날짜)과 알림 계획이 다음 분을 기다리지 않게 한다.
    ref.invalidate(nowProvider);
    ref.invalidate(notificationPermissionProvider);
    ref.read(clockOutNotificationSyncProvider.notifier).sync();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 구독해 두면 프로바이더가 만들어지고(첫 sync), 기록·설정이 바뀔 때마다 스스로 다시 맞춘다.
    ref.watch(clockOutNotificationSyncProvider);
    return widget.child;
  }
}

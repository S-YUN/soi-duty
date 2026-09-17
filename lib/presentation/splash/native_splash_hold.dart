import 'package:flutter/widgets.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../today/today_controller.dart';

/// 네이티브 스플래시를 오늘 상태가 준비될 때까지 잡아둔다. 인앱 스플래시는 따로 두지 않는다 —
/// 같은 화면을 두 번 그리는 셈이고, 로컬 DB라 준비도 순식간이라 대기 표시가 번쩍이기만 한다.
/// main()에서 [FlutterNativeSplash.preserve]를 부르고, 여기서 첫 값이 오면 걷는다. 최소 노출 시간 없음.
class NativeSplashHold extends ConsumerStatefulWidget {
  const NativeSplashHold({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<NativeSplashHold> createState() => _NativeSplashHoldState();
}

class _NativeSplashHoldState extends ConsumerState<NativeSplashHold> {
  var _removed = false;

  @override
  Widget build(BuildContext context) {
    if (!_removed && ref.watch(todayControllerProvider).hasValue) {
      _removed = true;
      FlutterNativeSplash.remove();
    }
    return widget.child;
  }
}

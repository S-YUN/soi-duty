import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ui/app_colors.dart';
import '../../ui/app_sizes.dart';
import '../../ui/app_text_styles.dart';
import '../today/today_controller.dart';
import 'splash_texts.dart';

/// 네이티브 스플래시의 연장. 같은 배경·같은 자리의 로고를 첫 프레임에 깔아 두었다가
/// 오늘 상태가 준비되면 0.2s 페이드로 걷는다. 최소 노출 시간은 두지 않는다.
///
/// 대기 바·문구는 [AppDurations.splashBarDelay]가 지나도 준비가 안 됐을 때만 나온다 —
/// 로컬 DB라 보통 그 전에 끝나고, 그때 바를 그리면 번쩍이기만 한다.
class SplashGate extends ConsumerStatefulWidget {
  const SplashGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends ConsumerState<SplashGate> {
  var _ready = false;
  var _gone = false;
  var _showBar = false;
  Timer? _barTimer;

  @override
  void initState() {
    super.initState();
    _barTimer = Timer(AppDurations.splashBarDelay, () {
      if (mounted && !_ready) setState(() => _showBar = true);
    });
  }

  @override
  void dispose() {
    _barTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_gone && !_ready && ref.watch(todayControllerProvider).hasValue) {
      _ready = true;
      _barTimer?.cancel();
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (!_gone)
          IgnorePointer(
            child: AnimatedOpacity(
              duration: AppDurations.splashFade,
              curve: Curves.easeOut,
              opacity: _ready ? 0 : 1,
              onEnd: () {
                if (_ready && mounted) setState(() => _gone = true);
              },
              child: _Splash(showBar: _showBar),
            ),
          ),
      ],
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash({required this.showBar});

  final bool showBar;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return ColoredBox(
      color: AppColors.splashBackground,
      child: Stack(
        children: [
          Center(child: Image.asset('assets/splash/logo.png', width: AppSizes.splashLogoWidth)),
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomInset + AppSizes.splashBottom,
            child: AnimatedOpacity(
              duration: AppDurations.splashFade,
              opacity: showBar ? 1 : 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showBar) const _WaitingBar(),
                  if (!showBar) SizedBox(height: AppSizes.splashBarHeight),
                  SizedBox(height: AppSizes.splashGap),
                  Text(SplashTexts.loading, style: AppTextStyles.splashCaption, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 폭 0 → 100%를 왕복하는 대기 표시. 실제 진행률이 아니다.
class _WaitingBar extends StatefulWidget {
  const _WaitingBar();

  @override
  State<_WaitingBar> createState() => _WaitingBarState();
}

class _WaitingBarState extends State<_WaitingBar> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this, duration: AppDurations.splashBar)..repeat(reverse: true);
  late final _width = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.splashBarWidth,
      height: AppSizes.splashBarHeight,
      decoration: BoxDecoration(color: AppColors.splashBarTrack, borderRadius: BorderRadius.circular(AppSizes.pill)),
      alignment: Alignment.centerLeft,
      child: AnimatedBuilder(
        animation: _width,
        builder: (_, _) => FractionallySizedBox(
          widthFactor: _width.value,
          child: DecoratedBox(
            decoration: BoxDecoration(color: AppColors.mint, borderRadius: BorderRadius.circular(AppSizes.pill)),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

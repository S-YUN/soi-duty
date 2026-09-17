import 'dart:async';

import 'package:flutter/material.dart';

import '../../ui/app_colors.dart';
import '../../ui/app_sizes.dart';
import '../../ui/app_text_styles.dart';

OverlayEntry? _current;
Timer? _timer;

/// 화면 아래에 뜨는 알약 토스트. 아래에서 살짝 떠오르며 나타났다가 [AppDurations.toast] 뒤 사라진다.
/// 새 토스트가 오면 이전 것은 바로 치운다. 터치를 막지 않는다.
void showAppToast(BuildContext context, String message) {
  final overlay = Overlay.of(context, rootOverlay: true);
  _dismiss();
  final entry = OverlayEntry(builder: (_) => _Toast(message: message));
  _current = entry;
  overlay.insert(entry);
  _timer = Timer(AppDurations.toast, _dismiss);
}

void _dismiss() {
  _timer?.cancel();
  _timer = null;
  _current?.remove();
  _current = null;
}

class _Toast extends StatefulWidget {
  const _Toast({required this.message});

  final String message;

  @override
  State<_Toast> createState() => _ToastState();
}

class _ToastState extends State<_Toast> {
  var _visible = false;

  @override
  void initState() {
    super.initState();
    // 첫 프레임은 숨긴 채 그리고 다음 프레임에 켜야 애니메이션이 돈다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Positioned(
      left: AppSizes.toastHPadding,
      right: AppSizes.toastHPadding,
      bottom: bottomInset + AppSizes.toastBottom,
      child: IgnorePointer(
        child: AnimatedOpacity(
          duration: AppDurations.toastFade,
          curve: Curves.easeOut,
          opacity: _visible ? 1 : 0,
          child: AnimatedSlide(
            duration: AppDurations.toastFade,
            curve: Curves.easeOut,
            offset: _visible ? Offset.zero : const Offset(0, AppScales.toastSlide),
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: AppSizes.toastPadding,
                  decoration: BoxDecoration(
                    color: AppColors.toastBackground,
                    borderRadius: BorderRadius.circular(AppSizes.pill),
                  ),
                  child: Text(widget.message, style: AppTextStyles.toast, textAlign: TextAlign.center),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

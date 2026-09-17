import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/presentation/size_config.dart';
import 'core/routing/router.dart';
import 'presentation/splash/native_splash_hold.dart';
import 'ui/app_theme.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  // 오늘 상태가 준비될 때까지 네이티브 스플래시를 유지 — NativeSplashHold가 걷는다.
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ProviderScope(child: SoiDutyApp()));
}

class SoiDutyApp extends ConsumerWidget {
  const SoiDutyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'SOI DUTY',
      theme: AppTheme.light,
      routerConfig: router,
      builder: (context, child) {
        SizeConfig.init(MediaQuery.sizeOf(context).width);
        // 시스템 글자 크기는 1.0으로 고정 — 히어로·행·캘린더 셀이 한 줄/고정 높이라 배율을 열면 잘린다.
        // 대신 기본 크기 자체를 실기기에서 키워 왔다 (app_text_styles.dart). 접근성 요구가 생기면 SizeConfig와 함께 다시 본다.
        return MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.0,
          child: KeyedSubtree(key: ValueKey(SizeConfig.scale), child: NativeSplashHold(child: child!)),
        );
      },
    );
  }
}

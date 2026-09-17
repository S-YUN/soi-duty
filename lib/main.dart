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
        return MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.0,
          child: KeyedSubtree(key: ValueKey(SizeConfig.scale), child: NativeSplashHold(child: child!)),
        );
      },
    );
  }
}

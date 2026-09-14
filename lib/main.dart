import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/presentation/size_config.dart';
import 'core/routing/router.dart';
import 'ui/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
          child: KeyedSubtree(key: ValueKey(SizeConfig.scale), child: child!),
        );
      },
    );
  }
}

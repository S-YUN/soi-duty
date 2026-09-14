import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/router.dart';

void main() {
  runApp(const ProviderScope(child: SoiDutyApp()));
}

class SoiDutyApp extends ConsumerWidget {
  const SoiDutyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'SOI DUTY',
      routerConfig: router,
    );
  }
}

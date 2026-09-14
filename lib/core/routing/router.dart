import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'route_paths.dart';

part 'router.g.dart';

@riverpod
GoRouter router(Ref ref) {
  return GoRouter(
    initialLocation: RoutePaths.today,
    routes: [
      GoRoute(
        path: RoutePaths.today,
        // TODO: 오늘 화면으로 교체
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('SOI DUTY')),
        ),
      ),
    ],
  );
}

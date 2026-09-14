import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../presentation/today/today_screen.dart';
import 'route_paths.dart';

part 'router.g.dart';

@riverpod
GoRouter router(Ref ref) {
  return GoRouter(
    initialLocation: RoutePaths.today,
    routes: [
      GoRoute(
        path: RoutePaths.today,
        builder: (context, state) => const TodayScreen(),
      ),
    ],
  );
}

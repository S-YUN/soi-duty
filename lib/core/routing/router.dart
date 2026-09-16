import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../presentation/month/month_screen.dart';
import '../../presentation/shell/tab_shell.dart';
import '../../presentation/today/today_screen.dart';
import '../../presentation/week/week_screen.dart';
import 'route_paths.dart';

part 'router.g.dart';

@riverpod
GoRouter router(Ref ref) {
  return GoRouter(
    initialLocation: RoutePaths.today,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => TabShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: RoutePaths.today, builder: (_, _) => const TodayScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: RoutePaths.week, builder: (_, _) => const WeekScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: RoutePaths.month, builder: (_, _) => const MonthScreen())]),
        ],
      ),
    ],
  );
}

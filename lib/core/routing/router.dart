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
      // IndexedStack 대신 PageView 컨테이너 — 스와이프로 탭을 넘긴다.
      StatefulShellRoute(
        builder: (context, state, navigationShell) => navigationShell,
        navigatorContainerBuilder: (context, navigationShell, children) =>
            TabShell(navigationShell: navigationShell, children: children),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: RoutePaths.today, builder: (_, _) => const TodayScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: RoutePaths.week, builder: (_, _) => const WeekScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: RoutePaths.month, builder: (_, _) => const MonthScreen())]),
        ],
      ),
    ],
  );
}

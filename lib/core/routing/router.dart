import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../presentation/month/month_screen.dart';
import '../../presentation/settings/settings_screen.dart';
import '../../presentation/shell/tab_shell.dart';
import '../../presentation/today/today_screen.dart';
import '../../presentation/week/week_screen.dart';
import '../../ui/app_sizes.dart';
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
      // 설정 — 탭 셸 위로 오른쪽에서 밀려오는 전체 화면. 뒤로가기(시스템 포함)로 닫힌다.
      GoRoute(
        path: RoutePaths.settings,
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const SettingsScreen(),
          transitionDuration: AppDurations.sheetSlide,
          reverseTransitionDuration: AppDurations.sheetSlide,
          transitionsBuilder: (context, animation, secondaryAnimation, child) => SlideTransition(
            position: Tween(begin: const Offset(1, 0), end: Offset.zero)
                .animate(CurvedAnimation(parent: animation, curve: AppCurves.sheet)),
            child: child,
          ),
        ),
      ),
    ],
  );
}

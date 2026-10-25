import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../presentation/month/month_screen.dart';
import '../../presentation/settings/settings_screen.dart';
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
      // 설정 — 탭 셸 위로 오른쪽에서 밀려오는 전체 화면. 뒤로가기(시스템 포함)로 닫힌다.
      GoRoute(path: RoutePaths.settings, pageBuilder: (context, state) => buildSettingsPage(state.pageKey)),
    ],
  );
}

/// 설정 화면 페이지. CupertinoPage — 오른쪽에서 밀려오고 iOS 가장자리 스와이프로도 닫힌다
/// (CustomTransitionPage로 260ms·AppCurves.sheet를 맞추면 스와이프 백이 사라져 리뷰에서 바꿨다, 2026-10-25).
Page<void> buildSettingsPage(LocalKey key) => CupertinoPage<void>(key: key, child: const SettingsScreen());

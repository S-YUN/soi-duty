import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../ui/app_colors.dart';
import '../../ui/app_sizes.dart';
import '../today/today_texts.dart';
import '../today/widgets/pill_tabs.dart';

/// 알약 탭 + 브랜치. Scaffold·SafeArea는 여기 한 번만. 탭 전환 애니메이션 없음 (IndexedStack).
class TabShell extends StatelessWidget {
  const TabShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(AppSizes.screenHPadding, AppSizes.topInset, AppSizes.screenHPadding, 0),
              child: PillTabs(
                labels: TodayTexts.tabs,
                selectedIndex: navigationShell.currentIndex,
                onSelected: (i) => navigationShell.goBranch(i, initialLocation: i == navigationShell.currentIndex),
              ),
            ),
            Expanded(child: navigationShell),
          ],
        ),
      ),
    );
  }
}

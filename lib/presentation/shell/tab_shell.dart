import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../ui/app_colors.dart';
import '../../ui/app_sizes.dart';
import '../today/today_texts.dart';
import '../today/widgets/pill_tabs.dart';

/// 알약 탭 + 브랜치 PageView. Scaffold·SafeArea는 여기 한 번만.
/// 스와이프하면 브랜치가 바뀌고, 탭을 누르면 페이지가 밀려간다. 둘 다 [navigationShell]의 인덱스로 동기화한다.
class TabShell extends StatefulWidget {
  const TabShell({super.key, required this.navigationShell, required this.children});

  final StatefulNavigationShell navigationShell;
  final List<Widget> children;

  @override
  State<TabShell> createState() => _TabShellState();
}

class _TabShellState extends State<TabShell> {
  late final _controller = PageController(initialPage: widget.navigationShell.currentIndex);
  var _animating = false;

  @override
  void didUpdateWidget(TabShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    final target = widget.navigationShell.currentIndex;
    if (!_controller.hasClients || _controller.page?.round() == target || _animating) return;
    _animating = true;
    _controller
        .animateToPage(target, duration: AppDurations.tabSwipe, curve: Curves.easeOut)
        .whenComplete(() => _animating = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shell = widget.navigationShell;
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: AppSizes.topInset),
              child: Center(
                child: PillTabs(
                  labels: TodayTexts.tabs,
                  selectedIndex: shell.currentIndex,
                  onSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                // 탭 탭으로 밀려가는 중에 지나치는 페이지는 무시 — 도착한 뒤 인덱스가 이미 맞다.
                onPageChanged: (i) {
                  if (!_animating && i != shell.currentIndex) shell.goBranch(i);
                },
                children: widget.children,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

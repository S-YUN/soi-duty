import 'package:flutter/material.dart';

import '../../ui/app_sizes.dart';
import '../settings/settings_texts.dart';
import '../today/widgets/pill_tabs.dart';
import 'gear_button.dart';

/// 알약 탭 줄 + 오른쪽 톱니. 알약은 그대로 화면 가운데 — 톱니는 위에 얹힌다.
class ShellTabBar extends StatelessWidget {
  const ShellTabBar({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
    required this.onSettings,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Center(child: PillTabs(labels: labels, selectedIndex: selectedIndex, onSelected: onSelected)),
        Positioned(
          right: AppSizes.gearRight,
          child: GearButton(onTap: onSettings, tooltip: SettingsTexts.title),
        ),
      ],
    );
  }
}

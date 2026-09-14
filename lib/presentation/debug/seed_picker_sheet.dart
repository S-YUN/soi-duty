import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/clock_provider.dart';
import '../../core/providers/database_providers.dart';
import '../../data/seed/debug_seed.dart';

/// 디버그 전용. 날짜 헤더 길게 누르면 열린다. 스타일은 기본 Material — 릴리즈에 안 들어간다.
Future<void> showSeedPicker(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          for (final s in SeedScenario.values)
            ListTile(
              title: Text(s.label),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                final db = ref.read(appDatabaseProvider);
                final today = ref.read(clockProvider)();
                await applySeed(db, s, today: today);
              },
            ),
        ],
      ),
    ),
  );
}

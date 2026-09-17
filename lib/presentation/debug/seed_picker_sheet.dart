import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/clock_provider.dart';
import '../../core/providers/database_providers.dart';
import '../../data/seed/debug_seed.dart';
import '../../domain/rules/work_calculator.dart';

/// 디버그 전용. 날짜 헤더 길게 누르면 열린다. 스타일은 기본 Material — 릴리즈에 안 들어간다.
///
/// 위: 시계 이동 (이번 주 요일 + 시각). 아래: 시드 시나리오. 시드는 이동한 시계 기준으로 들어간다.
Future<void> showSeedPicker(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => const SafeArea(child: _SeedPickerBody()),
  );
}

class _SeedPickerBody extends ConsumerWidget {
  const _SeedPickerBody();

  static const _weekdays = ['월', '화', '수', '목', '금', '토', '일'];
  static const _hours = [8, 9, 13, 18, 22];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockProvider)();
    final offset = ref.watch(debugClockOffsetProvider);
    final monday = mondayOf(now);

    return ListView(
      shrinkWrap: true,
      children: [
        ListTile(
          title: Text('지금: ${now.month}/${now.day} ${_weekdays[now.weekday - 1]} '
              '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}'
              '${offset == Duration.zero ? '' : '  (이동됨)'}'),
          subtitle: const Text('이번 주 요일 → 시각 순으로 탭. 시드도 이 시계 기준.'),
          trailing: offset == Duration.zero
              ? null
              : TextButton(onPressed: ref.read(debugClockOffsetProvider.notifier).reset, child: const Text('실제 시각')),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 6,
            children: [
              for (var i = 0; i < 7; i++)
                ChoiceChip(
                  label: Text(_weekdays[i]),
                  selected: now.weekday == i + 1,
                  onSelected: (_) {
                    final day = addDays(monday, i);
                    ref.read(debugClockOffsetProvider.notifier).moveTo(
                          DateTime(day.year, day.month, day.day, now.hour, now.minute),
                        );
                  },
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Wrap(
            spacing: 6,
            children: [
              for (final h in _hours)
                ChoiceChip(
                  label: Text('${h.toString().padLeft(2, '0')}:00'),
                  selected: now.hour == h,
                  onSelected: (_) => ref.read(debugClockOffsetProvider.notifier).moveTo(
                        DateTime(now.year, now.month, now.day, h),
                      ),
                ),
            ],
          ),
        ),
        const Divider(),
        for (final s in SeedScenario.values)
          ListTile(
            title: Text(s.label),
            onTap: () async {
              Navigator.of(context).pop();
              final db = ref.read(appDatabaseProvider);
              final today = ref.read(clockProvider)();
              await applySeed(db, s, today: today);
            },
          ),
      ],
    );
  }
}

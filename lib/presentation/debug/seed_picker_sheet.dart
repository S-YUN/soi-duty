import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/clock_provider.dart';
import '../../core/providers/database_providers.dart';
import '../../core/providers/notification_providers.dart';
import '../../data/seed/debug_seed.dart';
import '../../domain/notification/clock_out_notice.dart';
import '../../domain/repository/notification_scheduler.dart';
import '../../domain/rules/work_calculator.dart';
import '../notification/clock_out_notification_sync.dart';
import '../notification/notification_texts.dart';

/// 디버그 전용. 날짜 헤더 길게 누르면 열린다. 스타일은 기본 Material — 릴리즈에 안 들어간다.
///
/// 위: 시계 이동 (이번 주 요일 + 시각). 가운데: 알림 시험. 아래: 시드 시나리오. 시드는 이동한 시계 기준으로 들어간다.
///
/// 알림 시험은 실기기에서 포그라운드·백그라운드·종료·잠금·워치를 눈으로 확인하기 위한 것 — 예약해 두고 앱을 내리거나 끈다.
/// 앱의 알림 설정(켜짐/꺼짐)과 무관하게 OS에 바로 건다. 권한이 없으면 먼저 OS 창을 띄운다.
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
        ListTile(
          dense: true,
          title: const Text('알림 지금 보내기'),
          subtitle: const Text('앱을 보고 있을 때 배너가 뜨는지'),
          onTap: () => _testNotification(context, ref, delay: null),
        ),
        ListTile(
          dense: true,
          title: const Text('1분 뒤 알림 예약'),
          subtitle: const Text('누른 뒤 앱을 내리거나 · 끄거나 · 화면을 잠그고 기다린다'),
          onTap: () => _testNotification(context, ref, delay: const Duration(minutes: 1)),
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

/// 실제 기기 시각 기준으로 일일 알림(N1) 문구를 보낸다. [delay]가 null이면 지금.
Future<void> _testNotification(BuildContext context, WidgetRef ref, {required Duration? delay}) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final scheduler = ref.read(notificationSchedulerProvider);
  final (title, body) = NotificationTexts.notice(ClockOutNoticeKind.daily);
  String result;
  try {
    var granted = await scheduler.status() == OsNotificationStatus.granted;
    if (!granted) granted = await scheduler.requestPermission();
    if (!granted) {
      result = 'OS 알림 권한이 없어요';
    } else if (delay == null) {
      await scheduler.showNow(title: title, body: body);
      result = '보냈어요';
    } else {
      // 정시 방식으로만 건다 — "알람 및 리마인더"가 꺼져 있으면 OS 설정을 먼저 연다.
      if (!await scheduler.canScheduleExact() && !await scheduler.requestExactAlarm()) {
        throw StateError("'알람 및 리마인더' 권한이 없어요");
      }
      final at = DateTime.now().add(delay);
      await scheduler.schedule(at: at, title: title, body: body);
      // 울릴 때까지 예약 맞추기를 쉬게 한다 — 안 그러면 앱으로 돌아오는 순간 이 예약이 지워진다.
      ClockOutNotificationSync.debugTestUntil = at;
      result = '${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}:${at.second.toString().padLeft(2, '0')}쯤 울려요';
    }
  } catch (e) {
    result = '실패: $e';
  }
  if (context.mounted) Navigator.of(context).pop();
  messenger?.showSnackBar(SnackBar(content: Text(result)));
}

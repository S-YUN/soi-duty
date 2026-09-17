import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/clock_provider.dart';
import '../../core/providers/database_providers.dart';
import '../../domain/rules/navigation_bounds.dart';
import '../../domain/rules/work_calculator.dart';
import '../../ui/app_colors.dart';
import '../../ui/app_sizes.dart';
import '../../ui/app_text_styles.dart';
import '../record_edit/record_edit_sheet.dart';
import '../shared/handoff_page_view.dart';
import '../shared/period_navigator.dart';
import 'month_provider.dart';
import 'month_state.dart';
import 'month_texts.dart';
import 'selected_month.dart';
import 'widgets/calendar_card.dart';
import 'widgets/legend.dart';

class MonthScreen extends ConsumerWidget {
  const MonthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstAsync = ref.watch(firstRecordDateProvider);
    final today = ref.watch(clockProvider)();
    final selected = ref.watch(selectedMonthProvider);
    final notifier = ref.watch(selectedMonthProvider.notifier);
    return firstAsync.when(
      loading: () => const _Blank(),
      error: (e, _) => Center(child: Text('$e', style: AppTextStyles.caption)),
      data: (first) => MonthView(
        month: selected,
        earliest: earliestMonth(first, today),
        latest: latestMonth(today),
        onPrev: notifier.prev,
        onNext: notifier.next,
        onSelected: notifier.select,
        pageBuilder: (month) => _MonthPage(month: month),
      ),
    );
  }
}

class _MonthPage extends ConsumerWidget {
  const _MonthPage({required this.month});

  final DateTime month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(monthStateProvider(month)).when(
          loading: () => const _Blank(),
          error: (e, _) => Center(child: Text('$e', style: AppTextStyles.caption)),
          data: (state) => MonthBody(state: state, onCellTap: (date) => showRecordEditSheet(context, date)),
        );
  }
}

class _Blank extends StatelessWidget {
  const _Blank();

  @override
  Widget build(BuildContext context) =>
      const ColoredBox(color: AppColors.screenBackground, child: SizedBox.expand());
}

/// 월간 화면의 순수 UI. 기간 네비게이터 → 달 페이저. 페이저는 [earliest]..[latest] 사이를
/// 스와이프로 오가고, 화살표는 [month]를 바꿔 페이저를 밀어 보낸다.
class MonthView extends StatelessWidget {
  const MonthView({
    super.key,
    required this.month,
    required this.earliest,
    required this.latest,
    required this.onPrev,
    required this.onNext,
    required this.onSelected,
    required this.pageBuilder,
  });

  final DateTime month;
  final DateTime earliest;
  final DateTime latest;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final ValueChanged<DateTime> onSelected;
  final Widget Function(DateTime month) pageBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PeriodNavigator(
          label: MonthTexts.title(month),
          canGoPrev: month.isAfter(earliest),
          canGoNext: month.isBefore(latest),
          onPrev: onPrev,
          onNext: onNext,
        ),
        Expanded(
          child: _MonthPager(
            // 범위가 바뀌면(첫 기록일이 당겨짐, 시계 이동) 인덱스가 밀리므로 컨트롤러를 새로 만든다.
            key: ValueKey((earliest, latest)),
            earliest: earliest,
            latest: latest,
            month: month,
            onSelected: onSelected,
            pageBuilder: pageBuilder,
          ),
        ),
      ],
    );
  }
}

/// 달 하나의 본문. 캘린더 → 범례. (리포트는 보류 — CLAUDE.md)
class MonthBody extends StatelessWidget {
  const MonthBody({super.key, required this.state, required this.onCellTap});

  final MonthState state;
  final ValueChanged<DateTime> onCellTap;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return SingleChildScrollView(
      padding: AppSizes.bodyPadding.copyWith(bottom: AppSizes.bodyPadding.bottom + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CalendarCard(state: state, onCellTap: onCellTap),
          SizedBox(height: AppSizes.cardGap),
          const Legend(),
        ],
      ),
    );
  }
}

/// 선택한 달과 페이지 인덱스를 양방향으로 맞춘다 — 탭 셸과 같은 방식.
class _MonthPager extends StatefulWidget {
  const _MonthPager({
    super.key,
    required this.earliest,
    required this.latest,
    required this.month,
    required this.onSelected,
    required this.pageBuilder,
  });

  final DateTime earliest;
  final DateTime latest;
  final DateTime month;
  final ValueChanged<DateTime> onSelected;
  final Widget Function(DateTime month) pageBuilder;

  @override
  State<_MonthPager> createState() => _MonthPagerState();
}

class _MonthPagerState extends State<_MonthPager> {
  late final _controller = PageController(initialPage: _indexOf(widget.month));
  var _animating = false;

  int _indexOf(DateTime month) => monthsBetween(widget.earliest, month).clamp(0, _count - 1);
  int get _count => monthsBetween(widget.earliest, widget.latest) + 1;

  @override
  void didUpdateWidget(_MonthPager oldWidget) {
    super.didUpdateWidget(oldWidget);
    final target = _indexOf(widget.month);
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
    return HandoffPageView(
      controller: _controller,
      itemCount: _count,
      itemBuilder: (_, i) => widget.pageBuilder(addMonths(widget.earliest, i)),
      // 화살표로 밀려가는 중에 지나치는 달은 무시 — 도착한 뒤 선택 값이 이미 맞다.
      onPageChanged: (i) {
        if (_animating) return;
        final month = addMonths(widget.earliest, i);
        if (month != widget.month) widget.onSelected(month);
      },
    );
  }
}

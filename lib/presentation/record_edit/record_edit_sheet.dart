import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/clock_provider.dart';
import '../../core/providers/database_providers.dart';
import '../../domain/model/work_record.dart';
import '../../domain/rules/work_calculator.dart';
import '../../ui/app_colors.dart';
import '../../ui/app_sizes.dart';
import '../../ui/app_text_styles.dart';
import '../shared/confirm_dialog.dart';
import 'record_draft.dart';
import 'record_edit_controller.dart';
import 'record_edit_texts.dart';
import 'widgets/calc_rows.dart';
import 'widgets/time_row.dart';
import 'widgets/time_wheel.dart';
import 'widgets/type_chips.dart';

/// 네 진입점(오늘 시간 수정 · 누락 리스트 · 주간 행 · 월간 셀)이 공유하는 시트.
Future<void> showRecordEditSheet(BuildContext context, DateTime date) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.scrim,
    sheetAnimationStyle: AnimationStyle(duration: AppDurations.sheetSlide, curve: AppCurves.sheet),
    builder: (_) => RecordEditSheet(date: date),
  );
}

class RecordEditSheet extends ConsumerStatefulWidget {
  const RecordEditSheet({super.key, required this.date});

  final DateTime date;

  @override
  ConsumerState<RecordEditSheet> createState() => _RecordEditSheetState();
}

class _RecordEditSheetState extends ConsumerState<RecordEditSheet> {
  /// 기록 스트림의 첫 값으로 한 번만 만든다. 그 뒤 스트림이 다시 방출돼도 편집 중인 초안은 건드리지 않는다.
  RecordDraft? _draft;

  RecordDraft _initialDraft(List<WorkRecord> records) => RecordDraft.fromRecord(
        date: widget.date,
        today: ref.read(clockProvider)(),
        record: recordsByDate(records)[dateOnly(widget.date)],
      );

  void _update(RecordDraft next) => setState(() => _draft = next);

  void _close() => Navigator.of(context, rootNavigator: true).pop();

  Future<void> _save() async {
    await ref.read(recordEditControllerProvider.notifier).save(_draft!);
    if (mounted) _close();
  }

  Future<void> _delete() async {
    final ok = await showConfirmDialog(
      context,
      title: RecordEditTexts.deleteTitle,
      message: RecordEditTexts.deleteMessage,
      confirmLabel: RecordEditTexts.deleteConfirm,
    );
    if (!ok || !mounted) return;
    await ref.read(recordEditControllerProvider.notifier).delete(_draft!.date);
    if (mounted) _close();
  }

  /// 시트 좌우 패딩. 시각 행은 outdent만큼 바깥으로 나간다 (목업 margin 0 −12).
  Widget _inset(Widget child, {double outdent = 0}) => Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSizes.sheetPadding.left - outdent),
        child: child,
      );

  @override
  Widget build(BuildContext context) {
    final rules = ref.watch(workRulesProvider);
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final records = ref.watch(allRecordsProvider).value;
    if (records == null && _draft == null) return const SizedBox.shrink();
    final draft = _draft ??= _initialDraft(records!);
    final editing = draft.editing;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.sheetRadius)),
        boxShadow: [
          BoxShadow(
            color: AppColors.sheetShadow,
            offset: AppSizes.sheetShadowOffset,
            blurRadius: AppSizes.sheetShadowBlur,
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(top: AppSizes.sheetPadding.top, bottom: AppSizes.sheetPadding.bottom + bottomInset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: AppSizes.sheetHandleWidth,
                height: AppSizes.sheetHandleHeight,
                margin: EdgeInsets.only(bottom: AppSizes.sheetHandleBottom),
                decoration: BoxDecoration(color: AppColors.hairline, borderRadius: BorderRadius.circular(AppSizes.pill)),
              ),
            ),
            _inset(Text(RecordEditTexts.title(draft), style: AppTextStyles.sheetTitle)),
            if (draft.isWeekend)
              _inset(
                Container(
                  margin: AppSizes.sheetNoteMargin,
                  padding: AppSizes.sheetNotePadding,
                  decoration: BoxDecoration(
                    color: AppColors.chipNeutral,
                    borderRadius: BorderRadius.circular(AppSizes.sheetNoteRadius),
                  ),
                  child: Text(RecordEditTexts.weekendNote, style: AppTextStyles.sheetNote),
                ),
              ),
            if (draft.showsTypeChips)
              _inset(
                Padding(
                  padding: AppSizes.chipsMargin,
                  child: TypeChips(selected: draft.type, onChanged: (t) => _update(draft.withType(t))),
                ),
              ),
            if (draft.showsTimeRows) ...[
              _inset(
                outdent: AppSizes.timeRowOutdent,
                Column(
                  children: [
                    for (final row in EditingRow.values)
                      TimeRow(
                        label: row == EditingRow.clockIn ? RecordEditTexts.clockIn : RecordEditTexts.clockOut,
                        value: RecordEditTexts.time(draft.timeOf(row)),
                        selected: editing == row,
                        onTap: () => _update(draft.toggleEditing(row)),
                      ),
                  ],
                ),
              ),
              if (editing != null)
                _inset(
                  Container(
                    margin: EdgeInsets.only(top: AppSizes.wheelBoxTop),
                    padding: AppSizes.wheelBoxPadding,
                    decoration: BoxDecoration(
                      color: AppColors.cardInner,
                      borderRadius: BorderRadius.circular(AppSizes.wheelBoxRadius),
                    ),
                    child: Column(
                      children: [
                        Text(RecordEditTexts.wheelTitle(editing), style: AppTextStyles.wheelTitle),
                        SizedBox(height: AppSizes.wheelTitleBottom),
                        TimeWheel(
                          key: ValueKey(editing),
                          hour: draft.timeOf(editing)!.hour,
                          minute: draft.timeOf(editing)!.minute,
                          onChanged: (h, m) => _update(draft.withTime(editing, h, m)),
                        ),
                      ],
                    ),
                  ),
                ),
              _inset(
                Padding(
                  padding: EdgeInsets.only(top: AppSizes.calcTop),
                  child: draft.isValid
                      ? CalcRows(lines: calcLines(draft, rules))
                      : Text(RecordEditTexts.invalidRange, style: AppTextStyles.calcError),
                ),
              ),
            ],
            SizedBox(height: AppSizes.sheetButtonsTop),
            _inset(
              Row(
                children: [
                  Expanded(
                    child: SheetButton(label: RecordEditTexts.cancel, primary: false, onTap: _close),
                  ),
                  SizedBox(width: AppSizes.sheetButtonGap),
                  Expanded(
                    child: SheetButton(label: RecordEditTexts.save, primary: true, onTap: draft.isValid ? _save : null),
                  ),
                ],
              ),
            ),
            if (draft.existing)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _delete,
                child: Padding(
                  padding: EdgeInsets.only(top: AppSizes.deleteLinkTop),
                  child: Text(RecordEditTexts.deleteLink, style: AppTextStyles.deleteLink, textAlign: TextAlign.center),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

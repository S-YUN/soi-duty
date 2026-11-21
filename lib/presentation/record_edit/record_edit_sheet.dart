import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/clock_provider.dart';
import '../../core/providers/database_providers.dart';
import '../../domain/model/work_record.dart';
import '../../domain/model/work_type.dart';
import '../../domain/rules/work_calculator.dart';
import '../../domain/rules/work_rules.dart';
import '../../ui/app_colors.dart';
import '../../ui/app_sizes.dart';
import '../../ui/app_text_styles.dart';
import '../shared/confirm_dialog.dart';
import '../shared/quiet_text_button.dart';
import 'record_draft.dart';
import 'record_edit_controller.dart';
import 'record_edit_texts.dart';
import 'widgets/calc_rows.dart';
import 'widgets/deduction_sheet.dart';
import 'widgets/time_row.dart';
import 'widgets/time_wheel.dart';
import 'widgets/trip_choice_panel.dart';
import 'widgets/trip_sheet.dart';
import 'widgets/type_chips.dart';
import 'widgets/type_rows.dart';

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

  /// 출장 칩(행) 아래 "종일 / 시간" 패널이 열려 있는지. 초안이 아니라 화면 상태다.
  var _tripPanelOpen = false;

  RecordDraft _initialDraft(List<WorkRecord> records) => RecordDraft.fromRecord(
    date: widget.date,
    today: ref.read(clockProvider)(),
    record: recordsByDate(records)[dateOnly(widget.date)],
  );

  void _update(RecordDraft next) => setState(() => _draft = next);

  void _close() => Navigator.of(context, rootNavigator: true).pop();

  Future<void> _save() => _saveDraft(_draft!);

  Future<void> _saveDraft(RecordDraft draft) async {
    await ref.read(recordEditControllerProvider.notifier).save(draft);
    if (mounted) _close();
  }

  /// 시간공제 행 탭 — 작은 시트를 겹쳐 띄운다. 과거·퇴근한 오늘은 초안만 바꾸고(저장 버튼으로 마무리),
  /// 유형 전용 모드(미래·출근 전 오늘)는 유형 행처럼 작은 시트의 저장이 곧 저장이다.
  Future<void> _editDeduction(RecordDraft draft, WorkRules rules) async {
    final minutes = await showDeductionSheet(
      context,
      minutes: draft.deductionMinutes,
      maxHours: standardMinutes(draft.type, rules) ~/ 60,
      stepMinutes: rules.deductionStepMinutes,
      confirmLabel: draft.isTypeOnly ? RecordEditTexts.save : RecordEditTexts.confirm,
    );
    if (minutes == null || !mounted) return;
    final next = _draft!.withDeduction(minutes);
    if (next.isTypeOnly) return _saveDraft(next);
    _update(next);
  }

  /// 칩 탭. 연차·공휴일·출장은 그 자리에서 저장하고 닫는다 — 시각이 있던 날은 지워진다고 한 번 묻는다.
  /// 공휴일 근무는 다시 열어 "근무한 시간 입력"으로. 반차 선택·유형 해제는 시각 입력이 이어지므로 초안만 바꾼다.
  /// 유형 전용 모드(미래·출근 전 오늘)는 저장 버튼이 없어 어느 유형이든 바로 저장.
  Future<void> _onTypeChanged(RecordDraft draft, WorkType? type) async {
    if (_tripPanelOpen) setState(() => _tripPanelOpen = false);
    final next = draft.withType(type);
    if (!draft.isTypeOnly && !next.isOff) return _update(next);
    if (next.isOff && draft.hasAnyTime) {
      final ok = await showConfirmDialog(
        context,
        title: RecordEditTexts.replaceTimesTitle(next.type),
        message: RecordEditTexts.replaceTimesMessage,
        confirmLabel: RecordEditTexts.replaceTimesConfirm,
      );
      if (!ok || !mounted) return;
    }
    await _saveDraft(next);
  }

  /// 패널 "종일 출장" — 예전 출장 칩과 같다(즉시 저장·닫힘, 시각이 있으면 확인). 반차인 날은 패널이 눌리지 않게 막는다.
  Future<void> _onTripFullDay(RecordDraft draft) async {
    if (draft.isFullDayTrip) return setState(() => _tripPanelOpen = false);
    await _onTypeChanged(draft, WorkType.businessTrip);
  }

  /// 패널 "시간 출장"·출장 행 — 작은 시트를 겹쳐 띄운다. 시간공제와 같은 흐름:
  /// 과거·퇴근한 오늘은 초안만 바꾸고(저장 버튼으로 마무리), 유형 전용 모드는 작은 시트의 저장이 곧 저장.
  Future<void> _editTrip(RecordDraft draft, WorkRules rules) async {
    final (start, end) = draft.hasTrip
        ? (draft.tripStart!, draft.tripEnd!)
        : defaultTripRange(draft.date, draft.showsTimeRows ? draft.clockIn : null, rules);
    final result = await showTripSheet(
      context,
      start: start,
      end: end,
      existing: draft.hasTrip,
      // 넣은 뒤의 초안에 저장 버튼이 있으면 "확인"(큰 시트 저장으로 마무리), 없으면 이 버튼이 곧 저장.
      confirmLabel: draft.withTrip(start, end).showsSaveButton ? RecordEditTexts.confirm : RecordEditTexts.save,
    );
    if (result == null || !mounted) return;
    final next = switch (result) {
      TripSheetSet(:final start, :final end) => _draft!.withTrip(start, end),
      TripSheetCleared() => _draft!.withoutTrip(),
    };
    await _applyTrip(next);
  }

  /// 출장 범위를 바꾼 초안을 반영한다. 큰 시트에 저장 버튼이 없으면(유형 전용 모드, 근무 시간을 펼치지 않은 지난 공휴일)
  /// 여기서 바로 저장한다 — 초안에만 두면 저장할 길이 없어 닫는 순간 사라진다.
  Future<void> _applyTrip(RecordDraft next) async {
    if (!next.showsSaveButton) return _saveDraft(next);
    setState(() {
      _draft = next;
      _tripPanelOpen = false;
    });
  }

  /// 패널 "출장 빼기" — 종일이면 유형을 풀고, 시간이면 범위를 지운다.
  Future<void> _onTripRemove(RecordDraft draft) async {
    if (draft.isFullDayTrip) return _onTypeChanged(draft, null);
    await _applyTrip(draft.withoutTrip());
  }

  Widget _tripPanel(RecordDraft draft, WorkRules rules) => TripChoicePanel(
        fullDaySelected: draft.isFullDayTrip,
        timedSelected: draft.hasTrip,
        fullDayEnabled: draft.type != WorkType.halfDay,
        timedRange: draft.hasTrip ? RecordEditTexts.tripRange(draft.tripStart, draft.tripEnd) : null,
        onFullDay: () => _onTripFullDay(draft),
        onTimed: () => _editTrip(draft, rules),
        onRemove: draft.tripSelected ? () => _onTripRemove(draft) : null,
      );

  /// 패널을 열면 펼쳐둔 휠을 접는다 — 휠·패널·계산 내역이 같이 펼쳐지면 시트가 화면을 채워 닫히지 않는다.
  void _toggleTripPanel() => setState(() {
        _tripPanelOpen = !_tripPanelOpen;
        if (_tripPanelOpen) _draft = _draft!.collapsed();
      });

  /// 출퇴근 행 탭 — 휠을 펴면 패널을 닫는다.
  void _toggleEditing(RecordDraft draft, EditingRow row, WorkRules rules) => setState(() {
        _draft = draft.toggleEditing(row, rules);
        if (_draft!.editing != null) _tripPanelOpen = false;
      });

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
                decoration: BoxDecoration(
                  color: AppColors.hairline,
                  borderRadius: BorderRadius.circular(AppSizes.pill),
                ),
              ),
            ),
            _inset(Text(RecordEditTexts.title(draft), style: AppTextStyles.sheetTitle)),
            if (draft.isWeekend) _inset(_Note(RecordEditTexts.weekendNote)),
            // 미래·출근 전 오늘은 유형만 고르는 자리 — 안내 한 줄 + 전체 너비 행. 과거는 시각 행 위의 칩.
            if (draft.isTypeOnly && draft.showsTypeChips) ...[
              SizedBox(height: AppSizes.sheetSubtitleTop),
              _inset(Text(RecordEditTexts.futureNote, style: AppTextStyles.sheetSubtitle)),
              SizedBox(height: AppSizes.typeRowsTop),
              _inset(
                TypeRows(
                  selected: draft.type,
                  tripSelected: draft.tripSelected,
                  tripRange: draft.hasTrip ? RecordEditTexts.tripRange(draft.tripStart, draft.tripEnd) : null,
                  onChanged: (t) => _onTypeChanged(draft, t),
                  onTripTap: _toggleTripPanel,
                ),
              ),
              if (_tripPanelOpen) _inset(_tripPanel(draft, rules)),
            ] else if (draft.showsTypeChips) ...[
              _inset(
                Padding(
                  padding: AppSizes.chipsMargin,
                  child: TypeChips(
                    selected: draft.type,
                    tripSelected: draft.tripSelected,
                    onChanged: (t) => _onTypeChanged(draft, t),
                    onTripTap: _toggleTripPanel,
                  ),
                ),
              ),
              if (_tripPanelOpen) _inset(_tripPanel(draft, rules)),
            ],
            // 공휴일은 대부분 쉬는 날 — 근무 입력은 한 번 더 눌러야 펼쳐진다.
            if (draft.showsHolidayWorkButton)
              Padding(
                padding: EdgeInsets.only(top: AppSizes.holidayWorkButtonTop),
                child: Center(
                  child: QuietTextButton(
                    label: RecordEditTexts.holidayWorkButton,
                    onTap: () => _update(draft.expandHolidayWork()),
                  ),
                ),
              ),
            if (draft.showsTimeRows && draft.type == WorkType.holiday) _inset(_Note(RecordEditTexts.holidayNote)),
            if (draft.showsTimeRows) ...[
              _inset(
                outdent: AppSizes.timeRowOutdent,
                Column(
                  children: [
                    for (final row in const [EditingRow.clockIn, EditingRow.clockOut])
                      TimeRow(
                        label: row == EditingRow.clockIn ? RecordEditTexts.clockIn : RecordEditTexts.clockOut,
                        value: RecordEditTexts.time(draft.timeOf(row)),
                        selected: editing == row,
                        onTap: () => _toggleEditing(draft, row, rules),
                      ),
                  ],
                ),
              ),
              if (editing == EditingRow.clockIn || editing == EditingRow.clockOut)
                _inset(
                  _WheelBox(
                    title: RecordEditTexts.wheelTitle(editing!),
                    children: [
                      TimeWheel(
                        key: ValueKey(editing),
                        hour: draft.timeOf(editing)!.hour,
                        minute: draft.timeOf(editing)!.minute,
                        onChanged: (h, m) => _update(draft.withTime(editing, h, m)),
                      ),
                    ],
                  ),
                ),
            ],
            // 시간 출장 — 출퇴근 행(과 휠) 아래, 시간공제 위. 계산 내역에는 넣지 않는다(계산과 무관한 기록).
            // 휠을 펴는 동안은 숨긴다(계산 내역처럼) — 작은 기기에서 휠 + 출장 행 + 공제 행이 화면을 넘는다.
            if (draft.showsTripRow && editing == null)
              _inset(
                outdent: AppSizes.timeRowOutdent,
                TimeRow(
                  label: RecordEditTexts.tripRowLabel,
                  value: draft.hasTrip
                      ? RecordEditTexts.tripRange(draft.tripStart, draft.tripEnd)
                      : RecordEditTexts.tripNone,
                  selected: false,
                  onTap: () => _editTrip(draft, rules),
                ),
              ),
            if (draft.showsDeductionRow) ...[
              if (draft.isTypeOnly) SizedBox(height: AppSizes.typeRowsTop),
              _inset(
                outdent: AppSizes.timeRowOutdent,
                TimeRow(
                  label: RecordEditTexts.deductionLabel,
                  value: RecordEditTexts.deduction(draft.deductionMinutes),
                  selected: false,
                  onTap: () => _editDeduction(draft, rules),
                ),
              ),
            ],
            if ((draft.showsCalcRows && !_tripPanelOpen) || !draft.isValid(rules))
              _inset(
                Padding(
                  padding: EdgeInsets.only(top: AppSizes.calcTop),
                  child: !draft.isDeductionValid(rules)
                      ? Text(RecordEditTexts.halfDayDeductionTooLong, style: AppTextStyles.calcError)
                      : !draft.isValid(rules)
                      ? Text(RecordEditTexts.invalidRange, style: AppTextStyles.calcError)
                      : CalcRows(lines: calcLines(draft, rules)),
                ),
              ),
            // 저장은 시각 행이 있을 때만 — 연차·공휴일·출장·유형 전용 모드는 탭(작은 시트의 저장)이 곧 저장이다.
            // 닫기는 아래로 내리기·바깥 탭.
            if (draft.showsSaveButton) ...[
              SizedBox(height: AppSizes.sheetButtonsTop),
              _inset(
                SheetButton(label: RecordEditTexts.save, primary: true, onTap: draft.isValid(rules) ? _save : null),
              ),
            ],
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

/// 시트 상단 안내 박스 (주말·공휴일 근무).
class _Note extends StatelessWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppSizes.sheetNoteMargin,
      padding: AppSizes.sheetNotePadding,
      decoration: BoxDecoration(
        color: AppColors.chipNeutral,
        borderRadius: BorderRadius.circular(AppSizes.sheetNoteRadius),
      ),
      child: Text(text, style: AppTextStyles.sheetNote),
    );
  }
}

/// 펼친 행 아래 휠 박스 — 제목 + 휠(+ 시간공제면 사유·설명).
class _WheelBox extends StatelessWidget {
  const _WheelBox({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: AppSizes.wheelBoxTop),
      padding: AppSizes.wheelBoxPadding,
      decoration: BoxDecoration(
        color: AppColors.cardInner,
        borderRadius: BorderRadius.circular(AppSizes.wheelBoxRadius),
      ),
      child: Column(
        children: [
          Text(title, style: AppTextStyles.wheelTitle),
          SizedBox(height: AppSizes.wheelTitleBottom),
          ...children,
        ],
      ),
    );
  }
}

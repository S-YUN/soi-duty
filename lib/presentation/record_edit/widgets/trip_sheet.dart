import 'package:flutter/material.dart';

import '../../../ui/app_colors.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';
import '../record_edit_texts.dart';
import 'time_range_sheet.dart';

/// 시간 출장 작은 시트의 결과. 바깥 탭·아래로 내리기면 null — 아무것도 바꾸지 않는다.
sealed class TripSheetResult {
  const TripSheetResult();
}

/// "확인"/"저장" — 이 범위로 남긴다.
class TripSheetSet extends TripSheetResult {
  const TripSheetSet(this.start, this.end);

  final DateTime start;
  final DateTime end;
}

/// "출장 지우기"
class TripSheetCleared extends TripSheetResult {
  const TripSheetCleared();
}

/// "몇 시부터 몇 시까지 출장"을 고르는 작은 시트 — 시간공제 시트처럼 큰 시트(또는 오늘 화면) 위에 겹쳐 뜬다.
/// 기록만 남기는 값이라 검증은 "끝이 시작보다 늦을 것" 하나다 (핸드오프 6 §3).
/// [existing]이면 이미 있는 범위를 고치는 중 — "출장 지우기"가 보인다.
Future<TripSheetResult?> showTripSheet(
  BuildContext context, {
  required DateTime start,
  required DateTime end,
  required bool existing,
  required String confirmLabel,
}) {
  return showModalBottomSheet<TripSheetResult>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.scrim,
    sheetAnimationStyle: AnimationStyle(duration: AppDurations.sheetSlide, curve: AppCurves.sheet),
    builder: (_) => TripSheet(start: start, end: end, existing: existing, confirmLabel: confirmLabel),
  );
}

/// 골격은 [TimeRangeSheet] — 여기서는 출장 문구와 결과(범위 · 지우기)만 붙인다.
class TripSheet extends StatelessWidget {
  const TripSheet({
    super.key,
    required this.start,
    required this.end,
    required this.existing,
    required this.confirmLabel,
  });

  final DateTime start;
  final DateTime end;
  final bool existing;
  final String confirmLabel;

  @override
  Widget build(BuildContext context) {
    return TimeRangeSheet(
      title: RecordEditTexts.tripSheetTitle,
      help: RecordEditTexts.tripSheetHelp,
      startLabel: RecordEditTexts.tripStart,
      endLabel: RecordEditTexts.tripEnd,
      start: start,
      end: end,
      validNote: RecordEditTexts.tripResult,
      validNoteStyle: AppTextStyles.tripResult,
      invalidNote: RecordEditTexts.tripInvalid,
      confirmLabel: confirmLabel,
      onConfirm: (start, end) => Navigator.of(context).pop(TripSheetSet(start, end)),
      linkLabel: RecordEditTexts.tripClear,
      onLink: existing ? () => Navigator.of(context).pop(const TripSheetCleared()) : null,
    );
  }
}

import '../../core/presentation/format/date_format.dart';
import '../../core/presentation/format/time_format.dart';
import '../../domain/model/work_type.dart';
import 'month_state.dart';

/// 월간 화면의 모든 문구.
abstract final class MonthTexts {
  static const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
  static const legend = [(WorkType.halfDay, '반차'), (WorkType.dayOff, '연차'), (WorkType.holiday, '공휴일')];

  static String title(DateTime month) => formatMonthTitle(month);

  /// 출퇴근이 덜 찍힌 오늘을 탭했을 때. 연차·공휴일로 찍힌 오늘은 되돌리기 안내.
  static String todayInProgressToast(MonthCell cell) =>
      cell.type == WorkType.dayOff || cell.type == WorkType.holiday
          ? '오늘 연차·공휴일은 오늘 탭에서 되돌릴 수 있어요'
          : '오늘 기록은 퇴근한 뒤에 수정할 수 있어요';

  static String value(MonthCellValue v) => switch (v) {
        MonthCellNone() => '',
        MonthCellDelta(:final minutes) => formatSignedNarrowHm(minutes),
        MonthCellWeekendActual(:final minutes) => formatNarrowHm(minutes),
        MonthCellWorking() => '···',
        MonthCellUnrecorded() => '—',
      };
}

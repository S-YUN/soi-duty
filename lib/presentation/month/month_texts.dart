import '../../core/presentation/format/date_format.dart';
import '../../core/presentation/format/time_format.dart';
import '../../domain/model/work_type.dart';
import 'month_state.dart';

/// 월간 화면의 모든 문구.
abstract final class MonthTexts {
  static const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
  static const legend = [(WorkType.halfDay, '반차'), (WorkType.dayOff, '연차'), (WorkType.holiday, '공휴일')];

  static String title(DateTime month) => formatMonthTitle(month);

  static String value(MonthCellValue v) => switch (v) {
        MonthCellNone() => '',
        MonthCellDelta(:final minutes) => formatSignedHm(minutes),
        MonthCellWeekendActual(:final minutes) => formatHm(minutes),
        MonthCellWorking() => '···',
        MonthCellUnrecorded() => '—',
      };
}

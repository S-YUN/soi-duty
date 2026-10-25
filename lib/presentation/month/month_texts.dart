import '../../core/presentation/format/date_format.dart';
import '../../core/presentation/format/time_format.dart';
import '../../domain/model/work_type.dart';
import 'month_state.dart';

/// 월간 화면의 모든 문구.
abstract final class MonthTexts {
  /// 요일 헤더 — 첫 주의 실제 날짜로 그린다(시작 요일 설정에 따라 월…일 또는 일…토).
  static String weekday(DateTime d) => weekdayShort(d);
  static const legend = [
    (WorkType.halfDay, '반차'),
    (WorkType.dayOff, '연차'),
    (WorkType.holiday, '공휴일'),
    (WorkType.businessTrip, '출장'),
  ];

  static String title(DateTime month) => formatMonthTitle(month);

  /// 근무 중인 오늘을 탭했을 때. 퇴근은 오늘 화면이 찍는다.
  static const todayInProgressToast = '오늘 기록은 퇴근한 뒤에 수정할 수 있어요';

  static String value(MonthCellValue v) => switch (v) {
        MonthCellNone() => '',
        MonthCellDelta(:final minutes) => formatSignedNarrowHm(minutes),
        MonthCellWeekendActual(:final minutes) => formatNarrowHm(minutes),
        MonthCellWorking() => '···',
        MonthCellUnrecorded() => '—',
      };
}

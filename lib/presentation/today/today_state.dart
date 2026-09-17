import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/model/work_record.dart';
import '../../domain/model/work_type.dart';
import '../../domain/rules/week_summary.dart';
import '../../domain/rules/work_calculator.dart' as calc;

part 'today_state.freezed.dart';

enum TodayPhase { before, working, done }

/// 화면 5상태 중 버튼·슬롯 구성을 결정하는 4가지. 첫 주 예외는 [TodayState.isFirstWeek]로 겹쳐 본다.
enum TodayScreenState { beforeWork, working, done, dayType }

@freezed
abstract class TodayState with _$TodayState {
  const TodayState._();

  const factory TodayState({
    required DateTime date,
    WorkRecord? record,
    required TodayPhase phase,
    WorkType? dayType,
    required bool isHalfDay,
    DateTime? clockIn,
    DateTime? clockOut,
    /// working일 때 now − clockIn (점심 미공제)
    int? elapsedMinutes,
    /// working일 때만. 첫 주 예외·주말·연차·이미 채움이면 null
    DateTime? expectedClockOut,
    /// 출근 전·근무 중일 때 오늘 몫 (남은 시간 ÷ 남은 근무일). 반차는 4h 고정. 첫 주 예외·주말·연차면 null
    int? todayShareMinutes,
    /// 이번 주 남은 시간 (오늘 진행분 제외). 0 이하면 이미 채움
    int? weekRemainingBeforeToday,
    required bool isFirstWorkday,
    required bool isLastWorkday,
    int? todayActual,
    int? todayDelta,
    required WeekSummary week,
    required List<DateTime> unrecordedDays,
    DateTime? firstRecordDate,
  }) = _TodayState;

  bool get isWeekend => calc.isWeekend(date);
  bool get isFirstWeek => week.isFirstWeekException;

  /// 이번 주 이미 채워서 퇴근 시각 대신 안내를 띄우는 상태
  bool get isWeekFilled => (weekRemainingBeforeToday ?? 1) <= 0;

  TodayScreenState get screenState => switch (phase) {
        TodayPhase.working => TodayScreenState.working,
        TodayPhase.done => TodayScreenState.done,
        TodayPhase.before => dayType == null ? TodayScreenState.beforeWork : TodayScreenState.dayType,
      };
}

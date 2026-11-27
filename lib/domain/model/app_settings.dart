import 'package:freezed_annotation/freezed_annotation.dart';

import '../rules/work_rules.dart';
import 'leave_balance.dart';

part 'app_settings.freezed.dart';

/// 월간 캘린더 시작 요일. 주간 탭·주 40시간 계산은 월~일 고정 — 이 값은 월간 캘린더 모양만 바꾼다.
enum WeekStart { monday, sunday }

/// 사용자가 설정 화면에서 넣는 값. 연차·수당은 값을 넣으면 켜지고 비우면 꺼지는 옵트인이다.
@freezed
abstract class AppSettings with _$AppSettings {
  const AppSettings._();

  const factory AppSettings({
    @Default(WeekStart.monday) WeekStart weekStart,
    /// 해 → 그 해 남은 연차 + 기준일. 해마다 따로 — 새해에 고친 값이 지난해 카드를 바꾸지 않게. 없는 해 = 사용 안 함.
    @Default({}) Map<int, LeaveBalance> leaveBalanceByYear,
    /// 시급(원). null = 사용 안 함
    int? hourlyWage,
    /// 마지막 내보내기 날짜(날짜만). null = 아직 내보낸 적 없음. 백업 파일에는 넣지 않는다 — 기기별 값.
    DateTime? lastExportDate,
    /// 퇴근 알림을 켰는지. OS 권한과는 별개 — 켰어도 OS가 막고 있으면 울리지 않는다.
    /// 백업 파일에는 넣지 않는다 — 권한이 기기마다 달라 새 폰에서는 다시 묻는다.
    @Default(false) bool clockOutNotificationEnabled,
    /// "퇴근할 때 알려드릴까요?"를 이미 물었는지 — 첫 평일 출근 때 한 번만 묻는다. 기기 값.
    @Default(false) bool notificationPrompted,
    /// 기록 시트에서 빈 출근·퇴근 행을 열 때 휠의 처음 값(자정 기준 분, 핸드오프 7). 둘 다 있거나 둘 다 없다 —
    /// 없으면 [WorkRules]의 기본값(08:00 · 17:00). 읽을 때는 [defaultClockTimes]로.
    int? defaultClockInMinutes,
    int? defaultClockOutMinutes,
  }) = _AppSettings;

  /// 입력 한도. 설정 시트의 자릿수와 백업 가져오기의 범위 검사가 같은 값을 본다.
  /// 남은 연차는 일 단위 한도만 여기에 — 분 한도·단위 검사는 `isValidLeaveMinutes`(WorkRules 필요).
  static const maxLeaveDays = 99;
  static const maxHourlyWage = 9999999;
  static bool isValidHourlyWage(int won) => won >= 1 && won <= maxHourlyWage;

  /// 기본 출퇴근 시각 한 쌍이 쓸 수 있는 값인지 — 둘 다 하루 안이고 퇴근이 출근보다 늦을 것(자정 넘김 미지원).
  /// 설정 시트·저장소 읽기·백업 가져오기가 같은 검사를 쓴다.
  static bool isValidDefaultClockTimes(int? clockIn, int? clockOut) =>
      clockIn != null && clockOut != null && clockIn >= 0 && clockOut < 24 * 60 && clockOut > clockIn;

  /// 자정 기준 분 ↔ 저장·백업 표기 `HH:mm`.
  static String formatClockMinutes(int minutes) =>
      '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';

  /// `HH:mm`이 아니거나 하루 밖이면 null.
  static int? parseClockMinutes(Object? value) {
    if (value is! String) return null;
    final m = RegExp(r'^(\d{2}):(\d{2})$').firstMatch(value);
    if (m == null) return null;
    final hour = int.parse(m[1]!);
    final minute = int.parse(m[2]!);
    return hour < 24 && minute < 60 ? hour * 60 + minute : null;
  }

  /// 빈 출근·퇴근 행의 휠이 시작하는 시각 (출근, 퇴근). 사용자가 정한 값이 없거나 못 쓰는 값이면 [rules]의 기본값.
  (int, int) defaultClockTimes(WorkRules rules) => isValidDefaultClockTimes(defaultClockInMinutes, defaultClockOutMinutes)
      ? (defaultClockInMinutes!, defaultClockOutMinutes!)
      : (rules.defaultClockInMinutes, rules.defaultClockOutMinutes);

  /// 한 쌍으로만 바꾼다. 못 쓰는 쌍(하나만 있음 · 퇴근 ≤ 출근)은 둘 다 비운다 — 기본값으로 돌아간다.
  AppSettings withDefaultClockTimes(int? clockIn, int? clockOut) {
    final ok = isValidDefaultClockTimes(clockIn, clockOut);
    return copyWith(defaultClockInMinutes: ok ? clockIn : null, defaultClockOutMinutes: ok ? clockOut : null);
  }

  LeaveBalance? leaveBalanceOf(int year) => leaveBalanceByYear[year];

  /// balance가 null이면 그 해 값을 지운다.
  AppSettings withLeaveBalance(int year, LeaveBalance? balance) {
    final next = Map<int, LeaveBalance>.of(leaveBalanceByYear);
    if (balance == null) {
      next.remove(year);
    } else {
      next[year] = balance;
    }
    return copyWith(leaveBalanceByYear: next);
  }
}

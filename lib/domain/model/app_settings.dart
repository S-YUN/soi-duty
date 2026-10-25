import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings.freezed.dart';

/// 월간 캘린더 시작 요일. 주간 탭·주 40시간 계산은 월~일 고정 — 이 값은 월간 캘린더 모양만 바꾼다.
enum WeekStart { monday, sunday }

/// 사용자가 설정 화면에서 넣는 값. 연차·수당은 값을 넣으면 켜지고 비우면 꺼지는 옵트인이다.
@freezed
abstract class AppSettings with _$AppSettings {
  const AppSettings._();

  const factory AppSettings({
    @Default(WeekStart.monday) WeekStart weekStart,
    /// 해 → 그 해 총 연차(정수 일). 해마다 따로 — 새해에 고친 값이 지난해 카드를 바꾸지 않게.
    @Default({}) Map<int, int> annualLeaveDaysByYear,
    /// 시급(원). null = 사용 안 함
    int? hourlyWage,
    /// 마지막 내보내기 날짜(날짜만). null = 아직 내보낸 적 없음. 백업 파일에는 넣지 않는다 — 기기별 값.
    DateTime? lastExportDate,
  }) = _AppSettings;

  int? annualLeaveDaysOf(int year) => annualLeaveDaysByYear[year];

  /// days가 null이면 그 해 값을 지운다.
  AppSettings withAnnualLeaveDays(int year, int? days) {
    final next = Map<int, int>.of(annualLeaveDaysByYear);
    if (days == null) {
      next.remove(year);
    } else {
      next[year] = days;
    }
    return copyWith(annualLeaveDaysByYear: next);
  }
}

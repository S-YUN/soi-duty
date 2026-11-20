import '../notification/clock_out_notice.dart';

/// 퇴근 알림이 기기에 남겨야 하는 상태 둘. 사용자 설정이 아니라 동작 기록이라 `AppSettings`와 따로 둔다 — 백업에도 넣지 않는다.
abstract interface class NotificationStateRepository {
  /// 마지막으로 예약했거나 바로 띄운 알림. 예약 시각이 지났으면 OS가 이미 띄운 것으로 본다 —
  /// 이 값이 없으면 퇴근 시각이 지난 뒤 앱을 켤 때마다 같은 알림이 다시 울린다.
  Future<ClockOutNotice?> lastNotice();

  /// null이면 지운다.
  Future<void> saveLastNotice(ClockOutNotice? notice);

  /// OS 권한 창을 띄운 적이 있는지. 허용이 아닐 때 "아직 안 물어봄"과 "거부함"을 가르는 유일한 단서다
  /// (OS는 둘을 구분해 알려주지 않는다).
  Future<bool> osAsked();

  Future<void> markOsAsked();
}

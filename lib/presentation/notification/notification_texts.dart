import '../../domain/notification/clock_out_notice.dart';

/// 퇴근 알림의 모든 문구 — 알림 본문, 권한 묻기, OS 채널 이름 (핸드오프 6 §10).
abstract final class NotificationTexts {
  /// Android OS 설정의 알림 채널 이름·설명
  static const channelName = '퇴근 알림';
  static const channelDescription = '그날 채울 시간을 다 채우면 알려드려요';

  // 알림 (제목, 본문). 워치에서는 제목만 보여도 뜻이 통해야 한다 — 숫자(시각·남은 시간)와 "금요일"은 쓰지 않는다
  // (마지막 근무일이 목요일일 수 있다). 이미 지난 시각이라 바로 보낼 때(N3)도 같은 문구다.
  static const dailyTitle = '퇴근할 시간이에요';
  static const dailyBody = '오늘 채울 시간을 다 채웠어요. 수고 많으셨어요!';
  static const weeklyTitle = '이번 주 근무 시간을 다 채웠어요!';
  static const weeklyBody = '이제 퇴근하셔도 돼요. 즐거운 휴일 보내세요!';
  static const weeklyEarlyBody = '이제 퇴근하셔도 돼요. 남은 날은 더 채우지 않아도 돼요!';

  static (String title, String body) notice(ClockOutNoticeKind kind) => switch (kind) {
        ClockOutNoticeKind.daily => (dailyTitle, dailyBody),
        ClockOutNoticeKind.weekly => (weeklyTitle, weeklyBody),
        ClockOutNoticeKind.weeklyEarly => (weeklyTitle, weeklyEarlyBody),
      };
}

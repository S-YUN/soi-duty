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

  // 권한 묻기 (P1) — 첫 평일 출근 직후
  static const appName = '소이듀티';
  static const promptTitle = '퇴근할 때 알려드릴까요?';
  static const promptMessage = '오늘 채울 시간을 다 채우면 퇴근 알림을 보내드려요.';
  static const promptAccept = '알림 받기';
  static const promptDecline = '안 받을래요';

  /// P2 — 거절 직후
  static const declinedToast = '알림은 설정에서 언제든 켤 수 있어요';

  /// P5 — OS 권한 창에서 거절한 직후 (P1 수락 뒤, 또는 설정 토글을 켠 뒤)
  static const osDeniedToast = '기기 설정에서 알림을 허용해야 받을 수 있어요';

  // 설정 화면 (P3 · P4)
  static const settingsSection = '알림';
  static const settingsLabel = '퇴근 알림';
  static const settingsOnSub = '그날 채울 시간을 다 채우면 알려드려요';
  static const settingsOffSub = '알림을 켜면 퇴근할 시간에 알려드려요';
  static const osOffSub = '기기 설정에서 알림이 꺼져 있어요';
  static const osOffTitle = '알림이 꺼져 있어요';
  static const osOffMessage = '기기 설정에서 소이듀티 알림을 허용하면 퇴근할 시간에 알려드려요.';
  static const openSettings = '설정 열기';
  static const openSettingsFailed = '기기 설정을 열 수 없어요';

  static (String title, String body) notice(ClockOutNoticeKind kind) => switch (kind) {
        ClockOutNoticeKind.daily => (dailyTitle, dailyBody),
        ClockOutNoticeKind.weekly => (weeklyTitle, weeklyBody),
        ClockOutNoticeKind.weeklyEarly => (weeklyTitle, weeklyEarlyBody),
      };
}

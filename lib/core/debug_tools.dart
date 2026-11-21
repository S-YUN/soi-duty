import 'package:flutter/foundation.dart';

/// 디버그 도구(날짜 제목 길게 누르기 → 시계 이동 · 시드 · 알림 시험)를 켤지.
///
/// 디버그 빌드는 늘 켜진다. 릴리즈 빌드는 `--dart-define=SOI_DEBUG_TOOLS=true`를 줄 때만 —
/// iOS 실기기 디버그 빌드는 화면을 잠그면 연결이 끊기고 홈 화면에서 다시 열 수 없어,
/// 잠금 화면·앱 종료 상태의 알림은 릴리즈 빌드에서만 볼 수 있다 (2026-11-21).
/// `scripts/release.sh`는 이 값을 주지 않으니 스토어 빌드에는 들어가지 않는다(컴파일 상수라 코드째 빠진다).
const kDebugTools = kDebugMode || bool.fromEnvironment('SOI_DEBUG_TOOLS');

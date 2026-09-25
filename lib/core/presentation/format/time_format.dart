const _minus = '−';

/// 442 → "7h 22m", 2160 → "36h", 22 → "22m", 0 → "0m", 음수는 "−" 접두.
String formatHm(int minutes) {
  final negative = minutes < 0;
  final abs = minutes.abs();
  final h = abs ~/ 60;
  final m = abs % 60;
  final body = h > 0 ? (m > 0 ? '${h}h ${m}m' : '${h}h') : '${m}m';
  return negative ? '$_minus$body' : body;
}

/// 기준 대비용. 양수는 "+", 음수는 "−", 0은 부호 없음.
String formatSignedHm(int minutes) {
  if (minutes > 0) return '+${formatHm(minutes)}';
  return formatHm(minutes);
}

/// 공백 없는 좁은 칸용. 442 → "7h22m". 월간 캘린더 셀(폭 43 남짓)에서 "7h 22m"은 뒤가 잘린다.
String formatCompactHm(int minutes) => formatHm(minutes).replaceAll(' ', '');

/// 공백 없는 기준 대비. 232 → "+3h52m".
String formatSignedCompactHm(int minutes) => formatSignedHm(minutes).replaceAll(' ', '');

String formatClock(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

/// "09:05 – 18:36" (en dash)
String formatClockRange(DateTime clockIn, DateTime clockOut) => '${formatClock(clockIn)} – ${formatClock(clockOut)}';

/// 435 → "7시간 15분", 420 → "7시간", 15 → "15분", 0 → "0분"
String formatKoreanDuration(int minutes) {
  final abs = minutes.abs();
  final h = abs ~/ 60;
  final m = abs % 60;
  if (h == 0) return '$m분';
  return m == 0 ? '$h시간' : '$h시간 $m분';
}

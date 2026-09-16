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

String formatClock(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

/// "09:05 – 18:36" (en dash)
String formatClockRange(DateTime clockIn, DateTime clockOut) => '${formatClock(clockIn)} – ${formatClock(clockOut)}';

/// 천 단위 콤마. 12500 → "12,500"
String formatThousands(int n) {
  final digits = n.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
    buf.write(digits[i]);
  }
  return n < 0 ? '-$buf' : buf.toString();
}

/// 206250 → "206,250원"
String formatWon(int won) => '${formatThousands(won)}원';

/// 연차 분 → 일. 7200/480 → "15일", 4080 → "8.5일", 3960 → "8.25일", 0 → "0일". 소수 둘째 자리까지, 끝 0 제거.
String formatLeaveDays(int minutes, int dayMinutes) {
  if (minutes % dayMinutes == 0) return '${minutes ~/ dayMinutes}일';
  final text = (minutes / dayMinutes).toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  return '$text일';
}

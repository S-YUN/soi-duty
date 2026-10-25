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

/// 반일 단위 → 일. 15 → "7.5일", 30 → "15일", 1 → "0.5일"
String formatLeaveDays(int halfDays) => halfDays.isEven ? '${halfDays ~/ 2}일' : '${halfDays ~/ 2}.5일';

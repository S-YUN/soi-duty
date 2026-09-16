const _weekdayShort = ['월', '화', '수', '목', '금', '토', '일'];

String _weekday(DateTime d) => _weekdayShort[d.weekday - DateTime.monday];

/// "9월 11일 금요일"
String formatDateTitle(DateTime d) => '${d.month}월 ${d.day}일 ${_weekday(d)}요일';

/// "9월 4일 금"
String formatDateShort(DateTime d) => '${d.month}월 ${d.day}일 ${_weekday(d)}';

/// "9월 7일 – 13일", 달이 바뀌면 "8월 31일 – 9월 6일"
String formatWeekRange(DateTime monday) {
  final sunday = DateTime(monday.year, monday.month, monday.day + 6);
  if (sunday.month == monday.month) return '${monday.month}월 ${monday.day}일 – ${sunday.day}일';
  return '${monday.month}월 ${monday.day}일 – ${sunday.month}월 ${sunday.day}일';
}

/// "2026년 9월"
String formatMonthTitle(DateTime month) => '${month.year}년 ${month.month}월';

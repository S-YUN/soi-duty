const _weekdayShort = ['월', '화', '수', '목', '금', '토', '일'];

String _weekday(DateTime d) => _weekdayShort[d.weekday - DateTime.monday];

/// "9월 11일 금요일"
String formatDateTitle(DateTime d) => '${d.month}월 ${d.day}일 ${_weekday(d)}요일';

/// "9월 4일 금"
String formatDateShort(DateTime d) => '${d.month}월 ${d.day}일 ${_weekday(d)}';

/// "9월 2째주". 주가 두 달에 걸치면 목요일이 속한 달로 센다 (KS X ISO 8601 관례).
/// 8/31(월)–9/6 주는 "9월 1째주", 9/28(월)–10/4 주는 "10월 1째주".
String formatWeekTitle(DateTime monday) {
  final thursday = DateTime(monday.year, monday.month, monday.day + 3);
  final nth = (thursday.day - 1) ~/ 7 + 1;
  return '${thursday.month}월 $nth째주';
}

/// "2026년 9월"
String formatMonthTitle(DateTime month) => '${month.year}년 ${month.month}월';

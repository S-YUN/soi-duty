const _weekdayShort = ['월', '화', '수', '목', '금', '토', '일'];

String _weekday(DateTime d) => _weekdayShort[d.weekday - DateTime.monday];

/// "9월 11일 금요일"
String formatDateTitle(DateTime d) => '${d.month}월 ${d.day}일 ${_weekday(d)}요일';

/// "9월 4일 금"
String formatDateShort(DateTime d) => '${d.month}월 ${d.day}일 ${_weekday(d)}';

import 'work_calculator.dart';

/// 주간 탭이 뒤로 갈 수 있는 하한. 첫 기록일이 없거나 미래(미리 찍은 연차)면 이번 주.
DateTime earliestMonday(DateTime? firstRecordDate, DateTime today) {
  final thisMonday = mondayOf(today);
  if (firstRecordDate == null) return thisMonday;
  final firstMonday = mondayOf(firstRecordDate);
  return firstMonday.isBefore(thisMonday) ? firstMonday : thisMonday;
}

/// 월간 탭이 뒤로 갈 수 있는 하한.
DateTime earliestMonth(DateTime? firstRecordDate, DateTime today) {
  final thisMonth = firstOfMonth(today);
  if (firstRecordDate == null) return thisMonth;
  final firstMonth = firstOfMonth(firstRecordDate);
  return firstMonth.isBefore(thisMonth) ? firstMonth : thisMonth;
}

import 'package:soi_duty/domain/model/work_record.dart';
import 'package:soi_duty/domain/model/work_type.dart';

/// 2026년 9월 기준. 14(월) 15(화) 16(수) 17(목) 18(금) 19(토) 20(일), 이전 주 월요일 7.
DateTime d(int day, [int hour = 0, int minute = 0]) => DateTime(2026, 9, day, hour, minute);

WorkRecord rec(
  int day, {
  int? inH,
  int? inM,
  int? outH,
  int? outM,
  WorkType type = WorkType.normal,
}) =>
    WorkRecord(
      date: d(day),
      clockIn: inH == null ? null : d(day, inH, inM ?? 0),
      clockOut: outH == null ? null : d(day, outH, outM ?? 0),
      type: type,
    );

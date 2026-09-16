import '../model/work_record.dart';

abstract interface class WorkRecordRepository {
  Stream<List<WorkRecord>> watchAll();

  /// 가장 이른 저장 날짜. 기록을 지워도 바뀌지 않고, 더 이른 날짜를 저장하면 당겨진다.
  Stream<DateTime?> watchFirstRecordDate();

  /// date 기준 upsert. 첫 기록일이 비어 있거나 record.date가 더 이르면 record.date로 갱신한다.
  Future<void> save(WorkRecord record);

  Future<void> delete(DateTime date);
}

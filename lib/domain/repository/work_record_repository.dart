import '../model/work_record.dart';

abstract interface class WorkRecordRepository {
  Stream<List<WorkRecord>> watchAll();

  /// 최초 save 시점에 저장된 날짜. 이후 바뀌지 않는다.
  Stream<DateTime?> watchFirstRecordDate();

  /// date 기준 upsert. 첫 기록일이 비어 있으면 record.date로 채운다.
  Future<void> save(WorkRecord record);

  Future<void> delete(DateTime date);
}

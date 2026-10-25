import '../model/backup_snapshot.dart';

abstract interface class BackupRepository {
  /// 지금 저장된 전부를 담는다.
  Future<BackupSnapshot> snapshot(DateTime now);

  /// 기록 전부를 파일 내용으로 바꾼다(되돌릴 수 없음). 첫 기록일·설정 세 값도 덮어쓴다.
  Future<void> restore(BackupSnapshot snapshot);

  /// 가져오기 확인 문구("지금 기록 n건이 …")용.
  Future<int> recordCount();
}

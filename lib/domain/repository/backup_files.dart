/// 백업 파일을 밖으로 내보내고(OS 공유 시트) 안으로 들여오는(OS 파일 선택) 길. 구현은 data/, 테스트는 Fake.
abstract interface class BackupFiles {
  /// 임시 파일을 만들어 공유 시트를 연다. 사용자가 그냥 닫았으면(dismissed) false.
  Future<bool> shareJson({required String fileName, required String content});

  /// 파일 선택 화면. 취소하면 null.
  Future<String?> pickJson();
}

import '../model/app_settings.dart';

abstract interface class AppSettingsRepository {
  Stream<AppSettings> watch();

  /// 지금 저장된 값(일회성). 값을 고쳐 저장할 때는 스트림의 마지막 값이 아니라 이걸 읽는다 —
  /// 스트림은 방금 한 저장을 아직 못 봤을 수 있어, 연달아 저장하면 앞의 저장을 덮어쓴다.
  Future<AppSettings> read();

  Future<void> save(AppSettings settings);
}

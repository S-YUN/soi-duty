import '../model/app_settings.dart';

abstract interface class AppSettingsRepository {
  Stream<AppSettings> watch();

  Future<void> save(AppSettings settings);
}

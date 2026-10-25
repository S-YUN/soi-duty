import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/database_providers.dart';
import '../../domain/model/app_settings.dart';

part 'settings_controller.g.dart';

/// 설정값 변경. 현재 값을 읽어 한 필드만 바꿔 저장한다 — 스트림이 화면들을 갱신한다.
@riverpod
class SettingsController extends _$SettingsController {
  @override
  Future<AppSettings> build() => ref.watch(appSettingsProvider.future);

  Future<void> setWeekStart(WeekStart weekStart) => _update((s) => s.copyWith(weekStart: weekStart));

  /// days가 null이면 그 해 총 연차를 지운다("사용 안 함").
  Future<void> setAnnualLeaveDays(int year, int? days) => _update((s) => s.withAnnualLeaveDays(year, days));

  Future<void> setHourlyWage(int? won) => _update((s) => s.copyWith(hourlyWage: won));

  Future<void> _update(AppSettings Function(AppSettings) change) async {
    final current = await ref.read(appSettingsProvider.future);
    await ref.read(appSettingsRepositoryProvider).save(change(current));
  }
}

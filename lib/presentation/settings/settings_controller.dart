import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/database_providers.dart';
import '../../domain/backup/backup_codec.dart';
import '../../domain/model/app_settings.dart';
import '../../domain/model/backup_snapshot.dart';
import '../../domain/rules/work_calculator.dart';
import 'backup_files.dart';
import 'settings_texts.dart';

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

  /// 기록·설정을 JSON 파일로 만들어 공유 시트를 연다. 사용자가 실제로 어딘가로 보냈으면(닫지 않았으면)
  /// 마지막 내보내기 날짜를 오늘로 적고 true.
  Future<bool> exportBackup(DateTime now) async {
    final snapshot = await ref.read(backupRepositoryProvider).snapshot(now);
    final shared = await ref.read(backupFilesProvider).shareJson(
          fileName: SettingsTexts.backupFileName(now),
          content: encodeBackup(snapshot),
        );
    if (shared) await _update((s) => s.copyWith(lastExportDate: dateOnly(now)));
    return shared;
  }

  /// 파일을 고르고 읽는다. 확인 다이얼로그는 화면이 띄운다 — 지금 기록 건수를 함께 돌려준다.
  Future<BackupPick> pickBackup() async {
    final text = await ref.read(backupFilesProvider).pickJson();
    if (text == null) return const BackupPickCancelled();
    try {
      final snapshot = decodeBackup(text);
      return BackupPickReady(snapshot, await ref.read(backupRepositoryProvider).recordCount());
    } on BackupFormatException {
      return const BackupPickInvalid();
    }
  }

  Future<void> restoreBackup(BackupSnapshot snapshot) => ref.read(backupRepositoryProvider).restore(snapshot);

  Future<void> _update(AppSettings Function(AppSettings) change) async {
    final current = await ref.read(appSettingsProvider.future);
    await ref.read(appSettingsRepositoryProvider).save(change(current));
  }
}

sealed class BackupPick {
  const BackupPick();
}

class BackupPickCancelled extends BackupPick {
  const BackupPickCancelled();
}

class BackupPickInvalid extends BackupPick {
  const BackupPickInvalid();
}

class BackupPickReady extends BackupPick {
  const BackupPickReady(this.snapshot, this.currentCount);

  final BackupSnapshot snapshot;
  /// 확인 문구 "지금 기록 n건이 …"
  final int currentCount;
}

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/database_providers.dart';
import '../../domain/backup/backup_codec.dart';
import '../../domain/model/app_settings.dart';
import '../../domain/model/leave_balance.dart';
import '../../domain/model/backup_snapshot.dart';
import '../../domain/rules/work_calculator.dart';
import 'settings_texts.dart';

part 'settings_controller.g.dart';

/// 설정값 변경과 백업 동작. 상태가 없는 액션 모음이라 keepAlive — 화면이 붙잡아 둘 필요가 없다.
/// 현재 값을 읽어 한 필드만 바꿔 저장한다 — 스트림이 화면들을 갱신한다.
@Riverpod(keepAlive: true)
class SettingsController extends _$SettingsController {
  @override
  void build() {}

  Future<void> setWeekStart(WeekStart weekStart) => _update((s) => s.copyWith(weekStart: weekStart));

  /// balance가 null이면 그 해 남은 연차를 지운다("사용 안 함").
  Future<void> setLeaveBalance(int year, LeaveBalance? balance) => _update((s) => s.withLeaveBalance(year, balance));

  Future<void> setHourlyWage(int? won) => _update((s) => s.copyWith(hourlyWage: won));

  /// 기록 시트에서 빈 출근·퇴근 행을 열 때 휠의 처음 값(자정 기준 분). 이미 넣은 기록은 바뀌지 않는다.
  Future<void> setDefaultClockTimes(int clockInMinutes, int clockOutMinutes) =>
      _update((s) => s.withDefaultClockTimes(clockInMinutes, clockOutMinutes));

  /// 퇴근 알림 켜기/끄기. 예약은 `ClockOutNotificationSync`가 이 값을 보고 다시 맞춘다.
  Future<void> setClockOutNotification(bool on) => _update((s) => s.copyWith(clockOutNotificationEnabled: on));

  /// 권한 묻기(P1)를 띄웠다 — 수락·거절·넘김 모두. 다시 묻지 않는다.
  Future<void> markNotificationPrompted() => _update((s) => s.copyWith(notificationPrompted: true));

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
      final snapshot = decodeBackup(text, rules: ref.read(workRulesProvider));
      return BackupPickReady(snapshot, await ref.read(backupRepositoryProvider).recordCount());
    } on BackupFormatException {
      return const BackupPickInvalid();
    }
  }

  Future<void> restoreBackup(BackupSnapshot snapshot) => ref.read(backupRepositoryProvider).restore(snapshot);

  Future<void> _update(AppSettings Function(AppSettings) change) async {
    // 저장소에서 직접 읽는다 — 스트림(appSettingsProvider)의 값은 방금 한 저장을 아직 못 봤을 수 있어,
    // "물어봤다" 표시 → 알림 켜기처럼 연달아 저장하면 앞의 저장을 덮어쓴다.
    final repo = ref.read(appSettingsRepositoryProvider);
    await repo.save(change(await repo.read()));
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

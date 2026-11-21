import '../../domain/notification/clock_out_notice.dart';
import '../../domain/repository/notification_state_repository.dart';
import '../database/app_database.dart';

/// 기존 Settings(key/value) 테이블에 키 둘. 스키마 변경 없음. 일회성 읽기는 전부 `get()` — 스트림의 `.first`는 쓰지 않는다.
class DriftNotificationStateRepository implements NotificationStateRepository {
  DriftNotificationStateRepository(this._db);

  /// `2026-09-16T17:30:00.000|daily`
  static const lastNoticeKey = 'clock_out_notice';
  static const osAskedKey = 'notification_os_asked';
  static const _separator = '|';

  final AppDatabase _db;

  Future<String?> _read(String key) async =>
      (await (_db.select(_db.settings)..where((t) => t.key.equals(key))).getSingleOrNull())?.value;

  Future<void> _write(String key, String? value) {
    if (value == null) return (_db.delete(_db.settings)..where((t) => t.key.equals(key))).go();
    return _db.into(_db.settings).insertOnConflictUpdate(SettingsCompanion.insert(key: key, value: value));
  }

  @override
  Future<ClockOutNotice?> lastNotice() async => decodeNotice(await _read(lastNoticeKey));

  @override
  Future<void> saveLastNotice(ClockOutNotice? notice) =>
      _write(lastNoticeKey, notice == null ? null : encodeNotice(notice));

  @override
  Future<bool> osAsked() async => await _read(osAskedKey) != null;

  @override
  Future<void> markOsAsked() => _write(osAskedKey, '1');

  static String encodeNotice(ClockOutNotice notice) => '${notice.at.toIso8601String()}$_separator${notice.kind.name}';

  /// 손상된 값은 없는 것으로 읽는다.
  static ClockOutNotice? decodeNotice(String? value) {
    if (value == null) return null;
    final parts = value.split(_separator);
    if (parts.length != 2) return null;
    final at = DateTime.tryParse(parts[0]);
    final kind = ClockOutNoticeKind.values.asNameMap()[parts[1]];
    if (at == null || kind == null) return null;
    return ClockOutNotice(kind, at);
  }
}

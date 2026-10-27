import 'package:freezed_annotation/freezed_annotation.dart';

import 'app_settings.dart';
import 'leave_balance.dart';
import 'work_record.dart';

part 'backup_snapshot.freezed.dart';

/// 백업 파일 하나의 내용 — 기록 전체 + 첫 기록일 + 설정 세 값. `lastExportDate`는 기기별 값이라 넣지 않는다.
/// JSON 직렬화는 `backup_codec.dart`가 맡는다(파일 형식은 모델과 따로 버전을 센다).
@freezed
abstract class BackupSnapshot with _$BackupSnapshot {
  const factory BackupSnapshot({
    required DateTime exportedAt,
    DateTime? firstRecordDate,
    required WeekStart weekStart,
    required Map<int, LeaveBalance> leaveBalanceByYear,
    int? hourlyWage,
    required List<WorkRecord> records,
  }) = _BackupSnapshot;
}

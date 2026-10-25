import 'dart:async';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/core/presentation/size_config.dart';
import 'package:soi_duty/core/providers/app_info_provider.dart';
import 'package:soi_duty/core/providers/clock_provider.dart';
import 'package:soi_duty/core/providers/database_providers.dart';
import 'package:soi_duty/data/database/app_database.dart';
import 'package:soi_duty/data/repository/drift_work_record_repository.dart';
import 'package:soi_duty/domain/backup/backup_codec.dart';
import 'package:soi_duty/domain/model/app_settings.dart';
import 'package:soi_duty/domain/model/backup_snapshot.dart';
import 'package:soi_duty/domain/model/work_type.dart';
import 'package:soi_duty/domain/repository/backup_files.dart';
import 'package:soi_duty/presentation/settings/settings_screen.dart';
import 'package:soi_duty/ui/app_sizes.dart';
import 'package:soi_duty/ui/app_theme.dart';

import '../helpers/fonts.dart';
import '../helpers/records.dart';

class FakeBackupFiles implements BackupFiles {
  FakeBackupFiles({this.shareResult = true, this.pickResult});

  bool shareResult;
  String? pickResult;
  String? sharedName;
  String? sharedContent;
  /// 플랫폼 예외 흉내 — 임시 폴더 쓰기 실패, 선택기 오류 등.
  bool throwOnShare = false;
  bool throwOnPick = false;

  @override
  Future<bool> shareJson({required String fileName, required String content}) async {
    if (throwOnShare) throw Exception('share failed');
    sharedName = fileName;
    sharedContent = content;
    return shareResult;
  }

  @override
  Future<String?> pickJson() async {
    if (throwOnPick) throw Exception('pick failed');
    return pickResult;
  }
}

void main() {
  late AppDatabase db;
  late FakeBackupFiles files;
  final now = d(16, 12);

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    await loadPretendard();
  });
  setUp(() {
    SizeConfig.init(402);
    db = AppDatabase(NativeDatabase.memory());
    files = FakeBackupFiles();
  });
  tearDown(() => db.close());

  Future<void> pumpSettings(WidgetTester tester) async {
    tester.view.physicalSize = const Size(402 * 3, 874 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(() => now),
        nowProvider.overrideWith((ref) => Stream.value(now)),
        appVersionProvider.overrideWith((ref) async => '1.0.1'),
        backupFilesProvider.overrideWithValue(files),
      ],
      child: MaterialApp(theme: AppTheme.light, home: const SettingsScreen()),
    ));
    await tester.pumpAndSettle();
  }

  /// 토스트는 오버레이에 2.4초 남고, ProviderScope가 내려갈 때 Drift 스트림 정리 타이머(0ms)가 남는다.
  /// 각 테스트 끝에서 토스트 시간을 흘리고 트리를 비운 뒤 한 틱 더 흘린다.
  Future<void> finish(WidgetTester tester) async {
    await tester.pump(AppDurations.toast);
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  }

  Future<void> tapRow(WidgetTester tester, String label) async {
    await tester.ensureVisible(find.text(label));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  testWidgets('내보내기 — 공유 성공이면 토스트와 "마지막 내보내기 2026년 9월 16일", 파일 내용은 백업 JSON', (tester) async {
    await db.into(db.workRecords).insert(WorkRecordsCompanion.insert(date: '2026-09-14', type: WorkType.dayOff));
    await pumpSettings(tester);
    await tapRow(tester, '내보내기');
    expect(find.text('내보낼 파일을 만들었어요'), findsOneWidget);
    expect(find.text('마지막 내보내기 2026년 9월 16일'), findsOneWidget);
    expect(files.sharedName, 'soi_duty_backup_2026-09-16.json');
    final snapshot = decodeBackup(files.sharedContent!);
    expect(snapshot.records, [rec(14, type: WorkType.dayOff)]);
    expect(snapshot.firstRecordDate, isNull); // Drift에 직접 넣어 첫 기록일이 없다
    await finish(tester);
  });

  testWidgets('내보내기 — 공유 시트를 닫으면 날짜도 토스트도 없음 (Review Focus 5)', (tester) async {
    files.shareResult = false;
    await pumpSettings(tester);
    await tapRow(tester, '내보내기');
    expect(find.text('내보낼 파일을 만들었어요'), findsNothing);
    expect(find.text('아직 내보낸 적 없어요'), findsOneWidget);
    await finish(tester);
  });

  testWidgets('가져오기 — 취소면 아무것도 없음, 깨진 파일이면 실패 토스트', (tester) async {
    await pumpSettings(tester);
    await tapRow(tester, '가져오기');
    expect(find.text('기록을 가져올까요?'), findsNothing);
    expect(find.textContaining('파일을 읽을 수 없어요'), findsNothing);

    files.pickResult = '{"app":"other"}';
    await tapRow(tester, '가져오기');
    expect(find.text('파일을 읽을 수 없어요. 내보낸 파일이 맞는지 확인해 주세요'), findsOneWidget);
    expect(find.text('기록을 가져올까요?'), findsNothing);
    await finish(tester);
  });

  testWidgets('가져오기 — 정상 파일이면 확인 → 기록 교체 + 설정 반영 + 성공 토스트', (tester) async {
    final repo = DriftWorkRecordRepository(db);
    for (final r in [rec(7, inH: 9, outH: 18), rec(8, inH: 9, outH: 18), rec(9, type: WorkType.dayOff)]) {
      await repo.save(r);
    }
    files.pickResult = encodeBackup(BackupSnapshot(
      exportedAt: DateTime(2026, 9, 15),
      firstRecordDate: d(14),
      weekStart: WeekStart.sunday,
      annualLeaveDaysByYear: const {2026: 15},
      hourlyWage: 12500,
      records: [rec(14, inH: 9, outH: 18), rec(15, type: WorkType.halfDay, inH: 13, outH: 18)],
    ));
    await pumpSettings(tester);
    await tapRow(tester, '가져오기');
    expect(find.text('기록을 가져올까요?'), findsOneWidget);
    expect(find.text('지금 기록 3건이 파일 내용으로 바뀌어요. 되돌릴 수 없어요.'), findsOneWidget);

    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();
    expect((await db.select(db.workRecords).get()).length, 3);

    await tapRow(tester, '가져오기');
    await tester.tap(find.text('가져오기').last); // 다이얼로그의 확인 버튼
    await tester.pumpAndSettle();
    expect(find.text('기록을 가져왔어요'), findsOneWidget);
    // 위젯 테스트의 가짜 시간에서는 Drift 스트림 `.first`가 값을 내지 않는다 — 일회성 조회로 확인.
    final rows = await db.select(db.workRecords).get();
    expect(rows.map(DriftWorkRecordRepository.toDomain), [rec(14, inH: 9, outH: 18), rec(15, type: WorkType.halfDay, inH: 13, outH: 18)]);
    final first = await (db.select(db.settings)..where((t) => t.key.equals('first_record_date'))).getSingle();
    expect(first.value, '2026-09-14');
    expect(find.text('15일'), findsOneWidget);
    expect(find.text('12,500원'), findsOneWidget);
    await finish(tester);
  });

  testWidgets('내보내기 — 플랫폼 예외면 실패 토스트, 날짜는 그대로', (tester) async {
    files.throwOnShare = true;
    await pumpSettings(tester);
    await tapRow(tester, '내보내기');
    expect(find.text('내보내기에 실패했어요. 다시 시도해 주세요'), findsOneWidget);
    expect(find.text('아직 내보낸 적 없어요'), findsOneWidget);
    await finish(tester);
  });

  testWidgets('가져오기 — 파일 선택 중 예외면 읽기 실패 토스트', (tester) async {
    files.throwOnPick = true;
    await pumpSettings(tester);
    await tapRow(tester, '가져오기');
    expect(find.text('파일을 읽을 수 없어요. 내보낸 파일이 맞는지 확인해 주세요'), findsOneWidget);
    await finish(tester);
  });

  testWidgets('설정값이 아직 안 왔으면 기본값을 번쩍이지 않고 배경만 그린다', (tester) async {
    final pending = StreamController<AppSettings>();
    addTearDown(pending.close);
    tester.view.physicalSize = const Size(402 * 3, 874 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(() => now),
        nowProvider.overrideWith((ref) => Stream.value(now)),
        appVersionProvider.overrideWith((ref) async => '1.0.1'),
        appSettingsProvider.overrideWith((ref) => pending.stream),
        backupFilesProvider.overrideWithValue(files),
      ],
      child: MaterialApp(theme: AppTheme.light, home: const SettingsScreen()),
    ));
    await tester.pump();
    expect(find.text('사용 안 함'), findsNothing);
    expect(find.byType(SettingsView), findsNothing);
    pending.add(const AppSettings(hourlyWage: 9860));
    await tester.pump();
    await tester.pump();
    expect(find.text('9,860원'), findsOneWidget);
    await finish(tester);
  });
}

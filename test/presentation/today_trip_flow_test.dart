import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/core/presentation/size_config.dart';
import 'package:soi_duty/core/providers/clock_provider.dart';
import 'package:soi_duty/core/providers/database_providers.dart';
import 'package:soi_duty/data/database/app_database.dart';
import 'package:soi_duty/domain/model/work_type.dart';
import 'package:soi_duty/presentation/record_edit/widgets/trip_sheet.dart';
import 'package:soi_duty/presentation/today/today_screen.dart';
import 'package:soi_duty/presentation/today/widgets/today_trip_sheet.dart';
import 'package:soi_duty/ui/app_theme.dart';

import '../helpers/fonts.dart';
import '../helpers/records.dart';

/// 오늘 화면에서 시간 출장을 남기는 길 — 시트가 잠긴 근무 중에도 저장까지 되는지 (핸드오프 6 §4).
void main() {
  late AppDatabase db;
  final now = d(16, 10, 30); // 수요일

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    await loadPretendard();
  });
  setUp(() {
    SizeConfig.init(402);
    db = AppDatabase(NativeDatabase.memory());
  });
  tearDown(() => db.close());

  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(402 * 3, 874 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(() => now),
        nowProvider.overrideWith((ref) => Stream.value(now)),
      ],
      child: MaterialApp(theme: AppTheme.light, home: const Scaffold(body: TodayScreen())),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  }

  Future<void> insert({DateTime? clockIn, DateTime? tripStart, DateTime? tripEnd}) => db.into(db.workRecords).insert(
        WorkRecordsCompanion.insert(
          date: '2026-09-16',
          clockIn: Value(clockIn),
          type: WorkType.normal,
          tripStart: Value(tripStart),
          tripEnd: Value(tripEnd),
        ),
      );
  Future<List<WorkRecordRow>> rows() => db.select(db.workRecords).get();

  testWidgets('근무 중: "+ 출장" → 작은 시트(출근 시각부터 3시간, "저장") → 저장되고 칩이 범위로 바뀐다', (tester) async {
    await insert(clockIn: d(16, 9, 12));
    await pumpScreen(tester);
    await tester.tap(find.text('+ 출장'));
    await tester.pumpAndSettle();
    expect(find.byType(TripSheet), findsOneWidget);
    expect(find.text('09:12–12:12 · 3시간'), findsOneWidget);
    expect(find.text('출장 지우기'), findsNothing);
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();
    expect(find.byType(TripSheet), findsNothing);
    final saved = (await rows()).single;
    expect((saved.tripStart, saved.tripEnd), (d(16, 9, 12), d(16, 12, 12)));
    expect(saved.clockIn, d(16, 9, 12));
    expect(find.text('출장 09:12–12:12'), findsOneWidget);
    expect(find.text('퇴근하기'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('근무 중: 칩 → "출장 지우기" → 범위가 사라지고 근무 중 그대로', (tester) async {
    await insert(clockIn: d(16, 9, 12), tripStart: d(16, 9, 12), tripEnd: d(16, 12, 12));
    await pumpScreen(tester);
    await tester.tap(find.text('출장 09:12–12:12'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('출장 지우기'));
    await tester.pumpAndSettle();
    final saved = (await rows()).single;
    expect((saved.tripStart, saved.tripEnd), (null, null));
    expect(saved.clockIn, d(16, 9, 12));
    expect(find.text('+ 출장'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('출근 전: "출장" 라디오 → "오늘 출장" → 시간 출장 → 저장 → 출근 버튼은 남고 칩이 생긴다', (tester) async {
    await pumpScreen(tester);
    await tester.tap(find.text('출장'));
    await tester.pumpAndSettle();
    expect(find.byType(TodayTripSheet), findsOneWidget);
    await tester.tap(find.text('시간 출장'));
    await tester.pumpAndSettle();
    expect(find.byType(TodayTripSheet), findsNothing);
    expect(find.text('09:00–12:00 · 3시간'), findsOneWidget); // 출근 전이라 09:00부터
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();
    final saved = (await rows()).single;
    expect(saved.type, WorkType.normal);
    expect(saved.clockIn, isNull);
    expect((saved.tripStart, saved.tripEnd), (d(16, 9), d(16, 12)));
    expect(find.text('출장 09:00–12:00'), findsOneWidget);
    expect(find.text('출근하기'), findsOneWidget);
    expect(find.text('아직 출근 전'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('출근 전: "오늘 출장" → 종일 출장 → 지금의 출장 상태(출근 버튼 비활성, 되돌리기)', (tester) async {
    await pumpScreen(tester);
    await tester.tap(find.text('출장'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('종일 출장'));
    await tester.pumpAndSettle();
    expect((await rows()).single.type, WorkType.businessTrip);
    expect(find.textContaining('오늘은 출장입니다'), findsOneWidget);
    expect(find.text('되돌리기'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('출근 전: 시트를 그냥 닫으면 아무것도 저장되지 않는다', (tester) async {
    await pumpScreen(tester);
    await tester.tap(find.text('출장'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(await rows(), isEmpty);
    await tester.tap(find.text('출장'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('시간 출장'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(await rows(), isEmpty);
    await unmount(tester);
  });

  testWidgets('출근 전에 넣어둔 범위만 지우면 기록이 사라진다', (tester) async {
    await insert(tripStart: d(16, 9), tripEnd: d(16, 12));
    await pumpScreen(tester);
    await tester.tap(find.text('출장 09:00–12:00'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('출장 지우기'));
    await tester.pumpAndSettle();
    expect(await rows(), isEmpty);
    await unmount(tester);
  });
}

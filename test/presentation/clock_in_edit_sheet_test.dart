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
import 'package:soi_duty/presentation/today/widgets/clock_in_edit_sheet.dart';
import 'package:soi_duty/ui/app_theme.dart';

import '../helpers/fonts.dart';
import '../helpers/records.dart';

void main() {
  late AppDatabase db;
  final now = d(16, 12);

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    await loadPretendard();
  });
  setUp(() async {
    SizeConfig.init(402);
    db = AppDatabase(NativeDatabase.memory());
    await db.into(db.workRecords).insert(
          WorkRecordsCompanion.insert(date: '2026-09-16', clockIn: Value(d(16, 9, 12)), type: WorkType.normal),
        );
  });
  tearDown(() => db.close());

  Future<void> pumpSheet(WidgetTester tester) async {
    tester.view.physicalSize = const Size(402 * 3, 874 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(() => now),
        nowProvider.overrideWith((ref) => Stream.value(now)),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showClockInEditSheet(context, d(16, 9, 12), () => now),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  }

  testWidgets('현재 출근 시각으로 열리고, 분 휠을 돌려 저장하면 출근 시각만 바뀐다', (tester) async {
    await pumpSheet(tester);
    expect(find.text('출근 시각'), findsOneWidget);
    expect(find.text('오전'), findsOneWidget);
    expect(find.text('퇴근'), findsNothing);

    // 분 휠을 두 칸 위로 → 10분
    await tester.drag(find.text('12').last, const Offset(0, 88));
    await tester.pumpAndSettle();
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();

    expect(find.byType(ClockInEditSheet), findsNothing);
    final row = (await db.select(db.workRecords).get()).single;
    expect(row.clockIn, d(16, 9, 10));
    expect(row.clockOut, isNull);
    await unmount(tester);
  });

  testWidgets('지금보다 늦은 시각이면 저장이 막히고 안내가 뜬다', (tester) async {
    await pumpSheet(tester);
    // 오전 → 오후로 한 칸 내리면 21:12 > 12:00
    await tester.drag(find.text('오전'), const Offset(0, -44));
    await tester.pumpAndSettle();
    expect(find.text('지금보다 늦을 수 없어요'), findsOneWidget);
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();
    expect(find.byType(ClockInEditSheet), findsOneWidget); // 닫히지 않음
    expect((await db.select(db.workRecords).get()).single.clockIn, d(16, 9, 12));
    await unmount(tester);
  });
}

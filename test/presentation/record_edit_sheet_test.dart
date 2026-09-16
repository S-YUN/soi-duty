import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/core/presentation/size_config.dart';
import 'package:soi_duty/core/providers/clock_provider.dart';
import 'package:soi_duty/core/providers/database_providers.dart';
import 'package:soi_duty/data/database/app_database.dart';
import 'package:soi_duty/domain/model/work_type.dart';
import 'package:soi_duty/presentation/record_edit/record_edit_sheet.dart';
import 'package:soi_duty/presentation/record_edit/widgets/time_wheel.dart';
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
  setUp(() {
    SizeConfig.init(402);
    db = AppDatabase(NativeDatabase.memory());
  });
  tearDown(() => db.close());

  Future<void> pumpSheet(WidgetTester tester, DateTime date) async {
    tester.view.physicalSize = const Size(402 * 3, 874 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(() => now),
        nowProvider.overrideWith((ref) => Stream.value(now)),
      ],
      child: MaterialApp(theme: AppTheme.light, home: Scaffold(body: RecordEditSheet(date: date))),
    ));
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// ProviderScope가 내려갈 때 Drift 스트림 정리 타이머(0ms)가 남는다. 각 테스트 끝에서 트리를 비우고 흘려보낸다.
  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  }

  testWidgets('연차를 고르면 출근·퇴근 행이 사라진다', (tester) async {
    await pumpSheet(tester, d(14));
    expect(find.text('출근'), findsOneWidget);
    await tester.tap(find.text('연차'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('출근'), findsNothing);
    expect(find.text('저장'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('주말은 유형 칩이 없고 안내가 뜬다', (tester) async {
    await pumpSheet(tester, d(12));
    expect(find.text('반차'), findsNothing);
    expect(find.text('주말 근무는 주 40시간에 포함되지 않아요'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('미래 날짜는 시각 행이 없다', (tester) async {
    await pumpSheet(tester, d(23));
    expect(find.text('출근'), findsNothing);
    expect(find.text('연차'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('행을 탭하면 휠이 열리고 값이 00:00이 된다', (tester) async {
    await pumpSheet(tester, d(14));
    expect(find.text('--:--'), findsNWidgets(2));
    await tester.tap(find.text('출근'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(TimeWheel), findsOneWidget);
    expect(find.text('00:00'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('퇴근 < 출근이면 저장이 비활성이고 안내가 뜬다', (tester) async {
    await db.into(db.workRecords).insert(WorkRecordsCompanion.insert(
          date: '2026-09-14',
          clockIn: Value(d(14, 22)),
          clockOut: Value(d(14, 2)),
          type: WorkType.normal,
        ));
    await pumpSheet(tester, d(14));
    expect(find.text('퇴근이 출근보다 빨라요'), findsOneWidget);
    expect(find.text('이 날 기록 지우기'), findsOneWidget);
    await unmount(tester);
  });
}

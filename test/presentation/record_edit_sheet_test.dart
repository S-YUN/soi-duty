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

  /// 실제처럼 showRecordEditSheet로 띄운다 — 칩 탭·저장이 시트를 닫는 흐름까지 본다.
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
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(onPressed: () => showRecordEditSheet(context, date), child: const Text('open')),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Future<void> insert(int day, {int? inH, int inM = 0, int? outH, WorkType type = WorkType.normal}) =>
      db.into(db.workRecords).insert(
        WorkRecordsCompanion.insert(
          date: '2026-09-${day.toString().padLeft(2, '0')}',
          clockIn: Value(inH == null ? null : d(day, inH, inM)),
          clockOut: Value(outH == null ? null : d(day, outH)),
          type: type,
        ),
      );

  /// ProviderScope가 내려갈 때 Drift 스트림 정리 타이머(0ms)가 남는다. 각 테스트 끝에서 트리를 비우고 흘려보낸다.
  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  }

  testWidgets('시각 없는 날에 연차를 누르면 바로 저장되고 시트가 닫힌다', (tester) async {
    await pumpSheet(tester, d(14));
    expect(find.text('취소'), findsNothing);
    expect(find.text('저장'), findsOneWidget);
    await tester.tap(find.text('연차'));
    await tester.pumpAndSettle();
    expect(find.byType(RecordEditSheet), findsNothing);
    final rows = await db.select(db.workRecords).get();
    expect(rows.single.type, WorkType.dayOff);
    expect(rows.single.clockIn, isNull);
    await unmount(tester);
  });

  testWidgets('시각 있는 날에 공휴일을 누르면 확인 후 저장, 취소하면 그대로', (tester) async {
    await insert(14, inH: 9, outH: 18);
    await pumpSheet(tester, d(14));
    await tester.tap(find.text('공휴일'));
    await tester.pumpAndSettle();
    expect(find.text('공휴일로 바꿀까요?'), findsOneWidget);
    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();
    expect(find.byType(RecordEditSheet), findsOneWidget);
    expect(find.text('09:00'), findsOneWidget);
    expect((await db.select(db.workRecords).get()).single.type, WorkType.normal);

    await tester.tap(find.text('공휴일'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('바꾸기'));
    await tester.pumpAndSettle();
    expect(find.byType(RecordEditSheet), findsNothing);
    final row = (await db.select(db.workRecords).get()).single;
    expect(row.type, WorkType.holiday);
    expect(row.clockIn, isNull);
    await unmount(tester);
  });

  testWidgets('반차는 바로 저장하지 않고 시각 입력을 이어간다', (tester) async {
    await pumpSheet(tester, d(14));
    await tester.tap(find.text('반차'));
    await tester.pumpAndSettle();
    expect(find.byType(RecordEditSheet), findsOneWidget);
    expect(find.text('출근'), findsOneWidget);
    expect(await db.select(db.workRecords).get(), isEmpty);
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

  testWidgets('빈 행은 --:--, 탭하면 휠이 기본 시각(오전 8:00)으로 열린다', (tester) async {
    await pumpSheet(tester, d(14));
    expect(find.text('--:--'), findsNWidgets(2));
    await tester.tap(find.text('출근'));
    await tester.pumpAndSettle();
    expect(find.byType(TimeWheel), findsOneWidget);
    expect(find.text('08:00'), findsOneWidget);
    expect(find.text('오전'), findsOneWidget);
    expect(find.text('오후'), findsOneWidget);
    await tester.tap(find.text('퇴근'));
    await tester.pumpAndSettle();
    expect(find.text('17:00'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('13:30은 휠에서 오후 1:30, 휠을 돌리면 24시간 값으로 저장된다', (tester) async {
    await insert(14, inH: 13, inM: 30, outH: 18);
    await pumpSheet(tester, d(14));
    await tester.tap(find.text('출근'));
    await tester.pumpAndSettle();
    expect(find.text('13:30'), findsOneWidget);
    // 오전/오후 휠을 한 칸 올려 오전으로 → 01:30
    await tester.drag(find.text('오후'), const Offset(0, 44));
    await tester.pumpAndSettle();
    expect(find.text('01:30'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('퇴근 < 출근이면 저장이 비활성이고 안내가 뜬다', (tester) async {
    await insert(14, inH: 22, outH: 2);
    await pumpSheet(tester, d(14));
    expect(find.text('퇴근이 출근보다 빨라요'), findsOneWidget);
    expect(find.text('이 날 기록 지우기'), findsOneWidget);
    await unmount(tester);
  });
}

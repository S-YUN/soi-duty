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
import 'package:soi_duty/presentation/record_edit/widgets/duration_wheel.dart';
import 'package:soi_duty/presentation/record_edit/widgets/time_wheel.dart';
import 'package:soi_duty/presentation/record_edit/widgets/type_rows.dart';
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

  Future<void> insert(int day, {int? inH, int inM = 0, int? outH, WorkType type = WorkType.normal, int ded = 0}) =>
      db.into(db.workRecords).insert(
        WorkRecordsCompanion.insert(
          date: '2026-09-${day.toString().padLeft(2, '0')}',
          clockIn: Value(inH == null ? null : d(day, inH, inM)),
          clockOut: Value(outH == null ? null : d(day, outH)),
          type: type,
          deductionMinutes: Value(ded),
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

  testWidgets('미래 날짜는 시각 행 없이 유형 행 3개, 탭하면 바로 저장·닫힘, 다시 열면 체크', (tester) async {
    await pumpSheet(tester, d(23));
    expect(find.text('9월 23일'), findsOneWidget);
    expect(find.text('미리 지정해두면 그 주 목표 시간이 자동으로 계산돼요'), findsOneWidget);
    expect(find.text('출근'), findsNothing);
    expect(find.text('저장'), findsNothing);
    expect(find.byType(TypeRows), findsOneWidget);
    double checkOpacity(String label) => tester
        .widget<AnimatedOpacity>(find.descendant(
          of: find.ancestor(of: find.text(label), matching: find.byType(GestureDetector)).first,
          matching: find.byType(AnimatedOpacity),
        ))
        .opacity;
    expect(checkOpacity('연차'), 0);

    await tester.tap(find.text('연차'));
    await tester.pumpAndSettle();
    expect(find.byType(RecordEditSheet), findsNothing);
    expect((await db.select(db.workRecords).get()).single.type, WorkType.dayOff);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(checkOpacity('연차'), 1);
    expect(checkOpacity('반차'), 0);
    expect(find.text('이 날 기록 지우기'), findsOneWidget);
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

  group('출장 · 공휴일 근무 · 시간공제', () {
    Future<WorkRecordRow> only() async => (await db.select(db.workRecords).get()).single;

    /// 휠 한 칸 = 44 (SizeConfig 402 기준). 위로 끌면 값이 커진다.
    Future<void> spin(WidgetTester tester, String label, int steps) async {
      await tester.drag(find.text(label).last, Offset(0, -44.0 * steps));
      await tester.pumpAndSettle();
    }

    testWidgets('과거 평일: 칩 4개와 시간공제 행', (tester) async {
      await pumpSheet(tester, d(14));
      for (final label in ['반차', '연차', '공휴일', '출장']) {
        expect(find.text(label), findsOneWidget);
      }
      expect(find.text('시간공제'), findsOneWidget);
      expect(find.text('없음'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('출장 칩은 바로 저장·닫힘', (tester) async {
      await pumpSheet(tester, d(14));
      await tester.tap(find.text('출장'));
      await tester.pumpAndSettle();
      expect(find.byType(RecordEditSheet), findsNothing);
      expect((await only()).type, WorkType.businessTrip);
      await unmount(tester);
    });

    testWidgets('공휴일은 저장·닫힘, 다시 열면 근무 입력 버튼, 누르면 시각 행', (tester) async {
      await pumpSheet(tester, d(14));
      await tester.tap(find.text('공휴일'));
      await tester.pumpAndSettle();
      expect(find.byType(RecordEditSheet), findsNothing);

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('출근'), findsNothing);
      expect(find.text('시간공제'), findsNothing);
      await tester.tap(find.text('+ 이 날 근무한 시간 입력'));
      await tester.pumpAndSettle();
      expect(find.text('출근'), findsOneWidget);
      expect(find.text('공휴일 근무는 주 40시간에 포함되지 않아요'), findsOneWidget);
      expect(find.text('저장'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('공제 휠로 2시간 30분 + 사유를 넣고 저장', (tester) async {
      await insert(14, inH: 9, outH: 15);
      await pumpSheet(tester, d(14));
      await tester.tap(find.text('시간공제').first);
      await tester.pumpAndSettle();
      expect(find.text('뺄 시간'), findsOneWidget);
      expect(find.byType(DurationWheel), findsOneWidget);
      expect(find.text('연차·반차로 안 되는 시간을 직접 넣어 이 날 기준시간에서 빼요'), findsOneWidget);

      await spin(tester, '0', 2);
      await spin(tester, '00', 3);
      expect(find.text('2시간 30분'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '조기퇴근 공문');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(tester.testTextInput.isVisible, isFalse);

      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();
      final row = await only();
      expect((row.deductionMinutes, row.deductionReason), (150, '조기퇴근 공문'));
      await unmount(tester);
    });

    testWidgets('사유 입력 중 휠을 돌리면 키보드가 내려간다', (tester) async {
      await insert(14, inH: 9, outH: 15);
      await pumpSheet(tester, d(14));
      await tester.tap(find.text('시간공제').first);
      await tester.pumpAndSettle();
      await tester.showKeyboard(find.byType(TextField));
      expect(tester.testTextInput.isVisible, isTrue);
      await spin(tester, '0', 1);
      expect(tester.testTextInput.isVisible, isFalse);
      await unmount(tester);
    });

    testWidgets('반차에 5시간 공제는 저장 불가', (tester) async {
      await insert(14, inH: 9, outH: 13, type: WorkType.halfDay);
      await pumpSheet(tester, d(14));
      await tester.tap(find.text('시간공제').first);
      await tester.pumpAndSettle();
      await spin(tester, '0', 5);
      expect(find.text('반차인 날은 4시간까지 뺄 수 있어요'), findsOneWidget);
      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();
      expect(find.byType(RecordEditSheet), findsOneWidget);
      expect((await only()).deductionMinutes, 0);
      await unmount(tester);
    });

    testWidgets('미래: 행 4개 + 공제 행, 공제를 펴면 저장 버튼', (tester) async {
      await pumpSheet(tester, d(23));
      expect(find.byType(TypeRows), findsOneWidget);
      expect(find.text('출장'), findsOneWidget);
      expect(find.text('저장'), findsNothing);
      await tester.tap(find.text('시간공제').first);
      await tester.pumpAndSettle();
      expect(find.text('저장'), findsOneWidget);
      await spin(tester, '0', 2);
      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();
      final row = await only();
      expect((row.type, row.deductionMinutes), (WorkType.normal, 120));
      await unmount(tester);
    });

    testWidgets('출근 전 오늘은 유형 행 + 공제 행, 시각 행 없음', (tester) async {
      await pumpSheet(tester, d(16));
      expect(find.byType(TypeRows), findsOneWidget);
      expect(find.text('출근'), findsNothing);
      expect(find.text('시간공제'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('자동 공제 2h 47m은 행에 그대로, 휠을 안 돌리면 저장해도 그대로', (tester) async {
      await insert(14, inH: 9, outH: 15, ded: 167);
      await pumpSheet(tester, d(14));
      expect(find.text('2시간 47분'), findsOneWidget);
      await tester.tap(find.text('시간공제').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();
      expect((await only()).deductionMinutes, 167);
      await unmount(tester);
    });

    testWidgets('작은 화면에서 키보드가 올라와도 저장 버튼이 보이고 눌린다', (tester) async {
      SizeConfig.init(320);
      await insert(14, inH: 9, outH: 15);
      await pumpSheet(tester, d(14));
      tester.view.physicalSize = const Size(320 * 3, 568 * 3);
      tester.view.viewInsets = const FakeViewPadding(bottom: 300 * 3);
      await tester.pumpAndSettle();
      await tester.tap(find.text('시간공제').first);
      await tester.pumpAndSettle();
      await tester.showKeyboard(find.byType(TextField));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('저장'));
      await tester.pumpAndSettle();
      expect(tester.getRect(find.text('저장')).bottom, lessThanOrEqualTo(568 - 300));
      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();
      expect(find.byType(RecordEditSheet), findsNothing);
      await unmount(tester);
    });
  });
}

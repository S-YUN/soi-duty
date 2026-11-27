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
import 'package:soi_duty/presentation/record_edit/record_edit_texts.dart';
import 'package:soi_duty/presentation/record_edit/widgets/deduction_sheet.dart';
import 'package:soi_duty/presentation/record_edit/widgets/time_wheel.dart';
import 'package:soi_duty/presentation/record_edit/widgets/trip_choice_panel.dart';
import 'package:soi_duty/presentation/record_edit/widgets/trip_sheet.dart';
import 'package:soi_duty/presentation/record_edit/widgets/type_chips.dart';
import 'package:soi_duty/presentation/record_edit/widgets/type_rows.dart';
import 'package:soi_duty/ui/app_colors.dart';
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

  testWidgets('시각 있는 날에 출장을 누르면 확인창 제목은 "출장으로 바꿀까요?"', (tester) async {
    await insert(14, inH: 9, outH: 18);
    await pumpSheet(tester, d(14));
    await tester.tap(find.text('출장'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('종일 출장'));
    await tester.pumpAndSettle();
    expect(find.text('출장으로 바꿀까요?'), findsOneWidget);
    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();
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

  testWidgets('설정에 기본 출퇴근 시각이 있으면 빈 행의 휠이 그 값(09:30 · 18:30)으로 열린다', (tester) async {
    for (final (key, value) in const [('default_clock_in', '09:30'), ('default_clock_out', '18:30')]) {
      await db.into(db.settings).insert(SettingsCompanion.insert(key: key, value: value));
    }
    await pumpSheet(tester, d(14));
    await tester.tap(find.text('출근'));
    await tester.pumpAndSettle();
    expect(find.text('09:30'), findsOneWidget);
    final wheel = tester.widget<TimeWheel>(find.byType(TimeWheel));
    expect((wheel.hour, wheel.minute), (9, 30));
    await tester.tap(find.text('퇴근'));
    await tester.pumpAndSettle();
    expect(find.text('18:30'), findsOneWidget);
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

    testWidgets('출장 칩 → 패널 "종일 출장"은 바로 저장·닫힘', (tester) async {
      await pumpSheet(tester, d(14));
      await tester.tap(find.text('출장'));
      await tester.pumpAndSettle();
      expect(find.byType(RecordEditSheet), findsOneWidget); // 칩만으로는 저장되지 않는다
      expect(await db.select(db.workRecords).get(), isEmpty);
      await tester.tap(find.text('종일 출장'));
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

    /// 시간공제 행을 눌러 작은 시트를 연다.
    Future<void> openDeduction(WidgetTester tester) async {
      await tester.tap(find.text('시간공제').first);
      await tester.pumpAndSettle();
      expect(find.byType(DeductionSheet), findsOneWidget);
    }

    testWidgets('시간공제는 작은 시트 — 설명 + 휠만, 2시간 30분 확인하면 행에 반영, 저장하면 기록', (tester) async {
      await insert(14, inH: 9, outH: 15);
      await pumpSheet(tester, d(14));
      await openDeduction(tester);
      expect(find.text(RecordEditTexts.deductionHelp), findsOneWidget);
      expect(find.byType(TextField), findsNothing); // 사유 입력은 뺐다
      await spin(tester, '0', 2);
      await spin(tester, '00', 3);

      await tester.tap(find.text('확인'));
      await tester.pumpAndSettle();
      expect(find.byType(DeductionSheet), findsNothing);
      expect(find.text('2시간 30분'), findsOneWidget);
      expect((await only()).deductionMinutes, 0); // 원래 시트의 저장 전까지는 초안

      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();
      expect((await only()).deductionMinutes, 150);
      await unmount(tester);
    });

    testWidgets('작은 시트를 그냥 닫으면 아무것도 안 바뀐다', (tester) async {
      await insert(14, inH: 9, outH: 15);
      await pumpSheet(tester, d(14));
      await openDeduction(tester);
      await spin(tester, '0', 2);
      await tester.tapAt(const Offset(200, 20)); // 바깥 탭
      await tester.pumpAndSettle();
      expect(find.byType(DeductionSheet), findsNothing);
      expect(find.byType(RecordEditSheet), findsOneWidget);
      expect(find.text('없음'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('휠이 한도를 막는다 — 일반은 8시간에서 분이 00으로', (tester) async {
      await insert(14, inH: 9, outH: 15);
      await pumpSheet(tester, d(14));
      await openDeduction(tester);
      await spin(tester, '00', 3);
      await spin(tester, '0', 8);
      await spin(tester, '00', 2); // 8시간에서 분을 올려도 00으로 돌아온다
      await tester.tap(find.text('확인'));
      await tester.pumpAndSettle();
      expect(find.text('8시간'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('반차 날 휠은 4시간까지, 6시간 공제 후 반차로 바꾸면 저장 불가', (tester) async {
      await insert(14, inH: 9, outH: 13, type: WorkType.halfDay);
      await pumpSheet(tester, d(14));
      await openDeduction(tester);
      await spin(tester, '0', 7);
      await tester.tap(find.text('확인'));
      await tester.pumpAndSettle();
      expect(find.text('4시간'), findsOneWidget);
      await unmount(tester);

      await insert(15, inH: 9, outH: 18, ded: 360);
      await pumpSheet(tester, d(15));
      await tester.tap(find.text('반차'));
      await tester.pumpAndSettle();
      expect(find.text('반차인 날은 4시간까지 뺄 수 있어요'), findsOneWidget);
      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();
      expect(find.byType(RecordEditSheet), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('미래: 행 4개 + 공제 행, 작은 시트의 저장이 곧 저장이고 둘 다 닫힌다', (tester) async {
      await pumpSheet(tester, d(23));
      expect(find.byType(TypeRows), findsOneWidget);
      expect(find.text('출장'), findsOneWidget);
      expect(find.text('저장'), findsNothing);
      await openDeduction(tester);
      await spin(tester, '0', 2);
      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();
      expect(find.byType(DeductionSheet), findsNothing);
      expect(find.byType(RecordEditSheet), findsNothing);
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

    testWidgets('자동 공제 2h 47m은 휠을 안 돌리고 확인하면 그대로', (tester) async {
      await insert(14, inH: 9, outH: 15, ded: 167);
      await pumpSheet(tester, d(14));
      expect(find.text('2시간 47분'), findsOneWidget);
      await openDeduction(tester);
      await tester.tap(find.text('확인'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();
      expect((await only()).deductionMinutes, 167);
      await unmount(tester);
    });

    testWidgets('출근 휠을 펴도 시트 위에 여백이 남고, 계산 내역은 접었을 때만', (tester) async {
      await insert(14, inH: 9, outH: 18);
      await pumpSheet(tester, d(14));
      expect(find.text('기준 대비'), findsOneWidget);
      await tester.tap(find.text('출근'));
      await tester.pumpAndSettle();
      expect(find.text('기준 대비'), findsNothing);
      expect(tester.getRect(find.byType(RecordEditSheet)).top, greaterThan(120));
      await tester.tap(find.text('출근'));
      await tester.pumpAndSettle();
      expect(find.text('기준 대비'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('선택된 행은 배경을 칠하지 않는다 — 회색은 휠 박스 하나', (tester) async {
      await insert(14, inH: 9, outH: 18);
      await pumpSheet(tester, d(14));
      await tester.tap(find.text('출근'));
      await tester.pumpAndSettle();
      final tinted = tester
          .widgetList<Container>(find.ancestor(of: find.text('출근'), matching: find.byType(Container)))
          .map((c) => (c.decoration as BoxDecoration?)?.color)
          .where((c) => c == AppColors.cardInner);
      expect(tinted, isEmpty);
      await unmount(tester);
    });
  });

  group('시간 출장 (핸드오프 6)', () {
    Future<void> insertTrip(
      int day, {
      int? inH,
      int? outH,
      WorkType type = WorkType.normal,
      int ded = 0,
      int? tripInH,
      int tripInM = 0,
      int? tripOutH,
      int tripOutM = 0,
    }) =>
        db.into(db.workRecords).insert(
          WorkRecordsCompanion.insert(
            date: '2026-09-${day.toString().padLeft(2, '0')}',
            clockIn: Value(inH == null ? null : d(day, inH)),
            clockOut: Value(outH == null ? null : d(day, outH)),
            type: type,
            deductionMinutes: Value(ded),
            tripStart: Value(tripInH == null ? null : d(day, tripInH, tripInM)),
            tripEnd: Value(tripOutH == null ? null : d(day, tripOutH, tripOutM)),
          ),
        );
    Future<List<WorkRecordRow>> rows() => db.select(db.workRecords).get();
    Finder chip(String label) => find.descendant(of: find.byType(TypeChips), matching: find.text(label));
    Finder row(String label) => find.descendant(of: find.byType(TypeRows), matching: find.text(label));
    Finder inPanel(String label) => find.descendant(of: find.byType(TripChoicePanel), matching: find.text(label));
    Future<void> tap(WidgetTester tester, Finder finder) async {
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle();
      await tester.tap(finder);
      await tester.pumpAndSettle();
    }

    testWidgets('과거 평일: 출장 칩은 패널을 여닫을 뿐 저장하지 않는다', (tester) async {
      await insertTrip(14, inH: 9, outH: 18);
      await pumpSheet(tester, d(14));
      expect(find.byType(TripChoicePanel), findsNothing);
      await tap(tester, chip('출장'));
      expect(find.text('출장을 어떻게 넣을까요?'), findsOneWidget);
      expect(inPanel('8시간 인정'), findsOneWidget);
      expect(inPanel('시간 직접 입력'), findsOneWidget);
      expect(find.text('출장 빼기'), findsNothing); // 출장이 아직 없다
      expect((await rows()).single.type, WorkType.normal);
      await tap(tester, chip('출장'));
      expect(find.byType(TripChoicePanel), findsNothing);
      await unmount(tester);
    });

    testWidgets('반차를 켠 날은 종일 출장을 고를 수 없다', (tester) async {
      await insertTrip(14, inH: 13, outH: 17, type: WorkType.halfDay);
      await pumpSheet(tester, d(14));
      await tap(tester, chip('출장'));
      expect(inPanel('반차인 날은 안 돼요'), findsOneWidget);
      await tap(tester, inPanel('종일 출장'));
      expect(find.byType(RecordEditSheet), findsOneWidget);
      expect(find.text('출장으로 바꿀까요?'), findsNothing);
      expect((await rows()).single.type, WorkType.halfDay);
      await unmount(tester);
    });

    testWidgets('시간 출장 → 확인은 초안에만 반영되고, 저장해야 DB에 들어간다 (출퇴근 유지)', (tester) async {
      await insertTrip(14, inH: 9, outH: 18);
      await pumpSheet(tester, d(14));
      await tap(tester, chip('출장'));
      await tap(tester, inPanel('시간 출장'));
      expect(find.byType(TripSheet), findsOneWidget);
      expect(find.text('확인'), findsOneWidget);
      // 처음 값 = 그날 출근 시각 + 3시간
      expect(find.text('09:00–12:00 · 3시간'), findsOneWidget);
      expect(find.text('출장 지우기'), findsNothing);
      await tap(tester, find.text('확인'));
      expect(find.byType(TripSheet), findsNothing);
      expect(find.byType(TripChoicePanel), findsNothing);
      expect(find.text('09:00–12:00'), findsOneWidget); // 출장 행
      expect((await rows()).single.tripStart, isNull);
      await tap(tester, find.text('저장'));
      final saved = (await rows()).single;
      expect((saved.tripStart, saved.tripEnd), (d(14, 9), d(14, 12)));
      expect((saved.clockIn, saved.clockOut), (d(14, 9), d(14, 18)));
      expect(saved.type, WorkType.normal);
      await unmount(tester);
    });

    testWidgets('출장 행을 누르면 고칠 수 있고, "출장 지우기"로 행이 사라진다', (tester) async {
      await insertTrip(14, inH: 9, outH: 18, tripInH: 9, tripInM: 20, tripOutH: 12, tripOutM: 30);
      await pumpSheet(tester, d(14));
      expect(find.text('09:20–12:30'), findsOneWidget);
      await tap(tester, find.text('09:20–12:30'));
      expect(find.text('09:20–12:30 · 3시간 10분'), findsOneWidget);
      await tap(tester, find.text('출장 지우기'));
      expect(find.text('09:20–12:30'), findsNothing);
      await tap(tester, find.text('저장'));
      final saved = (await rows()).single;
      expect((saved.tripStart, saved.tripEnd), (null, null));
      expect(saved.clockIn, d(14, 9));
      await unmount(tester);
    });

    testWidgets('패널 "출장 빼기" — 시간 출장이면 범위만 지운다', (tester) async {
      await insertTrip(14, inH: 9, outH: 18, tripInH: 9, tripOutH: 12);
      await pumpSheet(tester, d(14));
      await tap(tester, chip('출장'));
      expect(inPanel('09:00–12:00'), findsOneWidget); // 시간 버튼 보조가 범위
      await tap(tester, find.text('출장 빼기'));
      expect(find.byType(TripChoicePanel), findsNothing);
      expect(find.text('09:00–12:00'), findsNothing);
      await tap(tester, find.text('저장'));
      expect((await rows()).single.tripStart, isNull);
      await unmount(tester);
    });

    testWidgets('연차인 날에 시간 출장을 넣으면 유형이 일반으로 풀려 시각 행이 나타난다', (tester) async {
      await insertTrip(14, type: WorkType.dayOff);
      await pumpSheet(tester, d(14));
      expect(find.text('출근'), findsNothing);
      await tap(tester, chip('출장'));
      await tap(tester, inPanel('시간 출장'));
      await tap(tester, find.text('확인'));
      expect(find.text('출근'), findsOneWidget);
      expect(find.text('09:00–12:00'), findsOneWidget);
      await tap(tester, find.text('저장'));
      final saved = (await rows()).single;
      expect(saved.type, WorkType.normal);
      expect((saved.tripStart, saved.tripEnd), (d(14, 9), d(14, 12)));
      await unmount(tester);
    });

    testWidgets('공휴일 근무 날에 넣으면 유형은 공휴일 그대로, 범위만 붙는다', (tester) async {
      await insertTrip(14, inH: 10, outH: 15, type: WorkType.holiday);
      await pumpSheet(tester, d(14));
      await tap(tester, chip('출장'));
      await tap(tester, inPanel('시간 출장'));
      expect(find.text('10:00–13:00 · 3시간'), findsOneWidget);
      await tap(tester, find.text('확인'));
      await tap(tester, find.text('저장'));
      final saved = (await rows()).single;
      expect(saved.type, WorkType.holiday);
      expect((saved.tripStart, saved.tripEnd), (d(14, 10), d(14, 13)));
      expect((saved.clockIn, saved.clockOut), (d(14, 10), d(14, 15)));
      await unmount(tester);
    });

    testWidgets('미래 평일: 시간 출장은 작은 시트의 "저장"이 곧 저장이고 전부 닫힌다 — 범위만 있는 기록', (tester) async {
      await pumpSheet(tester, d(23));
      await tap(tester, row('출장'));
      expect(find.byType(TripChoicePanel), findsOneWidget);
      expect(await rows(), isEmpty);
      await tap(tester, inPanel('시간 출장'));
      expect(find.text('09:00–12:00 · 3시간'), findsOneWidget); // 출근이 없으면 09:00
      expect(find.text('확인'), findsNothing);
      await tap(tester, find.text('저장'));
      expect(find.byType(TripSheet), findsNothing);
      expect(find.byType(RecordEditSheet), findsNothing);
      final saved = (await rows()).single;
      expect(saved.type, WorkType.normal);
      expect((saved.clockIn, saved.clockOut), (null, null));
      expect((saved.tripStart, saved.tripEnd), (d(23, 9), d(23, 12)));
      await unmount(tester);
    });

    testWidgets('미래 평일: 넣어둔 시간 출장은 출장 행에 범위로 보이고, 빼면 기록이 사라진다', (tester) async {
      await insertTrip(23, tripInH: 9, tripOutH: 12);
      await pumpSheet(tester, d(23));
      expect(row('09:00–12:00'), findsOneWidget);
      await tap(tester, row('출장'));
      await tap(tester, find.text('출장 빼기'));
      expect(find.byType(RecordEditSheet), findsNothing);
      expect(await rows(), isEmpty);
      await unmount(tester);
    });

    testWidgets('미래 평일: 종일 출장은 즉시 저장, 다시 열어 빼면 기록이 사라진다', (tester) async {
      await pumpSheet(tester, d(23));
      await tap(tester, row('출장'));
      await tap(tester, inPanel('종일 출장'));
      expect(find.byType(RecordEditSheet), findsNothing);
      expect((await rows()).single.type, WorkType.businessTrip);
      await unmount(tester);

      await pumpSheet(tester, d(23));
      await tap(tester, row('출장'));
      expect(inPanel('종일 출장 ✓'), findsOneWidget);
      await tap(tester, find.text('출장 빼기'));
      expect(find.byType(RecordEditSheet), findsNothing);
      expect(await rows(), isEmpty);
      await unmount(tester);
    });

    testWidgets('미래 평일: 시간 출장이 있던 날에 연차를 누르면 범위가 지워진다', (tester) async {
      await insertTrip(23, tripInH: 9, tripOutH: 12);
      await pumpSheet(tester, d(23));
      await tap(tester, row('연차'));
      final saved = (await rows()).single;
      expect(saved.type, WorkType.dayOff);
      expect((saved.tripStart, saved.tripEnd), (null, null));
      await unmount(tester);
    });

    testWidgets('주말(과거): 칩 없이 "출장 · 없음" 행이 늘 있고, 넣으면 저장 버튼으로 마무리', (tester) async {
      await insertTrip(12, inH: 10, outH: 14);
      await pumpSheet(tester, d(12));
      expect(find.byType(TypeChips), findsNothing);
      expect(find.text('출장'), findsOneWidget);
      expect(find.text('없음'), findsNWidgets(2)); // 출장 행 값 + 계산 내역의 "점심 공제 없음"
      await tap(tester, find.text('출장'));
      expect(find.text('10:00–13:00 · 3시간'), findsOneWidget);
      await tap(tester, find.text('확인'));
      expect(find.text('10:00–13:00'), findsOneWidget);
      await tap(tester, find.text('저장'));
      final saved = (await rows()).single;
      expect((saved.tripStart, saved.tripEnd), (d(12, 10), d(12, 13)));
      await unmount(tester);
    });

    testWidgets('주말(미래): 출장 행의 작은 시트는 "저장"이고 바로 저장된다', (tester) async {
      await pumpSheet(tester, d(26));
      await tap(tester, find.text('출장'));
      await tap(tester, find.text('저장'));
      expect(find.byType(RecordEditSheet), findsNothing);
      final saved = (await rows()).single;
      expect((saved.tripStart, saved.tripEnd), (d(26, 9), d(26, 12)));
      await unmount(tester);
    });

    testWidgets('반차 + 시간 출장: 반차 칩과 출장 칩이 함께 칠해진다', (tester) async {
      await insertTrip(14, inH: 13, outH: 17, type: WorkType.halfDay, ded: 30, tripInH: 13, tripInM: 40, tripOutH: 16);
      await pumpSheet(tester, d(14));
      final chips = tester.widget<TypeChips>(find.byType(TypeChips));
      expect(chips.selected, WorkType.halfDay);
      expect(chips.tripSelected, isTrue);
      expect(find.text('13:40–16:00'), findsOneWidget);
      expect(find.text('30분'), findsOneWidget); // 시간공제 행
      await unmount(tester);
    });

    testWidgets('작은 기기(320×568): 반차 + 출장 + 공제 시트와 패널이 넘치지 않는다', (tester) async {
      await insertTrip(14, inH: 13, outH: 17, type: WorkType.halfDay, ded: 30, tripInH: 13, tripInM: 40, tripOutH: 16);
      SizeConfig.init(320);
      tester.view.physicalSize = const Size(320 * 3, 568 * 3);
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
              builder: (context) =>
                  TextButton(onPressed: () => showRecordEditSheet(context, d(14)), child: const Text('open')),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tap(tester, chip('출장'));
      expect(tester.takeException(), isNull);
      // 패널 버튼 보조 줄은 한 줄 — 두 버튼 높이가 같다
      final buttons = tester.getSize(inPanel('종일 출장').first);
      expect(buttons.height, lessThan(30));
      await unmount(tester);
    });
  });

  group('시간 출장 — 검토에서 나온 경우', () {
    Future<void> insertTrip(int day, {int? inH, int? outH, WorkType type = WorkType.normal, int ded = 0, int? tripInH, int? tripOutH}) =>
        db.into(db.workRecords).insert(
          WorkRecordsCompanion.insert(
            date: '2026-09-${day.toString().padLeft(2, '0')}',
            clockIn: Value(inH == null ? null : d(day, inH)),
            clockOut: Value(outH == null ? null : d(day, outH)),
            type: type,
            deductionMinutes: Value(ded),
            tripStart: Value(tripInH == null ? null : d(day, tripInH)),
            tripEnd: Value(tripOutH == null ? null : d(day, tripOutH)),
          ),
        );
    Future<List<WorkRecordRow>> rows() => db.select(db.workRecords).get();
    Finder chip(String label) => find.descendant(of: find.byType(TypeChips), matching: find.text(label));
    Finder inPanel(String label) => find.descendant(of: find.byType(TripChoicePanel), matching: find.text(label));
    Future<void> tap(WidgetTester tester, Finder finder) async {
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle();
      await tester.tap(finder);
      await tester.pumpAndSettle();
    }

    testWidgets('근무 시간을 펼치지 않은 지난 공휴일: 저장 버튼이 없으므로 작은 시트의 "저장"이 곧 저장이다', (tester) async {
      await insertTrip(14, type: WorkType.holiday);
      await pumpSheet(tester, d(14));
      expect(find.text('저장'), findsNothing);
      await tap(tester, chip('출장'));
      await tap(tester, inPanel('시간 출장'));
      expect(find.text('확인'), findsNothing);
      await tap(tester, find.text('저장'));
      expect(find.byType(RecordEditSheet), findsNothing);
      final saved = (await rows()).single;
      expect(saved.type, WorkType.holiday);
      expect((saved.tripStart, saved.tripEnd), (d(14, 9), d(14, 12)));
      await unmount(tester);
    });

    testWidgets('근무 시간을 펼치지 않은 지난 공휴일: 넣어둔 범위를 지우기·빼기도 바로 저장된다', (tester) async {
      await insertTrip(14, type: WorkType.holiday, tripInH: 9, tripOutH: 12);
      await pumpSheet(tester, d(14));
      await tap(tester, find.text('09:00–12:00'));
      await tap(tester, find.text('출장 지우기'));
      expect(find.byType(RecordEditSheet), findsNothing);
      expect((await rows()).single.tripStart, isNull);
      expect((await rows()).single.type, WorkType.holiday);
      await unmount(tester);

      await db.delete(db.workRecords).go();
      await insertTrip(14, type: WorkType.holiday, tripInH: 9, tripOutH: 12);
      await pumpSheet(tester, d(14));
      await tap(tester, chip('출장'));
      await tap(tester, find.text('출장 빼기'));
      expect(find.byType(RecordEditSheet), findsNothing);
      expect((await rows()).single.tripStart, isNull);
      await unmount(tester);
    });

    testWidgets('지난 연차 날: 시간 출장을 넣으면 시각 행·저장 버튼이 생기므로 "확인"이고 저장 버튼으로 마무리', (tester) async {
      await insertTrip(14, type: WorkType.dayOff);
      await pumpSheet(tester, d(14));
      await tap(tester, chip('출장'));
      await tap(tester, inPanel('시간 출장'));
      expect(find.text('확인'), findsOneWidget);
      await unmount(tester);
    });

    for (final size in const [Size(320, 568), Size(360, 640), Size(402, 874)]) {
      testWidgets('반차 + 출장 + 공제 시트가 ${size.width.toInt()}×${size.height.toInt()}에서 화면을 채우지 않는다 — 기본 · 패널 · 휠', (tester) async {
        await insertTrip(14, inH: 13, outH: 17, type: WorkType.halfDay, ded: 30, tripInH: 13, tripOutH: 16);
        SizeConfig.init(size.width);
        tester.view.physicalSize = size * 3;
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
                builder: (context) =>
                    TextButton(onPressed: () => showRecordEditSheet(context, d(14)), child: const Text('open')),
              ),
            ),
          ),
        ));
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        double sheetHeight() => tester.getSize(find.byType(RecordEditSheet)).height;
        // 시트가 화면 높이를 다 채우면 바깥을 탭하거나 내려서 닫을 수 없다 (2026-09-27 넘침 이력).
        expect(sheetHeight(), lessThan(size.height), reason: '기본');
        expect(find.text('기준 대비'), findsOneWidget);

        await tap(tester, chip('출장'));
        expect(sheetHeight(), lessThan(size.height), reason: '패널');
        expect(find.text('기준 대비'), findsNothing); // 패널이 열린 동안 계산 내역은 숨는다

        await tap(tester, find.text('출근'));
        expect(find.byType(TripChoicePanel), findsNothing); // 휠을 펴면 패널이 닫힌다
        expect(find.byType(TimeWheel), findsOneWidget);
        expect(sheetHeight(), lessThan(size.height), reason: '휠');
        expect(find.text('13:00–16:00'), findsNothing); // 휠이 열린 동안 출장 행은 숨는다

        await tap(tester, chip('출장'));
        expect(find.byType(TimeWheel), findsNothing); // 패널을 열면 휠이 접힌다
        expect(sheetHeight(), lessThan(size.height), reason: '패널(휠에서 넘어옴)');
        await tap(tester, chip('출장'));
        expect(find.text('13:00–16:00'), findsOneWidget);
        expect(find.text('기준 대비'), findsOneWidget);
        await unmount(tester);
      });
    }
  });
}

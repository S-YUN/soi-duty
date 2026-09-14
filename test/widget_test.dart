import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/core/providers/clock_provider.dart';
import 'package:soi_duty/core/providers/database_providers.dart';
import 'package:soi_duty/data/database/app_database.dart';
import 'package:soi_duty/main.dart';
import 'package:soi_duty/presentation/today/today_screen.dart';
import 'package:soi_duty/presentation/today/widgets/primary_button.dart';

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  testWidgets('앱이 부팅되고 오늘 화면이 뜬다', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    // db.close()는 아래 try 블록 안, 위젯 트리가 아직 살아있는 동안 호출한다 (addTearDown이 아니라).
    // Drift는 스트림 구독이 취소되면 재구독 유예를 위해 정리를 Timer.run으로 미루는데
    // (stream_queries.dart markAsClosed 주석: "please call and await Database.close() in your
    // Flutter widget tests!"), 위젯 트리 해제가 끝난 뒤(addTearDown)에 close()를 호출하면 이미
    // 스케줄된 그 Timer가 flutter_test의 FakeAsync 존 안에서 더 이상 pump되지 않아 close()의 대기
    // 루프가 실제 시간 기준 테스트 타임아웃(기본 10분)까지 멈춘다. 위젯이 아직 마운트된 상태에서
    // 먼저 close()를 호출하면 _isShuttingDown이 곧바로 true가 되어 Timer 없이 즉시 정리된다.
    try {
      // nowProvider의 1분 타이머가 테스트 종료 시 pending timer로 잡히지 않게 고정 스트림으로 바꾼다.
      await tester.pumpWidget(ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          nowProvider.overrideWith((ref) => Stream.value(DateTime.now())),
        ],
        child: const SoiDutyApp(),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(TodayScreen), findsOneWidget);
      expect(find.byType(PrimaryButton), findsOneWidget);
      expect(find.text('출근하기'), findsOneWidget);
    } finally {
      await db.close();
    }
  });

  testWidgets('출근하기를 누르면 퇴근하기로 바뀐다', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    // 위와 동일한 이유로, 위젯 트리가 아직 마운트된 상태에서 명시적으로 닫는다.
    try {
      // nowProvider의 1분 타이머가 테스트 종료 시 pending timer로 잡히지 않게 고정 스트림으로 바꾼다.
      await tester.pumpWidget(ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          nowProvider.overrideWith((ref) => Stream.value(DateTime.now())),
        ],
        child: const SoiDutyApp(),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('출근하기'));
      await tester.pumpAndSettle();
      expect(find.text('퇴근하기'), findsOneWidget);
    } finally {
      await db.close();
    }
  });
}

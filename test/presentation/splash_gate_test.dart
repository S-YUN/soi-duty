import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/core/presentation/size_config.dart';
import 'package:soi_duty/core/providers/clock_provider.dart';
import 'package:soi_duty/core/providers/database_providers.dart';
import 'package:soi_duty/data/database/app_database.dart';
import 'package:soi_duty/presentation/splash/splash_gate.dart';
import 'package:soi_duty/ui/app_sizes.dart';

import '../helpers/records.dart';

void main() {
  late AppDatabase db;
  final now = d(16, 12);

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });
  setUp(() {
    SizeConfig.init(402);
    db = AppDatabase(NativeDatabase.memory());
  });
  tearDown(() => db.close());

  /// [neverReady]면 기록 스트림이 영영 안 와서 스플래시가 계속 떠 있다.
  Future<void> pump(WidgetTester tester, {bool neverReady = false}) => tester.pumpWidget(ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(() => now),
          nowProvider.overrideWith((ref) => Stream.value(now)),
          if (neverReady) allRecordsProvider.overrideWith((ref) => const Stream.empty()),
        ],
        child: const MaterialApp(home: SplashGate(child: Text('app'))),
      ));

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  }

  testWidgets('첫 프레임엔 스플래시가 덮고, 오늘 상태가 준비되면 페이드 후 사라진다 — 바는 안 나온다', (tester) async {
    await pump(tester);
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('app'), findsOneWidget);

    await tester.pumpAndSettle(); // 프로바이더 해석 + 페이드
    expect(find.byType(Image), findsNothing);
    expect(find.text('근무 기록 불러오는 중'), findsNothing);
    await unmount(tester);
  });

  testWidgets('준비가 늦어지면 200ms 뒤 대기 바·문구가 나온다', (tester) async {
    await pump(tester, neverReady: true);
    await tester.pump(AppDurations.splashBarDelay);
    await tester.pump(AppDurations.splashFade);
    expect(find.byType(Image), findsOneWidget);
    final caption = tester.widget<AnimatedOpacity>(
      find.ancestor(of: find.text('근무 기록 불러오는 중'), matching: find.byType(AnimatedOpacity)).first,
    );
    expect(caption.opacity, 1);
    await unmount(tester);
  });
}

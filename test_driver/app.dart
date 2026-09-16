import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soi_duty/core/providers/database_providers.dart';
import 'package:soi_duty/data/seed/debug_seed.dart';
import 'package:soi_duty/main.dart';

/// `flutter drive --flavor dev --target test_driver/app.dart` 진입점.
/// 앱 코드는 건드리지 않고, 앱과 같은 DB 인스턴스에 '두 달치 기록' 시드를 넣는다
/// (다른 인스턴스로 쓰면 Drift 스트림이 갱신을 못 본다).
Future<void> main() async {
  enableFlutterDriverExtension();
  final container = ProviderContainer();
  runApp(UncontrolledProviderScope(container: container, child: const SoiDutyApp()));
  await applySeed(container.read(appDatabaseProvider), SeedScenario.history, today: DateTime.now());
}

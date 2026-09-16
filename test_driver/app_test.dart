import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

/// 시드 → 주간 → 월간 → 시트를 눌러보고 docs/screenshots/에 남기는 스모크 드라이브.
/// 실행: `flutter drive --flavor dev --target test_driver/app.dart -d 시뮬레이터ID`
void main() {
  late FlutterDriver driver;
  final dir = Directory('docs/screenshots')..createSync(recursive: true);
  final stamp = DateTime.now().toIso8601String().substring(0, 10);

  Future<void> shot(String name) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final png = await driver.screenshot();
    File('${dir.path}/$stamp-$name.png').writeAsBytesSync(png);
  }

  setUpAll(() async => driver = await FlutterDriver.connect());
  tearDownAll(() => driver.close());

  test('seed → today → week → month → sheet', timeout: const Timeout(Duration(minutes: 3)), () async {
    // 시드('두 달치 기록')는 test_driver/app.dart가 앱 시작 전에 넣는다 → 오늘은 근무 중.
    await driver.waitFor(find.text('퇴근하기'));
    await shot('today-working');

    await driver.tap(find.text('주간'));
    await driver.waitFor(find.text('이번 주 누적'));
    await shot('week-current');
    await driver.tap(find.text('◀'));
    await driver.waitFor(find.text('주간 누적'));
    await shot('week-previous');

    await driver.tap(find.text('월간'));
    await driver.waitFor(find.text('기준 대비 ±'));
    await shot('month-current');
    await driver.tap(find.text('◀'));
    await shot('month-previous');
    await driver.tap(find.text('▶'));

    // 셀 탭 → 시트 → 출근 행 → 휠
    await driver.tap(find.text('14'));
    await driver.waitFor(find.text('저장'));
    await shot('sheet');
    await driver.tap(find.text('출근'));
    await driver.waitFor(find.text('출근 시각'));
    await shot('sheet-wheel');
    await driver.tap(find.text('연차'));
    await shot('sheet-dayoff');
    await driver.tap(find.text('취소'));

    await driver.tap(find.text('오늘'));
    await driver.waitFor(find.text('퇴근하기'));
  });
}

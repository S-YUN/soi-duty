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

    // 스와이프로 주간 이동
    await driver.scroll(find.byType('PageView'), -300, 0, const Duration(milliseconds: 300));
    await driver.waitFor(find.text('이번 주 근무 통계'));
    await shot('week-current');
    await driver.tap(find.text('◀'));
    await driver.waitFor(find.text('주간 근무 통계'));
    await shot('week-previous');

    await driver.tap(find.text('월간'));
    await driver.waitFor(find.text('토'));
    await shot('month-current');
    await driver.tap(find.text('◀'));
    await driver.waitFor(find.text('2026년 8월'));
    await shot('month-previous');
    await driver.tap(find.text('▶'));
    // 상태 변경은 다음 프레임에 애니메이션을 시작하므로, 타이틀 갱신을 본 뒤에 애니메이션 종료를 기다린다.
    await driver.waitFor(find.text('2026년 9월'));
    await driver.waitUntilNoTransientCallbacks();

    // 퇴근 전 오늘을 탭하면 시트 대신 토스트
    await driver.tap(find.text('${DateTime.now().day}'));
    // (driver.screenshot()은 오버레이 토스트를 못 담아 스크린샷은 생략)
    await driver.waitFor(find.text('오늘 기록은 퇴근한 뒤에 수정할 수 있어요'));
    await driver.waitForAbsent(find.text('오늘 기록은 퇴근한 뒤에 수정할 수 있어요'));

    // 셀 탭 → 시트 → 출근 행 → 휠
    await driver.tap(find.text('14'));
    await driver.waitFor(find.text('저장'));
    await shot('sheet');
    await driver.tap(find.text('출근'));
    await driver.waitFor(find.text('출근 시각'));
    await shot('sheet-wheel');
    // 시각 있는 날의 연차는 확인 팝업 → 취소하면 시트 유지 → 저장으로 닫기
    await driver.tap(find.text('연차'));
    await driver.waitFor(find.text('연차로 바꿀까요?'));
    await shot('sheet-dayoff-confirm');
    await driver.tap(find.text('취소'));
    await driver.waitForAbsent(find.text('연차로 바꿀까요?'));
    await driver.tap(find.text('저장'));

    // 미래 날짜: 칩 탭 한 번으로 저장·닫힘 → 배지가 생기고, 다시 열어 지우기
    await driver.tap(find.text('24'));
    await driver.waitFor(find.text('공휴일'));
    await shot('sheet-future');
    await driver.tap(find.text('반차'));
    await driver.waitFor(find.text('반차'));
    await shot('month-future-halfday');
    await driver.tap(find.text('24'));
    await driver.tap(find.text('이 날 기록 지우기'));
    await driver.tap(find.text('지우기'));

    await driver.tap(find.text('오늘'));
    await driver.waitFor(find.text('퇴근하기'));
  });
}

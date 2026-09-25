import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

/// 시드 → 주간 → 월간 → 시트를 눌러보고 docs/screenshots/에 남기는 스모크 드라이브.
/// 실행: `flutter drive --flavor dev --target test_driver/app.dart -d 시뮬레이터ID`
void main() {
  late FlutterDriver driver;
  // 고정 이름으로 덮어쓴다 (git 추적 안 함). 날짜를 붙이면 매일 쌓이고 커밋마다 PNG diff가 생긴다.
  final dir = Directory('docs/screenshots')..createSync(recursive: true);

  // 오늘이 바뀌어도 같은 시나리오를 돌 수 있게, 날짜는 실행 시점에 고른다.
  // 셀 키 규칙은 calendar_card.dart의 calendarCellKey와 같아야 한다.
  String cellKey(DateTime d) => 'cell-${d.year}-${d.month}-${d.day}';
  bool isWeekday(DateTime d) => d.weekday <= DateTime.friday;

  final today = DateTime.now();
  /// 이번 달의 지난 평일 하나 (기록이 있는 날 — 시드가 두 달치를 채운다).
  final pastWeekday = () {
    for (var day = today.day - 1; day >= 1; day--) {
      final d = DateTime(today.year, today.month, day);
      if (isWeekday(d)) return d;
    }
    return DateTime(today.year, today.month, today.day);
  }();
  /// 이번 달에 남은 평일 하나. 없으면 null.
  final futureWeekday = () {
    final lastDay = DateTime(today.year, today.month + 1, 0).day;
    for (var day = today.day + 1; day <= lastDay; day++) {
      final d = DateTime(today.year, today.month, day);
      if (isWeekday(d)) return d;
    }
    return null;
  }();

  Future<void> shot(String name) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final png = await driver.screenshot();
    File('${dir.path}/$name.png').writeAsBytesSync(png);
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
    await driver.tap(find.byValueKey(cellKey(today)));
    // (driver.screenshot()은 오버레이 토스트를 못 담아 스크린샷은 생략)
    await driver.waitFor(find.text('오늘 기록은 퇴근한 뒤에 수정할 수 있어요'));
    await driver.waitForAbsent(find.text('오늘 기록은 퇴근한 뒤에 수정할 수 있어요'));

    // 셀 탭 → 시트 → 출근 행 → 휠
    await driver.tap(find.byValueKey(cellKey(pastWeekday)));
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

    // 미래 평일: 유형 행 탭 한 번으로 저장·닫힘 → 색 원이 생기고, 다시 열어 지우기.
    // 이번 달에 남은 평일이 없는 날(말일 근처)에는 건너뛴다.
    if (futureWeekday != null) {
      await driver.tap(find.byValueKey(cellKey(futureWeekday)));
      await driver.waitFor(find.text('미리 지정해두면 그 주 목표 시간이 자동으로 계산돼요'));
      await shot('sheet-future');
      await driver.tap(find.text('반차'));
      await driver.waitForAbsent(find.text('미리 지정해두면 그 주 목표 시간이 자동으로 계산돼요'));
      await shot('month-future-halfday');
      await driver.tap(find.byValueKey(cellKey(futureWeekday)));
      await driver.tap(find.text('이 날 기록 지우기'));
      await driver.tap(find.text('지우기'));
    }

    await driver.tap(find.text('오늘'));
    await driver.waitFor(find.text('퇴근하기'));
  });
}

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/core/routing/router.dart';
import 'package:soi_duty/presentation/settings/settings_screen.dart';

void main() {
  test('설정 페이지는 CupertinoPage — iOS 가장자리 스와이프로 닫힌다', () {
    final page = buildSettingsPage(const ValueKey('settings'));
    expect(page, isA<CupertinoPage<void>>());
    expect((page as CupertinoPage<void>).child, isA<SettingsScreen>());
  });
}

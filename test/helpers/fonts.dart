import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// 테스트 기본 폰트는 글자마다 1em 폭이라 한 줄짜리 문구가 줄바꿈된다.
/// 실제 Pretendard를 로드해야 레이아웃 테스트가 의미 있다.
Future<void> loadPretendard() async {
  final loader = FontLoader('Pretendard')
    ..addFont(rootBundle.load('assets/fonts/Pretendard-Regular.otf'))
    ..addFont(rootBundle.load('assets/fonts/Pretendard-Medium.otf'))
    ..addFont(rootBundle.load('assets/fonts/Pretendard-SemiBold.otf'));
  await loader.load();
}

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clock_provider.g.dart';

typedef Clock = DateTime Function();

/// 디버그 전용 시계 이동. 실제 시각에 이 오프셋을 더한 값이 앱의 "지금"이 된다.
/// 릴리즈에서는 [clock]이 이 값을 읽지 않는다.
@Riverpod(keepAlive: true)
class DebugClockOffset extends _$DebugClockOffset {
  @override
  Duration build() => Duration.zero;

  /// 앱의 "지금"을 [target]으로 맞춘다. 분은 계속 실제로 흐른다.
  void moveTo(DateTime target) => state = target.difference(DateTime.now());

  void reset() => state = Duration.zero;
}

/// 액션이 시각을 찍을 때 쓰는 시계. 테스트에서 고정값으로 오버라이드한다.
@Riverpod(keepAlive: true)
Clock clock(Ref ref) {
  if (!kDebugMode) return DateTime.now;
  final offset = ref.watch(debugClockOffsetProvider);
  return () => DateTime.now().add(offset);
}

/// 즉시 1회, 이후 매 분 정각에 방출. 자정 넘김·경과 시간·퇴근 예상 갱신은 전부 이걸로.
@Riverpod(keepAlive: true)
Stream<DateTime> now(Ref ref) async* {
  final clock = ref.watch(clockProvider);
  yield clock();
  while (true) {
    final t = clock();
    final nextMinute = DateTime(t.year, t.month, t.day, t.hour, t.minute + 1);
    // DST로 시계가 뒤로 감기는 시간대엔 nextMinute.difference(t)가 0 이하일 수 있다 — 그때는
    // 1분 뒤에 재시도해 바쁜 루프(tight loop)를 막는다.
    final wait = nextMinute.difference(t);
    await Future<void>.delayed(wait > Duration.zero ? wait : const Duration(minutes: 1));
    yield clock();
  }
}

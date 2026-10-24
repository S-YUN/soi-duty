/// 한글 조사 선택. 문구는 `*_texts.dart`에서만 조립하지만 조사 규칙은 글자에 달린 것이라 여기 둔다.
library;

/// 받침이 있으면 "으로", 없거나 ㄹ 받침이면 "로". ("연차로" · "공휴일로" · "출장으로")
/// 한글이 아닌 글자로 끝나면 받침 없는 것으로 본다.
String withRo(String word) => '$word${_endsWithBatchim(word, exceptRieul: true) ? '으로' : '로'}';

bool _endsWithBatchim(String word, {required bool exceptRieul}) {
  if (word.isEmpty) return false;
  final code = word.codeUnitAt(word.length - 1);
  const base = 0xAC00, last = 0xD7A3;
  if (code < base || code > last) return false;
  final jong = (code - base) % 28; // 0 = 받침 없음, 8 = ㄹ
  if (jong == 0) return false;
  return !(exceptRieul && jong == 8);
}

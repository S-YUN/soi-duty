# 2차 구현 플랜 — 오늘 화면 변경분 · 시간 수정 시트 · 주간/월간 탭

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 알약 탭의 주간·월간을 살리고, 오늘·주간·월간·누락 리스트 네 곳에서 공유하는 시간 수정 시트를 붙인다.

**Architecture:** 1차와 같다 — `allRecords` 스트림 하나에서 `(records, firstRecordDate, now, rules, 선택 주/월) → State` 순수 함수로 화면 상태를 파생한다. 탭은 `StatefulShellRoute.indexedStack` 3 브랜치, 시트는 루트 내비게이터 위의 `showModalBottomSheet`. 저장은 `repo.save/delete`만 하고 갱신은 스트림에 맡긴다.

**Tech Stack:** Flutter 3.47, Riverpod 3 코드젠, freezed 3, Drift 2, go_router 18, CupertinoPicker.

**Spec:** `docs/specs/2026-09-17-week-month-sheet-design.md` (계산 규칙은 `CLAUDE.md`, 시각은 `docs/specs/design-handoff-2-weekly-monthly-sheet.md`)

## Global Constraints

- `domain/`에는 `package:flutter` import 금지. `RecordDraft`도 Flutter 없이 테스트한다.
- 위젯에 색·크기·스타일 리터럴 금지. 전부 `AppColors` / `AppSizes` / `AppTextStyles` / `AppDurations`.
- Riverpod은 `@riverpod` 코드젠만. `StateProvider` 등 구문법 금지.
- 코드젠: `dart run build_runner build --delete-conflicting-outputs`. freezed/riverpod 파일을 만들거나 바꾼 뒤 항상 실행.
- 테스트: `flutter test`. 위젯 테스트는 `loadPretendard()` + `SizeConfig.init(402)` (기존 `today_view_test.dart` 패턴).
- 커밋 메시지는 한국어, 끝에 `Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>`.
- 파생값 저장 금지. 월간 리포트 없음. 미래 날짜는 유형만. 연차·공휴일은 시각 null. 퇴근 < 출근 저장 불가. 빈 normal은 delete.

---

### Task 1: 토큰·포맷 함수

**Files:**
- Modify: `lib/ui/app_colors.dart`, `lib/ui/app_sizes.dart`, `lib/ui/app_text_styles.dart`
- Modify: `lib/core/presentation/format/date_format.dart`, `lib/core/presentation/format/time_format.dart`
- Test: `test/core/format_test.dart`

**Interfaces:**
- Produces: `formatWeekRange(DateTime monday)`, `formatMonthTitle(DateTime month)`, `formatClockRange(DateTime, DateTime)`, 아래 토큰들.

- [ ] **Step 1: 포맷 테스트 추가** — `test/core/format_test.dart`의 `main()` 끝에:

```dart
  group('formatWeekRange', () {
    test('같은 달', () => expect(formatWeekRange(DateTime(2026, 9, 7)), '9월 7일 – 13일'));
    test('다른 달', () => expect(formatWeekRange(DateTime(2026, 8, 31)), '8월 31일 – 9월 6일'));
    test('해 넘김', () => expect(formatWeekRange(DateTime(2026, 12, 28)), '12월 28일 – 1월 3일'));
  });
  test('formatMonthTitle', () => expect(formatMonthTitle(DateTime(2026, 9)), '2026년 9월'));
  test('formatClockRange', () =>
      expect(formatClockRange(DateTime(2026, 9, 7, 9, 5), DateTime(2026, 9, 7, 18, 36)), '09:05 – 18:36'));
```

- [ ] **Step 2: 실패 확인** — `flutter test test/core/format_test.dart` → 컴파일 에러 (함수 없음)

- [ ] **Step 3: 구현**

`date_format.dart` 끝에:
```dart
/// "9월 7일 – 13일", 달이 바뀌면 "8월 31일 – 9월 6일"
String formatWeekRange(DateTime monday) {
  final sunday = DateTime(monday.year, monday.month, monday.day + 6);
  if (sunday.month == monday.month) return '${monday.month}월 ${monday.day}일 – ${sunday.day}일';
  return '${monday.month}월 ${monday.day}일 – ${sunday.month}월 ${sunday.day}일';
}

/// "2026년 9월"
String formatMonthTitle(DateTime month) => '${month.year}년 ${month.month}월';
```

`time_format.dart` 끝에:
```dart
/// "09:05 – 18:36" (en dash)
String formatClockRange(DateTime clockIn, DateTime clockOut) => '${formatClock(clockIn)} – ${formatClock(clockOut)}';
```

`app_colors.dart`의 클래스 안, `dotInactive` 아래:
```dart
  static const hairline = Color(0xFFDCDFD8);
  static const rowDivider = Color(0xFFE7E9E3);
  static const faint = Color(0xFF8B9184);
  static const weekendNone = Color(0xFFC9CDC4);
  static const todayRow = Color(0xFFF3F5F1);
  static const chipNeutral = Color(0xFFF0F2ED);
  static const wheelUnselected = Color(0xFF9DA296);
  static const scrim = Color(0x6B16191A); // rgba(22,25,26,.42)
  static const sheetShadow = Color(0x2E16191A); // rgba(22,25,26,.18)
```

`app_sizes.dart`: `secondarySlot`을 `40.w`, `secondarySlotGap`을 `10.w`로 바꾸고, 클래스 안 `pill` 위에 추가:
```dart
  // 보조 슬롯 텍스트 버튼
  static EdgeInsets get quietButtonPadding => EdgeInsets.symmetric(vertical: 8.w, horizontal: 4.w);
  static double get slotDividerWidth => 1.w;
  static double get slotDividerHeight => 11.w;
  static double get slotItemGap => 16.w;

  // 기간 네비게이터
  static EdgeInsets get navPadding => EdgeInsets.fromLTRB(20.w, 16.w, 20.w, 14.w);
  static double get navArrow => 30.w;
  static double get navLabelMinWidth => 186.w;
  static double get navGap => 4.w;

  // 주간 누적 카드
  static EdgeInsets get weekCardPadding => EdgeInsets.all(20.w);
  static double get weekValueTop => 8.w;
  static double get weekReasonTop => 7.w;
  static double get weekBarTop => 14.w;

  // 주간 일별 행
  static EdgeInsets get rowPadding => EdgeInsets.symmetric(vertical: 13.w, horizontal: 18.w);
  static double get rowGap => 12.w;
  static double get rowDateWidth => 30.w;
  static double get rowValueWidth => 58.w;
  static double get rowNoteMinHeight => 16.w;
  static double get rowNoteTop => 3.w;
  static double get rowDowTop => 1.w;
  static double get rowBadgeGap => 6.w;
  static EdgeInsets get rowBadgePadding => EdgeInsets.symmetric(vertical: 2.w, horizontal: 7.w);
  static double get rowBadgeRadius => 5.w;
  static double get rowDivider => 1.w;

  // 월간 캘린더
  static EdgeInsets get calendarPadding => EdgeInsets.fromLTRB(14.w, 16.w, 14.w, 16.w);
  static EdgeInsets get calendarHeaderPadding => EdgeInsets.fromLTRB(2.w, 14.w, 2.w, 6.w);
  static EdgeInsets get calendarGridPadding => EdgeInsets.symmetric(horizontal: 2.w);
  static double get calendarCell => 58.w;
  static double get calendarCellRadius => 10.w;
  static double get calendarCellTop => 9.w;
  static double get calendarCellGap => 5.w;
  static double get calendarRowGap => 4.w;
  static double get calendarColGap => 3.w;
  static EdgeInsets get calendarBadgePadding => EdgeInsets.symmetric(vertical: 1.w, horizontal: 5.w);
  static double get calendarBadgeRadius => 4.w;
  static EdgeInsets get legendPadding => EdgeInsets.fromLTRB(6.w, 2.w, 6.w, 0);
  static double get legendChip => 13.w;
  static double get legendChipRadius => 4.w;
  static double get legendChipGap => 6.w;
  static double get legendRunGap => 8.w;
  static double get legendItemGap => 14.w;

  // 시간 수정 시트
  static double get sheetRadius => 24.w;
  static EdgeInsets get sheetPadding => EdgeInsets.fromLTRB(20.w, 10.w, 20.w, 30.w);
  static double get sheetHandleWidth => 38.w;
  static double get sheetHandleHeight => 4.w;
  static double get sheetHandleBottom => 14.w;
  static double get sheetShadowBlur => 34.w;
  static Offset get sheetShadowOffset => Offset(0, -8.w);
  static EdgeInsets get sheetNotePadding => EdgeInsets.symmetric(vertical: 11.w, horizontal: 13.w);
  static EdgeInsets get sheetNoteMargin => EdgeInsets.fromLTRB(0, 12.w, 0, 4.w);
  static double get sheetNoteRadius => 11.w;
  static EdgeInsets get chipsMargin => EdgeInsets.fromLTRB(0, 14.w, 0, 4.w);
  static double get chipGap => 7.w;
  static EdgeInsets get chipPadding => EdgeInsets.symmetric(vertical: 11.w);
  static double get chipRadius => 11.w;
  static double get timeRowOutdent => 12.w;
  static EdgeInsets get timeRowPadding => EdgeInsets.symmetric(vertical: 15.w, horizontal: 12.w);
  static double get timeRowRadius => 12.w;
  static double get wheelBoxTop => 14.w;
  static EdgeInsets get wheelBoxPadding => EdgeInsets.symmetric(vertical: 16.w, horizontal: 14.w);
  static double get wheelBoxRadius => 14.w;
  static double get wheelTitleBottom => 10.w;
  static double get wheelHeight => 176.w;
  static double get wheelItem => 44.w;
  static double get wheelBandRadius => 11.w;
  static double get wheelColonPadding => 2.w;
  static double get calcTop => 16.w;
  static double get sheetButtonsTop => 20.w;
  static double get sheetButton => 52.w;
  static double get sheetButtonRadius => 13.w;
  static double get sheetButtonGap => 9.w;
  static double get deleteLinkTop => 16.w;

  // 확인 다이얼로그
  static EdgeInsets get dialogPadding => EdgeInsets.all(20.w);
  static double get dialogMessageTop => 8.w;
  static double get dialogButtonsTop => 18.w;
  static double get dialogButton => 44.w;
```

`app_text_styles.dart` 클래스 안, `badge` 아래:
```dart
  // 보조 슬롯 텍스트 버튼
  static TextStyle get quietButton => _style(13, FontWeight.w500, color: AppColors.brand);

  // 기간 네비게이터
  static TextStyle get navLabel => _style(19, FontWeight.w600, letterSpacingEm: -0.02);
  static TextStyle get navArrow => _style(13, FontWeight.w400, color: AppColors.subtle);
  static TextStyle get navArrowDisabled => _style(13, FontWeight.w400, color: AppColors.hairline);

  // 주간
  static TextStyle get weekValue => _style(26, FontWeight.w600, letterSpacingEm: -0.03);
  static TextStyle get weekGoal => _style(17, FontWeight.w400, color: AppColors.subtle);
  static TextStyle get weekReason => _style(12.5, FontWeight.w400, height: 1.5, color: AppColors.subtle);
  static TextStyle get rowNum => _style(15, FontWeight.w500, height: 1.15);
  static TextStyle get rowNumWeekend => _style(15, FontWeight.w500, height: 1.15, color: AppColors.faint);
  static TextStyle get rowDow => _style(11.5, FontWeight.w400, color: AppColors.subtle);
  static TextStyle get rowDowWeekend => _style(11.5, FontWeight.w400, color: AppColors.faint);
  static TextStyle get rowMain => _style(15, FontWeight.w500);
  static TextStyle get rowMainDim => _style(15, FontWeight.w400, color: AppColors.subtle);
  static TextStyle get rowMainNone => _style(15, FontWeight.w400, color: AppColors.weekendNone);
  static TextStyle get rowNote => _style(11.5, FontWeight.w400, color: AppColors.subtle);
  static TextStyle get rowBadge => _style(11, FontWeight.w600);
  static TextStyle rowValue(Color color) => _style(13.5, FontWeight.w500, color: color);

  // 월간
  static TextStyle get calendarTitle => _style(12.5, FontWeight.w500, color: AppColors.subtle);
  static TextStyle get calendarHeader => _style(10.5, FontWeight.w400, color: AppColors.subtle);
  static TextStyle calendarNum({required bool dim}) =>
      _style(10.5, FontWeight.w400, color: dim ? AppColors.dotInactive : AppColors.subtle);
  static TextStyle get calendarBadge => _style(10, FontWeight.w700);
  static TextStyle calendarValue(Color color) => _style(11.5, FontWeight.w500, color: color);
  static TextStyle get calendarWeekendValue => _style(11, FontWeight.w400, color: AppColors.subtle);
  static TextStyle get legend => _style(11.5, FontWeight.w400, color: AppColors.subtle);

  // 시간 수정 시트
  static TextStyle get sheetTitle => _style(16, FontWeight.w600, letterSpacingEm: -0.01);
  static TextStyle get sheetNote => _style(11.5, FontWeight.w400, height: 1.5, color: AppColors.subtle);
  static TextStyle chip({required bool selected, required Color selectedColor}) =>
      _style(12.5, selected ? FontWeight.w600 : FontWeight.w500, color: selected ? selectedColor : AppColors.subtle);
  static TextStyle get timeLabel => _style(13, FontWeight.w400, color: AppColors.subtle);
  static TextStyle timeValue({required bool selected}) => _style(
        20,
        selected ? FontWeight.w600 : FontWeight.w500,
        letterSpacingEm: -0.01,
        color: selected ? AppColors.brand : AppColors.ink,
      );
  static TextStyle get wheelTitle => _style(12, FontWeight.w500, color: AppColors.subtle);
  static TextStyle get wheelSelected => _style(25, FontWeight.w600, letterSpacingEm: -0.02);
  static TextStyle get wheelItem => _style(20, FontWeight.w500, letterSpacingEm: -0.02, color: AppColors.wheelUnselected);
  static TextStyle get wheelColon => _style(20, FontWeight.w600);
  static TextStyle get calcRow => _style(12.5, FontWeight.w400, height: 1.9);
  static TextStyle get calcValue => _style(12.5, FontWeight.w500, height: 1.9);
  static TextStyle get calcNote => _style(11.5, FontWeight.w400, height: 1.9, color: AppColors.subtle);
  static TextStyle get calcSum => _style(12.5, FontWeight.w500, height: 1.9, color: AppColors.brand);
  static TextStyle get calcError => _style(12.5, FontWeight.w500, height: 1.9, color: AppColors.minus);
  static TextStyle get sheetButtonPrimary => _style(15, FontWeight.w600, color: AppColors.onBrand);
  static TextStyle get sheetButtonSecondary => _style(15, FontWeight.w600, color: AppColors.subtle);
  static TextStyle get deleteLink => _style(12.5, FontWeight.w400, color: AppColors.subtle);

  // 확인 다이얼로그
  static TextStyle get dialogTitle => _style(15, FontWeight.w600);
  static TextStyle get dialogMessage => _style(13, FontWeight.w400, height: 1.5, color: AppColors.subtle);
```

`app_sizes.dart`의 `AppDurations`에:
```dart
  static const sheetSlide = Duration(milliseconds: 260);
  static const wheelItem = Duration(milliseconds: 120);
  static const pressedOpacity = Duration(milliseconds: 100);
```
그리고 같은 파일 끝에:
```dart
abstract final class AppCurves {
  static const sheet = Cubic(0.22, 0.8, 0.3, 1);
}

abstract final class AppOpacities {
  static const quietPressed = 0.55;
  static const cellPressed = 0.6;
}
```
(`app_sizes.dart`는 이미 `package:flutter/widgets.dart`를 import하므로 `Cubic` 사용 가능.)

- [ ] **Step 4: 통과 확인** — `flutter test test/core/format_test.dart` → PASS. `flutter analyze` 클린.

- [ ] **Step 5: 커밋** — `git add lib/ui lib/core/presentation/format test/core && git commit -m "2차 토큰과 주간·월간 포맷 함수"`

---

### Task 2: 도메인 계산 추가

**Files:**
- Modify: `lib/domain/rules/work_calculator.dart`
- Create: `lib/domain/rules/navigation_bounds.dart`
- Test: `test/domain/work_calculator_test.dart`, `test/domain/navigation_bounds_test.dart`

**Interfaces:**
- Produces: `bool isValidClockRange(DateTime?, DateTime?)`, `int weekendMinutes(List<WorkRecord>, DateTime monday, WorkRules)`, `DateTime firstOfMonth(DateTime)`, `DateTime addMonths(DateTime month, int n)`, `DateTime addDays(DateTime, int)`, `List<DateTime> calendarDays(DateTime month)`, `DateTime earliestMonday(DateTime? firstRecordDate, DateTime today)`, `DateTime earliestMonth(DateTime? firstRecordDate, DateTime today)`.

- [ ] **Step 1: 테스트** — `test/domain/work_calculator_test.dart` `main()` 끝에:

```dart
  group('isValidClockRange', () {
    test('둘 중 하나라도 없으면 유효', () {
      expect(isValidClockRange(null, null), isTrue);
      expect(isValidClockRange(d(14, 9), null), isTrue);
    });
    test('퇴근 < 출근이면 무효, 같으면 유효', () {
      expect(isValidClockRange(d(14, 22), d(14, 2)), isFalse);
      expect(isValidClockRange(d(14, 9), d(14, 9)), isTrue);
    });
  });

  group('weekendMinutes', () {
    test('그 주 토·일 실근무 합, 점심 공제 없음', () {
      final records = [
        rec(14, inH: 9, outH: 18),
        rec(19, inH: 10, outH: 14, outM: 30), // 토
        rec(20, inH: 10, outH: 11), // 일
        rec(12, inH: 10, outH: 12), // 지난주 토
      ];
      expect(weekendMinutes(records, d(14), rules), 270 + 60);
    });
  });

  group('calendarDays', () {
    test('2026-09: 8/31(월)부터 10/4(일)까지 5주', () {
      final days = calendarDays(DateTime(2026, 9));
      expect(days.length, 35);
      expect(days.first, DateTime(2026, 8, 31));
      expect(days.last, DateTime(2026, 10, 4));
    });
    test('2026-02: 2/1이 일요일 → 1/26부터, 5주', () {
      final days = calendarDays(DateTime(2026, 2));
      expect(days.first, DateTime(2026, 1, 26));
      expect(days.length, 35);
    });
    test('2026-08: 6주', () => expect(calendarDays(DateTime(2026, 8)).length, 42));
    test('2027-02: 2/1 월요일, 28일 → 딱 4주', () => expect(calendarDays(DateTime(2027, 2)).length, 28));
  });

  test('addMonths는 해를 넘긴다', () {
    expect(addMonths(DateTime(2026, 12), 1), DateTime(2027, 1));
    expect(addMonths(DateTime(2026, 1), -1), DateTime(2025, 12));
  });
```

새 파일 `test/domain/navigation_bounds_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/domain/rules/navigation_bounds.dart';

import '../helpers/records.dart';

void main() {
  test('첫 기록일 없으면 이번 주 월요일', () => expect(earliestMonday(null, d(16)), d(14)));
  test('첫 기록일 있으면 그 주 월요일', () => expect(earliestMonday(d(9), d(16)), d(7)));
  test('첫 기록일이 미래(미리 찍은 연차)면 이번 주를 넘지 않는다', () => expect(earliestMonday(d(23), d(16)), d(14)));
  test('첫 기록일 없으면 이번 달', () => expect(earliestMonth(null, d(16)), DateTime(2026, 9)));
  test('첫 기록일 있으면 그 달', () => expect(earliestMonth(DateTime(2026, 7, 20), d(16)), DateTime(2026, 7)));
  test('첫 기록일이 다음 달이면 이번 달', () => expect(earliestMonth(DateTime(2026, 10, 2), d(16)), DateTime(2026, 9)));
}
```

- [ ] **Step 2: 실패 확인** — `flutter test test/domain` → 컴파일 에러

- [ ] **Step 3: 구현**

`work_calculator.dart`의 "날짜 유틸" 섹션에 추가:
```dart
DateTime addDays(DateTime d, int n) => DateTime(d.year, d.month, d.day + n);

DateTime firstOfMonth(DateTime d) => DateTime(d.year, d.month);

DateTime addMonths(DateTime month, int n) => DateTime(month.year, month.month + n);

/// 월요일 시작, 앞뒤를 채운 완전한 주 단위 (4~6주 × 7일).
List<DateTime> calendarDays(DateTime month) {
  final first = firstOfMonth(month);
  final last = DateTime(first.year, first.month + 1, 0);
  final start = mondayOf(first);
  final end = addDays(mondayOf(last), 6);
  return [for (var d = start; !d.isAfter(end); d = addDays(d, 1)) d];
}
```
"하루 단위" 섹션 끝에:
```dart
/// 둘 다 있을 때 퇴근이 출근보다 이르면 무효. 자정 넘김은 지원하지 않는다.
bool isValidClockRange(DateTime? clockIn, DateTime? clockOut) {
  if (clockIn == null || clockOut == null) return true;
  return !clockOut.isBefore(clockIn);
}
```
"주간" 섹션 끝에:
```dart
/// 그 주 토·일 실근무 합. 주 40시간 집계에는 안 들어가고 근거 문구("주말 4h 30m 제외")에만 쓴다.
int weekendMinutes(List<WorkRecord> records, DateTime monday, WorkRules rules) {
  final start = dateOnly(monday);
  var sum = 0;
  for (final r in records) {
    final day = dateOnly(r.date);
    if (!isWeekend(day) || mondayOf(day) != start) continue;
    sum += actualMinutes(r, rules) ?? 0;
  }
  return sum;
}
```

새 파일 `lib/domain/rules/navigation_bounds.dart`:
```dart
import 'work_calculator.dart';

/// 주간 탭이 뒤로 갈 수 있는 하한. 첫 기록일이 없거나 미래(미리 찍은 연차)면 이번 주.
DateTime earliestMonday(DateTime? firstRecordDate, DateTime today) {
  final thisMonday = mondayOf(today);
  if (firstRecordDate == null) return thisMonday;
  final firstMonday = mondayOf(firstRecordDate);
  return firstMonday.isBefore(thisMonday) ? firstMonday : thisMonday;
}

/// 월간 탭이 뒤로 갈 수 있는 하한.
DateTime earliestMonth(DateTime? firstRecordDate, DateTime today) {
  final thisMonth = firstOfMonth(today);
  if (firstRecordDate == null) return thisMonth;
  final firstMonth = firstOfMonth(firstRecordDate);
  return firstMonth.isBefore(thisMonth) ? firstMonth : thisMonth;
}
```

- [ ] **Step 4: 통과 확인** — `flutter test test/domain` → PASS

- [ ] **Step 5: 커밋** — `git add lib/domain test/domain && git commit -m "계산 함수: 출퇴근 범위 검증·주말 합·캘린더 날짜·네비게이션 하한"`

---

### Task 3: 첫 기록일 당기기

**Files:**
- Modify: `lib/domain/repository/work_record_repository.dart`, `lib/data/repository/drift_work_record_repository.dart`
- Test: `test/data/drift_work_record_repository_test.dart`

- [ ] **Step 1: 테스트** — 기존 파일의 첫 기록일 group에 추가 (기존 `repo`, `db` 픽스처 사용):

```dart
    test('첫 기록일보다 이른 날짜를 저장하면 당겨진다', () async {
      await repo.save(rec(16, inH: 9, outH: 18));
      await repo.save(rec(14, inH: 9, outH: 18));
      expect(await repo.watchFirstRecordDate().first, d(14));
    });

    test('첫 기록일보다 늦은 날짜는 영향 없다', () async {
      await repo.save(rec(14, inH: 9, outH: 18));
      await repo.save(rec(16, inH: 9, outH: 18));
      expect(await repo.watchFirstRecordDate().first, d(14));
    });
```

- [ ] **Step 2: 실패 확인** — `flutter test test/data/drift_work_record_repository_test.dart` → 첫 테스트 FAIL (16 유지)

- [ ] **Step 3: 구현**

인터페이스 주석:
```dart
  /// date 기준 upsert. 첫 기록일이 비어 있거나 record.date가 더 이르면 record.date로 갱신한다.
  Future<void> save(WorkRecord record);
```
Drift `save`:
```dart
  @override
  Future<void> save(WorkRecord record) => _db.transaction(() async {
        await _db.into(_db.workRecords).insertOnConflictUpdate(_toCompanion(record));
        final first = await (_db.select(_db.settings)..where((s) => s.key.equals(firstRecordDateKey)))
            .getSingleOrNull();
        final current = first == null ? null : parseDateKey(first.value);
        if (current == null || record.date.isBefore(current)) {
          await _db.into(_db.settings).insertOnConflictUpdate(
                SettingsCompanion.insert(key: firstRecordDateKey, value: dateKey(record.date)),
              );
        }
      });
```

- [ ] **Step 4: 통과 확인** — `flutter test test/data` → PASS

- [ ] **Step 5: 커밋** — `git add lib/domain/repository lib/data/repository test/data && git commit -m "첫 기록일: 더 이른 날짜를 저장하면 당긴다"`

---

### Task 4: 오늘 화면 보조 슬롯 + 취소 액션

**Files:**
- Create: `lib/presentation/shared/quiet_text_button.dart`
- Modify: `lib/presentation/today/today_controller.dart`, `today_texts.dart`, `widgets/status_card.dart`, `today_screen.dart`
- Test: `test/presentation/today_controller_test.dart`, `test/presentation/today_view_test.dart`, `test/presentation/today_texts_test.dart`

**Interfaces:**
- Produces: `QuietTextButton({label, onTap})`, `SlotDivider()`, `TodayController.cancelClockIn()`, `cancelClockOut()`, `TodayCallbacks.onCancelClockIn/onCancelClockOut`.

- [ ] **Step 1: 컨트롤러 테스트** — `today_controller_test.dart` `main()` 끝에:

```dart
  test('cancelClockIn → 기록이 지워지고 출근 전, 반차도 풀린다', () async {
    await notifier().clockIn();
    await waitFor((s) => s.phase == TodayPhase.working);
    await notifier().setHalfDay(true);
    await waitFor((s) => s.isHalfDay);
    await notifier().cancelClockIn();
    final s = await waitFor((s) => s.phase == TodayPhase.before);
    expect(s.record, isNull);
    expect(s.isHalfDay, isFalse);
  });

  test('cancelClockOut → 근무 중으로 돌아가고 type은 유지', () async {
    await notifier().clockIn();
    await waitFor((s) => s.phase == TodayPhase.working);
    await notifier().setHalfDay(true);
    await waitFor((s) => s.isHalfDay);
    await notifier().clockOut();
    await waitFor((s) => s.phase == TodayPhase.done);
    await notifier().cancelClockOut();
    final s = await waitFor((s) => s.phase == TodayPhase.working);
    expect(s.clockOut, isNull);
    expect(s.isHalfDay, isTrue);
  });
```

- [ ] **Step 2: 실패 확인** — `flutter test test/presentation/today_controller_test.dart` → 컴파일 에러

- [ ] **Step 3: 컨트롤러 구현** — `today_controller.dart`의 `revert()` 아래:

```dart
  /// 근무 중 → 출근 전. 실수로 찍은 출근을 없던 일로 — 반차 체크도 함께 풀린다 (기록 삭제).
  Future<void> cancelClockIn() async {
    final today = dateOnly(ref.read(clockProvider)());
    await ref.read(workRecordRepositoryProvider).delete(today);
  }

  /// 퇴근 완료 → 근무 중. type은 유지.
  Future<void> cancelClockOut() => _saveToday((r, _) => r.copyWith(clockOut: null));
```

- [ ] **Step 4: 통과 확인** — `flutter test test/presentation/today_controller_test.dart` → PASS

- [ ] **Step 5: 텍스트 버튼·구분선 위젯** — 새 파일 `lib/presentation/shared/quiet_text_button.dart`:

```dart
import 'package:flutter/material.dart';

import '../../ui/app_colors.dart';
import '../../ui/app_sizes.dart';
import '../../ui/app_text_styles.dart';

/// 보조 슬롯의 박스 없는 텍스트 버튼. 13/w500 brand, pressed opacity .55, 세로 44 히트 영역.
class QuietTextButton extends StatefulWidget {
  const QuietTextButton({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<QuietTextButton> createState() => _QuietTextButtonState();
}

class _QuietTextButtonState extends State<QuietTextButton> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: AppSizes.minTapHeight),
        child: Center(
          child: AnimatedOpacity(
            duration: AppDurations.pressedOpacity,
            opacity: _pressed ? AppOpacities.quietPressed : 1,
            child: Padding(
              padding: AppSizes.quietButtonPadding,
              child: Text(widget.label, style: AppTextStyles.quietButton),
            ),
          ),
        ),
      ),
    );
  }
}

/// 보조 슬롯에서 두 항목 사이에 서는 1×11 구분선.
class SlotDivider extends StatelessWidget {
  const SlotDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(width: AppSizes.slotDividerWidth, height: AppSizes.slotDividerHeight, color: AppColors.hairline);
  }
}
```

- [ ] **Step 6: 문구** — `today_texts.dart`에서 `editTime`을 `'시간 수정'`으로, `revertPrefix` 줄 삭제, 추가:
```dart
  static const cancelClockIn = '출근 취소';
  static const cancelClockOut = '퇴근 취소';
```
`today_texts_test.dart`에 `revertPrefix`를 쓰는 테스트가 있으면 지운다.

- [ ] **Step 7: 콜백·슬롯** — `status_card.dart`:

`TodayCallbacks`에 필드 추가 (생성자 `required`도):
```dart
  final VoidCallback onCancelClockIn;
  final VoidCallback onCancelClockOut;
```
`_secondary()`를 통째로 교체:
```dart
  Widget _secondary() {
    switch (state.screenState) {
      case TodayScreenState.beforeWork:
        if (state.isWeekend) return const SizedBox.shrink();
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SoiCheckbox(
              label: TodayTexts.dayOff,
              checked: false,
              onChanged: (_) => callbacks.onDayTypeChanged(WorkType.dayOff),
              shape: SoiCheckShape.round,
            ),
            SizedBox(width: AppSizes.dayTypeGap),
            SoiCheckbox(
              label: TodayTexts.holiday,
              checked: false,
              onChanged: (_) => callbacks.onDayTypeChanged(WorkType.holiday),
              shape: SoiCheckShape.round,
            ),
          ],
        );
      case TodayScreenState.working:
        final cancel = QuietTextButton(label: TodayTexts.cancelClockIn, onTap: callbacks.onCancelClockIn);
        if (state.isWeekend) return cancel;
        return _pair(
          SoiCheckbox(
            label: TodayTexts.halfDay,
            checked: state.isHalfDay,
            onChanged: callbacks.onHalfDayChanged,
            shape: SoiCheckShape.square,
          ),
          cancel,
        );
      case TodayScreenState.done:
        return _pair(
          QuietTextButton(label: TodayTexts.editTime, onTap: callbacks.onEditTime),
          QuietTextButton(label: TodayTexts.cancelClockOut, onTap: callbacks.onCancelClockOut),
        );
      case TodayScreenState.dayType:
        return QuietTextButton(label: TodayTexts.revert, onTap: callbacks.onRevert);
    }
  }

  Widget _pair(Widget left, Widget right) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          left,
          SizedBox(width: AppSizes.slotItemGap),
          const SlotDivider(),
          SizedBox(width: AppSizes.slotItemGap),
          right,
        ],
      );
```
import 추가: `import '../../shared/quiet_text_button.dart';`. 이제 안 쓰는 `AppTextStyles`/`GestureDetector` import는 정리.
클래스 주석의 "38·위 간격 12"를 "40·위 간격 10"으로 고친다.

- [ ] **Step 8: 화면 연결** — `today_screen.dart`의 `TodayCallbacks(...)`에 `onCancelClockIn: controller.cancelClockIn, onCancelClockOut: controller.cancelClockOut,` 추가. `today_view_test.dart`의 `noop()`에도 두 콜백 추가 (`() {}`).

- [ ] **Step 9: 위젯 테스트 보강** — `today_view_test.dart` `main()` 끝에:
```dart
  testWidgets('근무 중 슬롯에 반차 체크와 출근 취소, 퇴근 완료에 시간 수정과 퇴근 취소', (tester) async {
    await pumpView(tester, fixtures['근무 중']!);
    expect(find.text('오늘은 반차'), findsOneWidget);
    expect(find.text('출근 취소'), findsOneWidget);
    await pumpView(tester, fixtures['퇴근 완료']!);
    expect(find.text('시간 수정'), findsOneWidget);
    expect(find.text('퇴근 취소'), findsOneWidget);
    await pumpView(tester, fixtures['연차']!);
    expect(find.text('되돌리기'), findsOneWidget);
    expect(find.text('기록하려면'), findsNothing);
  });
```

- [ ] **Step 10: 전체 테스트** — `flutter test` → PASS (버튼 Y 불변 테스트 포함). `flutter analyze` 클린.

- [ ] **Step 11: 커밋** — `git add -A lib test && git commit -m "오늘 화면: 보조 슬롯 40, 출근 취소·퇴근 취소·시간 수정 텍스트 버튼"`

---

### Task 5: RecordDraft + RecordEditController

**Files:**
- Create: `lib/presentation/record_edit/record_draft.dart`, `record_edit_texts.dart`, `record_edit_controller.dart`
- Test: `test/presentation/record_draft_test.dart`, `test/presentation/record_edit_controller_test.dart`

**Interfaces:**
- Produces:
  - `enum EditingRow { clockIn, clockOut }`
  - `class RecordDraft { date, today, type, clockIn, clockOut, editing, existing; fromRecord(...); isWeekend; isFuture; showsTypeChips; showsTimeRows; isValid; toRecord(); isEmptyNormal; withType(WorkType?); toggleEditing(EditingRow); withTime(EditingRow, int hour, int minute); timeOf(EditingRow); }`
  - `enum CalcKind { value, note, sum }`, `class CalcLine { label, value, kind }`, `List<CalcLine> calcLines(RecordDraft, WorkRules)` (in `record_edit_texts.dart`)
  - `RecordEditController.save(RecordDraft)`, `.delete(DateTime)`

- [ ] **Step 1: 초안 테스트** — 새 파일 `test/presentation/record_draft_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/domain/model/work_type.dart';
import 'package:soi_duty/domain/rules/work_rules.dart';
import 'package:soi_duty/presentation/record_edit/record_draft.dart';
import 'package:soi_duty/presentation/record_edit/record_edit_texts.dart';

import '../helpers/records.dart';

void main() {
  const rules = WorkRules();
  final today = d(16);

  test('기록에서 초안: 값과 existing', () {
    final draft = RecordDraft.fromRecord(date: d(14), today: today, record: rec(14, inH: 9, outH: 18));
    expect(draft.clockIn, d(14, 9));
    expect(draft.existing, isTrue);
    expect(draft.editing, isNull);
  });

  test('기록 없으면 normal, 시각 null, existing false', () {
    final draft = RecordDraft.fromRecord(date: d(14), today: today, record: null);
    expect(draft.type, WorkType.normal);
    expect(draft.clockIn, isNull);
    expect(draft.existing, isFalse);
  });

  test('주말은 유형 칩 없음', () {
    expect(RecordDraft.fromRecord(date: d(19), today: today, record: null).showsTypeChips, isFalse);
    expect(RecordDraft.fromRecord(date: d(14), today: today, record: null).showsTypeChips, isTrue);
  });

  test('미래·연차·공휴일은 시각 행 없음', () {
    final future = RecordDraft.fromRecord(date: d(23), today: today, record: null);
    expect(future.isFuture, isTrue);
    expect(future.showsTimeRows, isFalse);
    final off = RecordDraft.fromRecord(date: d(14), today: today, record: null).withType(WorkType.dayOff);
    expect(off.showsTimeRows, isFalse);
    expect(RecordDraft.fromRecord(date: d(14), today: today, record: null).showsTimeRows, isTrue);
  });

  test('연차로 저장하면 시각이 비워진다', () {
    final draft = RecordDraft.fromRecord(date: d(14), today: today, record: rec(14, inH: 9, outH: 18))
        .withType(WorkType.dayOff);
    final r = draft.toRecord();
    expect(r.type, WorkType.dayOff);
    expect(r.clockIn, isNull);
    expect(r.clockOut, isNull);
  });

  test('미래 날짜는 유형이 있어도 시각이 비워진다', () {
    final draft = RecordDraft.fromRecord(date: d(23), today: today, record: rec(23, inH: 9, outH: 18))
        .withType(WorkType.halfDay);
    expect(draft.toRecord().clockIn, isNull);
  });

  test('withType(null)은 normal, 같은 유형 재선택은 호출부가 null로 보낸다', () {
    final draft = RecordDraft.fromRecord(date: d(14), today: today, record: null).withType(WorkType.halfDay);
    expect(draft.withType(null).type, WorkType.normal);
  });

  test('휠을 열면 null이던 값이 00:00으로 채워지고, 다시 탭하면 접힌다', () {
    var draft = RecordDraft.fromRecord(date: d(14), today: today, record: null);
    draft = draft.toggleEditing(EditingRow.clockIn);
    expect(draft.editing, EditingRow.clockIn);
    expect(draft.clockIn, d(14, 0, 0));
    draft = draft.toggleEditing(EditingRow.clockIn);
    expect(draft.editing, isNull);
    expect(draft.clockIn, d(14, 0, 0));
  });

  test('withTime은 날짜를 유지하고 시분만 바꾼다', () {
    final draft = RecordDraft.fromRecord(date: d(14), today: today, record: null).withTime(EditingRow.clockOut, 18, 5);
    expect(draft.clockOut, d(14, 18, 5));
  });

  test('퇴근 < 출근이면 무효', () {
    final draft = RecordDraft.fromRecord(date: d(14), today: today, record: null)
        .withTime(EditingRow.clockIn, 22, 0)
        .withTime(EditingRow.clockOut, 2, 0);
    expect(draft.isValid, isFalse);
  });

  test('빈 normal 판정', () {
    final empty = RecordDraft.fromRecord(date: d(14), today: today, record: null);
    expect(empty.isEmptyNormal, isTrue);
    expect(empty.withType(WorkType.holiday).isEmptyNormal, isFalse);
    expect(empty.withTime(EditingRow.clockIn, 9, 0).isEmptyNormal, isFalse);
    // 미래 반차 해제 → 시각 없는 normal → 빈 기록
    final future = RecordDraft.fromRecord(date: d(23), today: today, record: rec(23, type: WorkType.halfDay));
    expect(future.withType(null).isEmptyNormal, isTrue);
  });

  group('calcLines', () {
    test('평일 일반: 근무·점심·기준·기준 대비', () {
      final draft = RecordDraft.fromRecord(date: d(14), today: today, record: rec(14, inH: 9, outH: 18, outM: 20));
      final lines = calcLines(draft, rules);
      expect(lines.map((l) => l.label), ['근무', '점심 공제', '기준', '기준 대비']);
      expect(lines.map((l) => l.value), ['8h 20m', '1h', '8h', '+20m']);
      expect(lines.last.kind, CalcKind.sum);
    });
    test('반차: 점심 없음, 기준 4h', () {
      final draft = RecordDraft.fromRecord(date: d(14), today: today, record: rec(14, inH: 13, outH: 18, type: WorkType.halfDay));
      final values = calcLines(draft, rules).map((l) => l.value).toList();
      expect(values, ['5h', '없음 (반차)', '4h', '+1h']);
    });
    test('주말: 근무·점심 두 줄', () {
      final draft = RecordDraft.fromRecord(date: d(19), today: today, record: rec(19, inH: 10, outH: 14, outM: 30));
      final lines = calcLines(draft, rules);
      expect(lines.map((l) => l.label), ['근무', '점심 공제']);
      expect(lines.map((l) => l.value), ['4h 30m', '없음']);
    });
    test('시각이 비면 근무·기준 대비는 —', () {
      final draft = RecordDraft.fromRecord(date: d(14), today: today, record: null);
      final values = calcLines(draft, rules).map((l) => l.value).toList();
      expect(values, ['—', '1h', '8h', '—']);
    });
  });
}
```

- [ ] **Step 2: 실패 확인** — `flutter test test/presentation/record_draft_test.dart` → 컴파일 에러

- [ ] **Step 3: RecordDraft** — 새 파일 `lib/presentation/record_edit/record_draft.dart` (Flutter import 없음):

```dart
import '../../domain/model/work_record.dart';
import '../../domain/model/work_type.dart';
import '../../domain/rules/work_calculator.dart';

enum EditingRow { clockIn, clockOut }

/// 시간 수정 시트가 저장 전까지 들고 있는 초안. 불변, 순수 Dart.
class RecordDraft {
  const RecordDraft({
    required this.date,
    required this.today,
    required this.existing,
    this.type = WorkType.normal,
    this.clockIn,
    this.clockOut,
    this.editing,
  });

  factory RecordDraft.fromRecord({required DateTime date, required DateTime today, required WorkRecord? record}) =>
      RecordDraft(
        date: dateOnly(date),
        today: dateOnly(today),
        existing: record != null,
        type: record?.type ?? WorkType.normal,
        clockIn: record?.clockIn,
        clockOut: record?.clockOut,
      );

  final DateTime date;
  final DateTime today;
  /// 기존 기록이 있었는지 — "이 날 기록 지우기" 노출 여부
  final bool existing;
  final WorkType type;
  final DateTime? clockIn;
  final DateTime? clockOut;
  /// 휠이 펼쳐진 행
  final EditingRow? editing;

  bool get isWeekend => calcIsWeekend(date);
  bool get isFuture => date.isAfter(today);
  bool get isOff => type == WorkType.dayOff || type == WorkType.holiday;

  bool get showsTypeChips => !isWeekend;
  bool get showsTimeRows => !isFuture && !isOff;
  bool get isValid => isValidClockRange(clockIn, clockOut);

  DateTime? timeOf(EditingRow row) => row == EditingRow.clockIn ? clockIn : clockOut;

  /// 저장할 기록. 연차·공휴일·미래는 시각을 비운다.
  WorkRecord toRecord() => WorkRecord(
        date: date,
        type: type,
        clockIn: showsTimeRows ? clockIn : null,
        clockOut: showsTimeRows ? clockOut : null,
      );

  /// 시각 둘 다 없는 normal — 저장 대신 삭제한다.
  bool get isEmptyNormal {
    final r = toRecord();
    return r.type == WorkType.normal && r.clockIn == null && r.clockOut == null;
  }

  RecordDraft withType(WorkType? next) => _copy(type: next ?? WorkType.normal, editing: _Keep.editing);

  /// 행 탭. 같은 행이면 접고, 다른 행이면 편다. 펼 때 값이 없으면 00:00.
  RecordDraft toggleEditing(EditingRow row) {
    if (editing == row) return _copy(editing: null);
    final current = timeOf(row) ?? DateTime(date.year, date.month, date.day);
    return _copy(
      editing: row,
      clockIn: row == EditingRow.clockIn ? current : _Keep.time,
      clockOut: row == EditingRow.clockOut ? current : _Keep.time,
    );
  }

  RecordDraft withTime(EditingRow row, int hour, int minute) {
    final t = DateTime(date.year, date.month, date.day, hour, minute);
    return _copy(
      clockIn: row == EditingRow.clockIn ? t : _Keep.time,
      clockOut: row == EditingRow.clockOut ? t : _Keep.time,
      editing: _Keep.editing,
    );
  }

  RecordDraft _copy({WorkType? type, Object? clockIn = _Keep.time, Object? clockOut = _Keep.time, Object? editing}) =>
      RecordDraft(
        date: date,
        today: today,
        existing: existing,
        type: type ?? this.type,
        clockIn: identical(clockIn, _Keep.time) ? this.clockIn : clockIn as DateTime?,
        clockOut: identical(clockOut, _Keep.time) ? this.clockOut : clockOut as DateTime?,
        editing: identical(editing, _Keep.editing) ? this.editing : editing as EditingRow?,
      );
}

/// nullable 필드의 copyWith 센티널.
enum _Keep { time, editing }
```
(`work_calculator.dart`의 `isWeekend`와 getter 이름이 겹치므로 import 시 `show`/`as`를 쓰지 말고 파일 상단에 `import '../../domain/rules/work_calculator.dart' as calc;`로 바꾸고 `calc.isWeekend(date)`, `calc.dateOnly`, `calc.isValidClockRange`로 호출한다. 위 코드의 `calcIsWeekend`는 `calc.isWeekend`로 읽을 것.)

- [ ] **Step 4: 문구·계산 내역** — 새 파일 `lib/presentation/record_edit/record_edit_texts.dart`:

```dart
import '../../core/presentation/format/date_format.dart';
import '../../core/presentation/format/time_format.dart';
import '../../domain/model/work_type.dart';
import '../../domain/rules/work_calculator.dart';
import '../../domain/rules/work_rules.dart';
import 'record_draft.dart';

enum CalcKind { value, note, sum }

class CalcLine {
  const CalcLine(this.label, this.value, this.kind);
  final String label;
  final String value;
  final CalcKind kind;
}

abstract final class RecordEditTexts {
  static const weekendNote = '주말 근무는 주 40시간에 포함되지 않아요';
  static const clockIn = '출근';
  static const clockOut = '퇴근';
  static const clockInTitle = '출근 시각';
  static const clockOutTitle = '퇴근 시각';
  static const empty = '--:--';
  static const invalidRange = '퇴근이 출근보다 빨라요';
  static const cancel = '취소';
  static const save = '저장';
  static const deleteLink = '이 날 기록 지우기';
  static const deleteTitle = '이 날 기록을 지울까요?';
  static const deleteMessage = '출퇴근 시각과 유형이 모두 사라져요.';
  static const deleteConfirm = '지우기';
  static const dash = '—';

  static String title(RecordDraft d) => formatDateTitle(d.date);

  static String chipLabel(WorkType t) => switch (t) {
        WorkType.halfDay => '반차',
        WorkType.dayOff => '연차',
        WorkType.holiday => '공휴일',
        WorkType.normal => '',
      };

  static String time(DateTime? t) => t == null ? empty : formatClock(t);

  static String wheelTitle(EditingRow row) => row == EditingRow.clockIn ? clockInTitle : clockOutTitle;
}

/// 계산 내역. 주말은 근무·점심 공제 두 줄.
List<CalcLine> calcLines(RecordDraft d, WorkRules rules) {
  final record = d.toRecord();
  final actual = actualMinutes(record, rules);
  final lunch = d.isWeekend
      ? '없음'
      : d.type == WorkType.halfDay
          ? '없음 (반차)'
          : formatHm(rules.lunchBreakMinutes);
  final lines = [
    CalcLine('근무', actual == null ? RecordEditTexts.dash : formatHm(actual), CalcKind.value),
    CalcLine('점심 공제', lunch, CalcKind.note),
  ];
  if (d.isWeekend) return lines;
  final delta = deltaMinutes(record, rules);
  return [
    ...lines,
    CalcLine('기준', formatHm(standardMinutes(d.type, rules)), CalcKind.note),
    CalcLine('기준 대비', delta == null ? RecordEditTexts.dash : formatSignedHm(delta), CalcKind.sum),
  ];
}
```

- [ ] **Step 5: 통과 확인** — `flutter test test/presentation/record_draft_test.dart` → PASS

- [ ] **Step 6: 컨트롤러 테스트** — 새 파일 `test/presentation/record_edit_controller_test.dart`:

```dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/core/providers/database_providers.dart';
import 'package:soi_duty/data/database/app_database.dart';
import 'package:soi_duty/domain/model/work_type.dart';
import 'package:soi_duty/presentation/record_edit/record_draft.dart';
import 'package:soi_duty/presentation/record_edit/record_edit_controller.dart';

import '../helpers/records.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer.test(overrides: [appDatabaseProvider.overrideWithValue(db)]);
  });
  tearDown(() => db.close());

  RecordEditController controller() => container.read(recordEditControllerProvider.notifier);
  Future<List> all() => container.read(workRecordRepositoryProvider).watchAll().first;

  test('save는 기록을 저장한다', () async {
    final draft = RecordDraft.fromRecord(date: d(14), today: d(16), record: null).withTime(EditingRow.clockIn, 9, 0);
    await controller().save(draft);
    expect((await all()).length, 1);
  });

  test('빈 normal은 저장 대신 삭제한다', () async {
    await container.read(workRecordRepositoryProvider).save(rec(23, type: WorkType.halfDay));
    final draft = RecordDraft.fromRecord(date: d(23), today: d(16), record: rec(23, type: WorkType.halfDay)).withType(null);
    await controller().save(draft);
    expect(await all(), isEmpty);
  });

  test('delete', () async {
    await container.read(workRecordRepositoryProvider).save(rec(14, inH: 9, outH: 18));
    await controller().delete(d(14));
    expect(await all(), isEmpty);
  });
}
```

- [ ] **Step 7: 컨트롤러 구현** — 새 파일 `lib/presentation/record_edit/record_edit_controller.dart`:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/database_providers.dart';
import 'record_draft.dart';

part 'record_edit_controller.g.dart';

/// 시트의 저장·삭제. 저장되면 allRecords 스트림이 돌아 모든 화면이 갱신된다.
@riverpod
class RecordEditController extends _$RecordEditController {
  @override
  void build() {}

  Future<void> save(RecordDraft draft) {
    final repo = ref.read(workRecordRepositoryProvider);
    return draft.isEmptyNormal ? repo.delete(draft.date) : repo.save(draft.toRecord());
  }

  Future<void> delete(DateTime date) => ref.read(workRecordRepositoryProvider).delete(date);
}
```
코드젠: `dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 8: 통과 확인** — `flutter test test/presentation` → PASS

- [ ] **Step 9: 커밋** — `git add lib/presentation/record_edit test/presentation && git commit -m "시간 수정 초안(RecordDraft)과 저장 컨트롤러"`

---

### Task 6: 시간 수정 시트 위젯

**Files:**
- Create: `lib/presentation/shared/confirm_dialog.dart`, `lib/presentation/record_edit/widgets/type_chips.dart`, `time_row.dart`, `time_wheel.dart`, `calc_rows.dart`, `lib/presentation/record_edit/record_edit_sheet.dart`
- Test: `test/presentation/record_edit_sheet_test.dart`

**Interfaces:**
- Produces: `Future<void> showRecordEditSheet(BuildContext context, DateTime date)`, `RecordEditSheet({date})`, `Future<bool> showConfirmDialog(context, {title, message, confirmLabel})`.

- [ ] **Step 1: 위젯 테스트** — 새 파일 `test/presentation/record_edit_sheet_test.dart`:

```dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/core/presentation/size_config.dart';
import 'package:soi_duty/core/providers/clock_provider.dart';
import 'package:soi_duty/core/providers/database_providers.dart';
import 'package:soi_duty/data/database/app_database.dart';
import 'package:soi_duty/domain/model/work_type.dart';
import 'package:soi_duty/presentation/record_edit/record_edit_sheet.dart';
import 'package:soi_duty/presentation/record_edit/widgets/time_wheel.dart';
import 'package:soi_duty/ui/app_theme.dart';

import '../helpers/records.dart';

Future<void> loadPretendard() async {
  final loader = FontLoader('Pretendard')
    ..addFont(rootBundle.load('assets/fonts/Pretendard-Regular.otf'))
    ..addFont(rootBundle.load('assets/fonts/Pretendard-Medium.otf'))
    ..addFont(rootBundle.load('assets/fonts/Pretendard-SemiBold.otf'));
  await loader.load();
}

void main() {
  late AppDatabase db;
  final now = d(16, 12);

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    await loadPretendard();
  });
  setUp(() {
    SizeConfig.init(402);
    db = AppDatabase(NativeDatabase.memory());
  });
  tearDown(() => db.close());

  Future<void> pumpSheet(WidgetTester tester, DateTime date) async {
    tester.view.physicalSize = const Size(402 * 3, 874 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(() => now),
        nowProvider.overrideWith((ref) => Stream.value(now)),
      ],
      child: MaterialApp(theme: AppTheme.light, home: Scaffold(body: RecordEditSheet(date: date))),
    ));
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('연차를 고르면 출근·퇴근 행이 사라진다', (tester) async {
    await pumpSheet(tester, d(14));
    expect(find.text('출근'), findsOneWidget);
    await tester.tap(find.text('연차'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('출근'), findsNothing);
    expect(find.text('저장'), findsOneWidget);
  });

  testWidgets('주말은 유형 칩이 없고 안내가 뜬다', (tester) async {
    await pumpSheet(tester, d(19));
    expect(find.text('반차'), findsNothing);
    expect(find.text('주말 근무는 주 40시간에 포함되지 않아요'), findsOneWidget);
  });

  testWidgets('미래 날짜는 시각 행이 없다', (tester) async {
    await pumpSheet(tester, d(23));
    expect(find.text('출근'), findsNothing);
    expect(find.text('연차'), findsOneWidget);
  });

  testWidgets('행을 탭하면 휠이 열리고 값이 00:00이 된다', (tester) async {
    await pumpSheet(tester, d(14));
    expect(find.text('--:--'), findsNWidgets(2));
    await tester.tap(find.text('출근'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(TimeWheel), findsOneWidget);
    expect(find.text('00:00'), findsOneWidget);
  });

  testWidgets('퇴근 < 출근이면 저장이 비활성이고 안내가 뜬다', (tester) async {
    await db.into(db.workRecords).insert(WorkRecordsCompanion.insert(
          date: '2026-09-14',
          clockIn: Value(d(14, 22)),
          clockOut: Value(d(14, 2)),
          type: WorkType.normal,
        ));
    await pumpSheet(tester, d(14));
    expect(find.text('퇴근이 출근보다 빨라요'), findsOneWidget);
    expect(find.text('이 날 기록 지우기'), findsOneWidget);
  });
}
```

- [ ] **Step 2: 실패 확인** — `flutter test test/presentation/record_edit_sheet_test.dart` → 컴파일 에러

- [ ] **Step 3: 확인 다이얼로그** — 새 파일 `lib/presentation/shared/confirm_dialog.dart`:

```dart
import 'package:flutter/material.dart';

import '../../ui/app_colors.dart';
import '../../ui/app_decorations.dart';
import '../../ui/app_sizes.dart';
import '../../ui/app_text_styles.dart';

/// 앱 토큰으로 만든 확인 다이얼로그. true면 확인.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = '취소',
}) async {
  final result = await showDialog<bool>(
    context: context,
    useRootNavigator: true,
    barrierColor: AppColors.scrim,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: AppSizes.screenHPadding),
      child: Container(
        padding: AppSizes.dialogPadding,
        decoration: AppDecorations.card,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.dialogTitle),
            SizedBox(height: AppSizes.dialogMessageTop),
            Text(message, style: AppTextStyles.dialogMessage),
            SizedBox(height: AppSizes.dialogButtonsTop),
            Row(
              children: [
                Expanded(
                  child: SheetButton(label: cancelLabel, primary: false, onTap: () => Navigator.of(context, rootNavigator: true).pop(false)),
                ),
                SizedBox(width: AppSizes.sheetButtonGap),
                Expanded(
                  child: SheetButton(label: confirmLabel, primary: true, onTap: () => Navigator.of(context, rootNavigator: true).pop(true)),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}

/// 시트·다이얼로그 공용 버튼. primary(brand) / secondary(chipNeutral). onTap null이면 비활성.
class SheetButton extends StatefulWidget {
  const SheetButton({super.key, required this.label, required this.primary, required this.onTap, this.height});

  final String label;
  final bool primary;
  final VoidCallback? onTap;
  final double? height;

  @override
  State<SheetButton> createState() => _SheetButtonState();
}

class _SheetButtonState extends State<SheetButton> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final Color color;
    final TextStyle style;
    if (!enabled) {
      color = AppColors.buttonDisabled;
      style = AppTextStyles.sheetButtonSecondary;
    } else if (widget.primary) {
      color = _pressed ? AppColors.brandPressed : AppColors.brand;
      style = AppTextStyles.sheetButtonPrimary;
    } else {
      color = _pressed ? AppColors.listRowPressed : AppColors.chipNeutral;
      style = AppTextStyles.sheetButtonSecondary;
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: AppDurations.buttonColor,
        height: widget.height ?? AppSizes.sheetButton,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(AppSizes.sheetButtonRadius)),
        child: Text(widget.label, style: style),
      ),
    );
  }
}
```
(다이얼로그 버튼 높이는 `SheetButton(height: AppSizes.dialogButton)`로 넘긴다 — 위 두 곳에 `height: AppSizes.dialogButton` 추가.)

- [ ] **Step 4: 유형 칩** — 새 파일 `lib/presentation/record_edit/widgets/type_chips.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../domain/model/work_type.dart';
import '../../../ui/app_colors.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';
import '../record_edit_texts.dart';

/// 반차 / 연차 / 공휴일 3열. 상호배타, 같은 칩 재탭이면 null.
class TypeChips extends StatelessWidget {
  const TypeChips({super.key, required this.selected, required this.onChanged});

  final WorkType selected;
  final ValueChanged<WorkType?> onChanged;

  static const _types = [WorkType.halfDay, WorkType.dayOff, WorkType.holiday];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < _types.length; i++) ...[
          if (i > 0) SizedBox(width: AppSizes.chipGap),
          Expanded(
            child: _Chip(
              type: _types[i],
              selected: selected == _types[i],
              onTap: () => onChanged(selected == _types[i] ? null : _types[i]),
            ),
          ),
        ],
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.type, required this.selected, required this.onTap});

  final WorkType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (type) {
      WorkType.halfDay => (AppColors.halfDayBackground, AppColors.halfDayText),
      WorkType.dayOff => (AppColors.dayOffBackground, AppColors.dayOffText),
      WorkType.holiday => (AppColors.holidayBackground, AppColors.holidayText),
      WorkType.normal => (AppColors.chipNeutral, AppColors.subtle),
    };
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: AppSizes.minTapHeight),
        child: Center(
          child: AnimatedContainer(
            duration: AppDurations.checkbox,
            width: double.infinity,
            padding: AppSizes.chipPadding,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? bg : AppColors.chipNeutral,
              borderRadius: BorderRadius.circular(AppSizes.chipRadius),
            ),
            child: Text(RecordEditTexts.chipLabel(type), style: AppTextStyles.chip(selected: selected, selectedColor: fg)),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: 시각 행** — 새 파일 `lib/presentation/record_edit/widgets/time_row.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../ui/app_colors.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';

/// 출근/퇴근 행. 행 전체가 탭 영역. 선택되면 배경 cardInner, 값 brand w600.
class TimeRow extends StatelessWidget {
  const TimeRow({super.key, required this.label, required this.value, required this.selected, required this.onTap});

  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.checkbox,
        padding: AppSizes.timeRowPadding,
        decoration: BoxDecoration(
          color: selected ? AppColors.cardInner : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.timeRowRadius),
          border: Border(bottom: BorderSide(color: AppColors.rowDivider, width: AppSizes.rowDivider)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.timeLabel),
            Text(value, style: AppTextStyles.timeValue(selected: selected)),
          ],
        ),
      ),
    );
  }
}
```
주의: `BoxDecoration`에 `borderRadius`와 비균일 `Border`를 같이 쓰면 assert가 난다. 구분선은 `Border`가 아니라 행 아래에 `Container(height: AppSizes.rowDivider, color: AppColors.rowDivider)`를 별도로 두는 `Column`으로 만든다 — 위 코드에서 `border:` 줄을 빼고, `AnimatedContainer`를 `Column(children: [AnimatedContainer(...), Container(height:..., color:...)])`로 감싼다.

- [ ] **Step 6: 시각 휠** — 새 파일 `lib/presentation/record_edit/widgets/time_wheel.dart`:

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../ui/app_colors.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';

/// 시(0–23) · 분(0–59) 휠. 높이 176, 항목 44, 가운데 흰 띠, 위아래 페이드.
class TimeWheel extends StatefulWidget {
  const TimeWheel({super.key, required this.hour, required this.minute, required this.onChanged});

  final int hour;
  final int minute;
  final void Function(int hour, int minute) onChanged;

  @override
  State<TimeWheel> createState() => _TimeWheelState();
}

class _TimeWheelState extends State<TimeWheel> {
  late int _hour = widget.hour;
  late int _minute = widget.minute;
  late final _hourController = FixedExtentScrollController(initialItem: widget.hour);
  late final _minuteController = FixedExtentScrollController(initialItem: widget.minute);

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.wheelHeight,
      child: Stack(
        children: [
          Center(
            child: Container(
              height: AppSizes.wheelItem,
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(AppSizes.wheelBandRadius)),
            ),
          ),
          ShaderMask(
            shaderCallback: (rect) => LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: const [Colors.transparent, Colors.black, Colors.black, Colors.transparent],
              stops: const [0, 0.32, 0.68, 1],
            ).createShader(rect),
            blendMode: BlendMode.dstIn,
            child: Row(
              children: [
                Expanded(child: _column(24, _hour, _hourController, (v) => setState(() => _hour = v))),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSizes.wheelColonPadding),
                  child: Text(':', style: AppTextStyles.wheelColon),
                ),
                Expanded(child: _column(60, _minute, _minuteController, (v) => setState(() => _minute = v))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _column(int count, int selected, FixedExtentScrollController controller, ValueChanged<int> onSelected) {
    return CupertinoPicker(
      scrollController: controller,
      itemExtent: AppSizes.wheelItem,
      useMagnifier: false,
      squeeze: 1,
      diameterRatio: 100,
      selectionOverlay: const SizedBox.shrink(),
      onSelectedItemChanged: (i) {
        onSelected(i);
        widget.onChanged(_hour, _minute);
      },
      children: [
        for (var i = 0; i < count; i++)
          Center(
            child: AnimatedDefaultTextStyle(
              duration: AppDurations.wheelItem,
              style: i == selected ? AppTextStyles.wheelSelected : AppTextStyles.wheelItem,
              child: Text(i.toString().padLeft(2, '0')),
            ),
          ),
      ],
    );
  }
}
```
`onSelectedItemChanged` 안에서 `onSelected(i)`가 setState로 `_hour`를 바꾼 뒤 `widget.onChanged(_hour, _minute)`를 호출하므로 최신값이 올라간다.

- [ ] **Step 7: 계산 내역** — 새 파일 `lib/presentation/record_edit/widgets/calc_rows.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../ui/app_text_styles.dart';
import '../record_edit_texts.dart';

class CalcRows extends StatelessWidget {
  const CalcRows({super.key, required this.lines});

  final List<CalcLine> lines;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final l in lines)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l.label, style: l.kind == CalcKind.note ? AppTextStyles.calcNote : AppTextStyles.calcRow),
              Text(
                l.value,
                style: switch (l.kind) {
                  CalcKind.value => AppTextStyles.calcValue,
                  CalcKind.note => AppTextStyles.calcNote,
                  CalcKind.sum => AppTextStyles.calcSum,
                },
              ),
            ],
          ),
      ],
    );
  }
}
```

- [ ] **Step 8: 시트** — 새 파일 `lib/presentation/record_edit/record_edit_sheet.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/clock_provider.dart';
import '../../core/providers/database_providers.dart';
import '../../domain/rules/work_calculator.dart';
import '../../ui/app_colors.dart';
import '../../ui/app_sizes.dart';
import '../../ui/app_text_styles.dart';
import '../shared/confirm_dialog.dart';
import 'record_draft.dart';
import 'record_edit_controller.dart';
import 'record_edit_texts.dart';
import 'widgets/calc_rows.dart';
import 'widgets/time_row.dart';
import 'widgets/time_wheel.dart';
import 'widgets/type_chips.dart';

/// 네 진입점(오늘 시간 수정 · 누락 리스트 · 주간 행 · 월간 셀)이 공유하는 시트.
Future<void> showRecordEditSheet(BuildContext context, DateTime date) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.scrim,
    sheetAnimationStyle: AnimationStyle(duration: AppDurations.sheetSlide, curve: AppCurves.sheet),
    builder: (_) => RecordEditSheet(date: date),
  );
}

class RecordEditSheet extends ConsumerStatefulWidget {
  const RecordEditSheet({super.key, required this.date});

  final DateTime date;

  @override
  ConsumerState<RecordEditSheet> createState() => _RecordEditSheetState();
}

class _RecordEditSheetState extends ConsumerState<RecordEditSheet> {
  late RecordDraft _draft;

  @override
  void initState() {
    super.initState();
    final today = ref.read(clockProvider)();
    final records = ref.read(allRecordsProvider).value ?? const [];
    _draft = RecordDraft.fromRecord(
      date: widget.date,
      today: today,
      record: recordsByDate(records)[dateOnly(widget.date)],
    );
  }

  void _update(RecordDraft next) => setState(() => _draft = next);

  Future<void> _save() async {
    await ref.read(recordEditControllerProvider.notifier).save(_draft);
    if (mounted) Navigator.of(context, rootNavigator: true).pop();
  }

  Future<void> _delete() async {
    final ok = await showConfirmDialog(
      context,
      title: RecordEditTexts.deleteTitle,
      message: RecordEditTexts.deleteMessage,
      confirmLabel: RecordEditTexts.deleteConfirm,
    );
    if (!ok) return;
    await ref.read(recordEditControllerProvider.notifier).delete(_draft.date);
    if (mounted) Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    final rules = ref.watch(workRulesProvider);
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final editing = _draft.editing;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.sheetRadius)),
        boxShadow: [
          BoxShadow(color: AppColors.sheetShadow, offset: AppSizes.sheetShadowOffset, blurRadius: AppSizes.sheetShadowBlur),
        ],
      ),
      child: SingleChildScrollView(
        padding: AppSizes.sheetPadding.copyWith(bottom: AppSizes.sheetPadding.bottom + bottomInset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: AppSizes.sheetHandleWidth,
                height: AppSizes.sheetHandleHeight,
                margin: EdgeInsets.only(bottom: AppSizes.sheetHandleBottom),
                decoration: BoxDecoration(color: AppColors.hairline, borderRadius: BorderRadius.circular(AppSizes.pill)),
              ),
            ),
            Text(RecordEditTexts.title(_draft), style: AppTextStyles.sheetTitle),
            if (_draft.isWeekend)
              Container(
                margin: AppSizes.sheetNoteMargin,
                padding: AppSizes.sheetNotePadding,
                decoration: BoxDecoration(color: AppColors.chipNeutral, borderRadius: BorderRadius.circular(AppSizes.sheetNoteRadius)),
                child: Text(RecordEditTexts.weekendNote, style: AppTextStyles.sheetNote),
              ),
            if (_draft.showsTypeChips)
              Padding(
                padding: AppSizes.chipsMargin,
                child: TypeChips(selected: _draft.type, onChanged: (t) => _update(_draft.withType(t))),
              ),
            if (_draft.showsTimeRows) ...[
              // 행은 시트 패딩보다 12만큼 바깥으로 나간다 (목업 margin 0 -12).
              Transform.translate(
                offset: Offset.zero,
                child: Padding(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (final row in EditingRow.values)
                        TimeRow(
                          label: row == EditingRow.clockIn ? RecordEditTexts.clockIn : RecordEditTexts.clockOut,
                          value: RecordEditTexts.time(_draft.timeOf(row)),
                          selected: editing == row,
                          onTap: () => _update(_draft.toggleEditing(row)),
                        ),
                    ],
                  ),
                ),
              ),
              if (editing != null)
                Container(
                  margin: EdgeInsets.only(top: AppSizes.wheelBoxTop),
                  padding: AppSizes.wheelBoxPadding,
                  decoration: BoxDecoration(color: AppColors.cardInner, borderRadius: BorderRadius.circular(AppSizes.wheelBoxRadius)),
                  child: Column(
                    children: [
                      Text(RecordEditTexts.wheelTitle(editing), style: AppTextStyles.wheelTitle),
                      SizedBox(height: AppSizes.wheelTitleBottom),
                      TimeWheel(
                        key: ValueKey(editing),
                        hour: _draft.timeOf(editing)!.hour,
                        minute: _draft.timeOf(editing)!.minute,
                        onChanged: (h, m) => _update(_draft.withTime(editing, h, m)),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: EdgeInsets.only(top: AppSizes.calcTop),
                child: _draft.isValid
                    ? CalcRows(lines: calcLines(_draft, rules))
                    : Text(RecordEditTexts.invalidRange, style: AppTextStyles.calcError),
              ),
            ],
            SizedBox(height: AppSizes.sheetButtonsTop),
            Row(
              children: [
                Expanded(
                  child: SheetButton(
                    label: RecordEditTexts.cancel,
                    primary: false,
                    onTap: () => Navigator.of(context, rootNavigator: true).pop(),
                  ),
                ),
                SizedBox(width: AppSizes.sheetButtonGap),
                Expanded(
                  child: SheetButton(label: RecordEditTexts.save, primary: true, onTap: _draft.isValid ? _save : null),
                ),
              ],
            ),
            if (_draft.existing)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _delete,
                child: Padding(
                  padding: EdgeInsets.only(top: AppSizes.deleteLinkTop),
                  child: Text(RecordEditTexts.deleteLink, style: AppTextStyles.deleteLink, textAlign: TextAlign.center),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```
시각 행의 −12 outdent: `Transform.translate(Offset.zero)`와 `Padding(zero)` 자리 표시는 지우고, 시트 전체 패딩을 좌우 `20 − 12 = 8`로 두는 대신 **행 컨테이너를 `Padding(padding: EdgeInsets.symmetric(horizontal: -12))`로 만들 수 없으므로** 다음 방식으로 한다: `SingleChildScrollView`의 padding에서 좌우를 빼고(`AppSizes.sheetPadding.copyWith(left: 0, right: 0)`), 시각 행을 제외한 모든 자식을 `Padding(padding: EdgeInsets.symmetric(horizontal: AppSizes.sheetPadding.left))`로 감싸고, 시각 행 `Column`만 `EdgeInsets.symmetric(horizontal: AppSizes.sheetPadding.left - AppSizes.timeRowOutdent)`로 감싼다. 가독성을 위해 `Widget _inset(Widget child, {double outdent = 0})` 헬퍼를 만든다.

- [ ] **Step 9: 코드젠·테스트** — `dart run build_runner build --delete-conflicting-outputs` (변경 없으면 생략) → `flutter test test/presentation/record_edit_sheet_test.dart` → PASS. `flutter analyze` 클린.

- [ ] **Step 10: 오늘 화면 연결** — `today_screen.dart`의 TODO 두 줄을 교체:
```dart
          onEditTime: () => showRecordEditSheet(context, state.date),
          onUnrecordedTap: (date) => showRecordEditSheet(context, date),
```
import `'../record_edit/record_edit_sheet.dart'`.

- [ ] **Step 11: 커밋** — `git add -A lib test && git commit -m "시간 수정 시트: 유형 칩·시각 행·휠·계산 내역·삭제 확인, 오늘 화면 연결"`

---

### Task 7: 주간 상태·프로바이더

**Files:**
- Create: `lib/presentation/week/week_state.dart`, `week_state_builder.dart`, `selected_week.dart`, `week_provider.dart`, `week_texts.dart`
- Test: `test/presentation/week_state_builder_test.dart`, `test/presentation/week_texts_test.dart`, `test/presentation/selected_week_test.dart`

**Interfaces:**
- Produces: `WeekState`, `WeekDay`, `WeekDayKind`, `buildWeekState({records, firstRecordDate, now, rules, monday})`, `SelectedWeek` (`prev()/next()`), `weekStateProvider`, `WeekTexts`.

- [ ] **Step 1: 빌더 테스트** — 새 파일 `test/presentation/week_state_builder_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/domain/model/work_type.dart';
import 'package:soi_duty/domain/rules/work_rules.dart';
import 'package:soi_duty/presentation/week/week_state.dart';
import 'package:soi_duty/presentation/week/week_state_builder.dart';

import '../helpers/records.dart';

void main() {
  const rules = WorkRules();
  // 오늘 = 9/16(수) 12:00
  WeekState build(List records, {DateTime? monday, DateTime? first, DateTime? now}) => buildWeekState(
        records: records.cast(),
        firstRecordDate: first ?? d(7),
        now: now ?? d(16, 12),
        rules: rules,
        monday: monday ?? d(14),
      );

  WeekDay day(WeekState s, int date) => s.days.firstWhere((x) => x.date.day == date);

  test('7일, 월요일부터, 오늘 표시', () {
    final s = build([]);
    expect(s.days.length, 7);
    expect(s.days.first.date, d(14));
    expect(day(s, 16).isToday, isTrue);
    expect(s.isCurrentWeek, isTrue);
  });

  test('kind 판정', () {
    final s = build([
      rec(14, inH: 9, inM: 5, outH: 18, outM: 36),
      rec(15, type: WorkType.holiday),
      rec(16, inH: 9, inM: 12),
      rec(18, type: WorkType.halfDay),
      rec(19, inH: 10, outH: 14, outM: 30),
    ]);
    expect(day(s, 14).kind, WeekDayKind.recorded);
    expect(day(s, 14).actualMinutes, 511);
    expect(day(s, 14).deltaMinutes, 31);
    expect(day(s, 15).kind, WeekDayKind.off);
    expect(day(s, 16).kind, WeekDayKind.working);
    expect(day(s, 17).kind, WeekDayKind.future);
    expect(day(s, 18).kind, WeekDayKind.future); // 미래 반차 — 배지는 record.type으로
    expect(day(s, 18).record?.type, WorkType.halfDay);
    expect(day(s, 19).kind, WeekDayKind.weekendRecorded);
    expect(day(s, 19).actualMinutes, 270);
    expect(day(s, 20).kind, WeekDayKind.weekendEmpty);
  });

  test('과거 미기록·부분 기록·오늘 출근 전', () {
    final s = build([rec(15, inH: 9)]);
    expect(day(s, 14).kind, WeekDayKind.unrecorded);
    expect(day(s, 15).kind, WeekDayKind.partial);
    expect(day(s, 16).kind, WeekDayKind.beforeWork);
  });

  test('지난 주는 미래 없음, 이동 가능', () {
    final s = build([], monday: d(7));
    expect(s.isCurrentWeek, isFalse);
    expect(s.canGoNext, isTrue);
    expect(s.canGoPrev, isFalse); // 첫 기록일 9/7
    expect(day(s, 11).kind, WeekDayKind.unrecorded);
  });

  test('이번 주는 next 불가, 첫 기록 주보다 뒤면 prev 가능', () {
    final s = build([]);
    expect(s.canGoNext, isFalse);
    expect(s.canGoPrev, isTrue);
  });

  test('주말 합과 주간 요약', () {
    final s = build([rec(14, inH: 9, outH: 18), rec(19, inH: 10, outH: 12)]);
    expect(s.weekendMinutes, 120);
    expect(s.summary.workedMinutes, 480);
  });
}
```

- [ ] **Step 2: 실패 확인** — `flutter test test/presentation/week_state_builder_test.dart` → 컴파일 에러

- [ ] **Step 3: 상태** — 새 파일 `lib/presentation/week/week_state.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/model/work_record.dart';
import '../../domain/rules/week_summary.dart';

part 'week_state.freezed.dart';

enum WeekDayKind {
  recorded,
  working,
  beforeWork,
  unrecorded,
  partial,
  off,
  future,
  weekendRecorded,
  weekendEmpty,
}

@freezed
abstract class WeekDay with _$WeekDay {
  const factory WeekDay({
    required DateTime date,
    WorkRecord? record,
    required WeekDayKind kind,
    int? actualMinutes,
    int? deltaMinutes,
    required bool isToday,
  }) = _WeekDay;
}

@freezed
abstract class WeekState with _$WeekState {
  const factory WeekState({
    required DateTime monday,
    required bool isCurrentWeek,
    required bool canGoPrev,
    required bool canGoNext,
    required WeekSummary summary,
    required int weekendMinutes,
    required List<WeekDay> days,
    DateTime? firstRecordDate,
  }) = _WeekState;
}
```

- [ ] **Step 4: 빌더** — 새 파일 `lib/presentation/week/week_state_builder.dart`:

```dart
import '../../domain/model/work_record.dart';
import '../../domain/model/work_type.dart';
import '../../domain/rules/navigation_bounds.dart';
import '../../domain/rules/work_calculator.dart';
import '../../domain/rules/work_rules.dart';
import 'week_state.dart';

/// (기록 전체, 첫 기록일, 현재 시각, 규칙, 선택한 주) → 주간 화면 상태. 순수 함수.
WeekState buildWeekState({
  required List<WorkRecord> records,
  required DateTime? firstRecordDate,
  required DateTime now,
  required WorkRules rules,
  required DateTime monday,
}) {
  final today = dateOnly(now);
  final start = dateOnly(monday);
  final thisMonday = mondayOf(today);
  final byDate = recordsByDate(records);

  final days = [
    for (var i = 0; i < 7; i++) _day(addDays(start, i), byDate, today, now, rules),
  ];

  return WeekState(
    monday: start,
    isCurrentWeek: start == thisMonday,
    canGoPrev: start.isAfter(earliestMonday(firstRecordDate, today)),
    canGoNext: start.isBefore(thisMonday),
    summary: weekSummary(records: records, monday: start, rules: rules, now: now, firstRecordDate: firstRecordDate),
    weekendMinutes: weekendMinutes(records, start, rules),
    days: days,
    firstRecordDate: firstRecordDate,
  );
}

WeekDay _day(DateTime date, Map<DateTime, WorkRecord> byDate, DateTime today, DateTime now, WorkRules rules) {
  final r = byDate[date];
  final isToday = date == today;
  final hasBoth = r?.clockIn != null && r?.clockOut != null;

  WeekDayKind kind;
  if (isWeekend(date)) {
    kind = hasBoth ? WeekDayKind.weekendRecorded : WeekDayKind.weekendEmpty;
  } else if (r != null && (r.type == WorkType.dayOff || r.type == WorkType.holiday)) {
    kind = WeekDayKind.off;
  } else if (date.isAfter(today)) {
    kind = WeekDayKind.future;
  } else if (hasBoth) {
    kind = WeekDayKind.recorded;
  } else if (isToday) {
    kind = r?.clockIn != null ? WeekDayKind.working : WeekDayKind.beforeWork;
  } else if (r == null || (r.clockIn == null && r.clockOut == null)) {
    kind = WeekDayKind.unrecorded;
  } else {
    kind = WeekDayKind.partial;
  }

  final actual = r == null || !hasBoth ? null : actualMinutes(r, rules);
  return WeekDay(
    date: date,
    record: r,
    kind: kind,
    actualMinutes: actual,
    deltaMinutes: kind == WeekDayKind.recorded ? deltaMinutes(r!, rules) : null,
    isToday: isToday,
  );
}
```

- [ ] **Step 5: 통과 확인** — 코드젠 후 `flutter test test/presentation/week_state_builder_test.dart` → PASS

- [ ] **Step 6: 문구 테스트** — 새 파일 `test/presentation/week_texts_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/domain/model/work_type.dart';
import 'package:soi_duty/domain/rules/work_rules.dart';
import 'package:soi_duty/presentation/week/week_state.dart';
import 'package:soi_duty/presentation/week/week_state_builder.dart';
import 'package:soi_duty/presentation/week/week_texts.dart';

import '../helpers/records.dart';

void main() {
  const rules = WorkRules();
  WeekState build(List records, {DateTime? monday, DateTime? first, DateTime? now}) => buildWeekState(
        records: records.cast(),
        firstRecordDate: first ?? d(7),
        now: now ?? d(16, 12),
        rules: rules,
        monday: monday ?? d(14),
      );

  test('이번 주 근거: 남은 시간 · 반차 차감 · 주말 제외', () {
    final s = build([
      rec(14, inH: 9, outH: 18), // 8h
      rec(15, inH: 13, outH: 18, type: WorkType.halfDay), // 5h
      rec(19, inH: 10, outH: 14, outM: 30),
    ]);
    expect(WeekTexts.summaryLabel(s), '이번 주 누적');
    expect(WeekTexts.summaryValue(s), '13h');
    expect(WeekTexts.summaryGoal(s), '/ 36h');
    expect(WeekTexts.summaryReason(s, rules), '남은 23h · 반차 1회 · 주말 4h 30m 제외');
  });

  test('지난 주 부족·초과·딱 맞음', () {
    final short = build([for (var day = 7; day <= 11; day++) rec(day, inH: 9, outH: 17)], monday: d(7));
    expect(WeekTexts.summaryLabel(short), '주간 누적');
    expect(WeekTexts.summaryReason(short, rules), '5h 부족');
    final over = build([for (var day = 7; day <= 11; day++) rec(day, inH: 9, outH: 19)], monday: d(7));
    expect(WeekTexts.summaryReason(over, rules), '5h 초과');
    final exact = build([for (var day = 7; day <= 11; day++) rec(day, inH: 9, outH: 18)], monday: d(7));
    expect(WeekTexts.summaryReason(exact, rules), '딱 맞음');
  });

  test('이번 주 목표 달성', () {
    final s = build([for (var day = 14; day <= 16; day++) rec(day, inH: 8, outH: 23)], now: d(16, 23, 30));
    expect(WeekTexts.summaryReason(s, rules), startsWith('목표 달성 · +'));
  });

  test('첫 주 예외', () {
    final s = build([rec(16, inH: 9)], first: d(16));
    expect(WeekTexts.summaryLabel(s), '이번 주 기록한 시간');
    expect(WeekTexts.summaryGoal(s), '');
    expect(WeekTexts.summaryReason(s, rules), '9월 16일 수요일부터 기록 · 목표 없음');
  });

  test('행 문구', () {
    final s = build([
      rec(14, inH: 9, inM: 5, outH: 18, outM: 36),
      rec(15, type: WorkType.holiday),
      rec(16, inH: 9, inM: 12),
      rec(19, inH: 10, outH: 14, outM: 30),
    ]);
    WeekDay day(int n) => s.days.firstWhere((x) => x.date.day == n);
    expect(WeekTexts.main(day(14)), '8h 31m');
    expect(WeekTexts.note(day(14)), '09:05 – 18:36');
    expect(WeekTexts.value(day(14)), '+31m');
    expect(WeekTexts.main(day(15)), '—');
    expect(WeekTexts.note(day(15)), '근무 없음');
    expect(WeekTexts.main(day(16)), '근무 중');
    expect(WeekTexts.note(day(16)), '09:12 출근');
    expect(WeekTexts.value(day(16)), '—');
    expect(WeekTexts.main(day(17)), '—');
    expect(WeekTexts.value(day(17)), '');
    expect(WeekTexts.note(day(19)), '주 40시간 제외 · 10:00 – 14:30');
    expect(WeekTexts.value(day(19)), '');
  });

  test('부분 기록·미기록·출근 전', () {
    final s = build([rec(15, inH: 9), rec(14, outH: 18)]);
    WeekDay day(int n) => s.days.firstWhere((x) => x.date.day == n);
    expect(WeekTexts.main(day(15)), '기록 없음');
    expect(WeekTexts.note(day(15)), '09:00 출근 · 퇴근 없음');
    expect(WeekTexts.note(day(14)), '출근 없음 · 18:00 퇴근');
    expect(WeekTexts.note(day(16)), '아직 출근 전');
  });
}
```

- [ ] **Step 7: 문구 구현** — 새 파일 `lib/presentation/week/week_texts.dart`:

```dart
import '../../core/presentation/format/date_format.dart';
import '../../core/presentation/format/time_format.dart';
import '../../domain/model/work_type.dart';
import '../../domain/rules/work_rules.dart';
import 'week_state.dart';

/// 주간 화면의 모든 문구. 숫자(WeekState) → 문자열은 여기서만.
abstract final class WeekTexts {
  static const dash = '—';
  static const none = '';

  static String summaryLabel(WeekState s) {
    if (s.summary.isFirstWeekException) return '이번 주 기록한 시간';
    return s.isCurrentWeek ? '이번 주 누적' : '주간 누적';
  }

  static String summaryValue(WeekState s) => formatHm(s.summary.workedMinutes);

  /// " / 36h". 첫 주 예외면 빈 문자열.
  static String summaryGoal(WeekState s) {
    final target = s.summary.targetMinutes;
    return target == null ? '' : '/ ${formatHm(target)}';
  }

  static String summaryReason(WeekState s, WorkRules rules) {
    final w = s.summary;
    if (w.isFirstWeekException) {
      final first = s.firstRecordDate;
      return first == null ? '목표 없음' : '${formatDateTitle(first)}부터 기록 · 목표 없음';
    }
    final remaining = w.remainingMinutes ?? 0;
    final parts = <String>[];
    if (s.isCurrentWeek) {
      parts.add(remaining > 0 ? '남은 ${formatHm(remaining)}' : '목표 달성 · ${formatSignedHm(-remaining)}');
    } else if (remaining > 0) {
      parts.add('${formatHm(remaining)} 부족');
    } else if (remaining < 0) {
      parts.add('${formatHm(-remaining)} 초과');
    } else {
      parts.add('딱 맞음');
    }
    if (w.halfDayCount > 0) parts.add('반차 ${w.halfDayCount}회');
    if (w.dayOffCount > 0) parts.add('연차 ${w.dayOffCount}일로 목표 ${formatHm(w.dayOffCount * rules.dayOffCreditMinutes)} 차감');
    if (w.holidayCount > 0) {
      parts.add('공휴일 ${w.holidayCount}일로 목표 ${formatHm(w.holidayCount * rules.dayOffCreditMinutes)} 차감');
    }
    if (s.weekendMinutes > 0) parts.add('주말 ${formatHm(s.weekendMinutes)} 제외');
    return parts.join(' · ');
  }

  /// 진행률 0..1. 첫 주 예외면 null.
  static double? progress(WeekState s) {
    final target = s.summary.targetMinutes;
    if (target == null || target == 0) return null;
    return (s.summary.workedMinutes / target).clamp(0.0, 1.0);
  }

  static String main(WeekDay day) => switch (day.kind) {
        WeekDayKind.recorded || WeekDayKind.weekendRecorded => formatHm(day.actualMinutes ?? 0),
        WeekDayKind.working => '근무 중',
        WeekDayKind.unrecorded || WeekDayKind.partial => '기록 없음',
        WeekDayKind.off ||
        WeekDayKind.future ||
        WeekDayKind.beforeWork ||
        WeekDayKind.weekendEmpty =>
          dash,
      };

  static String note(WeekDay day) {
    final r = day.record;
    switch (day.kind) {
      case WeekDayKind.recorded:
        return formatClockRange(r!.clockIn!, r.clockOut!);
      case WeekDayKind.weekendRecorded:
        return '주 40시간 제외 · ${formatClockRange(r!.clockIn!, r.clockOut!)}';
      case WeekDayKind.working:
        return '${formatClock(r!.clockIn!)} 출근';
      case WeekDayKind.off:
        return '근무 없음';
      case WeekDayKind.unrecorded:
        return '눌러서 입력';
      case WeekDayKind.partial:
        final clockIn = r?.clockIn;
        final clockOut = r?.clockOut;
        return '${clockIn == null ? '출근 없음' : '${formatClock(clockIn)} 출근'} · '
            '${clockOut == null ? '퇴근 없음' : '${formatClock(clockOut)} 퇴근'}';
      case WeekDayKind.beforeWork:
        return '아직 출근 전';
      case WeekDayKind.future || WeekDayKind.weekendEmpty:
        return none;
    }
  }

  /// 우측 값. 기준 대비가 있으면 ±, 평일인데 없으면 "—", 주말·미래는 빈 문자열.
  static String value(WeekDay day) => switch (day.kind) {
        WeekDayKind.recorded => formatSignedHm(day.deltaMinutes ?? 0),
        WeekDayKind.working ||
        WeekDayKind.beforeWork ||
        WeekDayKind.unrecorded ||
        WeekDayKind.partial ||
        WeekDayKind.off =>
          dash,
        WeekDayKind.future || WeekDayKind.weekendRecorded || WeekDayKind.weekendEmpty => none,
      };

  /// 배지. 반차는 kind와 무관하게 record.type으로 (미래 반차 포함).
  static WorkType? badge(WeekDay day) {
    final t = day.record?.type;
    return t == null || t == WorkType.normal ? null : t;
  }

  static String badgeLabel(WorkType t) => switch (t) {
        WorkType.halfDay => '반차',
        WorkType.dayOff => '연차',
        WorkType.holiday => '공휴일',
        WorkType.normal => '',
      };
}
```

- [ ] **Step 8: 통과 확인** — `flutter test test/presentation/week_texts_test.dart` → PASS. (formatHm(1380−...)… 기대값이 안 맞으면 테스트의 숫자를 계산해서 맞추되 문구 형식은 유지.)

- [ ] **Step 9: 선택 주·프로바이더** — 새 파일 `lib/presentation/week/selected_week.dart`:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/clock_provider.dart';
import '../../core/providers/database_providers.dart';
import '../../domain/rules/navigation_bounds.dart';
import '../../domain/rules/work_calculator.dart';

part 'selected_week.g.dart';

/// 주간 탭이 보고 있는 주의 월요일. 탭을 오가도 유지되고, 앱을 다시 켜면 이번 주.
@Riverpod(keepAlive: true)
class SelectedWeek extends _$SelectedWeek {
  @override
  DateTime build() => mondayOf(ref.read(clockProvider)());

  void prev() {
    final today = ref.read(clockProvider)();
    final first = ref.read(firstRecordDateProvider).value;
    final earliest = earliestMonday(first, today);
    if (state.isAfter(earliest)) state = addDays(state, -7);
  }

  void next() {
    final thisMonday = mondayOf(ref.read(clockProvider)());
    if (state.isBefore(thisMonday)) state = addDays(state, 7);
  }
}
```
새 파일 `lib/presentation/week/week_provider.dart`:
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/clock_provider.dart';
import '../../core/providers/database_providers.dart';
import 'selected_week.dart';
import 'week_state.dart';
import 'week_state_builder.dart';

part 'week_provider.g.dart';

@riverpod
Future<WeekState> weekState(Ref ref) async {
  final records = await ref.watch(allRecordsProvider.future);
  final firstRecordDate = await ref.watch(firstRecordDateProvider.future);
  final now = await ref.watch(nowProvider.future);
  final rules = ref.watch(workRulesProvider);
  final monday = ref.watch(selectedWeekProvider);
  return buildWeekState(records: records, firstRecordDate: firstRecordDate, now: now, rules: rules, monday: monday);
}
```

- [ ] **Step 10: 선택 주 테스트** — 새 파일 `test/presentation/selected_week_test.dart`:

```dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/core/providers/clock_provider.dart';
import 'package:soi_duty/core/providers/database_providers.dart';
import 'package:soi_duty/data/database/app_database.dart';
import 'package:soi_duty/presentation/week/selected_week.dart';

import '../helpers/records.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer.test(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      clockProvider.overrideWithValue(() => d(16, 12)),
    ]);
    await container.read(workRecordRepositoryProvider).save(rec(2, inH: 9, outH: 18)); // 첫 기록일 9/2(수)
    container.listen(firstRecordDateProvider, (_, _) {});
    await container.read(firstRecordDateProvider.future);
  });
  tearDown(() => db.close());

  test('초기값은 이번 주 월요일, next는 막힘', () {
    final n = container.read(selectedWeekProvider.notifier);
    expect(container.read(selectedWeekProvider), d(14));
    n.next();
    expect(container.read(selectedWeekProvider), d(14));
  });

  test('prev는 첫 기록 주(8/31)까지만', () {
    final n = container.read(selectedWeekProvider.notifier);
    n.prev();
    n.prev();
    expect(container.read(selectedWeekProvider), DateTime(2026, 8, 31));
    n.prev();
    expect(container.read(selectedWeekProvider), DateTime(2026, 8, 31));
    n.next();
    expect(container.read(selectedWeekProvider), d(7));
  });
}
```

- [ ] **Step 11: 코드젠·테스트** — `dart run build_runner build --delete-conflicting-outputs` → `flutter test test/presentation` → PASS

- [ ] **Step 12: 커밋** — `git add lib/presentation/week test/presentation && git commit -m "주간 상태: WeekState 빌더·문구·선택 주 프로바이더"`

---

### Task 8: 월간 상태·프로바이더

**Files:**
- Create: `lib/presentation/month/month_state.dart`, `month_state_builder.dart`, `selected_month.dart`, `month_provider.dart`, `month_texts.dart`
- Test: `test/presentation/month_state_builder_test.dart`

**Interfaces:**
- Produces: `MonthState`, `MonthCell`, `MonthCellValue` (sealed), `buildMonthState({records, firstRecordDate, now, rules, month})`, `SelectedMonth`, `monthStateProvider`, `MonthTexts`.

- [ ] **Step 1: 테스트** — 새 파일 `test/presentation/month_state_builder_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/domain/model/work_type.dart';
import 'package:soi_duty/domain/rules/work_rules.dart';
import 'package:soi_duty/presentation/month/month_state.dart';
import 'package:soi_duty/presentation/month/month_state_builder.dart';
import 'package:soi_duty/presentation/month/month_texts.dart';

import '../helpers/records.dart';

void main() {
  const rules = WorkRules();
  MonthState build(List records, {DateTime? month, DateTime? first}) => buildMonthState(
        records: records.cast(),
        firstRecordDate: first ?? DateTime(2026, 8, 20),
        now: d(16, 12),
        rules: rules,
        month: month ?? DateTime(2026, 9),
      );
  MonthCell cell(MonthState s, DateTime date) => s.weeks.expand((w) => w).firstWhere((c) => c.date == date);

  test('2026-09은 5주, 8/31로 시작, 다른 달 표시', () {
    final s = build([]);
    expect(s.weeks.length, 5);
    expect(s.weeks.first.first.date, DateTime(2026, 8, 31));
    expect(cell(s, DateTime(2026, 8, 31)).isCurrentMonth, isFalse);
    expect(cell(s, d(1)).isCurrentMonth, isTrue);
    expect(cell(s, d(16)).isToday, isTrue);
  });

  test('값 판정', () {
    final s = build([
      rec(14, inH: 9, inM: 5, outH: 18, outM: 36),
      rec(15, type: WorkType.holiday),
      rec(16, inH: 9, inM: 12),
      rec(9, inH: 13, outH: 18, type: WorkType.halfDay),
      rec(12, inH: 10, outH: 14, outM: 30),
      rec(23, type: WorkType.dayOff),
    ]);
    expect(cell(s, d(14)).value, const MonthCellValue.delta(31));
    expect(cell(s, d(15)).value, const MonthCellValue.none());
    expect(cell(s, d(15)).type, WorkType.holiday);
    expect(cell(s, d(16)).value, const MonthCellValue.working());
    expect(cell(s, d(9)).value, const MonthCellValue.none());
    expect(cell(s, d(9)).type, WorkType.halfDay);
    expect(cell(s, d(12)).value, const MonthCellValue.weekendActual(270));
    expect(cell(s, d(10)).value, const MonthCellValue.unrecorded());
    expect(cell(s, d(17)).value, const MonthCellValue.none());
    expect(cell(s, d(17)).isFuture, isTrue);
    expect(cell(s, d(23)).type, WorkType.dayOff);
  });

  test('배경: 이번 달 과거·오늘 평일만', () {
    final s = build([]);
    expect(cell(s, d(14)).hasBackground, isTrue);
    expect(cell(s, d(16)).hasBackground, isTrue);
    expect(cell(s, d(17)).hasBackground, isFalse);
    expect(cell(s, d(12)).hasBackground, isFalse);
    expect(cell(s, DateTime(2026, 8, 31)).hasBackground, isFalse);
  });

  test('이동 가능 여부', () {
    final s = build([]);
    expect(s.canGoNext, isFalse);
    expect(s.canGoPrev, isTrue);
    final aug = build([], month: DateTime(2026, 8));
    expect(aug.canGoPrev, isFalse);
    expect(aug.canGoNext, isTrue);
  });

  test('문구', () {
    expect(MonthTexts.value(const MonthCellValue.delta(-15)), '−15m');
    expect(MonthTexts.value(const MonthCellValue.working()), '···');
    expect(MonthTexts.value(const MonthCellValue.unrecorded()), '—');
    expect(MonthTexts.value(const MonthCellValue.weekendActual(270)), '4h 30m');
    expect(MonthTexts.value(const MonthCellValue.none()), '');
  });
}
```

- [ ] **Step 2: 실패 확인** — 컴파일 에러

- [ ] **Step 3: 상태** — 새 파일 `lib/presentation/month/month_state.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/model/work_type.dart';

part 'month_state.freezed.dart';

@freezed
sealed class MonthCellValue with _$MonthCellValue {
  const factory MonthCellValue.none() = MonthCellNone;
  const factory MonthCellValue.delta(int minutes) = MonthCellDelta;
  const factory MonthCellValue.weekendActual(int minutes) = MonthCellWeekendActual;
  const factory MonthCellValue.working() = MonthCellWorking;
  const factory MonthCellValue.unrecorded() = MonthCellUnrecorded;
}

@freezed
abstract class MonthCell with _$MonthCell {
  const factory MonthCell({
    required DateTime date,
    required bool isCurrentMonth,
    required bool isToday,
    required bool isWeekend,
    required bool isFuture,
    /// 배지. normal이면 null
    WorkType? type,
    required MonthCellValue value,
    required bool hasBackground,
  }) = _MonthCell;
}

@freezed
abstract class MonthState with _$MonthState {
  const factory MonthState({
    required DateTime month,
    required bool canGoPrev,
    required bool canGoNext,
    required List<List<MonthCell>> weeks,
  }) = _MonthState;
}
```

- [ ] **Step 4: 빌더** — 새 파일 `lib/presentation/month/month_state_builder.dart`:

```dart
import '../../domain/model/work_record.dart';
import '../../domain/model/work_type.dart';
import '../../domain/rules/navigation_bounds.dart';
import '../../domain/rules/work_calculator.dart';
import '../../domain/rules/work_rules.dart';
import 'month_state.dart';

MonthState buildMonthState({
  required List<WorkRecord> records,
  required DateTime? firstRecordDate,
  required DateTime now,
  required WorkRules rules,
  required DateTime month,
}) {
  final today = dateOnly(now);
  final start = firstOfMonth(month);
  final thisMonth = firstOfMonth(today);
  final byDate = recordsByDate(records);
  final days = calendarDays(start);

  final cells = [for (final d in days) _cell(d, byDate, start, today, rules)];
  final weeks = [for (var i = 0; i < cells.length; i += 7) cells.sublist(i, i + 7)];

  return MonthState(
    month: start,
    canGoPrev: start.isAfter(earliestMonth(firstRecordDate, today)),
    canGoNext: start.isBefore(thisMonth),
    weeks: weeks,
  );
}

MonthCell _cell(DateTime date, Map<DateTime, WorkRecord> byDate, DateTime month, DateTime today, WorkRules rules) {
  final r = byDate[date];
  final weekend = isWeekend(date);
  final future = date.isAfter(today);
  final isCurrentMonth = date.month == month.month && date.year == month.year;
  final type = r == null || r.type == WorkType.normal ? null : r.type;
  final hasBoth = r?.clockIn != null && r?.clockOut != null;

  final MonthCellValue value;
  if (type != null) {
    value = const MonthCellValue.none();
  } else if (weekend) {
    value = hasBoth ? MonthCellValue.weekendActual(actualMinutes(r!, rules) ?? 0) : const MonthCellValue.none();
  } else if (future) {
    value = const MonthCellValue.none();
  } else if (hasBoth) {
    value = MonthCellValue.delta(deltaMinutes(r!, rules) ?? 0);
  } else if (date == today && r?.clockIn != null) {
    value = const MonthCellValue.working();
  } else if (date == today) {
    value = const MonthCellValue.none();
  } else {
    value = const MonthCellValue.unrecorded();
  }

  return MonthCell(
    date: date,
    isCurrentMonth: isCurrentMonth,
    isToday: date == today,
    isWeekend: weekend,
    isFuture: future,
    type: type,
    value: value,
    hasBackground: isCurrentMonth && !weekend && !future,
  );
}
```

- [ ] **Step 5: 문구** — 새 파일 `lib/presentation/month/month_texts.dart`:

```dart
import '../../core/presentation/format/date_format.dart';
import '../../core/presentation/format/time_format.dart';
import '../../domain/model/work_type.dart';
import 'month_state.dart';

abstract final class MonthTexts {
  static const calendarTitle = '기준 대비 ±';
  static const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
  static const legend = [(WorkType.halfDay, '반차'), (WorkType.dayOff, '연차'), (WorkType.holiday, '공휴일')];

  static String title(MonthState s) => formatMonthTitle(s.month);

  static String value(MonthCellValue v) => switch (v) {
        MonthCellNone() => '',
        MonthCellDelta(:final minutes) => formatSignedHm(minutes),
        MonthCellWeekendActual(:final minutes) => formatHm(minutes),
        MonthCellWorking() => '···',
        MonthCellUnrecorded() => '—',
      };

  static String badge(WorkType t) => switch (t) {
        WorkType.halfDay => '반차',
        WorkType.dayOff => '연차',
        WorkType.holiday => '공휴일',
        WorkType.normal => '',
      };
}
```

- [ ] **Step 6: 선택 월·프로바이더** — 새 파일 `lib/presentation/month/selected_month.dart`:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/clock_provider.dart';
import '../../core/providers/database_providers.dart';
import '../../domain/rules/navigation_bounds.dart';
import '../../domain/rules/work_calculator.dart';

part 'selected_month.g.dart';

/// 월간 탭이 보고 있는 달의 1일.
@Riverpod(keepAlive: true)
class SelectedMonth extends _$SelectedMonth {
  @override
  DateTime build() => firstOfMonth(ref.read(clockProvider)());

  void prev() {
    final today = ref.read(clockProvider)();
    final first = ref.read(firstRecordDateProvider).value;
    if (state.isAfter(earliestMonth(first, today))) state = addMonths(state, -1);
  }

  void next() {
    final thisMonth = firstOfMonth(ref.read(clockProvider)());
    if (state.isBefore(thisMonth)) state = addMonths(state, 1);
  }
}
```
새 파일 `lib/presentation/month/month_provider.dart`:
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/clock_provider.dart';
import '../../core/providers/database_providers.dart';
import 'month_state.dart';
import 'month_state_builder.dart';
import 'selected_month.dart';

part 'month_provider.g.dart';

@riverpod
Future<MonthState> monthState(Ref ref) async {
  final records = await ref.watch(allRecordsProvider.future);
  final firstRecordDate = await ref.watch(firstRecordDateProvider.future);
  final now = await ref.watch(nowProvider.future);
  final rules = ref.watch(workRulesProvider);
  final month = ref.watch(selectedMonthProvider);
  return buildMonthState(records: records, firstRecordDate: firstRecordDate, now: now, rules: rules, month: month);
}
```

- [ ] **Step 7: 코드젠·테스트** — `dart run build_runner build --delete-conflicting-outputs` → `flutter test test/presentation/month_state_builder_test.dart` → PASS

- [ ] **Step 8: 커밋** — `git add lib/presentation/month test/presentation && git commit -m "월간 상태: MonthState 빌더·문구·선택 월 프로바이더"`

---

### Task 9: 탭 셸·라우터·기간 네비게이터·주간/월간 화면

**Files:**
- Create: `lib/presentation/shell/tab_shell.dart`, `lib/presentation/shared/period_navigator.dart`, `lib/presentation/week/week_screen.dart`, `week/widgets/week_summary_card.dart`, `week/widgets/week_day_row.dart`, `lib/presentation/month/month_screen.dart`, `month/widgets/calendar_card.dart`, `month/widgets/legend.dart`
- Modify: `lib/core/routing/route_paths.dart`, `router.dart`, `lib/presentation/today/today_view.dart`, `today_texts.dart`
- Test: `test/presentation/today_view_test.dart`, `test/presentation/week_screen_test.dart`, `test/presentation/month_screen_test.dart`

**Interfaces:**
- Produces: `TabShell({navigationShell})`, `PeriodNavigator({label, canGoPrev, canGoNext, onPrev, onNext})`, `WeekScreen`, `WeekView({state, rules, onDayTap, onPrev, onNext})`, `MonthScreen`, `MonthView({state, onCellTap, onPrev, onNext})`.

- [ ] **Step 1: 라우트 경로**

`route_paths.dart`:
```dart
abstract final class RoutePaths {
  static const today = '/today';
  static const week = '/week';
  static const month = '/month';
}
```
`router.dart`:
```dart
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../presentation/month/month_screen.dart';
import '../../presentation/shell/tab_shell.dart';
import '../../presentation/today/today_screen.dart';
import '../../presentation/week/week_screen.dart';
import 'route_paths.dart';

part 'router.g.dart';

@riverpod
GoRouter router(Ref ref) {
  return GoRouter(
    initialLocation: RoutePaths.today,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => TabShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: RoutePaths.today, builder: (_, _) => const TodayScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: RoutePaths.week, builder: (_, _) => const WeekScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: RoutePaths.month, builder: (_, _) => const MonthScreen())]),
        ],
      ),
    ],
  );
}
```

- [ ] **Step 2: 셸** — 새 파일 `lib/presentation/shell/tab_shell.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../ui/app_colors.dart';
import '../../ui/app_sizes.dart';
import '../today/today_texts.dart';
import '../today/widgets/pill_tabs.dart';

/// 알약 탭 + 브랜치. Scaffold·SafeArea는 여기 한 번만. 탭 전환 애니메이션 없음.
class TabShell extends StatelessWidget {
  const TabShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(AppSizes.screenHPadding, AppSizes.topInset, AppSizes.screenHPadding, 0),
              child: PillTabs(
                labels: TodayTexts.tabs,
                selectedIndex: navigationShell.currentIndex,
                onSelected: (i) => navigationShell.goBranch(i, initialLocation: i == navigationShell.currentIndex),
              ),
            ),
            Expanded(child: navigationShell),
          ],
        ),
      ),
    );
  }
}
```
`TodayTexts.tabs`는 그대로 쓴다 (탭 라벨은 셸의 것이지만 옮기면 diff만 커진다).

- [ ] **Step 3: TodayView에서 셸 걷어내기** — `today_view.dart`의 `build`를:

```dart
  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Column(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onLongPress: callbacks.onDateLongPress,
          child: Padding(
            padding: AppSizes.datePadding,
            child: Text(formatDateTitle(state.date), style: AppTextStyles.dateTitle, textAlign: TextAlign.center),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: AppSizes.bodyPadding.copyWith(bottom: AppSizes.bodyPadding.bottom + bottomInset),
            child: Column(
              children: [
                HeroCard(state: state, rules: rules),
                SizedBox(height: AppSizes.cardGap),
                StatusCard(state: state, callbacks: callbacks),
                if (state.isFirstWeek) ...[
                  SizedBox(height: AppSizes.cardGap),
                  const FirstWeekCard(),
                ],
                if (state.unrecordedDays.isNotEmpty) ...[
                  SizedBox(height: AppSizes.cardGap),
                  UnrecordedCard(days: state.unrecordedDays, onTap: callbacks.onUnrecordedTap),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
```
`PillTabs`·`AppColors` import 제거. `today_screen.dart`의 `loading`/`error` 분기에서 `Scaffold`를 `ColoredBox(color: AppColors.screenBackground, child: ...)`로 바꾼다 (셸이 Scaffold를 가진다).
`today_view_test.dart`의 `pumpView`는 `home: Scaffold(body: TodayView(...))`로 감싼다 (버튼 Y 불변 테스트는 그대로 유효).

- [ ] **Step 4: 기간 네비게이터** — 새 파일 `lib/presentation/shared/period_navigator.dart`:

```dart
import 'package:flutter/material.dart';

import '../../ui/app_colors.dart';
import '../../ui/app_sizes.dart';
import '../../ui/app_text_styles.dart';

/// ◀ · 라벨(min-width 186) · ▶. 비활성 화살표는 hairline 색 + 무반응.
class PeriodNavigator extends StatelessWidget {
  const PeriodNavigator({
    super.key,
    required this.label,
    required this.canGoPrev,
    required this.canGoNext,
    required this.onPrev,
    required this.onNext,
  });

  final String label;
  final bool canGoPrev;
  final bool canGoNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSizes.navPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Arrow(glyph: '◀', enabled: canGoPrev, onTap: onPrev),
          SizedBox(width: AppSizes.navGap),
          ConstrainedBox(
            constraints: BoxConstraints(minWidth: AppSizes.navLabelMinWidth),
            child: Text(label, style: AppTextStyles.navLabel, textAlign: TextAlign.center),
          ),
          SizedBox(width: AppSizes.navGap),
          _Arrow(glyph: '▶', enabled: canGoNext, onTap: onNext),
        ],
      ),
    );
  }
}

class _Arrow extends StatefulWidget {
  const _Arrow({required this.glyph, required this.enabled, required this.onTap});

  final String glyph;
  final bool enabled;
  final VoidCallback onTap;

  @override
  State<_Arrow> createState() => _ArrowState();
}

class _ArrowState extends State<_Arrow> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: widget.enabled ? () => setState(() => _pressed = false) : null,
      onTap: widget.enabled ? widget.onTap : null,
      child: SizedBox(
        width: AppSizes.minTapHeight,
        height: AppSizes.minTapHeight,
        child: Center(
          child: Container(
            width: AppSizes.navArrow,
            height: AppSizes.navArrow,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, color: _pressed ? AppColors.tabContainer : Colors.transparent),
            child: Text(widget.glyph, style: widget.enabled ? AppTextStyles.navArrow : AppTextStyles.navArrowDisabled),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: 주간 위젯** — 새 파일 `lib/presentation/week/widgets/week_summary_card.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../domain/rules/work_rules.dart';
import '../../../ui/app_colors.dart';
import '../../../ui/app_decorations.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';
import '../week_state.dart';
import '../week_texts.dart';

class WeekSummaryCard extends StatelessWidget {
  const WeekSummaryCard({super.key, required this.state, required this.rules});

  final WeekState state;
  final WorkRules rules;

  @override
  Widget build(BuildContext context) {
    final progress = WeekTexts.progress(state);
    final goal = WeekTexts.summaryGoal(state);
    return Container(
      width: double.infinity,
      padding: AppSizes.weekCardPadding,
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(WeekTexts.summaryLabel(state), style: AppTextStyles.label),
          SizedBox(height: AppSizes.weekValueTop),
          Text.rich(
            TextSpan(
              text: WeekTexts.summaryValue(state),
              style: AppTextStyles.weekValue,
              children: [if (goal.isNotEmpty) TextSpan(text: ' $goal', style: AppTextStyles.weekGoal)],
            ),
          ),
          SizedBox(height: AppSizes.weekReasonTop),
          Text(WeekTexts.summaryReason(state, rules), style: AppTextStyles.weekReason),
          if (progress != null) ...[
            SizedBox(height: AppSizes.weekBarTop),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.pill),
              child: SizedBox(
                height: AppSizes.progressBar,
                child: Stack(
                  children: [
                    const ColoredBox(color: AppColors.divider, child: SizedBox.expand()),
                    AnimatedFractionallySizedBox(
                      duration: AppDurations.progressBar,
                      curve: Curves.easeOut,
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: const ColoredBox(color: AppColors.brand, child: SizedBox.expand()),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
```
(1차 `hero_card.dart`의 진행 바 구현이 다르면 그쪽 방식을 그대로 복사한다 — 같은 모양이어야 한다.)

새 파일 `lib/presentation/week/widgets/week_day_row.dart`:
```dart
import 'package:flutter/material.dart';

import '../../../domain/model/work_type.dart';
import '../../../ui/app_colors.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';
import '../week_state.dart';
import '../week_texts.dart';

/// 일별 행. 날짜 폭 30 가운데 · 내용 Expanded · 값 폭 58 우측. 보조 min-height 16으로 7행 높이가 같다.
class WeekDayRow extends StatefulWidget {
  const WeekDayRow({super.key, required this.day, required this.onTap});

  final WeekDay day;
  final VoidCallback onTap;

  @override
  State<WeekDayRow> createState() => _WeekDayRowState();
}

class _WeekDayRowState extends State<WeekDayRow> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    final day = widget.day;
    final weekend = day.date.weekday >= DateTime.saturday;
    final badge = WeekTexts.badge(day);
    final value = WeekTexts.value(day);
    final delta = day.deltaMinutes;

    final mainStyle = switch (day.kind) {
      WeekDayKind.weekendEmpty || WeekDayKind.future => AppTextStyles.rowMainNone,
      WeekDayKind.unrecorded || WeekDayKind.partial || WeekDayKind.beforeWork || WeekDayKind.off => AppTextStyles.rowMainDim,
      _ => AppTextStyles.rowMain,
    };
    final valueColor = delta == null
        ? AppColors.subtle
        : delta > 0
            ? AppColors.brand
            : delta < 0
                ? AppColors.minus
                : AppColors.subtle;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: AppDurations.checkbox,
        padding: AppSizes.rowPadding,
        color: _pressed
            ? AppColors.listRow
            : day.isToday
                ? AppColors.todayRow
                : Colors.transparent,
        child: Row(
          children: [
            SizedBox(
              width: AppSizes.rowDateWidth,
              child: Column(
                children: [
                  Text('${day.date.day}', style: weekend ? AppTextStyles.rowNumWeekend : AppTextStyles.rowNum),
                  SizedBox(height: AppSizes.rowDowTop),
                  Text(WeekTexts.dow(day.date), style: weekend ? AppTextStyles.rowDowWeekend : AppTextStyles.rowDow),
                ],
              ),
            ),
            SizedBox(width: AppSizes.rowGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(WeekTexts.main(day), style: mainStyle),
                      if (badge != null) ...[
                        SizedBox(width: AppSizes.rowBadgeGap),
                        _Badge(type: badge),
                      ],
                    ],
                  ),
                  SizedBox(height: AppSizes.rowNoteTop),
                  ConstrainedBox(
                    constraints: BoxConstraints(minHeight: AppSizes.rowNoteMinHeight),
                    child: Text(WeekTexts.note(day), style: AppTextStyles.rowNote),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSizes.rowGap),
            SizedBox(
              width: AppSizes.rowValueWidth,
              child: Text(value, style: AppTextStyles.rowValue(valueColor), textAlign: TextAlign.right),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.type});

  final WorkType type;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (type) {
      WorkType.halfDay => (AppColors.halfDayBackground, AppColors.halfDayText),
      WorkType.dayOff => (AppColors.dayOffBackground, AppColors.dayOffText),
      WorkType.holiday => (AppColors.holidayBackground, AppColors.holidayText),
      WorkType.normal => (AppColors.chipNeutral, AppColors.subtle),
    };
    return Container(
      padding: AppSizes.rowBadgePadding,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppSizes.rowBadgeRadius)),
      child: Text(WeekTexts.badgeLabel(type), style: AppTextStyles.rowBadge.copyWith(color: fg)),
    );
  }
}
```
`WeekTexts`에 추가:
```dart
  static const _dow = ['월', '화', '수', '목', '금', '토', '일'];
  static String dow(DateTime d) => _dow[d.weekday - DateTime.monday];
```

새 파일 `lib/presentation/week/week_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/presentation/format/date_format.dart';
import '../../core/providers/database_providers.dart';
import '../../domain/rules/work_rules.dart';
import '../../ui/app_colors.dart';
import '../../ui/app_decorations.dart';
import '../../ui/app_sizes.dart';
import '../../ui/app_text_styles.dart';
import '../record_edit/record_edit_sheet.dart';
import '../shared/period_navigator.dart';
import 'selected_week.dart';
import 'week_provider.dart';
import 'week_state.dart';
import 'widgets/week_day_row.dart';
import 'widgets/week_summary_card.dart';

class WeekScreen extends ConsumerWidget {
  const WeekScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rules = ref.watch(workRulesProvider);
    final async = ref.watch(weekStateProvider);
    final selected = ref.watch(selectedWeekProvider.notifier);
    return async.when(
      loading: () => const ColoredBox(color: AppColors.screenBackground, child: SizedBox.expand()),
      error: (e, _) => Center(child: Text('$e', style: AppTextStyles.caption)),
      data: (state) => WeekView(
        state: state,
        rules: rules,
        onDayTap: (date) => showRecordEditSheet(context, date),
        onPrev: selected.prev,
        onNext: selected.next,
      ),
    );
  }
}

/// 주간 화면의 순수 UI.
class WeekView extends StatelessWidget {
  const WeekView({
    super.key,
    required this.state,
    required this.rules,
    required this.onDayTap,
    required this.onPrev,
    required this.onNext,
  });

  final WeekState state;
  final WorkRules rules;
  final ValueChanged<DateTime> onDayTap;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Column(
      children: [
        PeriodNavigator(
          label: formatWeekRange(state.monday),
          canGoPrev: state.canGoPrev,
          canGoNext: state.canGoNext,
          onPrev: onPrev,
          onNext: onNext,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: AppSizes.bodyPadding.copyWith(bottom: AppSizes.bodyPadding.bottom + bottomInset),
            child: Column(
              children: [
                WeekSummaryCard(state: state, rules: rules),
                SizedBox(height: AppSizes.cardGap),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                  child: Container(
                    decoration: AppDecorations.card,
                    child: Column(
                      children: [
                        for (var i = 0; i < state.days.length; i++) ...[
                          if (i > 0) Container(height: AppSizes.rowDivider, color: AppColors.rowDivider),
                          WeekDayRow(day: state.days[i], onTap: () => onDayTap(state.days[i].date)),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 6: 월간 위젯** — 새 파일 `lib/presentation/month/widgets/legend.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../domain/model/work_type.dart';
import '../../../ui/app_colors.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';
import '../month_texts.dart';

class Legend extends StatelessWidget {
  const Legend({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSizes.legendPadding,
      child: Wrap(
        spacing: AppSizes.legendItemGap,
        runSpacing: AppSizes.legendRunGap,
        children: [
          for (final (type, label) in MonthTexts.legend)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: AppSizes.legendChip,
                  height: AppSizes.legendChip,
                  decoration: BoxDecoration(color: _color(type), borderRadius: BorderRadius.circular(AppSizes.legendChipRadius)),
                ),
                SizedBox(width: AppSizes.legendChipGap),
                Text(label, style: AppTextStyles.legend),
              ],
            ),
        ],
      ),
    );
  }

  static Color _color(WorkType t) => switch (t) {
        WorkType.halfDay => AppColors.halfDayBackground,
        WorkType.dayOff => AppColors.dayOffBackground,
        WorkType.holiday => AppColors.holidayBackground,
        WorkType.normal => AppColors.chipNeutral,
      };
}
```

새 파일 `lib/presentation/month/widgets/calendar_card.dart`:
```dart
import 'package:flutter/material.dart';

import '../../../domain/model/work_type.dart';
import '../../../ui/app_colors.dart';
import '../../../ui/app_decorations.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';
import '../month_state.dart';
import '../month_texts.dart';

class CalendarCard extends StatelessWidget {
  const CalendarCard({super.key, required this.state, required this.onCellTap});

  final MonthState state;
  final ValueChanged<DateTime> onCellTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSizes.calendarPadding,
      decoration: AppDecorations.card,
      child: Column(
        children: [
          Text(MonthTexts.calendarTitle, style: AppTextStyles.calendarTitle),
          Padding(
            padding: AppSizes.calendarHeaderPadding,
            child: Row(
              children: [
                for (final w in MonthTexts.weekdays)
                  Expanded(child: Text(w, style: AppTextStyles.calendarHeader, textAlign: TextAlign.center)),
              ],
            ),
          ),
          Padding(
            padding: AppSizes.calendarGridPadding,
            child: Column(
              children: [
                for (var r = 0; r < state.weeks.length; r++) ...[
                  if (r > 0) SizedBox(height: AppSizes.calendarRowGap),
                  Row(
                    children: [
                      for (var c = 0; c < 7; c++) ...[
                        if (c > 0) SizedBox(width: AppSizes.calendarColGap),
                        Expanded(child: _Cell(cell: state.weeks[r][c], onTap: () => onCellTap(state.weeks[r][c].date))),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Cell extends StatefulWidget {
  const _Cell({required this.cell, required this.onTap});

  final MonthCell cell;
  final VoidCallback onTap;

  @override
  State<_Cell> createState() => _CellState();
}

class _CellState extends State<_Cell> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cell = widget.cell;
    final dim = !cell.isCurrentMonth || cell.isWeekend || cell.isFuture;
    final text = MonthTexts.value(cell.value);
    final valueStyle = switch (cell.value) {
      MonthCellDelta(:final minutes) => AppTextStyles.calendarValue(
          minutes > 0 ? AppColors.brand : minutes < 0 ? AppColors.minus : AppColors.ink),
      MonthCellWeekendActual() => AppTextStyles.calendarWeekendValue,
      _ => AppTextStyles.calendarValue(AppColors.faint),
    };

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedOpacity(
        duration: AppDurations.pressedOpacity,
        opacity: _pressed ? AppOpacities.cellPressed : 1,
        child: Container(
          height: AppSizes.calendarCell,
          padding: EdgeInsets.only(top: AppSizes.calendarCellTop),
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: cell.hasBackground ? AppColors.cardInner : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.calendarCellRadius),
          ),
          child: Column(
            children: [
              Text('${cell.date.day}', style: AppTextStyles.calendarNum(dim: dim)),
              if (cell.type != null) ...[
                SizedBox(height: AppSizes.calendarCellGap),
                _Badge(type: cell.type!),
              ],
              if (text.isNotEmpty) ...[
                SizedBox(height: AppSizes.calendarCellGap),
                Text(text, style: valueStyle, maxLines: 1, overflow: TextOverflow.clip),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.type});

  final WorkType type;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (type) {
      WorkType.halfDay => (AppColors.halfDayBackground, AppColors.halfDayText),
      WorkType.dayOff => (AppColors.dayOffBackground, AppColors.dayOffText),
      WorkType.holiday => (AppColors.holidayBackground, AppColors.holidayText),
      WorkType.normal => (AppColors.chipNeutral, AppColors.subtle),
    };
    return Container(
      padding: AppSizes.calendarBadgePadding,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppSizes.calendarBadgeRadius)),
      child: Text(MonthTexts.badge(type), style: AppTextStyles.calendarBadge.copyWith(color: fg)),
    );
  }
}
```
배지 색 매핑이 세 곳(주간 행, 캘린더, 유형 칩)에 반복되므로 `lib/ui/app_colors.dart`에 `static (Color, Color) typeColors(WorkType t)`를 두고 세 곳이 그걸 쓰게 한다 — `app_colors.dart`가 `domain/model/work_type.dart`를 import하는 건 허용(ui → domain 방향).

새 파일 `lib/presentation/month/month_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ui/app_colors.dart';
import '../../ui/app_sizes.dart';
import '../../ui/app_text_styles.dart';
import '../record_edit/record_edit_sheet.dart';
import '../shared/period_navigator.dart';
import 'month_provider.dart';
import 'month_state.dart';
import 'month_texts.dart';
import 'selected_month.dart';
import 'widgets/calendar_card.dart';
import 'widgets/legend.dart';

class MonthScreen extends ConsumerWidget {
  const MonthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(monthStateProvider);
    final selected = ref.watch(selectedMonthProvider.notifier);
    return async.when(
      loading: () => const ColoredBox(color: AppColors.screenBackground, child: SizedBox.expand()),
      error: (e, _) => Center(child: Text('$e', style: AppTextStyles.caption)),
      data: (state) => MonthView(
        state: state,
        onCellTap: (date) => showRecordEditSheet(context, date),
        onPrev: selected.prev,
        onNext: selected.next,
      ),
    );
  }
}

class MonthView extends StatelessWidget {
  const MonthView({super.key, required this.state, required this.onCellTap, required this.onPrev, required this.onNext});

  final MonthState state;
  final ValueChanged<DateTime> onCellTap;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Column(
      children: [
        PeriodNavigator(
          label: MonthTexts.title(state),
          canGoPrev: state.canGoPrev,
          canGoNext: state.canGoNext,
          onPrev: onPrev,
          onNext: onNext,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: AppSizes.bodyPadding.copyWith(bottom: AppSizes.bodyPadding.bottom + bottomInset),
            child: Column(
              children: [
                CalendarCard(state: state, onCellTap: onCellTap),
                SizedBox(height: AppSizes.cardGap),
                const Legend(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 7: 위젯 테스트** — 새 파일 `test/presentation/week_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/core/presentation/size_config.dart';
import 'package:soi_duty/domain/model/work_type.dart';
import 'package:soi_duty/domain/rules/work_rules.dart';
import 'package:soi_duty/presentation/week/week_screen.dart';
import 'package:soi_duty/presentation/week/week_state_builder.dart';
import 'package:soi_duty/presentation/week/widgets/week_day_row.dart';
import 'package:soi_duty/ui/app_theme.dart';

import '../helpers/records.dart';

Future<void> loadPretendard() async {
  final loader = FontLoader('Pretendard')
    ..addFont(rootBundle.load('assets/fonts/Pretendard-Regular.otf'))
    ..addFont(rootBundle.load('assets/fonts/Pretendard-Medium.otf'))
    ..addFont(rootBundle.load('assets/fonts/Pretendard-SemiBold.otf'));
  await loader.load();
}

void main() {
  const rules = WorkRules();
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadPretendard();
  });
  setUp(() => SizeConfig.init(402));

  testWidgets('7행 높이가 모두 같고, 행을 탭하면 날짜가 올라온다', (tester) async {
    tester.view.physicalSize = const Size(402 * 3, 874 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final state = buildWeekState(
      records: [
        rec(14, inH: 9, inM: 5, outH: 18, outM: 36),
        rec(15, type: WorkType.holiday),
        rec(16, inH: 9, inM: 12),
        rec(19, inH: 10, outH: 14, outM: 30),
      ],
      firstRecordDate: d(7),
      now: d(16, 12),
      rules: rules,
      monday: d(14),
    );
    DateTime? tapped;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: WeekView(state: state, rules: rules, onDayTap: (d) => tapped = d, onPrev: () {}, onNext: () {}),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 500));

    final heights = tester.widgetList(find.byType(WeekDayRow)).map((w) => tester.getSize(find.byWidget(w)).height).toSet();
    expect(heights.length, 1, reason: '행 높이: $heights');

    await tester.tap(find.text('근무 중'));
    expect(tapped, d(16));
  });
}
```
`loadPretendard`가 세 테스트 파일에 중복되므로 `test/helpers/fonts.dart`로 뽑아 세 곳이 import한다.

새 파일 `test/presentation/month_screen_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/core/presentation/size_config.dart';
import 'package:soi_duty/domain/model/work_type.dart';
import 'package:soi_duty/domain/rules/work_rules.dart';
import 'package:soi_duty/presentation/month/month_screen.dart';
import 'package:soi_duty/presentation/month/month_state_builder.dart';
import 'package:soi_duty/ui/app_theme.dart';

import '../helpers/fonts.dart';
import '../helpers/records.dart';

void main() {
  const rules = WorkRules();
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadPretendard();
  });
  setUp(() => SizeConfig.init(402));

  testWidgets('35셀, 배지와 값, 셀 탭', (tester) async {
    tester.view.physicalSize = const Size(402 * 3, 874 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final state = buildMonthState(
      records: [rec(14, inH: 9, inM: 5, outH: 18, outM: 36), rec(15, type: WorkType.holiday)],
      firstRecordDate: DateTime(2026, 8, 20),
      now: d(16, 12),
      rules: rules,
      month: DateTime(2026, 9),
    );
    DateTime? tapped;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: MonthView(state: state, onCellTap: (d) => tapped = d, onPrev: () {}, onNext: () {})),
    ));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('+31m'), findsOneWidget);
    expect(find.text('공휴일'), findsNWidgets(2)); // 셀 배지 + 범례
    await tester.tap(find.text('+31m'));
    expect(tapped, d(14));
  });
}
```

- [ ] **Step 8: 코드젠·전체 테스트·분석** — `dart run build_runner build --delete-conflicting-outputs` → `flutter test` → PASS, `flutter analyze` 클린. 오버플로 경고가 나면 해당 텍스트에 `maxLines: 1` + 폰트 토큰 조정.

- [ ] **Step 9: 커밋** — `git add -A lib test && git commit -m "탭 셸(StatefulShellRoute)·기간 네비게이터·주간/월간 화면"`

---

### Task 10: 디버그 시드 `history`

**Files:**
- Modify: `lib/data/seed/debug_seed.dart`
- Test: `test/data/debug_seed_test.dart`

- [ ] **Step 1: 테스트** — 기존 파일 `main()` 끝에:

```dart
  test('history: 8주치 기록, 유형이 섞이고 누락과 미래 연차가 있다', () async {
    await applySeed(db, SeedScenario.history, today: today);
    final records = await repo.watchAll().first;
    final types = records.map((r) => r.type).toSet();
    expect(types, containsAll([WorkType.normal, WorkType.halfDay, WorkType.dayOff, WorkType.holiday]));
    expect(records.any((r) => r.date.isAfter(today) && r.type == WorkType.dayOff), isTrue);
    expect(records.any((r) => isWeekend(r.date) && r.clockOut != null), isTrue);
    final first = await repo.watchFirstRecordDate().first;
    expect(first, mondayOf(DateTime(today.year, today.month, today.day - 56)));
  });
```
(`today`, `db`, `repo` 픽스처 이름은 기존 파일 것을 따른다. `isWeekend`·`mondayOf` import.)

- [ ] **Step 2: 실패 확인** → 컴파일 에러

- [ ] **Step 3: 구현** — enum에 `history('두 달치 기록')` 추가, `_records`의 switch에:

```dart
    case SeedScenario.history:
      // −8주 월요일부터 어제까지. 날짜로 결정되는 변동으로 ±가 골고루 나온다.
      final start = DateTime(monday.year, monday.month, monday.day - 56);
      final records = <WorkRecord>[];
      for (var d = start; d.isBefore(today); d = DateTime(d.year, d.month, d.day + 1)) {
        final n = d.day;
        if (isWeekend(d)) {
          if (n % 9 == 0) records.add(full(d, inH: 10, outH: 14, outM: 30)); // 가끔 주말 근무
          continue;
        }
        if (n % 11 == 0) continue; // 누락
        if (n % 13 == 0) {
          records.add(WorkRecord(date: d, type: WorkType.dayOff));
        } else if (n % 17 == 0) {
          records.add(WorkRecord(date: d, type: WorkType.holiday));
        } else if (n % 7 == 0) {
          records.add(WorkRecord(
            date: d,
            type: WorkType.halfDay,
            clockIn: DateTime(d.year, d.month, d.day, 13, 30),
            clockOut: DateTime(d.year, d.month, d.day, 17, 40 + (n % 3) * 10),
          ));
        } else {
          records.add(full(d, inH: 9, inM: (n % 4) * 7, outH: 18, outM: (n % 5) * 9));
        }
      }
      // 오늘 근무 중 + 다음 주 미리 찍은 연차
      records.add(WorkRecord(date: today, clockIn: DateTime(today.year, today.month, today.day, 9, 12)));
      final nextWeek = DateTime(monday.year, monday.month, monday.day + 7);
      records.add(WorkRecord(date: DateTime(nextWeek.year, nextWeek.month, nextWeek.day + 2), type: WorkType.dayOff));
      return records;
```
`applySeed`는 이른 날짜부터 저장하므로 첫 기록일이 `start`(월요일)가 된다 — 단, `start`가 누락(`n % 11 == 0`)이거나 주말이면 첫 기록일이 밀린다. 테스트의 기대값이 안 맞으면 `start` 날짜의 기록은 조건과 무관하게 `full(start)`로 강제한다.

- [ ] **Step 4: 통과 확인** — `flutter test test/data` → PASS

- [ ] **Step 5: 커밋** — `git add lib/data test/data && git commit -m "디버그 시드: 두 달치 기록 시나리오"`

---

### Task 11: 마무리 검증

- [ ] **Step 1:** `flutter analyze` → No issues. `flutter test` → 전부 PASS.
- [ ] **Step 2:** `flutter build ios --flavor dev --simulator --no-codesign` 또는 `flutter build apk --flavor dev --debug` 중 환경에 맞는 것 하나 → 성공.
- [ ] **Step 3:** 시뮬레이터가 있으면 `flutter run --flavor dev -d <simulator>`로 띄워 `history` 시드 → 주간/월간/시트를 눈으로 확인하고 스크린샷을 `docs/screenshots/2026-09-17-*.png`에 남긴다. 없으면 이 단계는 건너뛰고 보고에 적는다.
- [ ] **Step 4:** 스펙 §"구현 중 내가 정한 것"에 실제 구현하며 추가로 정한 것이 있으면 덧붙이고 커밋.

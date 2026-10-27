# 남은 연차 + 기준일 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 연차 입력을 "올해 총 연차(정수)"에서 "지금 남은 연차(0.5 단위) + 저장한 날이 기준일"로 바꾸고, 잔여를 기준일 다음 날부터의 연차·반차만 빼서 계산한다.

**Architecture:** `AppSettings.annualLeaveDaysByYear: Map<int,int>`를 `leaveBalanceByYear: Map<int, LeaveBalance>`(분 + 기준일)로 교체한다. 계산은 `work_calculator.dart`의 `leaveMinutesUsed(after:)` 하나로 올해 사용·이후 사용·예정을 다 구한다. 저장소는 새 키 둘을 쓰고 옛 키는 읽을 때만 변환한다. 백업은 format 2. 숫자 시트는 소수점 모드·검증·헤드라인·안내 여러 줄·스크롤을 받는 공용 위젯으로 확장하고, 시급 쪽은 호출만 맞춘다.

**Tech Stack:** Flutter, Riverpod(코드젠), freezed, Drift(스키마 v2 유지), flutter_test.

**Spec:** `docs/specs/2026-10-27-leave-balance.md` — 실행자는 스펙과 CLAUDE.md를 함께 읽는다. 디자인 수치는 스펙 §5.

## Global Constraints

- flavor 없이 `flutter run`/`build` 금지. 테스트는 `flutter test`(PATH에 `~/flutter/bin`). 코드젠: `dart run build_runner build --delete-conflicting-outputs`(freezed 변경 후).
- `domain/`에 `package:flutter` import 금지. `presentation/`은 `data/`를 직접 import하지 않는다. 색·글꼴·사이즈는 `AppColors`·`AppTextStyles`·`AppSizes`. 한국어 문자열은 `<feature>_texts.dart`에서만.
- 연차 단위는 분. 1일 = `rules.dayOffCreditMinutes`(480), 입력 단위 `rules.leaveStepMinutes`(240). 한도 0 ≤ 분 ≤ 99 × 480.
- 기준일 당일 연차는 빼지 않는다(`date > baseDate`). 예정은 `date > max(today, baseDate)`.
- Settings 키 `leave_remaining_minutes_<year>` · `leave_base_date_<year>`. 옛 키 `annual_leave_days_<year>`는 읽기만(일 × 480, 기준일 1/1), 저장 시 삭제.
- 백업 `format: 2`, format 1 파일도 읽는다.
- 브랜치 `feature/leave-balance`에서 작업, 끝나면 dev로 병합. 커밋에 AI 표시 없음. push는 사용자가.

## Review Focus

1. **12월에 1월 카드에서 값을 넣는 경우** — 해 2027, 기준일 2026-12-20. 2027년 기록은 모두 기준일 뒤라 "이후 사용"에 다 들어가고, 2026년 기록은 안 들어간다. (Task 4 테스트)
2. **옛 키와 새 키가 같은 해에 둘 다 있을 때** — 새 키가 이기고, 저장하면 옛 키가 사라진다. (Task 2 테스트)
3. **"8." 상태에서 저장** — 비활성이고 오류 줄도 없다. "8.3"은 비활성 + 오류 줄. "0"은 활성. (Task 5 테스트)
4. **format 1 백업에 2026: 15가 있을 때** — 복원 뒤 카드가 "1월 1일 기준 · 남은 연차 15일"로 지금과 같은 잔여를 보여준다. (Task 3 테스트)
5. **키보드가 큰 기기(높이 640)** — 시트 제목이 잘리지 않고 본문이 스크롤되며 저장 버튼이 키보드 위에 있다. (Task 5 테스트)

---

## File Map

| 파일 | 변경 |
|---|---|
| `lib/domain/model/leave_balance.dart` (신규) | `LeaveBalance`(freezed) |
| `lib/domain/model/app_settings.dart` | `leaveBalanceByYear`, `leaveBalanceOf`, `withLeaveBalance`, `maxLeaveDays` |
| `lib/domain/rules/work_rules.dart` | `leaveStepMinutes = 240` |
| `lib/domain/rules/work_calculator.dart` | `leaveMinutesOf`, `leaveMinutesUsed`, `isValidLeaveMinutes`; `usedLeaveHalfDays`·`plannedLeaveHalfDays` 삭제 |
| `lib/core/presentation/format/number_format.dart` | `formatLeaveDays(minutes, dayMinutes)` |
| `lib/data/repository/drift_app_settings_repository.dart` | 새 키 + 옛 키 변환 |
| `lib/domain/model/backup_snapshot.dart`, `lib/domain/backup/backup_codec.dart`, `lib/data/repository/drift_backup_repository.dart` | format 2 |
| `lib/presentation/month/month_state.dart`, `month_state_builder.dart`, `month_texts.dart`, `widgets/leave_card.dart`, `month_screen.dart` | 카드 |
| `lib/presentation/shared/number_input_sheet.dart` | 소수점 모드 · 검증 · 헤드라인 · 안내 여러 줄 · 스크롤 |
| `lib/presentation/settings/settings_texts.dart`, `settings_controller.dart`, `settings_screen.dart` | 연차 행·시트 |
| `lib/ui/app_sizes.dart`, `app_text_styles.dart` | 토큰 |
| `lib/data/seed/debug_seed.dart` | 시드 |
| `CLAUDE.md` | 연차 절 · 설정 키 · 백업 · 테스트 목록 · 화면 규칙 |

---

### Task 1: 도메인 — 모델 · 규칙 · 계산 · 표기

**Files:**
- Create: `lib/domain/model/leave_balance.dart`
- Modify: `lib/domain/model/app_settings.dart`, `lib/domain/rules/work_rules.dart`, `lib/domain/rules/work_calculator.dart:376-396`, `lib/core/presentation/format/number_format.dart:15-16`
- Test: `test/domain/work_calculator_test.dart`(연차 group 교체), `test/core/format_test.dart`, `test/data/drift_app_settings_repository_test.dart:64-70`(모델 테스트)

**Interfaces:**
- Produces:
  - `class LeaveBalance { int remainingMinutes; DateTime baseDate; }` (freezed, `baseDate`는 날짜만)
  - `AppSettings.leaveBalanceByYear: Map<int, LeaveBalance>` · `LeaveBalance? leaveBalanceOf(int year)` · `AppSettings withLeaveBalance(int year, LeaveBalance? b)` · `static const maxLeaveDays = 99`
  - `WorkRules.leaveStepMinutes` (기본 240)
  - `int leaveMinutesOf(WorkType t, WorkRules rules)` · `int leaveMinutesUsed(List<WorkRecord> records, int year, WorkRules rules, {DateTime? after})` · `bool isValidLeaveMinutes(int minutes, WorkRules rules)`
  - `String formatLeaveDays(int minutes, int dayMinutes)`
- `annualLeaveDaysByYear`·`annualLeaveDaysOf`·`withAnnualLeaveDays`·`isValidAnnualLeaveDays`·`maxAnnualLeaveDays`는 **지운다** (컴파일 오류가 남은 호출처를 알려준다 — Task 2~7에서 고친다).

- [ ] **Step 1: 실패하는 테스트**

`test/domain/work_calculator_test.dart`의 `usedLeaveHalfDays`/`plannedLeaveHalfDays` 테스트를 아래로 교체(기존 `rs` 픽스처 유지 — 2026: 연차 2 · 반차 1 포함, 2027: 연차 1).

```dart
test('leaveMinutesOf — 연차 480 · 반차 240 · 그 외 0', () {
  expect(leaveMinutesOf(WorkType.dayOff, rules), 480);
  expect(leaveMinutesOf(WorkType.halfDay, rules), 240);
  expect(leaveMinutesOf(WorkType.holiday, rules), 0);
  expect(leaveMinutesOf(WorkType.businessTrip, rules), 0);
});
test('leaveMinutesUsed — 그 해 전체, 미래 포함, 다른 해 제외', () {
  expect(leaveMinutesUsed(rs, 2026, rules), 1200); // 연차 2 + 반차 1
  expect(leaveMinutesUsed(rs, 2027, rules), 480);
});
test('leaveMinutesUsed(after:) — 기준일 당일은 빼지 않고 다음 날부터', () {
  // rs(2026): 14 연차 · 17 반차 · 24 연차
  expect(leaveMinutesUsed(rs, 2026, rules, after: d(13)), 1200); // 셋 다
  expect(leaveMinutesUsed(rs, 2026, rules, after: d(14)), 720);  // 14 당일 제외
  expect(leaveMinutesUsed(rs, 2026, rules, after: d(17)), 480);  // 24만
  expect(leaveMinutesUsed(rs, 2026, rules, after: d(24)), 0);
  expect(leaveMinutesUsed(rs, 2026, rules, after: d(14, 23, 59)), 720); // after는 날짜만 본다
});
test('isValidLeaveMinutes — 0 허용, 0.5일 단위, 99일 한도', () {
  expect(isValidLeaveMinutes(0, rules), isTrue);
  expect(isValidLeaveMinutes(240, rules), isTrue);
  expect(isValidLeaveMinutes(4080, rules), isTrue);
  expect(isValidLeaveMinutes(120, rules), isFalse);
  expect(isValidLeaveMinutes(99 * 480, rules), isTrue);
  expect(isValidLeaveMinutes(99 * 480 + 240, rules), isFalse);
  expect(isValidLeaveMinutes(-240, rules), isFalse);
});
```

`test/core/format_test.dart`:
```dart
test('formatLeaveDays — 분 → 일, 끝 0 제거', () {
  expect(formatLeaveDays(7200, 480), '15일');
  expect(formatLeaveDays(4080, 480), '8.5일');
  expect(formatLeaveDays(3960, 480), '8.25일');
  expect(formatLeaveDays(0, 480), '0일');
  expect(formatLeaveDays(240, 480), '0.5일');
});
```

`test/data/drift_app_settings_repository_test.dart`의 `annualLeaveDaysOf / withAnnualLeaveDays` 테스트를 `leaveBalanceOf / withLeaveBalance`로 교체(값 `LeaveBalance(remainingMinutes: 4080, baseDate: DateTime(2026, 10, 26))`, null로 지우기).

- [ ] **Step 2: 실패 확인** — `flutter test test/domain/work_calculator_test.dart test/core/format_test.dart` → 컴파일 오류.

- [ ] **Step 3: 구현**

`leave_balance.dart`: freezed `LeaveBalance`. `app_settings.dart`: 필드 교체·헬퍼·`maxLeaveDays`. `work_rules.dart`: `this.leaveStepMinutes = 240` + 주석("남은 연차 입력 단위 — 반반차가 오면 120"). `work_calculator.dart`: 세 함수(`leaveMinutesUsed`는 `records.where((r) => r.date.year == year && (after == null || r.date.isAfter(dateOnly(after))))`). `number_format.dart`: `formatLeaveDays(int minutes, int dayMinutes)` — `minutes % dayMinutes == 0`이면 정수, 아니면 `(minutes / dayMinutes).toStringAsFixed(2)`에서 끝 `0`과 `.` 제거. 코드젠 실행.

- [ ] **Step 4: 통과 확인** — 위 세 테스트 파일 통과. 전체 `flutter test`는 아직 컴파일 오류(호출처) — 정상.

- [ ] **Step 5: Commit** — `연차 모델: 남은 연차(분) + 기준일, 계산·표기 함수`

---

### Task 2: 저장소 — 새 키 + 옛 키 변환

**Files:**
- Modify: `lib/data/repository/drift_app_settings_repository.dart`
- Test: `test/data/drift_app_settings_repository_test.dart`

**Interfaces:**
- Consumes: Task 1의 `LeaveBalance`, `AppSettings.leaveBalanceByYear`.
- Produces: `DriftAppSettingsRepository(AppDatabase db, {WorkRules rules = const WorkRules()})`. 상수 `leaveMinutesKeyPrefix = 'leave_remaining_minutes_'`, `leaveBaseDateKeyPrefix = 'leave_base_date_'`, `legacyAnnualLeaveDaysKeyPrefix = 'annual_leave_days_'`.

- [ ] **Step 1: 실패하는 테스트** (기존 `{2026: 15, 2027: 16}` 픽스처를 `LeaveBalance`로 바꾸고 아래 추가)

```dart
test('새 키 둘로 저장하고 읽는다', () async {
  await repo.save(AppSettings(leaveBalanceByYear: {2026: LeaveBalance(remainingMinutes: 4080, baseDate: DateTime(2026, 10, 26))}));
  final keys = (await db.select(db.settings).get()).map((r) => '${r.key}=${r.value}');
  expect(keys, containsAll(['leave_remaining_minutes_2026=4080', 'leave_base_date_2026=2026-10-26']));
  expect((await repo.read()).leaveBalanceOf(2026), LeaveBalance(remainingMinutes: 4080, baseDate: DateTime(2026, 10, 26)));
});
test('옛 키 annual_leave_days_<year>는 일 × 480 · 기준일 1/1로 읽는다', async () {
  await db.into(db.settings).insert(SettingsCompanion.insert(key: 'annual_leave_days_2026', value: '15'));
  expect((await repo.read()).leaveBalanceOf(2026), LeaveBalance(remainingMinutes: 7200, baseDate: DateTime(2026, 1, 1)));
});
test('옛 키와 새 키가 같이 있으면 새 키가 이기고, 저장하면 옛 키가 사라진다', () async {
  await db.into(db.settings).insert(SettingsCompanion.insert(key: 'annual_leave_days_2026', value: '15'));
  await db.into(db.settings).insert(SettingsCompanion.insert(key: 'leave_remaining_minutes_2026', value: '4080'));
  await db.into(db.settings).insert(SettingsCompanion.insert(key: 'leave_base_date_2026', value: '2026-10-26'));
  expect((await repo.read()).leaveBalanceOf(2026)!.remainingMinutes, 4080);
  await repo.save(await repo.read());
  final keys = (await db.select(db.settings).get()).map((r) => r.key);
  expect(keys, isNot(contains('annual_leave_days_2026')));
});
test('기준일 키가 없거나 못 읽으면 그 해는 없는 것', () async {
  await db.into(db.settings).insert(SettingsCompanion.insert(key: 'leave_remaining_minutes_2026', value: '4080'));
  expect((await repo.read()).leaveBalanceOf(2026), isNull);
});
```
기존 "접두 키만 지운다" 테스트는 세 접두사 모두에 대해 유지(`annual_leave_daysX2026` 같은 키는 남는다).

- [ ] **Step 2: 실패 확인** — `flutter test test/data/drift_app_settings_repository_test.dart`.

- [ ] **Step 3: 구현** — `save`: 세 접두사 키를 Dart에서 골라 지우고 새 키 두 개씩 쓴다. `fromRows(rows, rules)`: 새 키 두 맵을 모아 둘 다 있는 해만 `LeaveBalance`, 없는 해는 옛 키 변환(`days * rules.dayOffCreditMinutes`, `DateTime(year, 1, 1)`). `static` 유지가 어려우면 인스턴스 메서드로 바꾸고 호출처(백업 저장소 `_settings.read()`)는 그대로.

- [ ] **Step 4: 통과 확인** — 같은 파일 통과.

- [ ] **Step 5: Commit** — `설정 저장소: 남은 연차 키 둘, 옛 총 연차 키는 읽기 변환`

---

### Task 3: 백업 format 2

**Files:**
- Modify: `lib/domain/model/backup_snapshot.dart`, `lib/domain/backup/backup_codec.dart`, `lib/data/repository/drift_backup_repository.dart:29,55`
- Test: `test/domain/backup_codec_test.dart`, `test/data/drift_backup_repository_test.dart`

**Interfaces:**
- Consumes: Task 1.
- Produces: `BackupSnapshot.leaveBalanceByYear: Map<int, LeaveBalance>`; `backupFormatVersion = 2`; `decodeBackup(String text, {WorkRules rules = const WorkRules()})`.

- [ ] **Step 1: 실패하는 테스트**

`backup_codec_test.dart` — 픽스처를 `{2026: LeaveBalance(4080, 2026-10-26), 2027: LeaveBalance(7680, 2027-01-01)}`로 바꾸고:
```dart
test('format 2 — leaveBalanceByYear를 분·기준일로 쓴다', () {
  expect(json['format'], 2);
  expect((json['settings'] as Map)['leaveBalanceByYear'], {'2026': {'remainingMinutes': 4080, 'baseDate': '2026-10-26'}, '2027': {'remainingMinutes': 7680, 'baseDate': '2027-01-01'}});
});
test('format 1 파일의 annualLeaveDaysByYear는 일 × 480 · 기준일 1/1로 받는다', () {
  final s = decodeBackup(withPatch((j) => j..['format'] = 1..['settings'] = {'weekStart': 'monday', 'annualLeaveDaysByYear': {'2026': 15}, 'hourlyWage': null}));
  expect(s.leaveBalanceByYear, {2026: LeaveBalance(remainingMinutes: 7200, baseDate: DateTime(2026, 1, 1))});
});
test('범위 밖·단위 안 맞음·기준일 파싱 실패는 그 해만 버린다', () {
  final s = decodeBackup(withPatch((j) => j..['settings'] = {...j['settings'] as Map, 'leaveBalanceByYear': {
    '2026': {'remainingMinutes': 120, 'baseDate': '2026-10-26'},
    '2027': {'remainingMinutes': 4080, 'baseDate': 'nope'},
    '2028': {'remainingMinutes': 0, 'baseDate': '2028-03-01'},
  }}));
  expect(s.leaveBalanceByYear.keys, [2028]);
});
test('format 3은 거부', () { expect(() => decodeBackup(withPatch((j) => j..['format'] = 3)), throwsA(isA<BackupFormatException>())); });
```
`drift_backup_repository_test.dart` — 픽스처를 `LeaveBalance`로, 복원 뒤 `leaveBalanceOf(2026)` 확인. format 1 → 복원 → `read()`가 기준일 1/1 값을 돌려주는 테스트 하나.

- [ ] **Step 2: 실패 확인** — 두 파일.

- [ ] **Step 3: 구현** — 코덱 encode/decode(format 1 분기는 `annualLeaveDaysByYear` 읽기), `BackupSnapshot` 필드 교체, 백업 저장소의 snapshot/restore 필드명 교체. `decodeBackup` 호출처(설정 화면 가져오기)는 기본 rules로 둔다.

- [ ] **Step 4: 통과 확인**. **Step 5: Commit** — `백업 format 2: 남은 연차 + 기준일, format 1 변환`

---

### Task 4: 월간 연차 카드

**Files:**
- Modify: `lib/presentation/month/month_state.dart:46-60`, `month_state_builder.dart:44-54`, `month_texts.dart:42-54`, `widgets/leave_card.dart`, `lib/ui/app_sizes.dart`
- Test: `test/presentation/month_state_builder_test.dart:130-170`, `test/presentation/month_screen_test.dart`(카드 문구)

**Interfaces:**
- Consumes: Task 1.
- Produces:
  ```dart
  MonthLeave { int year; LeaveBalance? balance; int usedMinutes; int plannedMinutes; int? remainingMinutes; int dayMinutes; }
  ```
  `MonthTexts`: `leaveBaseLine(DateTime d)` → "10월 26일 기준" · `leaveBalanceLabel = '남은 연차'` · `leaveUsedYearLabel = '올해 사용'` · `leaveUsedAfterLabel = '이후 사용'` · `leaveRemainLabel = '지금 잔여'` · `leaveOverLabel = '초과'` · `days(int minutes, int dayMinutes)` · `plannedLine(minutes, dayMinutes)` · `leaveNudge = '지금 남은 연차를 알려주시면 잔여를 보여드려요'`. `leaveTotalLabel`·`leaveUsedLabel` 삭제.
  `AppSizes.leaveBaseLineTop` = 4.

- [ ] **Step 1: 실패하는 테스트** (`month_state_builder_test.dart` 130~170 교체; `build(records, {month, settings})` 헬퍼·오늘 9/16 가정 유지)

```dart
test('미입력 — 올해 전체 사용, 잔여 null', () {
  expect(build([rec(14, type: WorkType.dayOff), rec(18, type: WorkType.halfDay)]).leave,
    const MonthLeave(year: 2026, balance: null, usedMinutes: 720, plannedMinutes: 240, remainingMinutes: null, dayMinutes: 480));
});
test('값 있음 — 기준일 다음 날부터만 빼고, 예정은 오늘 뒤', () {
  final b = LeaveBalance(remainingMinutes: 4080, baseDate: DateTime(2026, 9, 14));
  final leave = build([rec(14, type: WorkType.dayOff), rec(15, type: WorkType.halfDay), rec(18, type: WorkType.dayOff)],
    settings: AppSettings(leaveBalanceByYear: {2026: b})).leave;
  expect(leave.usedMinutes, 720);         // 14일은 기준일 당일 → 제외, 15 반차 + 18 연차
  expect(leave.plannedMinutes, 480);      // 18일만 오늘(16) 뒤
  expect(leave.remainingMinutes, 4080 - 720);
});
test('초과 — 잔여 음수', () {
  final b = LeaveBalance(remainingMinutes: 240, baseDate: DateTime(2026, 9, 1));
  expect(build([rec(14, type: WorkType.dayOff)], settings: AppSettings(leaveBalanceByYear: {2026: b})).leave.remainingMinutes, -240);
});
test('12월에 1월 카드에서 넣은 값 — 해 2027, 기준일 2026-12-20: 2027 기록은 전부 이후, 2026 기록은 제외', () {
  final b = LeaveBalance(remainingMinutes: 7200, baseDate: DateTime(2026, 12, 20));
  final leave = build([rec(28, type: WorkType.dayOff), WorkRecord(date: DateTime(2027, 1, 5), type: WorkType.dayOff)],
    month: DateTime(2027, 1), settings: AppSettings(leaveBalanceByYear: {2027: b})).leave;
  expect(leave.year, 2027);
  expect(leave.usedMinutes, 480);
  expect(leave.remainingMinutes, 7200 - 480);
});
```
`month_screen_test.dart`에 카드 문구 테스트: 값 없음 → '미입력'·'올해 사용'·'—'·유도 줄 문구; 값 있음(4080, 10/26) → '10월 26일 기준'·'남은 연차'·'8.5일'·'이후 사용'·'지금 잔여'; 초과 → '초과'.

- [ ] **Step 2: 실패 확인**. 

- [ ] **Step 3: 구현** — `_leave`: `balance = settings.leaveBalanceOf(year)`, `used = leaveMinutesUsed(records, year, rules, after: balance?.baseDate)`, `planned = leaveMinutesUsed(..., after: balance == null || today.isAfter(balance.baseDate) ? today : balance.baseDate)`, `remaining = balance == null ? null : balance.remainingMinutes - used`. `LeaveCard`: 제목 아래 기준일 줄(`balance != null`), 1칸 라벨 `leaveBalanceLabel` 값 `balance == null ? notEntered : days(balance.remainingMinutes)`, 2칸 라벨 분기, 3칸 `remaining < 0 ? leaveOverLabel : leaveRemainLabel`. `month_screen.dart`의 `onOpenAnnual`은 Task 6에서 바꾼다 — 지금은 컴파일만 되게 `settings.leaveBalanceOf(...)`를 쓰되 시트 호출은 그대로 두면 `int?`가 안 맞으니 **임시로 `initial: null`**로 둔다.

- [ ] **Step 4: 통과 확인** — 두 테스트 파일. **Step 5: Commit** — `월간 연차 카드: 기준일 줄, 올해/이후 사용, 지금 잔여`

---

### Task 5: 숫자 입력 시트 — 소수점 모드 · 검증 · 헤드라인 · 안내 여러 줄 · 스크롤

**Files:**
- Modify: `lib/presentation/shared/number_input_sheet.dart`, `lib/ui/app_sizes.dart`, `lib/ui/app_text_styles.dart`
- Test: `test/presentation/number_input_sheet_test.dart`(기존 — 시급 모드 테스트를 유지하고 연차 모드를 추가)

**Interfaces:**
- Produces (호출부가 바뀌는 시그니처):
  ```dart
  Future<void> showNumberInputSheet(BuildContext context, {
    required String title, String? headline, required String unit,
    required List<String> notes, String? highlightNote, bool lockIcon = false,
    required int maxDigits, int decimalPlaces = 0, bool grouping = false,
    String? emptyCaption, bool Function(num value)? isValid, String? invalidNote,
    num? initial, required String saveLabel, required String clearLabel,
    required ValueChanged<num> onSave, VoidCallback? onClear,
  })
  ```
  - `isValid` 기본 `(v) => v > 0`(시급·기존 동작). 저장 활성 = 텍스트가 비어 있지 않고 숫자로 파싱되고 `isValid`.
  - `invalidNote`는 텍스트가 비어 있지 않고 점이 있고 끝이 점이 아닌데 `isValid`가 거짓일 때만 입력줄 아래 `minus` 색 13.
  - `decimalPlaces > 0`이면 `TextInputType.numberWithOptions(decimal: true)`, 포매터는 ","→".", 숫자와 첫 "."만, 정수 `maxDigits`자리, 소수 `decimalPlaces`자리, 앞자리 0 정리, "."부터 치면 "0.".
  - `initial` 표시: `num`이 정수면 "15", 아니면 끝 0 제거("8.5").
  - 레이아웃: 핸들·제목·헤드라인·입력줄·오류 줄·안내는 `Flexible(child: SingleChildScrollView)` 안, 저장·되돌리기는 밖(키보드 위 고정).
  - 토큰: `AppSizes.numberHeadlineTop` 12, `numberFieldTopWithHeadline` 4, `numberFieldPaddingCompact` (2, 6, 2, 8), `numberInvalidTop` 6, `numberNotesTop` 12, `numberSaveTopCompact` 12; `AppTextStyles.numberInvalid`(13, `minus`), `numberHighlightNote`(13 lh 1.55 `brand`), `numberNotes`(13 lh 1.55 `subtle`), `numberEmptyCaption`(13 `subtle`).

- [ ] **Step 1: 실패하는 테스트** — 시트를 `pumpWidget`으로 띄우는 헬퍼(기존 테스트가 있으면 재사용). 연차 모드 = `decimalPlaces: 2, maxDigits: 2, emptyCaption: '입력 전', isValid: (v) => v >= 0 && (v * 480) % 240 == 0, invalidNote: '0.5일 단위로 넣어주세요', headline: '오늘(10월 26일) 기준 남은 연차', notes: [a, b, c], highlightNote: '이 뒤로 찍어둔 연차 1.5일은 여기서 빼서 보여드려요.'`.

```dart
testWidgets('빈 값 — "0" 플레이스홀더 + "입력 전", 저장 비활성, 오류 줄 없음', ...);   // find.text('입력 전') one, 저장 onTap null
testWidgets('"8.5" — 저장 활성, onSave(8.5)', ...);
testWidgets('"0" — 저장 활성(0 허용)', ...);
testWidgets('"8." — 비활성, 오류 줄 없음', ...);
testWidgets('"8.3" — 비활성, "0.5일 단위로 넣어주세요"', ...);
testWidgets('"," 입력은 "."로, 소수 셋째 자리는 무시, 정수 3자리는 무시', ...);         // "8,5"→"8.5", "8.255"→"8.25", "123"→"12"
testWidgets('initial 4080/480=8.5 → "8.5", 7200/480=15 → "15"', ...);
testWidgets('헤드라인·안내 세 줄·강조 줄이 보인다', ...);
testWidgets('높이 640 + 키보드 300 — 저장 버튼이 보이고 제목은 스크롤로 닿는다', ...); // tester.view.physicalSize, MediaQuery viewInsets 주입
testWidgets('시급 모드(기존) — 0은 비활성, 콤마, 7자리 한도 유지', ...);                 // 기존 테스트 유지
```

- [ ] **Step 2: 실패 확인**. **Step 3: 구현** (위 인터페이스대로). **Step 4: 통과 확인**. 
- [ ] **Step 5: Commit** — `숫자 시트: 소수점 모드·단위 검증·헤드라인·안내 여러 줄·본문 스크롤`

---

### Task 6: 설정 행 · 시트 연결 · 월간 유도 줄

**Files:**
- Modify: `lib/presentation/settings/settings_texts.dart`, `settings_controller.dart:22`, `settings_screen.dart:55-80,175-200`, `lib/presentation/month/month_screen.dart:66-78`
- Test: `test/presentation/settings_view_test.dart`, `test/presentation/settings_backup_flow_test.dart`(연차 저장 흐름 하나), `test/presentation/month_screen_test.dart`(유도 줄 탭 → 시트 제목)

**Interfaces:**
- Consumes: Task 1·4·5.
- Produces: `SettingsController.setLeaveBalance(int year, LeaveBalance? balance)`. `SettingsTexts`: `annualLabel = '남은 연차'` · `annualSub = '알려주시면 월간 탭에서 잔여 연차를 볼 수 있어요'` · `annualBaseLine(DateTime d)` "10월 26일 기준" · `annualHeadline(DateTime today)` "오늘(10월 26일) 기준 남은 연차" · `annualNotes: List<String>`(세 줄) · `annualFutureNote(int minutes, int dayMinutes)` "이 뒤로 찍어둔 연차 1.5일은 여기서 빼서 보여드려요." · `annualEmptyCaption = '입력 전'` · `annualInvalidNote = '0.5일 단위로 넣어주세요'` · `annualValue(LeaveBalance?, int dayMinutes)` · `annualMaxDigits = 2` · `annualDecimalPlaces = 2`. `annualNote` 삭제.
- 시트를 여는 코드는 한 곳 — `presentation/settings/leave_sheet.dart`(신규)의 `Future<void> showLeaveBalanceSheet(BuildContext, {required int year, required DateTime today, required LeaveBalance? current, required List<WorkRecord> records, required WorkRules rules, required SettingsController controller})`. 설정 화면과 월간 화면이 둘 다 부른다. 기록은 `allRecordsProvider`에서(`.value ?? const []`).

- [ ] **Step 1: 실패하는 테스트** — `settings_view_test.dart`: 빈 상태 '남은 연차'·'알려주시면 월간 탭에서 잔여 연차를 볼 수 있어요'·'사용 안 함'; 채운 상태(4080, 10/26) '10월 26일 기준'·'8.5일'; 탭 → `taps` 'annual'. 폭 320·600 스냅샷 테스트의 픽스처를 `LeaveBalance`로. `settings_backup_flow_test.dart`(또는 신규 `leave_sheet_test.dart`): 시트에서 "8.5" 저장 → 저장소에 `LeaveBalance(4080, 오늘)`; 되돌리기 → null; 그 해 미래 연차가 있으면 강조 줄이 보인다("이 뒤로 찍어둔 연차 1일은 …"), 없으면 안 보인다. `month_screen_test.dart`: 유도 줄 탭 → '남은 연차' 시트 제목이 뜬다.

- [ ] **Step 2: 실패 확인**. **Step 3: 구현** — 컨트롤러·텍스트·`leave_sheet.dart`(저장: `LeaveBalance(remainingMinutes: (v * rules.dayOffCreditMinutes).round(), baseDate: dateOnly(today))`, 미래 연차 분 = `leaveMinutesUsed(records, year, rules, after: today)`), 설정 화면·월간 화면 호출 교체(Task 4의 임시 `initial: null` 제거). **Step 4: 통과 확인** — 전체 `flutter test` 통과·`flutter analyze` 무경고.
- [ ] **Step 5: Commit** — `설정·월간: 남은 연차 시트 연결, 기준일 표시`

---

### Task 7: 시드 · CLAUDE.md · 마무리

**Files:**
- Modify: `lib/data/seed/debug_seed.dart:41`, `test/data/debug_seed_test.dart:96`, `CLAUDE.md`(연차 절 · 데이터 모델의 설정 키 · 백업 문단 · 테스트 목록 · 프레젠테이션 규칙의 숫자 시트·월간 카드)

- [ ] **Step 1: 시드 테스트 수정** — `expect(settings.leaveBalanceOf(today.year), LeaveBalance(remainingMinutes: 15 * 480, baseDate: DateTime(today.year, 1, 1)))`. 실패 확인 → 시드 구현 → 통과.
- [ ] **Step 2: CLAUDE.md** — "연차 (2026-10-25)" 절을 스펙 §1~§3 요약으로 교체(날짜 2026-10-27), 설정 키·백업 `format: 2`·옛 키 변환 한 줄, 테스트 목록에 "기준일 다음 날부터 차감 · 옛 키/format 1 변환 · 0·0.5 저장 · 시트 단위 검증·스크롤", 프레젠테이션 규칙의 숫자 시트(소수점 모드·헤드라인·안내 네 줄·"입력 전")와 월간 카드(기준일 줄 · 남은 연차/올해·이후 사용/지금 잔여) 갱신. 스펙 파일 경로를 적는다.
- [ ] **Step 3: 전체 검증** — `flutter analyze` 무경고, `flutter test` 전부 통과. 시뮬레이터가 있으면 `flutter drive --flavor dev --target test_driver/app.dart -d <ID>`로 스크린샷을 확인한다(선택).
- [ ] **Step 4: Commit** — `시드·CLAUDE.md: 남은 연차 + 기준일`, 그리고 `dev`로 `--no-ff` 병합.

# 공휴일 근무 · 출장 · 시간공제 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 공휴일에도 근무를 기록할 수 있게 하고(주말처럼 계산), 출장 유형과 시간공제(그날 기준시간에서 직접 빼는 시간)를 추가한다.

**Architecture:** 규칙은 전부 `domain/rules/work_calculator.dart`의 순수 함수에 모은다 — "그날 기준시간" 하나(`dayStandardMinutes`)가 목표·기준 대비·오늘 몫·누락 판정을 모두 끌고 간다. 데이터는 `WorkRecord`에 `deductionMinutes`·`deductionReason` 두 필드, Drift는 v1→v2 addColumn. 저장 직전 `sanitizeRecord`로 불변식(쉬는 날엔 공제·시각 없음 등)을 한 곳에서 강제한다.

**Tech Stack:** Flutter, Riverpod(코드젠), freezed, Drift 2.35(+drift_dev), flutter_test.

**Spec:** `docs/specs/2026-09-27-holiday-work-trip-deduction.md` — 실행자는 이 스펙과 CLAUDE.md를 함께 읽는다.

## Global Constraints

- flavor 없이 `flutter run`/`build` 금지. 테스트는 `flutter test`로 충분하다.
- 코드젠: `dart run build_runner build --delete-conflicting-outputs` (freezed·riverpod·drift 변경 후 매번).
- `domain/`에 `package:flutter` import 금지. `presentation/`은 `data/` 직접 import 금지.
- 색·글꼴·사이즈 하드코딩 금지 — `AppColors`·`AppTextStyles`·`AppSizes` 토큰.
- 위젯 안에 한국어 문자열 금지 — `<feature>_texts.dart`에서만.
- 토스트는 `presentation/shared/app_toast.dart`만.
- 커밋 메시지에 AI 표시(Co-Authored-By 등)를 붙이지 않는다. dev 브랜치에 커밋, push 하지 않는다.
- 시간공제 휠: 시간 0–8, 분 00–50 10분 단위. 사유 최대 20자, 선택.
- 쉬는 날(`isOffType`) = 연차·공휴일·출장. 시간공제 가능한 날 = 평일 && (일반 || 반차).

## Review Focus

1. **v1 데이터가 있는 폰에서 업데이트** — 기존 기록·첫 기록일이 그대로이고 공제 0/사유 null로 읽힌다. (Task 2 마이그레이션 테스트)
2. **공제가 있던 날을 연차·출장·공휴일로 바꿈** — 공제·사유가 지워져 목표가 이중으로 줄지 않는다. (Task 1 `sanitizeRecord`, Task 2 repo 테스트, Task 3 `setDayType` 테스트)
3. **반차 날 "공제하고 퇴근"인데 이미 4h 넘게 일함** — 공제 0, 음수 아님. 반차에 5h 공제 입력 시 저장 불가. (Task 1, Task 4)
4. **공휴일 오늘 출근 취소** — 기록이 지워지지 않고 공휴일이 남는다. (Task 3)
5. **작은 기기(320×568)에서 사유 입력 중 키보드** — 시트가 키보드 위로 올라와 입력칸과 저장 버튼이 보인다. (Task 5 위젯 테스트: `viewInsets` 주입 후 저장 버튼 hit-test 가능)

---

## File Map

| 파일 | 변경 |
|---|---|
| `lib/domain/model/work_type.dart` | `businessTrip` 추가 |
| `lib/domain/model/work_record.dart` | `deductionMinutes`, `deductionReason` |
| `lib/domain/rules/work_rules.dart` | `businessTripCreditMinutes`, `deductionStepMinutes` |
| `lib/domain/rules/week_summary.dart` | `businessTripCount`, `deductionMinutes` |
| `lib/domain/rules/work_calculator.dart` | 기준시간·공휴일 근무·출장·공제·잠금·정리 함수 |
| `lib/data/database/app_database.dart` | 컬럼 2개, v2, migration |
| `lib/data/repository/drift_work_record_repository.dart` | 매핑 + save 시 sanitize |
| `drift_schemas/drift_schema_v2.json`, `test/generated_migrations/` | 스키마 덤프·검증 코드 |
| `lib/presentation/today/*` | 출장 라디오·상태, 공휴일 출근, 공제하고 퇴근 |
| `lib/presentation/record_edit/*` | 4유형, 공제 행·휠·사유, 공휴일 근무 펼침, 출근 전 오늘 = 유형 전용 |
| `lib/presentation/record_edit/widgets/wheel_column.dart` (신규) | TimeWheel·DurationWheel 공용 휠 열 |
| `lib/presentation/record_edit/widgets/duration_wheel.dart` (신규) | 시간·분 휠 |
| `lib/presentation/record_edit/widgets/reason_field.dart` (신규) | 사유 입력칸 |
| `lib/presentation/week/*`, `lib/presentation/month/*` | 배지·요약·공휴일 근무·범례·잠금 |
| `lib/presentation/shared/type_tag.dart` | 색을 직접 받도록 일반화 |
| `lib/ui/app_colors.dart`, `app_sizes.dart`, `app_text_styles.dart` | 출장·공제 토큰 |
| `lib/data/seed/debug_seed.dart` | 시드에 새 케이스 |
| `CLAUDE.md` | 계산 규칙·모델·화면 갱신 |

---

### Task 1: 도메인 — 유형·모델·계산

**Files:**
- Modify: `lib/domain/model/work_type.dart`, `lib/domain/model/work_record.dart`, `lib/domain/rules/work_rules.dart`, `lib/domain/rules/week_summary.dart`, `lib/domain/rules/work_calculator.dart`
- Modify (rename only): `lib/presentation/week/week_state.dart`, `week_state_builder.dart`, `week_screen.dart`, `lib/presentation/month/month_state.dart`, `month_state_builder.dart`, `month_screen.dart` — `isTodayInProgress` → `isTodayWorking`, `weekendMinutes` → `excludedMinutes`
- Modify: `lib/ui/app_colors.dart` (`typeColors`에 businessTrip 분기 — switch exhaustiveness 때문에 여기서 컴파일이 깨진다), 그 외 `WorkType` switch가 있는 texts 파일(`record_edit_texts.dart`, `week_texts.dart`)에 `businessTrip => '출장'` 분기
- Test: `test/domain/work_calculator_test.dart`, `test/helpers/records.dart`

**Interfaces — Produces:**
```dart
enum WorkType { normal, halfDay, dayOff, holiday, businessTrip }
WorkRecord(..., @Default(0) int deductionMinutes, String? deductionReason)
WorkRules.businessTripCreditMinutes (480), WorkRules.deductionStepMinutes (10)
WeekSummary(..., required int businessTripCount, required int deductionMinutes)

bool isOffType(WorkType t);                                   // dayOff·holiday·businessTrip
bool canDeduct(DateTime date, WorkType t);                     // 평일 && normal|halfDay
bool countsTowardWeek(WorkRecord r);                           // 평일 && holiday 아님
int standardMinutes(WorkType type, WorkRules rules);           // 기본 기준 (공제 전) — 기존 시그니처 유지
int dayStandardMinutes(WorkRecord? r, WorkRules rules);        // max(0, 기본 − 공제). null이면 8h
int? actualMinutes(WorkRecord r, WorkRules rules);             // 공휴일 근무 포함
int? deltaMinutes(WorkRecord r, WorkRules rules);              // 주말·공휴일 null
int excludedMinutes(List<WorkRecord>, DateTime monday, WorkRules); // 주말 + 공휴일 근무
int closingDeduction(WorkRecord r, DateTime clockOut, WorkRules rules);
bool isValidDeduction(WorkType type, int minutes, WorkRules rules);
bool isTodayWorking(WorkRecord? r, DateTime date, DateTime today);
WorkRecord sanitizeRecord(WorkRecord r);
```

- [ ] **Step 1: 헬퍼 확장** — `test/helpers/records.dart`의 `rec`에 `int ded = 0, String? reason` 파라미터를 추가해 `deductionMinutes: ded, deductionReason: reason`으로 넘긴다.

- [ ] **Step 2: 실패하는 테스트 작성** — `test/domain/work_calculator_test.dart`에 추가(기존 `standardMinutes`·`actualMinutes` 공휴일 케이스와 `isTodayInProgress`·`weekendMinutes` 그룹은 아래로 교체):

```dart
  group('공휴일 근무', () {
    test('점심 공제 없음', () {
      expect(deductsLunch(rec(14, type: WorkType.holiday)), isFalse);
      expect(actualMinutes(rec(14, inH: 10, outH: 15, type: WorkType.holiday), rules), 300);
    });
    test('시각 없는 공휴일은 0', () => expect(actualMinutes(rec(14, type: WorkType.holiday), rules), 0));
    test('기준 대비 없음', () => expect(deltaMinutes(rec(14, inH: 10, outH: 15, type: WorkType.holiday), rules), isNull));
    test('주간 실적에서 빠지고 목표는 −8h', () {
      final s = weekSummary(
        records: [rec(14, inH: 10, outH: 15, type: WorkType.holiday), rec(15, inH: 9, outH: 18)],
        monday: d(14), rules: rules, now: d(15, 20), firstRecordDate: d(7),
      );
      expect(s.targetMinutes, 2400 - 480);
      expect(s.workedMinutes, 480);
      expect(s.holidayCount, 1);
    });
    test('excludedMinutes = 주말 + 공휴일 근무', () {
      final records = [rec(14, inH: 10, outH: 15, type: WorkType.holiday), rec(19, inH: 10, outH: 14)];
      expect(excludedMinutes(records, d(14), rules), 300 + 240);
    });
    test('누락 아님', () {
      expect(unrecordedWeekdays(records: [rec(14, type: WorkType.holiday)], today: d(16), firstRecordDate: d(14)), [d(15)]);
    });
  });

  group('출장', () {
    test('기준 0, 실근무 0, 쉬는 날', () {
      expect(standardMinutes(WorkType.businessTrip, rules), 0);
      expect(actualMinutes(rec(14, type: WorkType.businessTrip), rules), 0);
      expect(isOffType(WorkType.businessTrip), isTrue);
    });
    test('목표 −8h, 개수 집계', () {
      final s = weekSummary(records: [rec(14, type: WorkType.businessTrip)], monday: d(14), rules: rules, now: d(14, 12), firstRecordDate: d(7));
      expect(s.targetMinutes, 1920);
      expect(s.businessTripCount, 1);
    });
    test('근무일에서 빠진다 — 금요일 출장이면 목요일이 마지막', () {
      final records = [rec(18, type: WorkType.businessTrip)];
      expect(isLastWorkday(records, d(17)), isTrue);
      expect(remainingWorkdays(records, d(14)), 4);
    });
    test('누락 아님', () {
      expect(unrecordedWeekdays(records: [rec(14, type: WorkType.businessTrip)], today: d(15), firstRecordDate: d(14)), isEmpty);
    });
  });

  group('시간공제', () {
    test('그날 기준시간 = 기본 − 공제, 0 미만 없음', () {
      expect(dayStandardMinutes(rec(14, ded: 120), rules), 360);
      expect(dayStandardMinutes(rec(14, type: WorkType.halfDay, ded: 60), rules), 180);
      expect(dayStandardMinutes(rec(14, type: WorkType.halfDay, ded: 300), rules), 0);
      expect(dayStandardMinutes(null, rules), 480);
    });
    test('주간 목표에서 빠지고 합계가 집계된다 (미래 공제도 즉시)', () {
      final s = weekSummary(
        records: [rec(14, inH: 9, outH: 18, ded: 60), rec(18, ded: 150)],
        monday: d(14), rules: rules, now: d(14, 20), firstRecordDate: d(7),
      );
      expect(s.targetMinutes, 2400 - 210);
      expect(s.deductionMinutes, 210);
    });
    test('기준 대비에 반영, 실근무·점심은 그대로', () {
      final r = rec(14, inH: 9, outH: 15, ded: 120); // 실근무 5h, 기준 6h
      expect(actualMinutes(r, rules), 300);
      expect(deltaMinutes(r, rules), -60);
    });
    test('오늘 몫: 공제는 그날에만 반영', () {
      // 월요일, 이번 주 기록 없음, 오늘 2h 공제 → 목표 38h / 5일. 공제 없던 셈 40h/5 = 8h, 오늘 몫 = 8h − 2h
      final records = [rec(14, ded: 120)];
      expect(todayShareMinutes(records: records, today: d(14), rules: rules, firstRecordDate: d(7)), 360);
      // 같은 주 수요일 공제는 월요일 몫에 영향 없음
      final later = [rec(16, ded: 120)];
      expect(todayShareMinutes(records: later, today: d(14), rules: rules, firstRecordDate: d(7)), 480);
    });
    test('반차 오늘 몫 = 4h − 공제', () {
      expect(todayShareMinutes(records: [rec(14, type: WorkType.halfDay, ded: 60)], today: d(14), rules: rules, firstRecordDate: d(7)), 180);
    });
    test('공제로 기준 0이 된 날은 누락 아님', () {
      expect(unrecordedWeekdays(records: [rec(14, ded: 480)], today: d(15), firstRecordDate: d(14)), isEmpty);
    });
    test('isValidDeduction: 반차는 4h까지', () {
      expect(isValidDeduction(WorkType.normal, 480, rules), isTrue);
      expect(isValidDeduction(WorkType.halfDay, 240, rules), isTrue);
      expect(isValidDeduction(WorkType.halfDay, 250, rules), isFalse);
    });
    test('closingDeduction = max(0, 기본 − 실근무)', () {
      expect(closingDeduction(rec(14, inH: 9), d(14, 15), rules), 180); // 5h 근무
      expect(closingDeduction(rec(14, inH: 9, type: WorkType.halfDay), d(14, 11), rules), 120);
      expect(closingDeduction(rec(14, inH: 9, type: WorkType.halfDay), d(14, 14), rules), 0); // 이미 초과
      expect(closingDeduction(rec(14, inH: 9, ded: 60), d(14, 16, 13), rules), 107); // 기존 공제는 무시하고 다시 계산
    });
  });

  group('sanitizeRecord', () {
    test('쉬는 날은 공제·사유를 지우고, 연차·출장은 시각도 지운다', () {
      final dayOff = sanitizeRecord(rec(14, inH: 9, outH: 18, type: WorkType.dayOff, ded: 60, reason: 'x'));
      expect((dayOff.clockIn, dayOff.clockOut, dayOff.deductionMinutes, dayOff.deductionReason), (null, null, 0, null));
      final holiday = sanitizeRecord(rec(14, inH: 10, outH: 15, type: WorkType.holiday, ded: 60));
      expect((holiday.clockIn, holiday.deductionMinutes), (d(14, 10), 0));
    });
    test('주말은 공제 없음', () => expect(sanitizeRecord(rec(19, ded: 60)).deductionMinutes, 0));
    test('공제 0이면 사유 null, 빈 사유는 null, 앞뒤 공백 제거', () {
      expect(sanitizeRecord(rec(14, reason: '공문')).deductionReason, isNull);
      expect(sanitizeRecord(rec(14, ded: 60, reason: '  ')).deductionReason, isNull);
      expect(sanitizeRecord(rec(14, ded: 60, reason: ' 공문 ')).deductionReason, '공문');
    });
  });

  test('isTodayWorking: 오늘 && 출근만 찍힘', () {
    expect(isTodayWorking(rec(16, inH: 9), d(16), d(16, 12)), isTrue);
    expect(isTodayWorking(null, d(16), d(16, 12)), isFalse); // 출근 전은 유형 전용 시트가 열린다
    expect(isTodayWorking(rec(16, type: WorkType.dayOff), d(16), d(16, 12)), isFalse);
    expect(isTodayWorking(rec(16, inH: 9, outH: 18), d(16), d(16, 12)), isFalse);
    expect(isTodayWorking(rec(15, inH: 9), d(15), d(16, 12)), isFalse);
  });
```

또 기존 `standardMinutes` 그룹에 `expect(standardMinutes(WorkType.businessTrip, rules), 0);`, 기존 "연차·공휴일은 출퇴근과 무관하게 0" 테스트는 연차만 남기고 공휴일 줄은 위 공휴일 그룹으로 옮긴다.

- [ ] **Step 3: 실패 확인** — `flutter test test/domain/work_calculator_test.dart` → 컴파일 에러(`businessTrip`, `ded` 등 없음).

- [ ] **Step 4: 모델·규칙 구현**

`work_type.dart`:
```dart
/// 근무 유형. 주말은 넣지 않는다 — date.weekday로 안다.
enum WorkType { normal, halfDay, dayOff, holiday, businessTrip }
```
`work_record.dart` 필드 추가:
```dart
    @Default(WorkType.normal) WorkType type,
    /// 시간공제(분). 그날 기준시간에서 뺀다. 평일 일반·반차에만 의미가 있다 — [sanitizeRecord].
    @Default(0) int deductionMinutes,
    /// 시간공제 사유. 선택. 공제가 0이면 null.
    String? deductionReason,
```
`work_rules.dart`: 생성자에 `this.businessTripCreditMinutes = 480, this.deductionStepMinutes = 10,` + 필드와 주석(`/// 출장 1일 차감량 (8h)`, `/// 시간공제 휠의 분 단위`).
`week_summary.dart`: `required int businessTripCount, required int deductionMinutes,` 추가.

- [ ] **Step 5: 계산 구현** — `work_calculator.dart`:

```dart
// ---- 하루 단위 ----

/// 쉬는 날 — 목표에서 하루가 통째로 빠지고 근무일로 세지 않는다.
bool isOffType(WorkType t) => t == WorkType.dayOff || t == WorkType.holiday || t == WorkType.businessTrip;

/// 시간공제를 가질 수 있는 날: 평일 && 일반·반차.
bool canDeduct(DateTime date, WorkType t) => !isWeekend(date) && (t == WorkType.normal || t == WorkType.halfDay);

/// 주 40시간 실적에 들어가는 날. 주말·공휴일 근무는 기록만 되고 빠진다.
bool countsTowardWeek(WorkRecord r) => !isWeekend(r.date) && r.type != WorkType.holiday;

/// 점심 공제 조건: 반차가 아니고, 주말이 아니고, 공휴일이 아닐 것.
bool deductsLunch(WorkRecord r) =>
    r.type != WorkType.halfDay && r.type != WorkType.holiday && !isWeekend(r.date);

/// 유형의 기본 기준시간 (시간공제 전).
int standardMinutes(WorkType type, WorkRules rules) => switch (type) {
      WorkType.normal => rules.dailyStandardMinutes,
      WorkType.halfDay => rules.halfDayCreditMinutes,
      WorkType.dayOff || WorkType.holiday || WorkType.businessTrip => 0,
    };

/// 그날 기준시간 = 기본 − 시간공제. 기록 없는 평일은 8h.
int dayStandardMinutes(WorkRecord? r, WorkRules rules) {
  if (r == null) return rules.dailyStandardMinutes;
  return math.max(0, standardMinutes(r.type, rules) - r.deductionMinutes);
}

/// 하루 실근무. 연차·출장은 0, 시각 없는 공휴일은 0, 출퇴근이 비면 null.
int? actualMinutes(WorkRecord r, WorkRules rules) {
  if (r.type == WorkType.dayOff || r.type == WorkType.businessTrip) return 0;
  final clockIn = r.clockIn;
  final clockOut = r.clockOut;
  if (clockIn == null || clockOut == null) return r.type == WorkType.holiday ? 0 : null;
  final raw = clockOut.difference(clockIn).inMinutes;
  final lunch = deductsLunch(r) ? rules.lunchBreakMinutes : 0;
  return math.max(0, raw - lunch);
}
```
`deltaMinutes`: 첫 줄을 `if (isWeekend(r.date) || r.type == WorkType.holiday) return null;`로, 마지막을 `return actual - dayStandardMinutes(r, rules);`로.

추가 함수:
```dart
/// "남은 시간 공제하고 퇴근" — 퇴근 순간 기본 기준에서 실근무를 뺀 나머지. 기존 공제는 무시하고 새로 잡는다.
int closingDeduction(WorkRecord r, DateTime clockOut, WorkRules rules) {
  final worked = actualMinutes(r.copyWith(clockOut: clockOut), rules) ?? 0;
  return math.max(0, standardMinutes(r.type, rules) - worked);
}

/// 반차 날은 4h, 일반은 8h까지.
bool isValidDeduction(WorkType type, int minutes, WorkRules rules) =>
    minutes >= 0 && minutes <= standardMinutes(type, rules);

/// 저장 직전 불변식. 쉬는 날·주말은 공제 없음, 연차·출장은 시각 없음, 공제 0이면 사유 없음.
WorkRecord sanitizeRecord(WorkRecord r) {
  final deduction = canDeduct(r.date, r.type) ? r.deductionMinutes : 0;
  final reason = r.deductionReason?.trim();
  final dropTimes = r.type == WorkType.dayOff || r.type == WorkType.businessTrip;
  return r.copyWith(
    clockIn: dropTimes ? null : r.clockIn,
    clockOut: dropTimes ? null : r.clockOut,
    deductionMinutes: deduction,
    deductionReason: deduction == 0 || reason == null || reason.isEmpty ? null : reason,
  );
}
```
`isTodayInProgress` → 교체:
```dart
/// 오늘 근무 중(출근만 찍힘). 주간·월간에서 탭해도 시트 대신 토스트 — 퇴근은 오늘 화면이 찍는다.
/// 출근 전 오늘은 미래처럼 유형·시간공제만 고르는 시트가 열리고, 퇴근까지 찍힌 오늘은 다른 날처럼 편집한다.
bool isTodayWorking(WorkRecord? record, DateTime date, DateTime today) =>
    dateOnly(date) == dateOnly(today) && record?.clockIn != null && record?.clockOut == null;
```

`weekSummary` 루프:
```dart
    final type = r?.type ?? WorkType.normal;
    reduction += rules.dailyStandardMinutes - dayStandardMinutes(r, rules);
    deduction += r == null ? 0 : sanitizedDeduction(r); // 아래 설명
    switch (type) { ... case WorkType.businessTrip: trips++; ... }
    if (r != null && countsTowardWeek(r)) {
      worked += actualMinutes(r, rules) ?? ongoingMinutes(r, now, rules) ?? 0;
    }
```
`deduction` 집계는 `canDeduct(r.date, r.type) ? r.deductionMinutes : 0` (저장 전 sanitize를 거치지만 방어적으로). WeekSummary에 `businessTripCount: trips, deductionMinutes: deduction`.

`weekendMinutes` → `excludedMinutes`:
```dart
/// 주 40시간 집계에서 빠지는 근무 — 주말 + 공휴일 근무. 근거 문구에만 쓴다.
int excludedMinutes(List<WorkRecord> records, DateTime monday, WorkRules rules) {
  final start = dateOnly(monday);
  var sum = 0;
  for (final r in records) {
    final day = dateOnly(r.date);
    if (mondayOf(day) != start || countsTowardWeek(r)) continue;
    if (r.clockIn == null || r.clockOut == null) continue;
    sum += actualMinutes(r, rules) ?? 0;
  }
  return sum;
}
```
`_isOff(r)` → `r != null && isOffType(r.type)`.

`weekRemainingBeforeToday` 루프: `reduction += rules.dailyStandardMinutes - dayStandardMinutes(r, rules);`, `if (weekday.isBefore(day) && r != null && countsTowardWeek(r)) workedBefore += ...`.

`todayShareMinutes`:
```dart
  final day = dateOnly(today);
  final byDate = recordsByDate(records);
  final r = byDate[day];
  if (_isOff(r)) return null;
  final todayDeduction = r?.deductionMinutes ?? 0;
  if (r?.type == WorkType.halfDay) return math.max(0, rules.halfDayCreditMinutes - todayDeduction);
  final remaining = weekRemainingBeforeToday(records: records, today: day, rules: rules, firstRecordDate: firstRecordDate);
  if (remaining == null) return null;
  final days = workdaysOfWeek(records, mondayOf(day)).where((d) => !d.isBefore(day)).toList();
  if (days.isEmpty) return null;
  // 공제는 그날에만 — 남은 날들의 공제를 되돌려 균등 배분한 뒤 오늘 공제만 뺀다.
  final pendingDeductions = days.fold<int>(0, (sum, d) => sum + (byDate[d]?.deductionMinutes ?? 0));
  return ((remaining + pendingDeductions) / days.length).round() - todayDeduction;
```

`unrecordedWeekdays` 판정:
```dart
      final r = byDate[cursor];
      final needsClock = dayStandardMinutes(r, rules) > 0;
```
→ `rules`가 필요하므로 시그니처에 `WorkRules rules = const WorkRules()` 대신 **`required WorkRules rules`**를 추가하고 호출부(`today_state_builder.dart`, 기존 테스트)를 고친다. 위 새 테스트들도 `rules: rules`를 넘기도록 작성한다.

- [ ] **Step 6: 컴파일 복구** — `dart run build_runner build --delete-conflicting-outputs`. 이어서:
  - `app_colors.dart` `typeColors`에 `WorkType.businessTrip => (tripBackground, tripText)`와 토큰 `tripBackground = Color(0xFFD3DDE3)`, `tripBorder = Color(0xFFC3D0D8)`, `tripText = Color(0xFF3F5866)` 추가(청회색, 기존 유형과 같은 채도).
  - `record_edit_texts.dart` `chipLabel`, `week_texts.dart` `badgeLabel`에 `WorkType.businessTrip => '출장'`.
  - 주간·월간 `isTodayInProgress` 필드를 `isTodayWorking`으로 이름만 바꾸고 builder에서 `isTodayWorking(r, date, today)` 호출. `WeekState.weekendMinutes` → `excludedMinutes`.
  - `flutter analyze` 에러 0.

- [ ] **Step 7: 통과 확인** — `flutter test test/domain` PASS. 전체 `flutter test` 실행해 기존 주간·월간 테스트의 `isTodayInProgress` 기대값 중 "출근 전 오늘 = true"였던 것(`month_state_builder_test.dart:30` 등)을 `isTodayWorking` = false로 고친다 — 스펙 §4 변경사항이다.

- [ ] **Step 8: Commit** — `git commit -am "도메인: 출장·시간공제·공휴일 근무 계산"`

---

### Task 2: Drift v2 + 저장 정리

**Files:**
- Modify: `lib/data/database/app_database.dart`, `lib/data/repository/drift_work_record_repository.dart`
- Create: `drift_schemas/drift_schema_v2.json`, `test/generated_migrations/*` (생성), `test/data/migration_test.dart`
- Test: `test/data/drift_work_record_repository_test.dart`

**Interfaces — Consumes:** `sanitizeRecord` (Task 1). **Produces:** `AppDatabase.schemaVersion == 2`.

- [ ] **Step 1: 테이블·마이그레이션**

```dart
  TextColumn get type => textEnum<WorkType>()();
  IntColumn get deductionMinutes => integer().withDefault(const Constant(0))();
  TextColumn get deductionReason => text().nullable()();
```
```dart
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          // v2: 시간공제 (2026-09-27). 기존 행은 공제 0 · 사유 null.
          if (from < 2) {
            await m.addColumn(workRecords, workRecords.deductionMinutes);
            await m.addColumn(workRecords, workRecords.deductionReason);
          }
        },
      );
```

- [ ] **Step 2: 코드젠 + 스키마 덤프 + 검증 코드 생성**

```bash
dart run build_runner build --delete-conflicting-outputs
dart run drift_dev schema dump lib/data/database/app_database.dart drift_schemas/drift_schema_v2.json
dart run drift_dev schema generate drift_schemas/ test/generated_migrations/
```
`drift_schemas/`에 v1·v2 JSON, `test/generated_migrations/`에 `schema.dart`, `schema_v1.dart`, `schema_v2.dart`가 생긴다.

- [ ] **Step 3: 마이그레이션 테스트 작성** — `test/data/migration_test.dart`:

```dart
import 'package:drift/drift.dart' hide isNull;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/data/database/app_database.dart';
import 'package:soi_duty/data/repository/drift_work_record_repository.dart';
import 'package:soi_duty/domain/model/work_type.dart';

import '../generated_migrations/schema.dart';
import '../helpers/records.dart';

void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    verifier = SchemaVerifier(GeneratedHelper());
  });

  test('v1 → v2 스키마가 일치한다', () async {
    final connection = await verifier.startAt(1);
    final db = AppDatabase(connection);
    await verifier.migrateAndValidate(db, 2);
    await db.close();
  });

  test('v1 기록·첫 기록일이 v2에서 그대로 읽히고 공제는 0', () async {
    final schema = await verifier.schemaAt(1);
    schema.rawDatabase.execute(
      "INSERT INTO work_records (date, clock_in, clock_out, type) VALUES ('2026-09-14', ?, ?, 'halfDay')",
      [d(14, 13).millisecondsSinceEpoch ~/ 1000, d(14, 17).millisecondsSinceEpoch ~/ 1000],
    );
    schema.rawDatabase.execute("INSERT INTO settings (key, value) VALUES ('first_record_date', '2026-09-14')");

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 2);
    final repo = DriftWorkRecordRepository(db);
    final all = await repo.watchAll().first;
    expect(all.single.type, WorkType.halfDay);
    expect(all.single.clockIn, d(14, 13));
    expect(all.single.deductionMinutes, 0);
    expect(all.single.deductionReason, isNull);
    expect(await repo.watchFirstRecordDate().first, d(14));
    await db.close();
  });
}
```
(Drift의 DateTime 기본 저장은 unix 초 정수. `app_database.g.dart`/`build.yaml`에 `store_date_time_values_as_text`가 없음을 확인했다. 다르면 v1 JSON의 컬럼 타입에 맞춰 값 형식을 바꾼다.)

- [ ] **Step 4: repo 매핑 + sanitize** — `_toDomain`에 `deductionMinutes: row.deductionMinutes, deductionReason: row.deductionReason`, `_toCompanion`에 `deductionMinutes: Value(r.deductionMinutes), deductionReason: Value(r.deductionReason)`. `save` 첫 줄에서 `record = sanitizeRecord(record);` (파라미터를 `WorkRecord input`으로 받고 `final record = sanitizeRecord(input);`).

repo 테스트 추가:
```dart
  test('공제·사유가 왕복되고, 연차로 저장하면 공제·시각이 지워진다', () async {
    await repo.save(rec(14, inH: 9, outH: 15, ded: 180, reason: '조기퇴근 공문'));
    expect((await repo.watchAll().first).single.deductionReason, '조기퇴근 공문');
    await repo.save(rec(14, inH: 9, outH: 15, type: WorkType.dayOff, ded: 180, reason: 'x'));
    final r = (await repo.watchAll().first).single;
    expect((r.clockIn, r.deductionMinutes, r.deductionReason), (null, 0, null));
  });
```

- [ ] **Step 5: 통과 확인** — `flutter test test/data` PASS.

- [ ] **Step 6: Commit** — `git add drift_schemas test/generated_migrations test/data lib/data && git commit -m "Drift v2: 시간공제 컬럼 + v1 마이그레이션"`

---

### Task 3: 오늘 화면 — 출장 · 공휴일 출근 · 공제하고 퇴근

**Files:**
- Modify: `lib/presentation/today/today_state.dart`, `today_state_builder.dart`, `today_controller.dart`, `today_texts.dart`, `today_screen.dart`, `widgets/status_card.dart`, `widgets/status_block.dart`, `widgets/type_badge.dart`
- Modify: `lib/ui/app_sizes.dart` (필요 시 근무 중 블록 간격 토큰)
- Test: `test/presentation/today_controller_test.dart`, `today_state_builder_test.dart`, `today_texts_test.dart`, `today_view_test.dart`

**Interfaces — Consumes:** `isOffType`, `dayStandardMinutes`, `closingDeduction`, `canDeduct` (Task 1).
**Produces:**
```dart
TodayState: WorkType? dayType  // dayOff·holiday·businessTrip, 출근 전에만
TodayState: required int todayStandardMinutes      // 안내 문구 기준선
TodayState get isHoliday; bool get canDeductOnClockOut  // 근무 중 && 평일 && 공휴일 아님
TodayController.clockOut({bool deductRemaining = false})
TodayCallbacks.onClockOut: ValueChanged<bool>      // deductRemaining
TodayTexts.buttonLabel(TodayState s, {bool deductRemaining = false})
```

- [ ] **Step 1: 실패하는 테스트 작성**

`today_controller_test.dart` (기존 파일의 컨테이너·시계 셋업을 그대로 쓴다):
```dart
  test('공휴일 출근은 공휴일을 유지한다', ...
      // setDayType(holiday) → clockIn() → 기록 type == holiday, clockIn != null
  test('공휴일 출근 취소는 시각만 비우고 공휴일을 남긴다', ...
      // holiday + clockIn → cancelClockIn() → 기록 존재, type holiday, clockIn null
  test('연차·출장 상태에서 clockIn은 일반으로 바꾼다', ... // 기존 동작 유지
  test('공제하고 퇴근: 기본 − 실근무가 공제로 저장된다', ...
      // 09:00 출근, 시계 15:00 → clockOut(deductRemaining: true) → deductionMinutes 180
  test('반차 날 이미 4h 넘겼으면 공제 0', ...
      // halfDay, 09:00 출근, 시계 14:00 → deductionMinutes 0
  test('공제 체크 없이 퇴근하면 기존 공제 유지', ...
      // ded 60 저장 후 clockOut() → 60
  test('공제가 있던 오늘을 연차로 바꾸면 공제가 지워진다', ...
      // ded 60 → setDayType(dayOff) → deductionMinutes 0 (repo sanitize)
```
각 테스트는 기존 파일의 패턴대로 실제 `NativeDatabase.memory()` + 시계 오버라이드로 작성하고, 기록은 `ref.read(allRecordsProvider.future)`로 읽어 단언한다.

`today_state_builder_test.dart`:
```dart
  test('출장 오늘 → dayType businessTrip', ...);
  test('공휴일 출근 → working, canDeductOnClockOut false', ...);
  test('평일 근무 중 → canDeductOnClockOut true', ...);
  test('todayStandardMinutes = 8h − 오늘 공제', ...); // rec(16, ded: 120) → 360
```
`today_texts_test.dart`:
```dart
  test('안내 기준선은 그날 기준시간 — 공제 2h 날 오늘 몫 6h면 페이스 좋아요', ...);
  test('공제 체크 시 버튼 문구', () => expect(TodayTexts.buttonLabel(working, deductRemaining: true), '공제하고 퇴근하기'));
  test('출장 상태 문구·배지', ...); // '오늘은 출장입니다\n8시간 근무로 인정돼요', '출장'
```
`today_view_test.dart` (기존 네 상태 카드 높이 동일 테스트 확장):
  - 근무 중(체크박스 줄 포함) 카드 높이가 출근 전·퇴근 완료·연차와 같은지.
  - 출근 전 보조 슬롯 라디오 3개가 폭 320에서 overflow 없이 그려지는지 (`tester.takeException()` null).
  - 공휴일 상태에서 주 버튼이 활성(탭 시 `onClockIn` 호출), 연차·출장 상태에선 비활성.
  - 체크박스를 탭하면 버튼이 "공제하고 퇴근하기"로 바뀌고, 버튼 탭 시 `onClockOut(true)`.

- [ ] **Step 2: 실패 확인** — `flutter test test/presentation/today_*` FAIL.

- [ ] **Step 3: 상태·빌더**
  - `today_state_builder.dart`: `dayType = isOffType(type) ? type : null` 이되 **공휴일은 출근 전에만** dayType(출근 후엔 phase가 working/done이므로 `screenState`가 이미 그쪽을 택한다 — 현재 `screenState`는 phase before일 때만 dayType을 본다. 그대로 둔다). `todayStandardMinutes: dayStandardMinutes(record, rules)`.
  - `today_state.dart`: 필드 `required int todayStandardMinutes`, getter
    ```dart
    bool get isHoliday => record?.type == WorkType.holiday;
    /// 근무 중에 "남은 시간 공제하고 퇴근"을 보여줄지. 주말·공휴일 근무엔 기준이 없다.
    bool get canDeductOnClockOut => phase == TodayPhase.working && !isWeekend && !isHoliday;
    ```
  - `build_runner`.

- [ ] **Step 4: 컨트롤러**
```dart
  Future<void> clockIn() => _saveToday((r, now) {
        // 연차·출장이면 되돌리고 출근, 공휴일은 그대로 두고 출근(공휴일 근무).
        final type = (r.type == WorkType.dayOff || r.type == WorkType.businessTrip) ? WorkType.normal : r.type;
        return r.copyWith(clockIn: now, type: type);
      });

  /// [deductRemaining]: 당일 공문 — 기본 기준에서 일한 만큼 빼고 나머지를 시간공제로 저장.
  Future<void> clockOut({bool deductRemaining = false}) => _saveToday((r, now) => r.copyWith(
        clockOut: now,
        deductionMinutes: deductRemaining ? closingDeduction(r, now, ref.read(workRulesProvider)) : r.deductionMinutes,
      ));

  /// 근무 중 → 출근 전. 실수로 찍은 출근을 없던 일로 — 반차 체크도 함께 풀린다 (기록 삭제).
  /// 공휴일 근무였으면 공휴일 표시는 남기고 시각만 비운다.
  Future<void> cancelClockIn() async {
    final current = await future;
    if (current.isHoliday) return _saveToday((r, _) => r.copyWith(clockIn: null, clockOut: null));
    final today = dateOnly(ref.read(clockProvider)());
    await ref.read(workRecordRepositoryProvider).delete(today);
  }
```
`setHalfDay(false)`는 공제가 남아 있어도 그대로 둔다(일반 8h 한도 안이므로 유효).

- [ ] **Step 5: 문구** — `today_texts.dart`:
```dart
  static const businessTrip = '오늘은 출장';
  static const deductRemaining = '남은 시간 공제하고 퇴근';

  static String buttonLabel(TodayState s, {bool deductRemaining = false}) => switch (s.screenState) {
        TodayScreenState.beforeWork || TodayScreenState.dayType => '출근하기',
        TodayScreenState.working => deductRemaining ? '공제하고 퇴근하기' : '퇴근하기',
        TodayScreenState.done => '오늘 퇴근 완료',
      };

  static String dayTypeMessage(WorkType type) => switch (type) {
        WorkType.dayOff => '오늘은 연차입니다\n근무 기록을 남기지 않습니다',
        WorkType.businessTrip => '오늘은 출장입니다\n8시간 근무로 인정돼요',
        _ => '오늘은 공휴일입니다\n행복한 휴일 되세요',
      };

  static String badgeLabel(WorkType type) => switch (type) {
        WorkType.dayOff => '연차',
        WorkType.businessTrip => '출장',
        _ => '공휴일',
      };
```
`encouragement`: 기준선을 `rules.dailyStandardMinutes` 대신 `s.todayStandardMinutes`로.

- [ ] **Step 6: 위젯**
  - `TypeBadge`: `isDayOff` 분기 대신 `AppColors.typeColors(type)` + 새 `AppColors.typeBorder(type)`(dayOff·holiday·businessTrip 테두리, 그 외 transparent)로.
  - `StatusCard` → `StatefulWidget`. `bool _deductRemaining = false;` `didUpdateWidget`에서 `state.screenState`가 working이 아니게 되면 false로. 주 버튼: `PrimaryButton(label: TodayTexts.buttonLabel(state, deductRemaining: _deductRemaining), onPressed: ...)`.
    - `_primaryAction`: `beforeWork → onClockIn`, `working → () => callbacks.onClockOut(_deductRemaining)`, `dayType → state.dayType == WorkType.holiday ? onClockIn : null`, `done → null`.
    - 출근 전 슬롯: 라디오 3개(`dayOff`·`holiday`·`businessTrip`), 간격 `AppSizes.dayTypeGap`. 폭 320 테스트가 overflow를 내면 `AppSizes.dayTypeGapTight`(12) 토큰을 추가해 쓰고, 그래도 넘치면 라벨을 `'연차'/'공휴일'/'출장'`으로 줄인다(texts에 짧은 라벨 상수).
    - 근무 중 슬롯: 공휴일이면 주말처럼 `_pair(edit, cancel)`.
  - `StatusBlock`에 `deductRemaining`·`onDeductRemainingChanged` 파라미터. working일 때 `state.canDeductOnClockOut`이면 세 번째 줄로 `SoiCheckbox(label: TodayTexts.deductRemaining, checked: ..., shape: SoiCheckShape.square)`.
    - 높이 104 안에 들어가야 한다: 두 줄(각 ≈22) + 체크박스(히트 44). 간격을 `AppSizes.statusBlockGapTight`(4)로 줄이고, 그래도 넘치면 체크박스를 `SizedBox(height: 36)`에 넣고 히트 영역은 `SoiCheckbox`의 `minHeight`를 파라미터(`minHeight: AppSizes.statusCheckHeight`)로 받게 한다. 판정은 Step 1의 카드 높이 테스트.
  - `TodayCallbacks.onClockOut`을 `ValueChanged<bool>`로, `today_screen.dart`에서 `onClockOut: (deduct) => controller.clockOut(deductRemaining: deduct)`.

- [ ] **Step 7: 통과 확인** — `flutter test test/presentation/today_*` PASS, `flutter analyze` 0.

- [ ] **Step 8: Commit** — `git commit -am "오늘 화면: 출장, 공휴일 출근, 남은 시간 공제하고 퇴근"`

---

### Task 4: 시트 초안 로직 (RecordDraft · 문구 · 계산 내역)

**Files:**
- Modify: `lib/presentation/record_edit/record_draft.dart`, `record_edit_texts.dart`
- Test: `test/presentation/record_draft_test.dart`

**Interfaces — Consumes:** `canDeduct`, `isOffType`, `isValidDeduction`, `dayStandardMinutes`, `standardMinutes` (Task 1).
**Produces:**
```dart
enum EditingRow { clockIn, clockOut, deduction }
RecordDraft.fromRecord(date, today, record)       // deductionMinutes/Reason, showsHolidayWork 초기화
RecordDraft: int deductionMinutes; String deductionReason ('' = 없음); bool showsHolidayWork
bool get isTypeOnly        // 미래 || (오늘 && 출근 없음)
bool get isOff             // isOffType(type)
bool get showsTimeRows     // !isTypeOnly && (normal|halfDay || (holiday && showsHolidayWork))
bool get showsHolidayWorkButton  // !isTypeOnly && holiday && !showsHolidayWork
bool get showsDeductionRow // canDeduct(date, type)
bool get isDeductionValid; bool get isValid
bool get showsSaveButton   // showsTimeRows || (isTypeOnly && editing == EditingRow.deduction)
RecordDraft withDeduction(int minutes); RecordDraft withReason(String text); RecordDraft expandHolidayWork()
RecordDraft toggleEditing(EditingRow row, WorkRules rules)  // deduction: 10분 내림 위치에서 연다, 값은 안 바꾼다
WorkRecord toRecord()
bool get isEmptyNormal     // normal && 시각 없음 && 공제 0
RecordEditTexts: deductionLabel, deductionWheelTitle, deductionNone, reasonHint, deductionHelp,
                 halfDayDeductionTooLong, holidayWorkButton, holidayNote, deduction(int), businessTrip chip
List<CalcLine> calcLines(RecordDraft d, WorkRules rules)
```

- [ ] **Step 1: 실패하는 테스트 작성** — `record_draft_test.dart`에 추가:

```dart
  group('유형 전용 모드', () {
    test('미래는 유형 전용', () => expect(draft(date: d(18), today: d(16)).isTypeOnly, isTrue));
    test('출근 전 오늘도 유형 전용', () => expect(draft(date: d(16), today: d(16)).isTypeOnly, isTrue));
    test('퇴근 완료 오늘은 아님', () =>
        expect(draft(date: d(16), today: d(16), record: rec(16, inH: 9, outH: 18)).isTypeOnly, isFalse));
  });

  group('공휴일 근무', () {
    test('공휴일은 기본으로 시각 행 대신 버튼', () {
      final x = draft(date: d(14), today: d(16), record: rec(14, type: WorkType.holiday));
      expect((x.showsTimeRows, x.showsHolidayWorkButton), (false, true));
      final y = x.expandHolidayWork();
      expect((y.showsTimeRows, y.showsHolidayWorkButton), (true, false));
    });
    test('시각이 있는 공휴일은 펼친 채로 열린다', () {
      final x = draft(date: d(14), today: d(16), record: rec(14, inH: 10, outH: 15, type: WorkType.holiday));
      expect(x.showsTimeRows, isTrue);
    });
    test('미래 공휴일엔 버튼 없음', () =>
        expect(draft(date: d(18), today: d(16), record: rec(18, type: WorkType.holiday)).showsHolidayWorkButton, isFalse));
    test('공휴일 계산 내역: 근무 · 점심 공제(없음 (공휴일))', () {
      final x = draft(date: d(14), today: d(16), record: rec(14, inH: 10, outH: 15, type: WorkType.holiday));
      expect(calcLines(x, rules).map((l) => (l.label, l.value)), [('근무', '5h'), ('점심 공제', '없음 (공휴일)')]);
    });
  });

  group('시간공제', () {
    test('평일 일반·반차만 공제 행', () {
      expect(draft(date: d(14), today: d(16)).showsDeductionRow, isTrue);
      expect(draft(date: d(19), today: d(20)).showsDeductionRow, isFalse); // 주말
      expect(draft(date: d(14), today: d(16), record: rec(14, type: WorkType.holiday)).showsDeductionRow, isFalse);
    });
    test('반차 4h 초과는 무효', () {
      final x = draft(date: d(14), today: d(16), record: rec(14, inH: 9, outH: 13, type: WorkType.halfDay)).withDeduction(250);
      expect(x.isValid, isFalse);
    });
    test('toRecord: 공제·사유 반영, 공제 0이면 사유 없음', () {
      final base = draft(date: d(14), today: d(16), record: rec(14, inH: 9, outH: 15));
      expect(base.withDeduction(120).withReason('공문').toRecord().deductionReason, '공문');
      expect(base.withReason('공문').toRecord().deductionReason, isNull);
    });
    test('공제만 있는 normal은 빈 기록이 아니다', () {
      expect(draft(date: d(18), today: d(16)).withDeduction(60).isEmptyNormal, isFalse);
    });
    test('휠은 10분 내림 위치에서 열리고 값은 그대로', () {
      final x = draft(date: d(14), today: d(16), record: rec(14, inH: 9, outH: 15, ded: 167))
          .toggleEditing(EditingRow.deduction, rules);
      expect(x.editing, EditingRow.deduction);
      expect(x.deductionMinutes, 167);
      expect(x.deductionWheelStart(rules), 160);
    });
    test('유형 전용 모드에서 공제 휠을 펴면 저장 버튼', () {
      final x = draft(date: d(18), today: d(16));
      expect(x.showsSaveButton, isFalse);
      expect(x.toggleEditing(EditingRow.deduction, rules).showsSaveButton, isTrue);
    });
    test('계산 내역에 시간공제 줄과 공제 반영 기준', () {
      final x = draft(date: d(14), today: d(16), record: rec(14, inH: 9, outH: 15, ded: 120));
      expect(calcLines(x, rules).map((l) => (l.label, l.value)).toList(), [
        ('근무', '5h'), ('점심 공제', '1h'), ('시간공제', '−2h'), ('기준', '6h'), ('기준 대비', '−1h'),
      ]);
    });
  });
```
`draft(...)` 헬퍼가 파일에 없으면 `RecordDraft.fromRecord(date:, today:, record:)` 래퍼로 만든다. `formatHm`/`formatSignedHm`의 실제 출력(예: `'−1h'` vs `'-1h'`, `'5h'` vs `'5h 0m'`)은 `test/core/format_test.dart`를 보고 맞춘다. 시간공제 줄 값은 `'−${formatHm(m)}'` 형태.

- [ ] **Step 2: 실패 확인** — `flutter test test/presentation/record_draft_test.dart` FAIL.

- [ ] **Step 3: 구현** — `record_draft.dart`:
  - 생성자/`_copy`에 `deductionMinutes`(int, 0), `deductionReason`(String, ''), `showsHolidayWork`(bool) 추가, `_copy`는 non-null 파라미터로 받는다.
  - `fromRecord`: `deductionMinutes: record?.deductionMinutes ?? 0`, `deductionReason: record?.deductionReason ?? ''`, `showsHolidayWork: record?.clockIn != null || record?.clockOut != null`, 그리고 유형 전용 판정을 위해 `hasClockIn: record?.clockIn != null` 저장.
  - getter:
```dart
  bool get isFuture => date.isAfter(today);
  /// 시각 없이 유형·시간공제만 고르는 모드 — 미래, 그리고 출근 전인 오늘.
  bool get isTypeOnly => isFuture || (date == today && !hasClockIn);
  bool get isOff => isOffType(type);
  bool get showsTypeChips => !isWeekend;
  bool get showsTimeRows =>
      !isTypeOnly && (type == WorkType.normal || type == WorkType.halfDay || (type == WorkType.holiday && showsHolidayWork));
  bool get showsHolidayWorkButton => !isTypeOnly && type == WorkType.holiday && !showsHolidayWork;
  bool get showsDeductionRow => calc.canDeduct(date, type);
  bool isDeductionValid(WorkRules rules) => calc.isValidDeduction(type, deductionMinutes, rules);
  bool isValid(WorkRules rules) => calc.isValidClockRange(clockIn, clockOut) && isDeductionValid(rules);
  bool get showsSaveButton => showsTimeRows || (isTypeOnly && editing == EditingRow.deduction);
  int deductionWheelStart(WorkRules rules) =>
      deductionMinutes - deductionMinutes % rules.deductionStepMinutes;
```
  (`isValid`가 rules를 받게 바뀌므로 시트의 호출부도 Task 5에서 맞춘다. Task 4에서는 시트 컴파일이 되도록 `draft.isValid(rules)`로 바꿔만 둔다.)
  - `toRecord()`:
```dart
  WorkRecord toRecord() => calc.sanitizeRecord(WorkRecord(
        date: date,
        type: type,
        clockIn: showsTimeRows ? clockIn : null,
        clockOut: showsTimeRows ? clockOut : null,
        deductionMinutes: showsDeductionRow ? deductionMinutes : 0,
        deductionReason: deductionReason,
      ));
  bool get isEmptyNormal {
    final r = toRecord();
    return r.type == WorkType.normal && r.clockIn == null && r.clockOut == null && r.deductionMinutes == 0;
  }
```
  - `withDeduction`, `withReason`, `expandHolidayWork` (`_copy(showsHolidayWork: true)`).
  - `toggleEditing`: `EditingRow.deduction`이면 시각을 건드리지 않고 `editing`만 토글.
  - `timeOf(row)`는 clockIn/clockOut만 — deduction은 호출하지 않는다(시트에서 분기).

  `record_edit_texts.dart`:
```dart
  static const deductionLabel = '시간공제';
  static const deductionWheelTitle = '뺄 시간';
  static const deductionNone = '없음';
  static const reasonHint = '사유 (선택) 예: 조기퇴근 공문';
  static const deductionHelp = '연차·반차로 안 되는 시간을 직접 넣어 이 날 기준시간에서 빼요';
  static const halfDayDeductionTooLong = '반차인 날은 4시간까지 뺄 수 있어요';
  static const holidayWorkButton = '+ 이 날 근무한 시간 입력';
  static const holidayNote = '공휴일 근무는 주 40시간에 포함되지 않아요';
  static const hourUnit = '시간';
  static const minuteUnit = '분';
  /// "2시간 30분" / "2시간" / "30분" / "없음"
  static String deduction(int m) => m == 0 ? deductionNone : formatKoreanDuration(m);
```
  (`formatKoreanDuration`은 오늘 화면 "7시간 15분째"에 쓰는 기존 함수. 0분일 때 출력 확인 후 필요하면 위처럼 분기.)
  `calcLines`: 주말 또는 공휴일이면 `[근무, 점심 공제]` 두 줄(공휴일 점심 값 `'없음 (공휴일)'`). 그 외에는 근무 / 점심 공제 / (공제>0이면) `CalcLine('시간공제', '−${formatHm(m)}', CalcKind.note)` / `기준 = formatHm(dayStandardMinutes(record))` / 기준 대비.
  `replaceTimesTitle`은 `'${chipLabel(t)}(으)로'` 조사 문제: "출장으로"·"연차로"·"공휴일로" 모두 '로'가 맞다(받침 ㅇ·ㄹ) → 그대로.

- [ ] **Step 4: 통과 확인** — `flutter test test/presentation/record_draft_test.dart` PASS, `flutter analyze` 0.

- [ ] **Step 5: Commit** — `git commit -am "시트 초안: 시간공제·공휴일 근무·출근 전 오늘 유형 전용"`

---

### Task 5: 시트 UI — 4유형 · 공제 행 · 휠 · 사유 · 키보드

**Files:**
- Create: `lib/presentation/record_edit/widgets/wheel_column.dart`, `duration_wheel.dart`, `reason_field.dart`
- Modify: `lib/presentation/record_edit/widgets/time_wheel.dart` (WheelColumn 사용), `type_chips.dart`, `type_rows.dart`, `record_edit_sheet.dart`, `lib/ui/app_sizes.dart`, `app_text_styles.dart`
- Test: `test/presentation/record_edit_sheet_test.dart`

**Interfaces — Consumes:** Task 4의 RecordDraft·RecordEditTexts 전부.
**Produces:**
```dart
class WheelColumn extends StatelessWidget { labels, selected, controller, onSelected }
class DurationWheel extends StatefulWidget { int minutes; int maxHours; int stepMinutes; ValueChanged<int> onChanged }
class ReasonField extends StatefulWidget { String initial; ValueChanged<String> onChanged }
```

- [ ] **Step 1: 실패하는 위젯 테스트 작성** — `record_edit_sheet_test.dart`의 기존 셋업(인메모리 DB + 시계 + `pumpSheet`)을 쓴다:
  - 과거 평일 시트에 칩 4개(반차·연차·공휴일·출장)와 "시간공제 없음" 행.
  - 출장 칩 탭 → 즉시 저장·닫힘, 기록 type businessTrip.
  - 공휴일 칩 탭 → 즉시 저장·닫힘. 다시 열면 "+ 이 날 근무한 시간 입력"만, 탭하면 출근/퇴근 행·안내 줄·저장 버튼.
  - 공제 행 탭 → "뺄 시간" 휠 + 사유칸 + 설명. 휠을 2시간 30분으로 드래그(`tester.drag` on hour/minute column) 후 저장 → deductionMinutes 150.
  - 사유 입력 후 저장 → deductionReason 저장. 완료 키(`tester.testTextInput.receiveAction(TextInputAction.done)`) → `FocusManager.instance.primaryFocus`가 사유칸이 아님.
  - 사유칸 포커스 중 휠 드래그 → 포커스 해제.
  - 반차 + 5h 공제 → 저장 버튼 비활성 + "반차인 날은 4시간까지 뺄 수 있어요".
  - 미래 날짜 시트: 행 4개 + 공제 행. 공제 행 펼치면 저장 버튼이 나타난다.
  - **출근 전 오늘**: 유형 행 4개 + 공제 행, 시각 행 없음.
  - **키보드(Review Focus 5)**: 화면 320×568, `tester.view.viewInsets = FakeViewPadding(bottom: 300)`로 키보드를 흉내 낸 상태에서 사유칸에 포커스 → 저장 버튼 `tester.getRect`의 bottom이 `568 − 300` 이하이고 `tester.tap`이 동작.

- [ ] **Step 2: 실패 확인** — `flutter test test/presentation/record_edit_sheet_test.dart` FAIL.

- [ ] **Step 3: WheelColumn 추출** — `time_wheel.dart`의 `_column`을 그대로 `WheelColumn` 위젯으로 옮기고 TimeWheel이 이를 쓰게 한다(동작 변화 없음 → 기존 테스트로 확인). 페이드 마스크·가운데 띠를 그리는 Stack도 `WheelFrame({required Widget child})`로 같은 파일에 둔다.

- [ ] **Step 4: DurationWheel** — `duration_wheel.dart`:
```dart
/// 시간공제 휠 — 시간(0–maxHours) · 분(0–50, step 단위). [onChanged]는 합친 분을 돌려준다.
/// [minutes]가 step에 안 맞으면(퇴근 시 자동 공제 등) 내림한 위치에서 열리지만, 돌리기 전엔 onChanged를 부르지 않는다.
class DurationWheel extends StatefulWidget {
  const DurationWheel({super.key, required this.minutes, required this.maxHours, required this.stepMinutes, required this.onChanged});
  ...
}
```
열: `[0..maxHours]` 라벨 `'$h'`, 단위 텍스트 `RecordEditTexts.hourUnit`, `[0, step, .., 60−step]` 라벨 `padLeft(2,'0')`, 단위 `minuteUnit`. 변경 시 `onChanged(h * 60 + m)`. 스크롤 시작 시 `FocusManager.instance.primaryFocus?.unfocus()` (`NotificationListener<ScrollStartNotification>`로 감싼다).

- [ ] **Step 5: ReasonField** — `reason_field.dart`:
```dart
/// 시간공제 사유 한 줄. 완료 키·바깥 탭이면 포커스를 놓는다.
class ReasonField extends StatefulWidget { ... }
// TextField(
//   controller, maxLength: 20, maxLengthEnforcement: enforced, buildCounter: (_, {...}) => null,
//   textInputAction: TextInputAction.done,
//   onSubmitted: (_) => FocusScope.of(context).unfocus(),
//   onTapOutside: (_) => FocusScope.of(context).unfocus(),
//   scrollPadding: EdgeInsets.only(bottom: AppSizes.reasonScrollPadding),  // 저장 버튼까지 보이도록
//   style: AppTextStyles.reasonInput, decoration: 토큰 기반 InputDecoration (배경 AppColors.cardInner, radius AppSizes.wheelBoxRadius, 힌트 AppTextStyles.reasonHint)
// )
```
토큰 추가: `AppSizes.reasonFieldTop`, `reasonFieldPadding`, `reasonScrollPadding`(= 저장 버튼 높이 + 여백), `AppTextStyles.reasonInput`(14.5 w400 ink), `reasonHint`(14.5 w400 faint), `deductionHelp`(12.5 subtle).

- [ ] **Step 6: 칩·행 4개** — `TypeChips._types`, `TypeRows._types`에 `WorkType.businessTrip` 추가. 칩 4열이 320 폭에서 안 잘리는지 테스트(Step 1에 `tester.takeException()` 단언 포함).

- [ ] **Step 7: 시트 조립** — `record_edit_sheet.dart`:
  - 패딩 bottom: `AppSizes.sheetPadding.bottom + math.max(bottomInset, MediaQuery.viewInsetsOf(context).bottom)` — 키보드가 올라오면 시트가 그만큼 올라간다(`isScrollControlled: true`는 이미 켜져 있다).
  - 전체를 `GestureDetector(onTap: () => FocusScope.of(context).unfocus(), behavior: HitTestBehavior.translucent)`로 감싸 빈 곳 탭 시 포커스 해제.
  - 유형 전용 판정: `draft.isFuture` 대신 `draft.isTypeOnly`(행 목록 분기, 제목은 미래일 때만 요일 생략 그대로).
  - `_onTypeChanged`: `if (!draft.isTypeOnly && !next.isOff) return _update(next);` — 공휴일도 `isOff`이므로 즉시 저장된다.
  - 공휴일 안내 줄: `draft.type == WorkType.holiday && draft.showsTimeRows`이면 주말 안내와 같은 박스로 `RecordEditTexts.holidayNote`.
  - `showsHolidayWorkButton`이면 `QuietTextButton(label: holidayWorkButton, onTap: () => _update(draft.expandHolidayWork()))`를 가운데 정렬로.
  - 시각 행 뒤(유형 전용 모드에선 유형 행 뒤)에 `showsDeductionRow`이면 `TimeRow(label: deductionLabel, value: RecordEditTexts.deduction(draft.deductionMinutes), selected: editing == EditingRow.deduction, onTap: ...)`.
  - 펼친 휠 박스: `editing == EditingRow.deduction`이면 제목 `deductionWheelTitle` + `DurationWheel(minutes: draft.deductionWheelStart(rules) ..., maxHours: 8, stepMinutes: rules.deductionStepMinutes, onChanged: (m) => _update(draft.withDeduction(m)))` + `ReasonField(initial: draft.deductionReason, onChanged: (t) => _update(draft.withReason(t)))` + 설명 줄. `maxHours`는 `rules.dailyStandardMinutes ~/ 60`.
    - 주의: DurationWheel의 `minutes`는 **내림 위치**만 결정하고, `withDeduction`은 사용자가 돌렸을 때만 호출된다(Step 4 계약).
  - 오류 줄: `!draft.isDeductionValid(rules)`이면 `halfDayDeductionTooLong`, 아니고 시각 범위 무효면 기존 `invalidRange`.
  - 저장 버튼: `if (draft.showsSaveButton)`, `onTap: draft.isValid(rules) ? _save : null`. `_saveDraft` 첫 줄에 `FocusScope.of(context).unfocus();`.

- [ ] **Step 8: 통과 확인** — `flutter test test/presentation/record_edit_sheet_test.dart test/presentation/record_draft_test.dart` PASS, `flutter analyze` 0.

- [ ] **Step 9: Commit** — `git commit -am "시트: 출장 칩, 시간공제 휠·사유, 공휴일 근무 펼침, 출근 전 오늘"`

---

### Task 6: 주간 — 배지 · 요약 · 공휴일 근무 행 · 잠금

**Files:**
- Modify: `lib/presentation/week/week_state.dart`, `week_state_builder.dart`, `week_texts.dart`, `week_screen.dart`, `widgets/week_day_row.dart`, `lib/presentation/shared/type_tag.dart`, `lib/ui/app_colors.dart`
- Test: `test/presentation/week_state_builder_test.dart`, `week_texts_test.dart`, `week_screen_test.dart`

**Interfaces — Consumes:** Task 1. **Produces:** `WeekDayKind.holidayRecorded`; `WeekTexts.badges(WeekDay) → List<WeekBadge>`; `TypeTag(background:, foreground:, ...)`.

- [ ] **Step 1: 실패하는 테스트 작성**
  - builder: 공휴일 + 시각 둘 → `holidayRecorded`, `actualMinutes` 300, `deltaMinutes` null. 오늘 공휴일 출근만 → `working`. 시각 없는 공휴일 → `off`. 출장 → `off`. `excludedMinutes`에 공휴일 근무 포함. 출근 전 오늘 `isTodayWorking` false, 근무 중 true.
  - texts:
    - `summaryDetail`: `'연차 1 · 반차 1 · 공휴일 1 · 출장 1 · 공제 2h 30m'`, 0 생략.
    - `badges(day)`: 반차 + 공제 150 → `[반차, 공제 2h 30m]`; 공휴일 근무 → `[공휴일]`.
    - `note`: 공제 사유 있는 기록 `'09:00–15:00 · 조기퇴근 공문'`; 공휴일 근무 `'주 40시간 제외 · 10:00–15:00'`; 사유만 있고 시각 없는 미래 `'조기퇴근 공문'`.
    - `main(holidayRecorded)` = 근무시간, `value(holidayRecorded)` = `''`.
    - `todayInProgressToast`는 인자 없는 상수 `'오늘 기록은 퇴근한 뒤에 수정할 수 있어요'`.
  - screen: 기존 "7행 높이 동일" 테스트에 배지 둘 + 20자 사유 행을 포함한 주를 추가, 폭 320에서 overflow 없음.

- [ ] **Step 2: 실패 확인.**

- [ ] **Step 3: 구현**
  - `WeekDayKind`에 `holidayRecorded` 추가. `_day`:
```dart
  if (isWeekend(date)) { ... }
  else if (r != null && r.type == WorkType.holiday && hasBoth) kind = WeekDayKind.holidayRecorded;
  else if (r != null && r.type == WorkType.holiday && isToday && r.clockIn != null) kind = WeekDayKind.working;
  else if (r != null && isOffType(r.type)) kind = WeekDayKind.off;
  ...
```
  - `WeekTexts`:
```dart
  static const todayInProgressToast = '오늘 기록은 퇴근한 뒤에 수정할 수 있어요';

  /// 행 배지. 유형(일반 제외) + 시간공제.
  static List<WeekBadge> badges(WeekDay day) {
    final r = day.record;
    if (r == null) return const [];
    return [
      if (r.type != WorkType.normal) WeekBadge.type(r.type, badgeLabel(r.type)),
      if (r.deductionMinutes > 0) WeekBadge.deduction('공제 ${formatHm(r.deductionMinutes)}'),
    ];
  }
```
    `WeekBadge`는 `week_texts.dart` 옆 `week_state.dart`에 둔 작은 값 클래스(`final String label; final WorkType? type;` — type null이면 공제). `main`/`note`/`value` switch에 `holidayRecorded`를 `weekendRecorded`와 같은 줄에 묶고, note 문구는 `'주 40시간 제외 · ${formatClockRange(...)}'`. `note`의 끝에 `_withReason(base, r)` — 사유가 있으면 `base.isEmpty ? reason : '$base · $reason'`.
    `summaryDetail`에 `if (w.businessTripCount > 0) '출장 ${w.businessTripCount}'`, `if (w.deductionMinutes > 0) '공제 ${formatHm(w.deductionMinutes)}'`.
  - `TypeTag`: `type` 대신 `background`, `foreground` 색을 받는다. 호출부(주간 행)는 `AppColors.typeColors(t)` 또는 `(AppColors.deductionBackground, AppColors.deductionText)`. 새 토큰 `deductionBackground = Color(0xFFE6E8E2)`, `deductionText = Color(0xFF4F5549)`.
  - `WeekDayRow`: 배지 목록을 `rowBadgeGap` 간격으로 나열. 행 전체가 한 줄을 넘지 않도록 배지 Row를 `Flexible` + `Wrap` 없이 `ClipRect`하지 말고, 기존 main `Text`에 `overflow: TextOverflow.ellipsis`만 둔다(배지 둘 + 시간값은 320에서 들어간다 — 테스트가 판정).
  - `week_screen.dart`: `if (day.isTodayWorking) return showAppToast(context, WeekTexts.todayInProgressToast);`

- [ ] **Step 4: 통과 확인** — `flutter test test/presentation/week_*` PASS.

- [ ] **Step 5: Commit** — `git commit -am "주간: 출장·공제 배지, 공휴일 근무 행, 요약 줄"`

---

### Task 7: 월간 — 범례 · 출장 · 공휴일 근무 · 잠금

**Files:**
- Modify: `lib/presentation/month/month_state_builder.dart`, `month_texts.dart`, `month_screen.dart`
- Test: `test/presentation/month_state_builder_test.dart`, `month_screen_test.dart`

- [ ] **Step 1: 실패하는 테스트 작성**
  - builder: 공휴일 + 시각 둘 → `type == holiday`, `value == MonthCellValue.weekendActual(300)`; 오늘 공휴일 근무 중 → `working`; 출장 → `type businessTrip`, `value none`; 공제 있는 날의 delta는 공제 반영값(`rec(14, inH: 9, outH: 15, ded: 120)` → `delta(-60)`).
  - texts: `legend`에 `(WorkType.businessTrip, '출장')`; `todayInProgressToast` 상수.
  - screen: 기존 "8종 폭에서 캘린더 값 자연 폭" 테스트 유지 + 범례 4개가 폭 320에서 overflow 없음.

- [ ] **Step 2: 실패 확인.**

- [ ] **Step 3: 구현** — `_cell` 분기 앞부분:
```dart
  if (type == WorkType.holiday && hasBoth) {
    value = MonthCellValue.weekendActual(actualMinutes(r!, rules) ?? 0); // 공휴일 근무 — 주말처럼 부호 없는 근무시간
  } else if (type == WorkType.holiday && date == today && r?.clockIn != null) {
    value = const MonthCellValue.working();
  } else if (type != null && isOffType(type)) {
    value = const MonthCellValue.none();
  } else if (weekend) { ... 기존 ...
```
  `MonthCellValue.weekendActual` 주석을 "주말·공휴일 근무 — 기준 대비 없이 근무시간"으로. `month_texts.dart`의 `todayInProgressToast`를 상수로, `month_screen.dart`는 `cell.isTodayWorking`.

- [ ] **Step 4: 통과 확인** — `flutter test test/presentation/month_*` PASS.

- [ ] **Step 5: Commit** — `git commit -am "월간: 출장 범례, 공휴일 근무 셀"`

---

### Task 8: 시드 · CLAUDE.md · 전체 검증

**Files:**
- Modify: `lib/data/seed/debug_seed.dart`, `test/data/debug_seed_test.dart`, `CLAUDE.md`

- [ ] **Step 1: 시드** — `history` 시나리오 루프에:
  - `n % 19 == 0` 평일 → `WorkRecord(date: d, type: WorkType.businessTrip)`
  - `n % 23 == 0` 평일 → `full(d, outH: 16).copyWith(deductionMinutes: 120, deductionReason: '조기퇴근 공문')`
  - `n % 29 == 0` 평일 → `full(d, outH: 17).copyWith(deductionMinutes: 60)` (사유 없음)
  - 기존 `n % 17` 공휴일 중 하나(첫 번째)는 `WorkRecord(date: d, type: WorkType.holiday, clockIn: 10:00, clockOut: 15:00)`
  - `SeedScenario`에 `holidayWork('공휴일 근무 중')` 추가: `filledPast()` + 오늘 공휴일 + 09:30 출근.
  분기 순서는 기존 `n % 11`(누락) 뒤, `n % 13` 앞. `debug_seed_test.dart`에 history에 출장·공제·공휴일 근무가 각각 1개 이상 있는지 단언 추가.

- [ ] **Step 2: CLAUDE.md 갱신** — 스펙 내용을 해당 절에 반영:
  - 근무 유형 표에 출장 행, "시간공제" 소절(유형이 아닌 그날 값, 0–8h·10분, 반차 4h 한도, 쉬는 날·주말 불가, 사유 선택 20자).
  - 하루 실근무에 공휴일 근무, 점심 공제 조건 갱신.
  - 주간 목표 식, "주간 실적에서 공휴일 근무 제외", 기록 누락 판정(그날 기준 > 0).
  - 오늘 퇴근 시각 계산에 "공제는 그날에만" 식, 안내 문구 기준선 = 그날 기준시간.
  - 기록 수정 절: 4유형·공휴일 칩 즉시 저장 + "근무한 시간 입력" 펼침, 출근 전 오늘 = 유형 전용 시트, `isTodayWorking`.
  - 오늘 화면: 출근 전 슬롯 3개, 공휴일 출근/취소, "남은 시간 공제하고 퇴근".
  - 데이터 모델 코드 블록, WorkRules 코드 블록, Drift v2 한 줄, 테스트 목록.
  - 날짜 표기 (2026-09-27).

- [ ] **Step 3: 전체 검증**
```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```
전부 통과해야 한다. 실패가 있으면 해당 Task로 돌아간다.

- [ ] **Step 4: 스모크 드라이브** — 부팅된 시뮬레이터가 있으면 `flutter drive --flavor dev --target test_driver/app.dart -d <ID>`로 스크린샷을 떠 월간 범례·주간 배지·시트를 눈으로 확인한다. 시뮬레이터가 없으면 건너뛰었다고 보고한다.

- [ ] **Step 5: Commit** — `git commit -am "시드·CLAUDE.md: 공휴일 근무·출장·시간공제"`

# 시간 출장 기록 · 퇴근 알림 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** (A) 근무한 날에 "몇 시부터 몇 시까지 출장"을 계산과 무관한 기록으로 남기고 오늘·주간·월간에 보인다. (B) 그날/이번 주 채울 시간을 다 채운 시각에 OS 로컬 알림을 하루 최대 하나 보낸다.

**Architecture:** A는 `WorkRecord`에 `tripStart`·`tripEnd`(Drift v3, 백업 format 3)를 붙이고 계산 함수는 건드리지 않는다. B는 순수 함수 `planClockOutNotice`(무엇을 언제)와, 기록·설정·날짜가 바뀔 때마다 **한 곳에서** OS 예약을 다시 맞추는 keepAlive 동기화 프로바이더로 나눈다. OS 호출은 domain 포트 `NotificationScheduler` 뒤에 두고(구현은 `flutter_local_notifications`), 테스트는 Fake로 "무엇이 언제 예약·발송·취소됐는지"를 검증한다.

**Tech Stack:** Flutter, Riverpod(코드젠), freezed, Drift(v2 → v3), `flutter_local_notifications` ^23 · `timezone` · `flutter_timezone` · `app_settings`(OS 알림 설정 열기).

**Spec:** `docs/specs/design-handoff-6-partial-trip-notification.md`(화면·문구·치수 확정본) · `docs/specs/2026-11-10-clock-out-notification.md`(예약 규칙) · `docs/specs/2026-11-10-partial-business-trip.md`. 실행자는 셋과 CLAUDE.md를 함께 읽는다. 충돌하면 화면·문구는 핸드오프 6, 계산·예약 규칙은 이 계획의 "확정 규칙".

## Global Constraints

- flavor 없이 `flutter run`/`build` 금지. 테스트는 `flutter test`. 코드젠: `dart run build_runner build --delete-conflicting-outputs` (freezed·riverpod·drift 변경 후).
- `domain/`에 `package:flutter` import 금지. `presentation/`은 `data/`를 직접 import하지 않는다(프로바이더로만). 색·글꼴·사이즈는 `AppColors`·`AppTextStyles`·`AppSizes` 토큰. 한국어 문자열은 `<feature>_texts.dart`에서만. **새 색은 없다.**
- 저장소 코드에서 Drift `watch().first` 금지 — 일회성은 `get()`.
- 시간 출장은 **계산에 전혀 영향이 없다.** `domain/rules/work_calculator.dart`의 계산 함수는 `tripStart`·`tripEnd`를 읽지 않는다(`sanitizeRecord`와 주간 요약 개수만 예외).
- 알림은 하루 최대 하나, 정시, 버튼 없음. "남았어요" 알림 없음.
- 브랜치 `feature/trip-record-notification`(dev에서). 커밋 메시지 끝에 `Co-Authored-By: Claude Fable 5.2 <noreply@anthropic.com>`. push는 사용자가.
- 지금 `docs/specs/`에 커밋 안 된 문서 4개(스펙 2 수정 · 브리프 6 · 핸드오프 6)가 있다 — Task 1 첫 커밋에 함께 넣는다.

## 확정 규칙 (스펙·핸드오프에 없거나 흩어진 것)

**시간 출장**
1. 유효성은 `tripEnd > tripStart`, 둘 다 그 기록 날짜 안. 하나만 있거나 뒤집혔으면 둘 다 비운다(`sanitizeRecord`, 백업 가져오기).
2. 연차·종일 출장 유형이면 비운다. 일반·반차·공휴일·주말·미래는 유지.
3. "빈 일반 기록" = 시각 없음 · 공제 0 · **출장 범위 없음**. 출장 범위만 있는 기록은 남긴다(오늘 출근 취소 포함).
4. 주간 요약 "출장 n" = 그 주 **월~일** 중 종일 출장 유형이거나 시간 출장이 있는 날 수.
5. 월간 원: 유형이 있으면 유형색(반차·공휴일이 먼저). 유형 없고 시간 출장이 있으면 출장색 — **미래 날짜 포함**(미리 찍은 유형과 같은 취급). 출장 원 위 숫자는 주말이어도 `tripText`.
6. 처음 값: 시작 = 그날 출근 시각 ?? `rules.defaultTripStartMinutes`(540), 끝 = 시작 + `rules.defaultTripMinutes`(180), 23:59에서 멈춤.

**퇴근 알림** — `planClockOutNotice`
```
오늘 기록이 "출근 있음 · 퇴근 없음"이 아니면            → 없음
주말 · 공휴일 근무                                      → 없음
T기준 = expectedClockOut(오늘, dayStandardMinutes(오늘), rules)
첫 주 예외                                             → 그날 기준 > 0 이면 daily @ T기준, 아니면 없음
remaining = weekRemainingBeforeToday                   → ≤ 0 이면 없음 (출근 전에 이미 채움)
T주간 = expectedClockOut(오늘, remaining, rules)
마지막 근무일                                          → T주간이 오늘 안이면 weekly(N2) @ T주간, 아니면 없음
T주간 ≤ T기준                                          → weeklyEarly(N2′) @ T주간
그 외                                                  → 그날 기준 > 0 이면 daily(N1) @ T기준, 아니면 없음
```
- 그날 기준이 0(공제로 다 빠짐)이면 daily는 보내지 않는다 — 채울 게 없는 날 출근하자마자 "퇴근할 시간"이 울리지 않게.

**동기화** — `ClockOutNotificationSync.sync()` (직렬 실행, 마지막 요청만 남기는 큐)
```
enabled 아님 || OS 권한 없음        → cancel, 저장된 통지 지움
plan 없음                           → cancel, 저장된 통지 지움
plan.at > now                       → 같은 통지가 이미 예약돼 있으면 그대로, 아니면 schedule(replace) + 저장
plan.at ≤ now (N3)
   오늘 이미 전달됨(저장된 통지의 날짜 = 오늘 && at ≤ now) → 아무것도 안 함
   아니면                           → cancel + showNow + 저장(at = now)
```
- "저장된 통지" = Settings 키 `clock_out_notice`(`yyyy-MM-ddTHH:mm|kind`). 예약 시각이 지났으면 OS가 이미 띄운 것으로 본다.
  이 값이 없으면 앱을 켤 때마다·기록을 고칠 때마다 N3가 반복해서 울린다.
- 계획이 **미래로 옮겨가면**(반차 해제, 출근 시각을 늦춤) 이미 울렸어도 새로 예약한다 — 앞의 알림이 틀린 데이터로 울린 것이므로.
- OS에 넘기는 시각 = `plan.at − 디버그 시계 오프셋`(릴리즈는 0). 앱 시계를 옮겨도 실제 시각에 울린다.
- 다시 맞추는 사건: 기록 스트림 · 첫 기록일 · 날짜 바뀜 · 알림 설정 · 디버그 오프셋 · 앱 resume(OS 설정에서 권한을 바꾸고 돌아옴). **버튼마다 따로 부르지 않는다.**

**권한·설정**
- P1은 **첫 평일 출근 직후** 한 번(주말·공휴일 근무 출근은 건너뜀). 수락/거절/바깥 탭 모두 `notificationPrompted = true`.
- OS 권한 상태 = OS가 허용이면 `granted`, 아니고 우리가 OS 창을 띄운 적이 없으면(`notification_os_asked` 없음) `notDetermined`, 띄운 적 있으면 `denied`.
- 설정 행: OS `denied`면 켜짐 여부와 무관하게 "설정 열기" 행. 그 외는 토글(값 = `clockOutNotificationEnabled`).
- 알림 설정 두 값(`clock_out_notification` · `notification_prompted`)은 `AppSettings`에 넣되 **백업에 넣지 않는다**(`last_export_date`처럼 기기 값 — 권한이 기기마다 다르다).

## Review Focus

1. **N3 중복** — 예약 시각이 지난 뒤 앱을 다시 켜거나, 지난 날 기록을 고치거나, 퇴근 취소를 해도 알림이 다시 울리지 않는다. (Task 9)
2. **시작 시 취소 금지** — 기록 스트림이 아직 안 온 동안 "plan 없음"으로 보고 예약을 지우지 않는다. (Task 9)
3. **빠른 연속 변경** — 출근 → 반차 체크 → 출근 변경을 연달아 해도 마지막 상태로 한 번 예약된다. (Task 9)
4. **v2 → v3 마이그레이션** — 기존 기록·공제·첫 기록일 보존, 새 컬럼 null. format 1·2 백업이 읽힌다. (Task 1)
5. **출장 범위만 있는 기록** — 미래 날짜·출근 전 오늘에서 저장돼 남고, 출근 취소해도 남고, 지우면 사라진다. (Task 1·3·5)
6. **레이아웃** — 주간 7행 높이 동일(반차+출장+공제), 오늘 화면 주 버튼 Y 불변(칩이 붙어도), SE 320×568에서 출장 작은 시트가 넘치지 않음. (Task 4·5·6)
7. **계산 불변** — 시간 출장을 넣고 빼도 잔여·기준 대비·오늘 몫·알림 계획이 같다. (Task 1·8)

---

## File Map

| 파일 | 변경 |
|---|---|
| `lib/domain/model/work_record.dart` | `tripStart`·`tripEnd` |
| `lib/domain/rules/work_rules.dart` | `defaultTripStartMinutes = 540`, `defaultTripMinutes = 180` |
| `lib/domain/rules/work_calculator.dart` | `hasTrip`, `isValidTripRange`, `tripMinutes`, `defaultTripRange`, `sanitizeRecord`, `weekSummary` 출장 수 |
| `lib/data/database/app_database.dart`, `drift_schemas/drift_schema_v3.json`, `test/generated_migrations/*` | 스키마 v3 |
| `lib/data/repository/drift_work_record_repository.dart` | 컬럼 매핑 |
| `lib/domain/backup/backup_codec.dart` | format 3, 뒤집힌 출장 범위 버림 |
| `lib/core/presentation/format/time_format.dart` | `formatClockSpan` ("09:20–12:30") |
| `lib/presentation/record_edit/record_draft.dart`, `record_edit_sheet.dart`, `record_edit_texts.dart` | 초안·시트 |
| `lib/presentation/record_edit/widgets/trip_sheet.dart` (신규) | 시간 출장 작은 시트 |
| `lib/presentation/record_edit/widgets/trip_choice_panel.dart` (신규) | "종일 / 시간" 패널 |
| `lib/presentation/record_edit/widgets/type_chips.dart`, `type_rows.dart` | 출장 칩·행 동작 |
| `lib/presentation/today/widgets/trip_chip.dart` (신규), `today_trip_sheet.dart` (신규) | 오늘 칩 · "오늘 출장" 시트 |
| `lib/presentation/today/today_controller.dart`, `today_screen.dart`, `today_texts.dart`, `widgets/status_block.dart`, `widgets/status_card.dart` | 오늘 화면 |
| `lib/presentation/week/week_state.dart`, `week_texts.dart`, `widgets/week_day_row.dart` | 배지 |
| `lib/presentation/month/month_state.dart`, `month_state_builder.dart`, `widgets/calendar_card.dart` | 원 색 |
| `lib/data/seed/debug_seed.dart` | 시간 출장 날 |
| `lib/domain/notification/clock_out_notice.dart` (신규) | `ClockOutNotice`, `planClockOutNotice` |
| `lib/domain/repository/notification_scheduler.dart` (신규) | 포트 + `NotificationPermission` |
| `lib/domain/repository/notification_state_repository.dart` (신규) | 저장된 통지 · OS 창 띄웠는지 |
| `lib/data/notification/local_notification_scheduler.dart` (신규) | 플랫폼 구현 |
| `lib/data/repository/drift_notification_state_repository.dart` (신규) | Settings 키 2개 |
| `lib/domain/model/app_settings.dart`, `lib/data/repository/drift_app_settings_repository.dart` | 알림 설정 두 값 |
| `lib/core/providers/notification_providers.dart` (신규) | 포트·권한·오늘 날짜 프로바이더 |
| `lib/presentation/notification/clock_out_notification_sync.dart` (신규), `notification_texts.dart` (신규), `notification_prompt.dart` (신규) | 동기화 · 문구 · P1 흐름 |
| `lib/presentation/shared/confirm_dialog.dart` | `body` 슬롯(미리보기 카드) |
| `lib/presentation/settings/*`, `widgets/soi_switch.dart` (신규) | 알림 섹션 |
| `lib/presentation/debug/seed_picker_sheet.dart` | 알림 시험 버튼 |
| `lib/main.dart` | 동기화 시작 · resume 훅 |
| `android/app/src/main/AndroidManifest.xml`, `android/app/build.gradle.kts`, `android/app/src/main/res/drawable*/ic_stat_soi.*` | 권한·리시버·desugaring·알림 아이콘 |
| `ios/Runner/AppDelegate.swift` | `UNUserNotificationCenter` delegate |
| `lib/ui/app_sizes.dart`, `app_text_styles.dart`, `app_colors.dart` | 토큰 (색은 기존 값의 새 이름만) |
| `CLAUDE.md`, 스펙 2개 | 규칙 반영 |

---

# Part A — 시간 출장 기록

### Task 1: 도메인·데이터 — 모델 · 규칙 · 스키마 v3 · 백업 format 3

**Files:**
- Modify: `lib/domain/model/work_record.dart`, `lib/domain/rules/work_rules.dart`, `lib/domain/rules/work_calculator.dart`, `lib/data/database/app_database.dart`, `lib/data/repository/drift_work_record_repository.dart`, `lib/domain/backup/backup_codec.dart`, `lib/core/presentation/format/time_format.dart`
- Create: `drift_schemas/drift_schema_v3.json`, `test/generated_migrations/schema_v3.dart`(생성)
- Test: `test/domain/work_calculator_test.dart`, `test/domain/work_record_test.dart`, `test/domain/backup_codec_test.dart`, `test/data/migration_test.dart`, `test/data/drift_work_record_repository_test.dart`, `test/data/drift_backup_repository_test.dart`, `test/core/format_test.dart`, `test/helpers/records.dart`

**Interfaces — Produces:**
```dart
// work_record.dart
DateTime? tripStart, DateTime? tripEnd   // 둘 다 있거나 둘 다 없다

// work_rules.dart
final int defaultTripStartMinutes; // 9 * 60
final int defaultTripMinutes;      // 180

// work_calculator.dart
bool hasTrip(WorkRecord? r);                                   // 둘 다 있음
bool isValidTripRange(DateTime? start, DateTime? end);         // 둘 다 null이면 true, 둘 다 있으면 end > start(분 단위), 하나만 있으면 false
int? tripMinutes(WorkRecord r);                                // 표시용 길이. 없으면 null
bool canHaveTrip(WorkType t);                                  // dayOff·businessTrip만 false
(DateTime, DateTime) defaultTripRange(DateTime date, DateTime? clockIn, WorkRules rules);

// time_format.dart
String formatClockSpan(DateTime start, DateTime end);          // "09:20–12:30" (en dash, 공백 없음)

// test/helpers/records.dart — rec()에 ({int? tripInH, int? tripInM, int? tripOutH, int? tripOutM}) 추가
```

- [ ] **Step 1: 브랜치 + 문서 커밋.** `git checkout -b feature/trip-record-notification` → `git add docs/specs docs/plans` → 커밋 "스펙: 시간 출장 기록 · 퇴근 알림 확정 (브리프 6 · 핸드오프 6 · 계획)".
- [ ] **Step 2: 실패하는 테스트 작성.**
  - `work_calculator_test.dart` 새 group "시간 출장":
    - `isValidTripRange`: (null,null) true · (9,12) true · (12,12) false · (12,9) false · (9,null) false.
    - `sanitizeRecord`: 연차 + 출장 범위 → 둘 다 null · 종일 출장 + 범위 → null · 일반/반차/공휴일/주말 + 범위 → 유지 · 끝 ≤ 시작 → 둘 다 null · 하나만 → 둘 다 null · 날짜가 기록 날짜와 다른 시각 → 그 날짜의 같은 시·분으로 맞춤.
    - **계산 불변**(Review 7): 같은 주 기록에 시간 출장을 붙인 것과 뺀 것의 `weekSummary`(출장 수 제외 전 필드) · `actualMinutes` · `deltaMinutes` · `dayStandardMinutes` · `todayShareMinutes` · `unrecordedWeekdays`가 같다.
    - `weekSummary.businessTripCount`: 종일 1 + 평일 시간 출장 1 + 토요일 시간 출장 1 → 3. 종일 출장 유형인 날은 한 번만.
    - `defaultTripRange`: 출근 09:12 → (09:12, 12:12) · 출근 없음 → (09:00, 12:00) · 출근 22:30 → (22:30, 23:59).
  - `work_record_test.dart`: toJson/fromJson 왕복에 trip 필드, 필드 없는 JSON → null.
  - `backup_codec_test.dart`: `format` 3으로 쓰인다 · format 2 파일(트립 필드 없음) 읽힘 · format 4 거부 · 끝 ≤ 시작인 출장 범위는 둘 다 버림(출퇴근은 유지).
  - `migration_test.dart`: v2에 기록 2건(공제 포함) + `first_record_date` → v3로 올린 뒤 기록·공제·첫 기록일 보존, `trip_start`·`trip_end` null. v1 → v3도.
  - `drift_work_record_repository_test.dart`: 출장 범위 저장·읽기 왕복 · 연차로 저장하면 범위가 지워진다.
  - `drift_backup_repository_test.dart`: 복원 뒤 출장 범위 유지.
  - `format_test.dart`: `formatClockSpan(9:20, 12:30) == '09:20–12:30'`.
- [ ] **Step 3: 실패 확인.** `flutter test test/domain test/data test/core` → 컴파일 오류/FAIL.
- [ ] **Step 4: 구현.**
  - `WorkRecord`에 두 필드. `WorkRules`에 두 값.
  - `work_calculator.dart`:
    ```dart
    bool hasTrip(WorkRecord? r) => r?.tripStart != null && r?.tripEnd != null;
    bool canHaveTrip(WorkType t) => t != WorkType.dayOff && t != WorkType.businessTrip;
    bool isValidTripRange(DateTime? start, DateTime? end) {
      if (start == null && end == null) return true;
      if (start == null || end == null) return false;
      return minuteOnly(end).isAfter(minuteOnly(start));
    }
    int? tripMinutes(WorkRecord r) => hasTrip(r) ? minutesBetween(r.tripStart!, r.tripEnd!) : null;
    ```
    `sanitizeRecord`: `keepTrip = canHaveTrip(r.type) && r.tripStart != null && r.tripEnd != null` → 두 시각을 `DateTime(r.date.y, m, d, h, min)`으로 옮긴 뒤 `isValidTripRange` 아니면 비움.
    `weekSummary`: 평일 루프의 `trips++`는 그대로 두고, 루프 뒤에 `for i in 0..6`의 날짜 중 `r.type != businessTrip && hasTrip(r)`인 날을 더한다.
  - `app_database.dart`: `tripStart`·`tripEnd` `dateTime().nullable()`, `schemaVersion => 3`, `if (from < 3) { addColumn × 2 }`.
  - 저장소 `toDomain`/`toCompanion`에 두 컬럼.
  - `backup_codec.dart`: `backupFormatVersion = 3`(주석에 3 설명), `_dropInvalidRange`가 출장 범위도 검사.
- [ ] **Step 5: 코드젠·스키마 덤프.**
  ```bash
  dart run build_runner build --delete-conflicting-outputs
  dart run drift_dev schema dump lib/data/database/app_database.dart drift_schemas/drift_schema_v3.json
  dart run drift_dev schema generate drift_schemas/ test/generated_migrations/
  ```
- [ ] **Step 6: 통과 확인.** `flutter test` 전체 PASS (기존 441 + 신규). `flutter analyze` 깨끗.
- [ ] **Step 7: 커밋** "시간 출장: 모델 · 스키마 v3 · 백업 format 3".

### Task 2: 시간 출장 작은 시트 (`TripSheet`)

**Files:**
- Create: `lib/presentation/record_edit/widgets/trip_sheet.dart`
- Modify: `lib/presentation/record_edit/record_edit_texts.dart`, `lib/ui/app_sizes.dart`, `lib/ui/app_text_styles.dart`
- Test: `test/presentation/trip_sheet_test.dart` (신규)

**Interfaces — Produces:**
```dart
sealed class TripSheetResult {}
class TripSheetSet extends TripSheetResult { final DateTime start, end; }
class TripSheetCleared extends TripSheetResult {}

/// 바깥 탭·내리기면 null(아무것도 안 바꿈).
Future<TripSheetResult?> showTripSheet(
  BuildContext context, {
  required DateTime date,
  required DateTime start,   // 처음 값 또는 기존 값
  required DateTime end,
  required bool existing,    // true면 "출장 지우기" 노출
  required String confirmLabel, // "확인" | "저장"
});
```
`RecordEditTexts`: `tripSheetTitle = '시간 출장'` · `tripSheetHelp = '몇 시부터 몇 시까지 출장이었는지 기록으로 남겨요.'` · `tripStart = '시작'` · `tripEnd = '끝'` · `tripInvalid = '끝이 시작보다 늦어야 해요'` · `tripClear = '출장 지우기'` · `tripResult(start, end)` → `'09:00–12:00 · 3시간'`(`formatClockSpan` + `formatKoreanDuration`).

- [ ] **Step 1: 테스트.** (`deduction_sheet`를 다루는 `record_edit_sheet_test.dart`의 pump 패턴을 따른다)
  - 열면 "시작" 칸이 선택(값 브랜드 w600), 결과 줄 "09:00–12:00 · 3시간".
  - "끝" 칸을 누르면 선택이 옮겨가고 휠이 끝 값을 가리킨다(휠은 칸마다 `ValueKey`로 새로 만든다).
  - 끝 ≤ 시작이면 결과 줄 자리에 안내, 버튼 탭해도 닫히지 않음.
  - 확인 → `TripSheetSet(start, end)` 반환. `existing: false`면 "출장 지우기" 없음, true면 있고 탭 → `TripSheetCleared`.
  - 화면 320×568에서 overflow 없음(`tester.takeException()` null), 버튼이 화면 안.
- [ ] **Step 2: 실패 확인** → **Step 3: 구현.** `DeductionSheet`와 같은 컨테이너(핸들·제목·그림자). 치수는 핸드오프 §3 표 그대로:
  시작·끝 칸 = 라벨 13 subtle / 값 20, 고른 칸 아래 2px brand · 다른 칸 1px `rowDivider`, 사이 "–" 18 `wheelUnselected`, 위 12. 휠 박스는 기존 `wheelBox*` 토큰 + `TimeWheel`. 결과 줄 14.5/w500 가운데 위 14, 안내 13.5/w500 minus. 버튼 `SheetButton` 위 12. "출장 지우기" 13.5 subtle 히트 44.
  본문은 `ConstrainedBox(maxHeight: 화면 높이 − 44)` + `SingleChildScrollView`.
- [ ] **Step 4: 통과 확인** → **Step 5: 커밋** "시간 출장: 작은 시트".

### Task 3: 시간 수정 시트 — 출장 고르기 패널 · 출장 행

**Files:**
- Create: `lib/presentation/record_edit/widgets/trip_choice_panel.dart`
- Modify: `record_draft.dart`, `record_edit_sheet.dart`, `record_edit_texts.dart`, `widgets/type_chips.dart`, `widgets/type_rows.dart`, 토큰 파일
- Test: `test/presentation/record_draft_test.dart`, `test/presentation/record_edit_sheet_test.dart`

**Interfaces — Consumes:** Task 1·2. **Produces:**
```dart
// RecordDraft
final DateTime? tripStart, tripEnd;
bool get hasTrip;                       // 범위 있음
bool get isFullDayTrip;                 // type == businessTrip
bool get tripSelected;                  // hasTrip || isFullDayTrip  — 칩·행 선택 표시
bool get showsTripRow;                  // !isTypeOnly && (hasTrip || isWeekend)  +  isTypeOnly && isWeekend
RecordDraft withTrip(DateTime start, DateTime end); // 연차·종일 출장이면 type → normal, 공휴일·반차는 유지
RecordDraft withoutTrip();
// toRecord(): canHaveTrip(type)일 때만 범위 포함. isEmptyNormal: 범위도 없어야 true.

// TypeChips / TypeRows
TypeChips({required selected, required tripSelected, required onChanged, required onTripTap});
TypeRows({required selected, required tripSelected, required tripRange /* String? */, required onChanged, required onTripTap});
```
`RecordEditTexts`: `tripPanelNote = '출장을 어떻게 넣을까요?'` · `tripFullDay = '종일 출장'` · `tripFullDaySub = '8시간 인정'` · `tripFullDayHalfDay = '반차인 날은 안 돼요'` · `tripTimed = '시간 출장'` · `tripTimedSub = '시간 직접 입력'` · `tripRemove = '출장 빼기'` · `tripRowLabel = '출장'` · `tripNone = '없음'`.

- [ ] **Step 1: 초안 테스트** (`record_draft_test.dart`):
  - `fromRecord`가 범위를 읽는다. `withTrip`: 연차 → normal + 범위, 종일 출장 → normal + 범위, 공휴일 → 공휴일 유지, 반차 → 반차 유지.
  - `toRecord`: 연차로 바꾸면 범위 없음. 미래 날짜 + 범위만 → `isEmptyNormal` false. 범위·시각·공제 없으면 true.
  - `showsTripRow`: 과거 평일 범위 있음 true / 없음 false · 주말은 범위 없어도 true · 미래 평일 false(행 대신 유형 행이 보인다) · 미래 주말 true.
- [ ] **Step 2: 시트 위젯 테스트** (`record_edit_sheet_test.dart`, 기존 헬퍼 재사용):
  - 과거 평일: 출장 칩 탭 → 저장되지 않고 패널이 열린다(안내 문구 보임). 다시 탭 → 닫힘.
  - 패널 "종일 출장" → 시각 있던 날이면 기존 확인 다이얼로그 → 저장 후 닫힘, DB에 `businessTrip`·시각 null.
  - 반차 켠 날: "종일 출장" 보조가 "반차인 날은 안 돼요", 탭해도 변화 없음.
  - 패널 "시간 출장" → 작은 시트("확인") → 확인 → 큰 시트에 "출장" 행 `09:00–12:00`, 칩 선택 표시, **아직 DB에 없음** → 저장 → DB에 범위, 출퇴근 유지.
  - "출장" 행 탭 → 작은 시트에 "출장 지우기" → 탭 → 행 사라짐.
  - 연차인 날 패널 "시간 출장" → 확인 → 초안 유형이 일반으로(시각 행이 나타남).
  - 공휴일 근무 날 → 시간 출장 넣고 저장 → 유형 공휴일 그대로.
  - 미래 평일: 출장 행 탭 → 패널. "시간 출장" → 작은 시트 버튼이 "저장" → 저장 → 시트 전부 닫힘, DB에 범위만 있는 기록. 다시 열면 출장 행이 선택 배경 + `09:00–12:00`.
  - 미래 평일 종일 출장 상태에서 패널 "출장 빼기" → 기록 삭제(빈 일반).
  - 주말(과거): 칩 없이 "출장 · 없음" 행 → 탭 → 작은 시트("확인").
  - 계산 내역에 출장 줄이 없다(`calcLines` 길이 불변).
  - 폭 320 · 높이 568: 반차 + 출장 + 공제가 다 있는 과거 시트에서 overflow 없음.
- [ ] **Step 3: 실패 확인** → **Step 4: 구현.**
  - 패널 치수는 핸드오프 §2 표(배경 `cardInner`, 라운드 14, 패딩 12, 위 8, 버튼 `card` 라운드 12 최소 높이 58, 제목 15/w600, 보조 12.5 한 줄, 선택 = 브랜드 + " ✓" + 안쪽 1.5 테두리, 비활성 제목 `dotInactive`).
  - 시트 상태 `_tripPanelOpen`(초안이 아니라 위젯 상태). 다른 유형 칩/행을 누르면 닫는다.
  - `_onTripTimed`: `showTripSheet(start/end = 기존 범위 ?? defaultTripRange(date, draft.clockIn, rules), existing: draft.hasTrip, confirmLabel: isTypeOnly ? 저장 : 확인)` → `TripSheetSet` → `next = draft.withTrip(...)` → typeOnly면 `_saveDraft(next)`, 아니면 `_update(next)` + 패널 닫기. `TripSheetCleared` → `withoutTrip()` 같은 분기.
  - `_onTripFullDay`: 기존 `_onTypeChanged(draft, WorkType.businessTrip)`.
  - `_onTripRemove`: 종일이면 `_onTypeChanged(draft, null)`, 시간이면 `withoutTrip()`(typeOnly면 저장).
  - 출장 행 = `TimeRow(label: 출장, value: formatClockSpan | 없음)`, 위치는 출퇴근 행·휠 아래, 시간공제 행 위. 주말 typeOnly에서도 보인다.
  - `RecordEditController.save`는 `isEmptyNormal`을 그대로 쓴다(초안이 범위를 반영).
- [ ] **Step 5: 통과 확인**(전체 `flutter test`) → **Step 6: 커밋** "시간 출장: 시트에서 종일/시간 고르기".

### Task 4: 주간 배지 · 월간 원

**Files:**
- Modify: `week/week_state.dart`, `week/week_texts.dart`, `week/widgets/week_day_row.dart`, `month/month_state.dart`, `month/month_state_builder.dart`, `month/widgets/calendar_card.dart`, 토큰
- Test: `test/presentation/week_texts_test.dart`, `week_screen_test.dart`, `month_state_builder_test.dart`, `month_screen_test.dart`

**Interfaces — Produces:**
```dart
enum WeekBadgeKind { type, trip, deduction }
class WeekBadge { const WeekBadge(this.label, this.kind, {this.type}); }
// MonthCell
required bool hasTrip   // 시간 출장 범위가 있는 날 (유형과 무관하게 사실만)
```

- [ ] **Step 1: 테스트.**
  - `week_texts_test`: 배지 순서 유형 → 출장 → 공제. 시간 출장 3h 10m → "출장 3h 10m"(kind trip). 종일 출장 → "출장"(kind type) 하나만. 요약 줄 "출장 2".
  - `week_screen_test`: 기존 "7행 높이 동일"(폭 320·360·600)에 **반차 + 출장 + 공제** 행을 넣는다. 셋째 배지(공제)가 둘째 줄 맨 앞에 그려진다(`tester.getTopLeft` y 비교). 첫 줄에 overflow 없음.
  - `month_state_builder_test`: `hasTrip` 참/거짓. 값(`MonthCellValue`)은 출장 유무로 바뀌지 않는다.
  - `month_screen_test`: 평일 근무 + 출장 → 원 `tripBackground`, 숫자 `tripText` · 반차 + 출장 → 반차색 · 공휴일 근무 + 출장 → 공휴일색 · **주말 근무 + 출장 → 출장 원 + 숫자 `tripText`(적갈색 아님)** · 미래 + 출장만 → 출장 원 · 범례 그대로. 기존 "값이 잘리지 않는다" 폭 8종 통과.
- [ ] **Step 2: 실패 확인** → **Step 3: 구현.**
  - `WeekTexts.badges`: `[유형?, if (hasTrip(r)) WeekBadge('출장 ${formatHm(tripMinutes(r)!)}', trip), 공제?]`.
  - `WeekDayRow`: 첫 줄엔 앞의 두 개까지, 셋째는 둘째 줄 `Row[배지, gap, Expanded(note)]`. 둘째 줄 높이는 기존 `rowNoteHeight`(20) 그대로 — 그 줄의 배지는 세로 패딩을 줄인 토큰(`rowBadgePaddingTight`, 줄높이 16)으로. trip 색은 `AppColors.typeColors(WorkType.businessTrip)`.
  - `_circleColor`: `type != null` → 유형색, `cell.hasTrip` → `tripBackground`, 그 외 기존. `_numColor`: 출장 원이면 `tripText`(주말 예외 — 주석에 대비 3.6:1 이유).
- [ ] **Step 4: 통과 확인** → **Step 5: 커밋** "시간 출장: 주간 배지 · 월간 원".

### Task 5: 오늘 화면 — 출장 칩 · "오늘 출장" 시트

**Files:**
- Create: `lib/presentation/today/widgets/trip_chip.dart`, `lib/presentation/today/widgets/today_trip_sheet.dart`
- Modify: `today_controller.dart`, `today_screen.dart`, `today_texts.dart`, `widgets/status_block.dart`, `widgets/status_card.dart`, 토큰
- Test: `test/presentation/today_controller_test.dart`, `today_view_test.dart`, `today_texts_test.dart`

**Interfaces — Produces:**
```dart
// TodayController
Future<void> setTrip(DateTime start, DateTime end);  // 시·분만 쓰고 날짜는 오늘. 연차·종일 출장이면 유형을 일반으로
Future<void> clearTrip();                            // 지운 결과가 빈 일반 기록이면 행 삭제

// TodayCallbacks
required VoidCallback onTripTap;        // 근무 중·출근 전 칩 → 시간 출장 작은 시트("저장")
required VoidCallback onTripRadioTap;   // 출근 전 "출장" 라디오 → "오늘 출장" 시트

enum TodayTripChoice { fullDay, timed }
Future<TodayTripChoice?> showTodayTripSheet(BuildContext context, {required String? tripRange});
```
`TodayTexts`: `tripAdd = '+ 출장'` · `tripChip(start, end) => '출장 ${formatClockSpan}'` · `tripAddSemantics = '출장 시간 남기기'` · `tripEditSemantics = '출장 시간 고치기'` · `todayTripTitle = '오늘 출장'` · `todayTripFullDay = '종일 출장'` / `'출근 없이 8시간 근무로 인정돼요'` · `todayTripTimed = '시간 출장'` / `'출퇴근은 그대로 찍고, 출장 시간만 남겨요'`.

- [ ] **Step 1: 컨트롤러 테스트.**
  - 출근 전 `setTrip` → 범위만 있는 오늘 기록, phase before. `clearTrip` → 기록 삭제.
  - 근무 중 `setTrip` → 출근 시각·유형 유지. `clearTrip` → 기록 남음.
  - 근무 중 + 출장 → `cancelClockIn` → 기록이 남고 범위 유지, 시각 null. (공제·출장 둘 다 없을 때만 삭제 — 기존 테스트 유지)
  - 종일 출장 상태에서 `setTrip` → 유형 일반 + 범위.
  - 범위 있는 날 `setDayType(businessTrip)` → 범위 지워짐.
- [ ] **Step 2: 뷰 테스트** (`today_view_test.dart`):
  - 근무 중: "09:12 출근" 옆에 "+ 출장" 칩, 탭 → `onTripTap`. 범위 있으면 "출장 09:12–12:12".
  - 출근 전: 범위 없으면 칩 없음, 있으면 "아직 출근 전" 옆에 칩. "출장" 라디오 탭 → `onTripRadioTap`(예전처럼 `onDayTypeChanged`가 불리지 않는다).
  - 퇴근 완료: 범위 있으면 요약 위에 칩(탭 반응 없음), 없으면 없음.
  - **기존 "상태들의 주 버튼 Y가 같다" 테스트에 칩이 있는 출근 전·근무 중·퇴근 완료를 추가** — Y 불변. 폭 320·360·402에서 근무 중 줄 overflow 없음.
  - "오늘 출장" 시트: 두 행, 종일 탭 → `fullDay`, 시간 탭 → `timed`, 범위가 있으면 시간 행 오른쪽에 범위.
- [ ] **Step 3: 실패 확인** → **Step 4: 구현.**
  - `TripChip`: 핸드오프 §4 표(없음 = 투명 + 1px 점선 `tripBorder` + 12.5/w600 subtle, 있음 = `tripBackground` + `tripText`, 패딩 3/8, 라운드 6). 점선은 `CustomPainter`. 히트 영역은 `Stack` + `Positioned`(-8/-6)로 레이아웃에 영향 없이 넓힌다. `Semantics(button, label)`.
  - `StatusBlock`: 근무 중 `_DotLine` 줄을 `Row[_DotLine, 7, TripChip]`로. 출근 전은 범위 있을 때만. 퇴근 완료는 `Column[TripChip, gap, SummaryRow]` — 104 안에 들어가는지 Step 2 테스트가 판정, 넘치면 gap 토큰을 줄인다.
  - `TodayScreen`: `onTripTap` → `showTripSheet(start/end = 기존 ?? defaultTripRange(today, state.clockIn, rules), existing, confirmLabel: 저장)` → `setTrip`/`clearTrip`. `onTripRadioTap` → `showTodayTripSheet` → `fullDay`면 `setDayType(businessTrip)`, `timed`면 위와 같은 작은 시트.
  - `cancelClockIn`의 삭제 조건에 `!hasTrip(next)` 추가.
- [ ] **Step 5: 통과 확인** → **Step 6: 커밋** "시간 출장: 오늘 화면 칩 · 오늘 출장 시트".

### Task 6: 시드 · Part A 마무리

**Files:** `lib/data/seed/debug_seed.dart`, `test/data/debug_seed_test.dart`, `CLAUDE.md`

- [ ] **Step 1:** '두 달치 기록' `fixed`에 시간 출장 날 5개를 넣는다(기존 출장·공제 날 화·수·목은 그대로 둔다).
  - 지난 주 금요일: 일반 근무 + 출장 09:20–12:30
  - 지난 주 월요일: 반차(13:30 출근) + 출장 13:40–16:00 + 공제 30m — 배지 셋
  - 2주 전 월요일 공휴일 근무(이미 있음)에 출장 10:00–13:00
  - 지난 토요일: 주말 근무 10:00–14:00 + 출장 10:00–12:00
  - 다음 주 화요일: 출장 09:00–12:00만(예정)

  `debug_seed_test`에 "시간 출장 날이 일반·반차+공제·공휴일 근무·주말 각 1 + 미래 1" 단언.
- [ ] **Step 2:** `CLAUDE.md` — 근무 유형 표 아래 "시간 출장 (2026-11-20)" 절(확정 규칙 1~6 요약), 데이터 모델·스키마 v3 문단, 백업 format 3, "기록 수정" 절의 출장 고르기·출장 행, 프레젠테이션 규칙에 오늘 칩·주간 배지(셋째는 둘째 줄)·월간 주말 숫자 예외, 테스트 목록, 시드 설명.
- [ ] **Step 3:** `flutter test` 전체 + `flutter analyze` → **커밋** "시간 출장: 시드 · CLAUDE.md".

---

# Part B — 퇴근 알림

### Task 7: 패키지 · 플랫폼 설정 · 포트 · 플랫폼 구현

**Files:**
- Modify: `pubspec.yaml`, `android/app/src/main/AndroidManifest.xml`, `android/app/build.gradle.kts`, `ios/Runner/AppDelegate.swift`
- Create: `lib/domain/repository/notification_scheduler.dart`, `lib/data/notification/local_notification_scheduler.dart`, `lib/core/providers/notification_providers.dart`, `android/app/src/main/res/drawable-{mdpi,hdpi,xhdpi,xxhdpi,xxxhdpi}/ic_stat_soi.png`
- Test: `test/data/local_notification_scheduler_test.dart`(순수 부분만)

**Interfaces — Produces:**
```dart
// domain/repository/notification_scheduler.dart
enum OsNotificationStatus { granted, notGranted }

abstract interface class NotificationScheduler {
  /// 지금 OS가 이 앱의 알림을 허용하는지. 창을 띄우지 않는다.
  Future<OsNotificationStatus> status();
  /// OS 권한 창. 허용되면 true. 이미 거부된 기기에선 창 없이 false.
  Future<bool> requestPermission();
  /// 퇴근 알림 하나를 [at](실제 기기 시각)에 예약. 이전 예약을 대체한다.
  Future<void> schedule({required DateTime at, required String title, required String body});
  /// 지금 바로 띄운다. 예약은 건드리지 않는다.
  Future<void> showNow({required String title, required String body});
  Future<void> cancel();
  /// OS의 이 앱 알림 설정 화면.
  Future<void> openSystemSettings();
}

// core/providers/notification_providers.dart
@Riverpod(keepAlive: true) NotificationScheduler notificationScheduler(Ref ref);
```

- [ ] **Step 1: 패키지 추가.** `flutter pub add flutter_local_notifications timezone flutter_timezone app_settings`.
- [ ] **Step 2: 설치된 버전의 문서를 읽는다.** `flutter_local_notifications` ^23은 이 계획을 쓴 시점의 지식보다 새 버전이다 —
  `~/AppData/Local/Pub/Cache/hosted/pub.dev/flutter_local_notifications-*/README.md`와 `example/lib/main.dart`에서 **Android setup(Gradle·manifest)** · **iOS setup(AppDelegate)** · `initialize` · `zonedSchedule` · `AndroidScheduleMode` · `DarwinNotificationDetails` · 권한 요청 API의 **현재 시그니처**를 확인하고, 아래 단계와 다르면 README를 따른다. 차이는 커밋 메시지에 적는다.
- [ ] **Step 3: Android.**
  - manifest: `<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>` · `RECEIVE_BOOT_COMPLETED` · `<receiver>` 두 개(`ScheduledNotificationReceiver`, `ScheduledNotificationBootReceiver` + BOOT_COMPLETED·MY_PACKAGE_REPLACED·QUICKBOOT_POWERON intent-filter) — README 그대로. **`SCHEDULE_EXACT_ALARM`·`USE_EXACT_ALARM`은 넣지 않는다**(정시 ±수 분 허용, Play 정책 회피).
  - `build.gradle.kts`: `compileOptions { isCoreLibraryDesugaringEnabled = true }` + `dependencies { coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:<README 버전>") }`.
  - 알림 아이콘: `assets/images/mark-transparent.png`의 알파를 살리고 색을 흰색으로 바꾼 PNG 5벌(24/36/48/72/96px)을 PowerShell `System.Drawing`으로 만든다(스크립트는 스크래치패드에, 산출물만 커밋). Android 상태바 아이콘은 알파만 쓰인다 — 컬러 런처 아이콘을 쓰면 흰 사각형이 된다.
- [ ] **Step 4: iOS.** `AppDelegate.application(_:didFinishLaunchingWithOptions:)`에 `UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate`(README 문구 그대로). 이게 없으면 **앱을 보고 있을 때 배너가 뜨지 않는다.**
- [ ] **Step 5: 구현 `LocalNotificationScheduler`.**
  - 지연 초기화 한 번(`_ready ??= _init()`): `tz.initializeTimeZones()` → `tz.setLocalLocation(tz.getLocation(await FlutterTimezone.getLocalTimezone() 의 식별자))`(실패하면 UTC 유지 — 절대 시각으로 예약하므로 울리는 순간은 같다) → `plugin.initialize(Android: 'ic_stat_soi', Darwin: requestAlert/Badge/Sound 전부 false, defaultPresentBanner/List/Sound true)`.
    **초기화에서 권한을 묻지 않는다** — P1 수락 뒤에만 묻는다.
  - 채널: id `clock_out`, 이름 "퇴근 알림", `Importance.high`(헤드업 배너 + 진동 — Wear OS·갤럭시 워치로 그대로 미러링된다). `setLocalOnly` 류 옵션을 쓰지 않는다.
  - 알림 id는 상수 하나(`1`) — 같은 id로 예약하면 대체된다.
  - `schedule`: `zonedSchedule(id, title, body, tz.TZDateTime.from(at, tz.local), details, androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle)`.
  - Darwin details: `presentBanner: true, presentList: true, presentSound: true`(포그라운드에서도 배너). 배지는 쓰지 않는다. 버튼(카테고리) 없음.
  - `status`: Android `areNotificationsEnabled()`, iOS `checkPermissions()`의 허용 여부. `requestPermission`: Android `requestNotificationsPermission()`, iOS `requestPermissions(alert·sound: true, badge: false)`.
  - `openSystemSettings`: `app_settings` 패키지의 알림 설정 열기(우리 `AppSettings` 모델과 이름이 겹친다 — `import ... as os_settings`).
  - 순수 함수로 뺄 수 있는 것(채널 상수, `DateTime` → `TZDateTime` 변환)만 단위 테스트. 플러그인 호출은 기기 확인(Task 12).
- [ ] **Step 6:** `flutter analyze` · `flutter test` · `flutter build apk --flavor dev --debug`로 Gradle 설정 확인(desugaring·manifest 병합 오류가 여기서 난다) → **커밋** "퇴근 알림: 패키지 · 플랫폼 설정 · 스케줄러 포트".

### Task 8: 도메인 — `planClockOutNotice`

**Files:**
- Create: `lib/domain/notification/clock_out_notice.dart`
- Test: `test/domain/clock_out_notice_test.dart`

**Interfaces — Produces:**
```dart
enum ClockOutNoticeKind { daily, weekly, weeklyEarly }   // N1 · N2 · N2′

class ClockOutNotice {
  const ClockOutNotice(this.kind, this.at);
  final ClockOutNoticeKind kind;
  final DateTime at;   // 앱 시계 기준, 분 단위
  // ==, hashCode
}

ClockOutNotice? planClockOutNotice({
  required List<WorkRecord> records,
  required DateTime today,            // 날짜만 쓴다
  required WorkRules rules,
  required DateTime? firstRecordDate, // 호출부가 effectiveFirstRecordDate를 먼저 적용
});
```

- [ ] **Step 1: 테스트** (헬퍼 `rec`/`d` — 2026-09-14(월)~18(금) 주. 앞선 날은 9–18시 8h로 채운다고 가정):
  | 상황 | 기대 |
  |---|---|
  | 수요일 08:30 출근, 일반 | daily @ 17:30 |
  | 수요일 13:30 출근(점심 창 뒤) | daily @ 21:30 |
  | 수요일 반차 08:30 | daily @ 12:30 |
  | 수요일 공제 2h, 09:00 | daily @ 16:00 |
  | 수요일 공제 8h(기준 0), 09:00 | 없음 |
  | 수요일 + 시간 출장 09:00–12:00 | 출장 없는 경우와 **같은 값** |
  | 금요일(마지막), 남은 8h, 09:00 | weekly @ 18:00 |
  | 금요일, 남은 6h(앞에서 +2h), 09:00 | weekly @ 16:00 |
  | 금요일, 남은 10h(앞에서 −2h), 09:00 | weekly @ 20:00 (17:30/18:00에 daily 없음) |
  | 금요일, 남은 20h, 09:00 | 없음(T주간이 다음 날) |
  | 금요일 연차 → 목요일이 마지막, 남은 8h | weekly @ 목 18:00 |
  | 목요일(마지막 아님), 남은 3h(월~수 초과) 09:00 | weeklyEarly @ 12:00 |
  | 월~수에 이미 40h+ 채움, 목요일 출근 | 없음 |
  | 첫 주 예외(첫 기록일 수요일), 목요일 09:00 | daily @ 18:00 |
  | 첫 주 예외인 금요일 | daily (weekly 아님) |
  | 토요일 출근 | 없음 |
  | 평일 공휴일 근무 | 없음 |
  | 출근 전 / 퇴근 완료 / 연차 / 종일 출장 / 기록 없음 | 없음 |
- [ ] **Step 2: 실패 확인** → **Step 3: 구현** ("확정 규칙"의 의사코드 그대로, 기존 `expectedClockOut`·`weekRemainingBeforeToday`·`isLastWorkday`·`dayStandardMinutes`·`isFirstWeekException` 재사용. 새 계산식을 만들지 않는다.) → **Step 4: 통과** → **Step 5: 커밋** "퇴근 알림: 무엇을 언제 — planClockOutNotice".

### Task 9: 설정 값 · 상태 저장 · 동기화

**Files:**
- Modify: `lib/domain/model/app_settings.dart`, `lib/data/repository/drift_app_settings_repository.dart`, `lib/presentation/settings/settings_controller.dart`, `lib/core/providers/notification_providers.dart`, `lib/main.dart`
- Create: `lib/domain/repository/notification_state_repository.dart`, `lib/data/repository/drift_notification_state_repository.dart`, `lib/presentation/notification/clock_out_notification_sync.dart`, `lib/presentation/notification/notification_texts.dart`
- Test: `test/data/drift_app_settings_repository_test.dart`, `test/data/drift_notification_state_repository_test.dart`, `test/data/drift_backup_repository_test.dart`, `test/presentation/clock_out_notification_sync_test.dart`, `test/helpers/fake_notification_scheduler.dart`

**Interfaces — Produces:**
```dart
// AppSettings
@Default(false) bool clockOutNotificationEnabled,   // key clock_out_notification = on|off
@Default(false) bool notificationPrompted,          // key notification_prompted = 1

// NotificationStateRepository (Settings 키 clock_out_notice · notification_os_asked)
Future<ClockOutNotice?> lastNotice();
Future<void> saveLastNotice(ClockOutNotice? notice);   // null이면 행 삭제
Future<bool> osAsked();
Future<void> markOsAsked();

// notification_providers.dart
@Riverpod(keepAlive: true) NotificationStateRepository notificationStateRepository(Ref ref);
@Riverpod(keepAlive: true) Future<DateTime> todayDate(Ref ref);          // nowProvider의 날짜만 — 분마다 다시 돌지 않게
@Riverpod(keepAlive: true) Future<ClockOutNotice?> clockOutNoticePlan(Ref ref); // records · firstRecordDate · todayDate · rules
enum NotificationPermission { granted, notDetermined, denied }
@riverpod Future<NotificationPermission> notificationPermission(Ref ref); // status() + osAsked()

// clock_out_notification_sync.dart
@Riverpod(keepAlive: true)
class ClockOutNotificationSync extends _$ClockOutNotificationSync {
  void build();                 // listen 등록 + 첫 sync
  Future<void> sync();          // 직렬. 실행 중에 또 불리면 끝난 뒤 한 번 더
}

// SettingsController
Future<void> setClockOutNotification(bool on);
Future<void> markNotificationPrompted();

// NotificationTexts
static (String title, String body) notice(ClockOutNoticeKind kind);   // 핸드오프 §10 N1 · N2 · N2′
```

- [ ] **Step 1: 저장소 테스트.** 두 설정 값 저장·읽기 왕복, 없는 키 = false, 다른 키(연차·시급)를 건드리지 않음. **백업 복원 뒤 두 값이 기기 값 그대로**(`last_export_date`와 같은 테스트 옆에). `lastNotice` 왕복·삭제·손상된 값은 null, `osAsked` 기본 false.
- [ ] **Step 2: Fake.** `FakeNotificationScheduler`: `status`(바꿀 수 있는 필드), `requestResult`, 호출 로그 `List<String>`(`schedule 2026-09-16 17:30 퇴근할 시간이에요`, `showNow …`, `cancel`), 현재 예약(`scheduledAt`), `openSettingsCount`.
- [ ] **Step 3: 동기화 테스트** (`ProviderContainer.test` + 인메모리 Drift + 고정 `clockProvider`/`nowProvider`, `today_controller_test.dart`의 구성 그대로. 시계는 테스트가 바꿀 수 있는 변수로):
  - 꺼짐(기본) → 출근해도 예약 없음.
  - 켜짐 + 허용: 출근(08:30) → `schedule 17:30` 한 번, `lastNotice` 저장.
  - 퇴근 → `cancel`, `lastNotice` null. 출근 취소 → `cancel`.
  - 출근 변경(08:00) → 다시 예약 17:00. 반차 체크 → 12:00(이전 예약 대체), 해제 → 17:00.
  - 근무 중 지난 날 기록 수정(어제 +1h) → 마지막 근무일이면 시각이 바뀌어 재예약, 아니면 **같은 통지라 schedule을 다시 부르지 않는다**.
  - 켜짐 + OS 미허용 → 예약 없음. `status`를 허용으로 바꾸고 `sync()` → 예약.
  - 알림 끔 → `cancel`.
  - **N3**: 출근 08:30, 시계를 18:00으로 → 출근 변경으로 T가 17:00 → `showNow` 한 번. 다시 `sync()` 세 번 → 추가 호출 없음.
  - **이미 울린 뒤**: 17:30 예약 저장 → 시계 18:00 → `sync()`(앱 재시작 흉내: 컨테이너를 새로 만들고 같은 DB) → `showNow` 없음, `schedule` 없음.
  - 울린 뒤 퇴근 → 퇴근 취소 → (저장이 지워졌으므로) `showNow` 한 번 — 스펙 N3와 같은 동작임을 테스트 이름에 적는다.
  - 울린 뒤 계획이 미래로(반차 해제) → 새로 `schedule`.
  - **시작 시**(Review 2): 예약이 있는 상태에서 컨테이너를 만들고 기록 스트림이 오기 전에 `cancel`이 불리지 않는다.
  - **연속 변경**(Review 3): `clockIn(); setHalfDay(true); setClockIn(...)`를 await 없이 이어 부른 뒤 안정되면 마지막 예약이 최종 상태와 같다.
  - 날짜가 바뀜(`nowProvider`가 다음 날) + 오늘 기록 없음 → `cancel`.
  - 디버그 오프셋 +3h → OS에 넘긴 시각 = 앱 시각 − 3h.
  - `schedule`이 예외를 던져도 다음 `sync()`가 동작한다(큐가 죽지 않는다).
- [ ] **Step 4: 실패 확인** → **Step 5: 구현.**
  ```dart
  @override
  void build() {
    ref.listen(clockOutNoticePlanProvider, (_, next) { if (next.hasValue) sync(); });
    ref.listen(appSettingsProvider.select((s) => s.value?.clockOutNotificationEnabled), (_, _) => sync());
    if (kDebugMode) ref.listen(debugClockOffsetProvider, (_, _) => sync());
    sync();
  }

  Future<void> sync() {
    _dirty = true;
    return _running ??= _drain().whenComplete(() => _running = null);
  }

  Future<void> _drain() async {
    while (_dirty) {
      _dirty = false;
      try { await _run(); } catch (_) { /* 알림 실패가 앱을 막지 않는다 */ }
    }
  }
  ```
  `_run()`은 "확정 규칙 — 동기화" 표 그대로. 읽기는 전부 `await ref.read(xProvider.future)` 또는 저장소의 `get()` 계열. `now = minuteOnly(ref.read(clockProvider)())`.
  "같은 통지가 이미 예약돼 있음" = `lastNotice == plan`(kind·at 동일) && `plan.at > now`.
  - `main.dart`: `SoiDutyApp.build`에서 `ref.watch(clockOutNotificationSyncProvider)`로 시작. `AppLifecycleListener(onResume:)`(작은 `ConsumerStatefulWidget`로 감싼다)에서 `ref.invalidate(notificationPermissionProvider)` + `sync()`.
  - **위젯 테스트 보호**: `test/widget_test.dart`와 화면 테스트들이 실제 플러그인을 부르지 않게 `notificationSchedulerProvider`를 Fake로 오버라이드하는 헬퍼를 `test/helpers/`에 두고 기존 부팅 테스트에 적용한다.
- [ ] **Step 6: 통과 확인**(전체) → **Step 7: 커밋** "퇴근 알림: 설정 값 · 한 곳에서 다시 맞추는 동기화".

### Task 10: 권한 묻기 (P1 · P2 · P5)

**Files:**
- Create: `lib/presentation/notification/notification_prompt.dart`, `lib/presentation/notification/widgets/notification_preview_card.dart`
- Modify: `lib/presentation/shared/confirm_dialog.dart`(`Widget? body`), `lib/presentation/today/today_screen.dart`, `notification_texts.dart`, 토큰
- Test: `test/presentation/notification_prompt_test.dart`, `test/presentation/widgets_test.dart`

**Interfaces — Produces:**
```dart
/// 출근 저장 직후 TodayScreen이 부른다. 조건이 안 맞으면 아무것도 안 한다.
Future<void> maybePromptClockOutNotification(BuildContext context, WidgetRef ref);
/// 설정 토글·P1 수락 공용: 켜고, 필요하면 OS 창. 거절되면 P5 토스트.
Future<void> enableClockOutNotification(BuildContext context, WidgetRef ref);
```

- [ ] **Step 1: 테스트** (전체 앱을 인메모리 DB + Fake 스케줄러로 pump — `widget_test.dart` 패턴):
  - 평일 첫 출근 → 출근이 먼저 저장되고(버튼 "퇴근하기") 그 위에 P1(제목·설명·미리보기 "소이듀티"/"퇴근할 시간이에요"·"안 받을래요"/"알림 받기").
  - "알림 받기" + OS 허용 → 켜짐·prompted 저장, 예약됨. 토스트 없음.
  - "알림 받기" + OS 거절 → 켜짐 저장, P5 토스트, 예약 없음.
  - "안 받을래요" → 꺼짐·prompted, P2 토스트. 바깥 탭도 같다.
  - 이미 prompted → 다음 출근에 안 뜬다. 출근 취소 → 다시 출근해도 안 뜬다.
  - 토요일 출근 → 안 뜨고 prompted도 안 된다. 평일 공휴일 근무 출근 → 안 뜬다.
  - 미리보기 카드는 `ExcludeSemantics`.
- [ ] **Step 2: 실패 확인** → **Step 3: 구현.** `showConfirmDialog`에 `Widget? body`(설명 아래 위 14). 미리보기 카드는 핸드오프 §8 치수(배경 `chipNeutral`, 라운드 14, 패딩 11/12, 아이콘 30 라운드 8 `brandDeep` + `assets/images/mark-transparent.png` 안쪽 여백 11%, "소이듀티"·"18:12" 12 subtle, 본문 14/w600 ink). 미리보기 시각은 고정 문자열이 아니라 **지금 계획된 시각**(`clockOutNoticePlan`의 `at`, 없으면 줄 생략).
  `enableClockOutNotification`: `setClockOutNotification(true)` → `status()`가 허용이 아니고 `!osAsked` → `markOsAsked()` + `requestPermission()` → false면 P5. 끝에 `invalidate(notificationPermissionProvider)` + `sync()`.
  `TodayScreen.onClockIn`: `await controller.clockIn(); if (context.mounted) await maybePromptClockOutNotification(context, ref);`
- [ ] **Step 4: 통과** → **Step 5: 커밋** "퇴근 알림: 첫 평일 출근 때 묻기".

### Task 11: 설정 화면 "알림" 섹션 (P3 · P4) · 디버그 시험 버튼

**Files:**
- Create: `lib/presentation/settings/widgets/soi_switch.dart`
- Modify: `settings_screen.dart`, `settings_texts.dart`, `lib/presentation/debug/seed_picker_sheet.dart`, 토큰
- Test: `test/presentation/settings_view_test.dart`, `test/presentation/settings_notification_flow_test.dart`

**Interfaces — Produces:**
```dart
// SettingsView
required NotificationPermission notificationPermission,
// SettingsCallbacks
required ValueChanged<bool> onNotificationToggle,
required VoidCallback onOpenNotificationSettings,   // P4 다이얼로그 → OS 설정
```

- [ ] **Step 1: 뷰 테스트.** 섹션 순서 **캘린더 · 알림 · 연차 · 수당 · 데이터 · 앱 정보**. 켜짐: 토글 on + "그날 채울 시간을 다 채우면 알려드려요". 꺼짐: off + "알림을 켜면 퇴근할 시간에 알려드려요". OS `denied`: 토글 없음, "설정 열기"(브랜드) + 꺾쇠, 보조 "기기 설정에서 알림이 꺼져 있어요"가 minus 색 — 켜짐 여부와 무관. 행 어디를 눌러도 토글. 토글에 `Semantics(toggled:)`. 폭 320에서 overflow 없음.
- [ ] **Step 2: 흐름 테스트.** 꺼짐 → 토글 → (미정) OS 창 허용 → 켜짐. 거절 → P5 + 행이 OS 꺼짐으로. 켜짐 → 토글 → 꺼짐 + `cancel`. OS 꺼짐 행 탭 → P4 다이얼로그 → "설정 열기" → `openSettingsCount == 1`. OS 설정에서 켜고 돌아옴(Fake `status` 변경 + resume) → 토글 행으로 바뀜.
- [ ] **Step 3: 실패 확인** → **Step 4: 구현.** `SoiSwitch`: 핸드오프 §9(트랙 51×31, 켜짐 `brand` / 꺼짐 `checkboxBorder`, 노브 27 `card` + 그림자, 0.18s). `CupertinoSwitch`를 쓰지 않는다(색·크기 토큰). `SettingsRow`의 `trailing`에 넣고 `onTap`으로 행 전체 탭.
- [ ] **Step 5: 디버그 시트.** `seed_picker_sheet.dart`에 버튼 둘 — "알림 지금 보내기"(`showNow` N1) · "1분 뒤 알림 예약"(`schedule(실제 now + 1분)`, 권한 없으면 먼저 요청). 문구는 디버그 전용 텍스트 상수. kDebugMode 진입로 안에만.
- [ ] **Step 6: 통과** → **Step 7: 커밋** "퇴근 알림: 설정 알림 섹션 · 디버그 시험 버튼".

### Task 12: 문서 · 전체 확인 · 기기 확인표

**Files:** `CLAUDE.md`, `docs/specs/2026-11-10-clock-out-notification.md`, `docs/specs/2026-11-10-partial-business-trip.md`, `docs/specs/2026-11-20-notification-device-checklist.md`(신규)

- [ ] **Step 1: 스펙 맞추기.** 알림 스펙에 "확정 규칙"(기준 0이면 daily 없음, T주간이 다음 날이면 없음, 동기화 표, 저장된 통지, 첫 평일 출근, 권한 상태 정의, 백업 제외, 정확한 알람 권한 미사용)과 §7 열린 질문 정리. 출장 스펙을 핸드오프 6 기준으로(종일/시간 패널, 주간 "출장 3h 10m", 월~일 개수).
- [ ] **Step 2: CLAUDE.md.** "퇴근 알림 (2026-11-20)" 절 · 설정 키 4개 · 플랫폼 패키지 4개 · Repository 절(포트 `NotificationScheduler`·`NotificationStateRepository`, Fake로 테스트) · 디렉터리(`domain/notification/`, `data/notification/`, `presentation/notification/`) · 프레젠테이션 규칙(알림 섹션·토글·P1 미리보기) · 테스트 목록 · "하지 않는 것"에 예고 알림·알림 버튼·정확한 알람 권한 · 디버그 시험 버튼.
- [ ] **Step 3: 기기 확인표 작성** — 자동 테스트가 닿지 않는 것. 사용자가 실기기에서 체크한다. 각 줄에 방법(디버그 시트 "1분 뒤 알림 예약" 또는 시계 이동)과 기대 결과:
  - iOS: 앱을 보고 있을 때(배너) · 백그라운드 · 앱 종료 · 화면 잠금 · Apple Watch(폰 잠금 + 워치 착용 시 워치로, 제목이 한 줄에 읽히는지) · 집중 모드 · 권한 거절 뒤 설정 행 · OS 설정에서 켜고 돌아오기 · 재부팅 뒤.
  - Android: 포그라운드(헤드업) · 백그라운드 · 최근 앱에서 밀어 종료 · Doze(화면 끄고 30분 뒤 예약, **지연 몇 분인지 기록**) · 재부팅 뒤 예약 유지 · Android 13+ 권한 창 · 12 이하(창 없이 허용) · 갤럭시 워치/Wear OS 미러링 · 제조사 배터리 최적화(삼성 "절전 예외") · 상태바 아이콘이 흰 사각형이 아닌지.
  - 공통: 퇴근하면 예약이 사라지는지 · 출근 변경 뒤 새 시각에 오는지 · 같은 알림이 두 번 오지 않는지(앱을 껐다 켜기) · 마지막 근무일 주간 알림 문구.
- [ ] **Step 4:** `flutter analyze` · `flutter test` 전체 · `flutter build apk --flavor dev --debug` → **커밋** "퇴근 알림: 문서 · 기기 확인표".
- [ ] **Step 5:** superpowers:finishing-a-development-branch — dev 병합은 사용자가 기기 확인표를 본 뒤 결정.

---

## 이 계획이 보장하지 못하는 것

- **실기기 동작.** 이 작업 환경(Windows)에는 iOS 시뮬레이터·실기기·워치가 없다. 예약 로직은 Fake로 전부 검증하지만, OS가 실제로 배너를 띄우는지·워치로 가는지·Doze 지연이 얼마인지는 Task 12의 확인표로 사용자가 확인해야 한다.
- **iOS 빌드.** `AppDelegate.swift` 변경과 Pod 설치는 맥에서 `flutter build ios --flavor dev`로 확인이 필요하다.
- **전원이 꺼져 있던 동안의 예약.** 예약 시각에 폰이 꺼져 있었다면 OS가 켜진 뒤 늦게 띄울 수 있다. 앱을 열면 다음 동기화가 정리한다.
- **Android 강제 종료·제조사 절전.** 사용자가 설정에서 "강제 종료"하거나 제조사 절전이 앱을 죽이면 예약이 사라질 수 있다 — OS 제약이라 앱이 막을 수 없다.

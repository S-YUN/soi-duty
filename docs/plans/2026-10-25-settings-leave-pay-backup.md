# 설정 · 시작 요일 · 잔여 연차 · 주말 수당 · 백업 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 설정 화면을 처음 만들고, 그 위에 월간 캘린더 시작 요일 · 잔여 연차 · 주말/공휴일 수당 · JSON 백업(내보내기/가져오기)을 올린다.

**Architecture:** 설정값은 `AppSettings`(freezed) 하나로 묶고 기존 Drift `Settings` 키-값 테이블에 저장한다(스키마 변경 없음). 계산은 전부 `domain/rules/work_calculator.dart`의 순수 함수에 추가하고, 월간 카드는 `buildMonthState`가 설정을 받아 `MonthState`에 파생값을 실어 보낸다. 백업은 도메인 `BackupSnapshot` + 순수 코덱 + Drift 복원 저장소로 나누고, 파일 I/O(공유 시트·파일 선택)는 프레젠테이션의 작은 인터페이스 뒤에 둔다.

**Tech Stack:** Flutter, Riverpod(코드젠), freezed, Drift 2.35, go_router, share_plus, file_picker, path_provider, package_info_plus, url_launcher, flutter_test.

**Spec:** `docs/specs/2026-10-25-settings-leave-pay-backup.md` — 실행자는 이 스펙과 CLAUDE.md를 함께 읽는다. 디자인 수치는 스펙 §6.

## Global Constraints

- flavor 없이 `flutter run`/`build` 금지. 테스트는 `flutter test`(PATH에 `~/flutter/bin`).
- 코드젠: `dart run build_runner build --delete-conflicting-outputs` (freezed·riverpod 변경 후).
- `domain/`에 `package:flutter` import 금지. `presentation/`은 `data/`를 직접 import하지 않는다(프로바이더로만).
- 색·글꼴·사이즈 하드코딩 금지 — `AppColors`·`AppTextStyles`·`AppSizes`. 한국어 문자열은 `<feature>_texts.dart`에서만. 토스트는 `app_toast.dart`.
- 수당 배율 1.5는 `WorkRules.extraWorkPayMultiplier`. 급여 기간 = 달력 월. 연차 기준 = 1~12월.
- 총 연차 1~99 정수, 시급 1~9,999,999 정수. 빈 값·0은 저장 비활성.
- 백업 파일: `app: "soi_duty"`, `format: 1`, 파일명 `soi_duty_backup_yyyy-MM-dd.json`. 가져오기는 기록·첫 기록일·설정 세 값을 덮어쓰고 `lastExportDate`는 유지.
- 커밋은 dev 브랜치, AI 표시 없음, push는 사용자가 따로.

## Review Focus

1. **다른 폰에서 내보낸 파일에 오늘의 '출근만 찍힌' 기록이 있을 때** — 복원 뒤 오늘 화면이 근무 중 상태로 이어진다. (Task 8 복원 테스트)
2. **시급 7자리 한도에서 8번째 숫자 입력** — 무시되고 "1,234,567"이 유지된다. (Task 5)
3. **12월 → 다음 해 1월로 넘길 때 연차 카드** — 사용·예정은 새 해 기준으로 0부터, 총 연차는 새 해 값(없으면 "—" + 유도 줄). 지난해 카드는 지난해 값 그대로. (Task 4)
4. **일요일 시작에서 설치 전 날짜 판정** — 첫 주 월요일 앞의 일요일 셀은 흐리고 탭이 막힌다(`editableFrom`은 월요일 기준 그대로). (Task 2)
5. **공유 시트를 닫거나 파일 선택을 취소했을 때** — 마지막 내보내기 날짜가 바뀌지 않고 토스트도 뜨지 않는다. (Task 9)

---

## File Map

| 파일 | 변경 |
|---|---|
| `lib/domain/model/app_settings.dart` (신규) | `WeekStart`, `AppSettings` |
| `lib/domain/repository/app_settings_repository.dart` (신규) | 포트 |
| `lib/data/repository/drift_app_settings_repository.dart` (신규) | Drift 구현 |
| `lib/domain/rules/work_rules.dart` | `extraWorkPayMultiplier` |
| `lib/domain/rules/work_calculator.dart` | `weekStartOf`, `calendarDays(weekStart)`, `extraWorkMinutesOfMonth`, `extraPayWon`, `usedLeaveHalfDays` |
| `lib/core/presentation/format/number_format.dart` (신규) | `formatThousands`, `formatWon`, `formatLeaveDays` |
| `lib/core/presentation/format/date_format.dart` | `weekdayShort` 공개 |
| `lib/domain/model/backup_snapshot.dart` (신규), `lib/domain/backup/backup_codec.dart` (신규) | 백업 모델·코덱 |
| `lib/domain/repository/backup_repository.dart` (신규), `lib/data/repository/drift_backup_repository.dart` (신규) | 백업 포트·구현 |
| `lib/core/providers/database_providers.dart`, `lib/core/providers/app_info_provider.dart` (신규) | 설정·백업·버전 프로바이더 |
| `lib/core/routing/router.dart`, `route_paths.dart` | `/settings` 슬라이드 라우트 |
| `lib/presentation/shell/tab_shell.dart`, `shell/gear_button.dart` (신규) | 톱니 |
| `lib/presentation/shared/number_input_sheet.dart` (신규) | 숫자 입력 시트 |
| `lib/presentation/settings/*` (신규) | 화면·텍스트·컨트롤러·백업 파일 I/O |
| `lib/presentation/month/*` | 시작 요일, 카드 2종, 시트 연결 |
| `lib/ui/*` | 토큰 |
| `android/app/src/main/AndroidManifest.xml`, `pubspec.yaml` | queries, 패키지 |
| `CLAUDE.md` | 규칙·화면·디렉터리 갱신 |

---

### Task 1: 설정 모델 · 저장소 · 프로바이더

**Files:**
- Create: `lib/domain/model/app_settings.dart`, `lib/domain/repository/app_settings_repository.dart`, `lib/data/repository/drift_app_settings_repository.dart`
- Modify: `lib/core/providers/database_providers.dart`
- Test: `test/data/drift_app_settings_repository_test.dart`

**Interfaces:**
- Produces:
  - `enum WeekStart { monday, sunday }`
  - `AppSettings({WeekStart weekStart = WeekStart.monday, Map<int, int> annualLeaveDaysByYear = const {}, int? hourlyWage, DateTime? lastExportDate})` (freezed, `copyWith`) + 확장 `int? annualLeaveDaysOf(int year)`, `AppSettings withAnnualLeaveDays(int year, int? days)` (null이면 그 해 키 제거)
  - `abstract interface class AppSettingsRepository { Stream<AppSettings> watch(); Future<void> save(AppSettings settings); }`
  - `DriftAppSettingsRepository(AppDatabase db)` — 키 상수 `weekStartKey='week_start'`, `annualLeaveDaysKeyPrefix='annual_leave_days_'`(+해), `hourlyWageKey='hourly_wage'`, `lastExportDateKey='last_export_date'`
  - 프로바이더: `appSettingsRepositoryProvider` (keepAlive), `appSettingsProvider` (`Stream<AppSettings>`)

- [ ] **Step 1: 실패하는 테스트** — `NativeDatabase.memory()`로 `AppDatabase` 구동 (`test/data/drift_work_record_repository_test.dart` 패턴).

```dart
test('비어 있으면 기본값', () async => expect(await repo.watch().first, const AppSettings()));
test('저장한 값이 그대로 읽히고 null은 행을 지운다', () async {
  await repo.save(const AppSettings(weekStart: WeekStart.sunday, annualLeaveDaysByYear: {2026: 15, 2027: 16}, hourlyWage: 12500));
  await repo.save((await repo.watch().first).copyWith(lastExportDate: DateTime(2026, 10, 24)));
  expect(await repo.watch().first, AppSettings(weekStart: WeekStart.sunday, annualLeaveDaysByYear: {2026: 15, 2027: 16}, hourlyWage: 12500, lastExportDate: DateTime(2026, 10, 24)));
  expect((await db.select(db.settings).get()).map((r) => r.key), containsAll(['annual_leave_days_2026', 'annual_leave_days_2027']));
  await repo.save(const AppSettings(weekStart: WeekStart.sunday));
  expect((await db.select(db.settings).get()).map((r) => r.key), ['week_start']);
});
test('first_record_date 행은 건드리지 않는다', ...); // 미리 넣은 first_record_date가 save 뒤에도 남는다
test('watch는 save마다 새 값을 흘린다', ...);     // expectLater(repo.watch(), emitsInOrder([기본값, 바뀐 값]))
```

- [ ] **Step 2: 실행해 실패 확인** — `flutter test test/data/drift_app_settings_repository_test.dart` → 컴파일 실패.
- [ ] **Step 3: 구현** — 모델·포트·Drift 구현. `watch()`는 `select(settings).watch()`를 매핑(모르는 키는 무시, 숫자 파싱 실패는 무시/null, `annual_leave_days_` 접두 키는 해로 파싱). `save()`는 트랜잭션에서 고정 키 셋을 upsert/delete하고 `annual_leave_days_%` 행은 전부 지운 뒤 맵대로 다시 넣는다. 프로바이더 추가 후 코드젠.
- [ ] **Step 4: 통과 확인** — 위 명령 PASS. `flutter analyze` 깨끗.
- [ ] **Step 5: 커밋** — `설정 모델·저장소: AppSettings (시작 요일 · 총 연차 · 시급 · 마지막 내보내기)`

---

### Task 2: 월간 캘린더 시작 요일

**Files:**
- Modify: `lib/domain/rules/work_calculator.dart:30-40`, `lib/core/presentation/format/date_format.dart`, `lib/presentation/month/month_state_builder.dart`, `month_provider.dart`, `month_texts.dart`, `widgets/calendar_card.dart`
- Test: `test/domain/work_calculator_test.dart`, `test/presentation/month_state_builder_test.dart`, `test/presentation/month_screen_test.dart`

**Interfaces:**
- Consumes: `WeekStart`, `AppSettings`, `appSettingsProvider` (Task 1)
- Produces:
  - `DateTime weekStartOf(DateTime d, WeekStart weekStart)` — `monday`면 `mondayOf(d)`, `sunday`면 그 날 이전(포함) 가장 가까운 일요일
  - `List<DateTime> calendarDays(DateTime month, {WeekStart weekStart = WeekStart.monday})`
  - `buildMonthState({..., required AppSettings settings})` — 기존 호출부(테스트 포함) 모두 `settings:` 추가
  - `String weekdayShort(DateTime d)` (date_format) · `MonthTexts.weekdays` 삭제, 헤더는 `state.weeks.first[i].date`에서

- [ ] **Step 1: 실패하는 테스트**

```dart
test('calendarDays — 일요일 시작이면 2026년 10월은 9/27(일)부터 10/31(토)까지 35일', () {
  final days = calendarDays(DateTime(2026, 10), weekStart: WeekStart.sunday);
  expect(days.first, DateTime(2026, 9, 27)); expect(days.last, DateTime(2026, 10, 31)); expect(days.length, 35);
});
test('calendarDays — 기본(월요일)은 9/28부터 11/1까지', ...);
// month_state_builder_test: settings sunday → weeks[0][0].date.weekday == DateTime.sunday,
//   첫 기록일 2026-09-14(월)일 때 2026-09-13(일) 셀은 isBeforeFirstWeek == true (Review Focus 4)
// month_screen_test: 일요일 시작 상태에서 헤더 첫 글자 '일', 마지막 '토'; 기본은 '월'…'일'
```

- [ ] **Step 2: 실패 확인** — 세 파일 실행, 컴파일 실패 또는 FAIL.
- [ ] **Step 3: 구현** — 계산 함수, 빌더 시그니처, 프로바이더에서 `await ref.watch(appSettingsProvider.future)`, 헤더를 날짜 기반으로. 주말 헤더 색은 `isWeekend(date)`.
- [ ] **Step 4: 통과 확인** — `flutter test test/domain test/presentation/month_state_builder_test.dart test/presentation/month_screen_test.dart` PASS.
- [ ] **Step 5: 커밋** — `월간 캘린더: 시작 요일 설정 (일요일 시작)`

---

### Task 3: 연차 · 수당 계산 (순수 Dart)

**Files:**
- Modify: `lib/domain/rules/work_rules.dart`, `lib/domain/rules/work_calculator.dart`
- Create: `lib/core/presentation/format/number_format.dart`
- Test: `test/domain/work_calculator_test.dart`, `test/core/format_test.dart`

**Interfaces:**
- Produces:
  - `WorkRules.extraWorkPayMultiplier` (`double`, 기본 1.5)
  - `({int weekendMinutes, int holidayMinutes}) extraWorkMinutesOfMonth(List<WorkRecord> records, DateTime month, WorkRules rules)` — 그 달, 출퇴근 둘 다 있는 날만, 주말 → weekend, 평일 `holiday` 유형 → holiday, `actualMinutes` 사용
  - `int extraPayWon(int minutes, int hourlyWage, WorkRules rules)` = `(minutes * hourlyWage * multiplier / 60).floor()`
  - `int usedLeaveHalfDays(List<WorkRecord> records, int year)` — `dayOff` 2, `halfDay` 1 (그 해 전체, 미래 포함)
  - `int plannedLeaveHalfDays(List<WorkRecord> records, int year, DateTime today)` — 그중 `date.isAfter(dateOnly(today))`인 것만
  - `String formatThousands(int n)` → `"12,500"`, `String formatWon(int won)` → `"12,500원"`, `String formatLeaveDays(int halfDays)` → `15 → "7.5일"`, `30 → "15일"`

- [ ] **Step 1: 실패하는 테스트**

```dart
test('extraWorkMinutesOfMonth — 주말·평일 공휴일만, 점심 공제 없음, 퇴근 없는 날 제외', () {
  final rs = [rec(19, inH: 9, outH: 14), rec(20, inH: 10, outH: 12), rec(15, inH: 9, outH: 13, type: WorkType.holiday),
              rec(16, inH: 9, outH: 18), rec(26, inH: 9)];
  expect(extraWorkMinutesOfMonth(rs, DateTime(2026, 9), rules), (weekendMinutes: 420, holidayMinutes: 240));
});
test('extraPayWon — 660분 × 12,500 × 1.5 = 206,250, 소수점 버림(7분 × 10,000 = 1,750)', ...);
test('usedLeaveHalfDays — 연차 2 · 반차 1, 다른 해 제외, 미래 포함', ...);
test('plannedLeaveHalfDays — 오늘보다 뒤인 날만, 오늘은 제외', ...); // today 9/16: rec(16 dayOff) 제외, rec(17 halfDay)+rec(24 dayOff) → 3
test('formatLeaveDays / formatWon / formatThousands', ...); // 15→"7.5일", 30→"15일", 1→"0.5일", 1234567→"1,234,567"
```

- [ ] **Step 2: 실패 확인** → **Step 3: 구현** → **Step 4: PASS** (`flutter test test/domain test/core`)
- [ ] **Step 5: 커밋** — `계산: 주말·공휴일 근무 월 합계와 수당, 연차 사용 일수`

---

### Task 4: MonthState에 카드 데이터

**Files:**
- Modify: `lib/presentation/month/month_state.dart`, `month_state_builder.dart`
- Test: `test/presentation/month_state_builder_test.dart`

**Interfaces:**
- Consumes: Task 3 함수, `AppSettings`
- Produces (freezed):
  - `MonthExtraWork({required int weekendMinutes, required int holidayMinutes, int? payWon})` — `payWon`은 시급 있을 때만
  - `MonthLeave({required int year, int? totalDays, required int usedHalfDays, required int plannedHalfDays, int? remainingHalfDays})` — `totalDays = settings.annualLeaveDaysOf(year)`, `remaining = total*2 − used` (예정 포함, 음수 = 초과), total 없으면 null
  - `MonthState({..., MonthExtraWork? extraWork, MonthLeave? leave})` — `extraWork`는 합계 0이면 null, `leave`는 total 없고 used 0이면 null

- [ ] **Step 1: 실패하는 테스트**

```dart
test('수당 카드 — 주말·공휴일 근무 없는 달은 null, 있으면 분과 (시급 있을 때) 금액', ...);
test('연차 카드 — 총 연차 없고 사용 0이면 null, 사용만 있으면 total null·remaining null', ...);
test('연차 카드 — 총 6일에 사용 7.5일이면 remainingHalfDays == -3', ...);
test('연차 카드 — month가 2027-01이면 year 2027, 총 연차는 2027 키(없으면 null), 2026년 사용분은 빠진다 (Review Focus 3)', ...);
test('연차 카드 — plannedHalfDays는 오늘 이후 연차·반차만 (오늘 9/16, 9/17 반차·9/24 연차 → 3)', ...);
```

- [ ] **Step 2: 실패 확인** → **Step 3: 구현**(빌더 끝에서 두 값 계산) → **Step 4: PASS** → 코드젠 포함
- [ ] **Step 5: 커밋** — `월간 상태: 수당·연차 카드 데이터`

---

### Task 5: 토큰 + 숫자 입력 시트

**Files:**
- Modify: `lib/ui/app_sizes.dart`, `app_text_styles.dart`, `app_colors.dart`(필요 시)
- Create: `lib/presentation/shared/number_input_sheet.dart`
- Test: `test/presentation/number_input_sheet_test.dart`

**Interfaces:**
- Produces:
  ```dart
  Future<void> showNumberInputSheet(BuildContext context, {
    required String title, required String unit, required String note, bool lockIcon = false,
    required int maxDigits, bool grouping = false, int? initial,
    required String saveLabel, required String clearLabel,
    required ValueChanged<int> onSave, VoidCallback? onClear,
  })
  ```
  - 저장 활성: 입력이 비어 있지 않고 값 > 0. `onClear`는 `initial != null`일 때만 링크가 보인다.
  - `TextField(keyboardType: TextInputType.number, autofocus: true, inputFormatters: [digitsOnly, 길이·앞자리 0·콤마 포매터])`. 시트 하단 패딩에 `MediaQuery.viewInsetsOf(context).bottom`.
  - 토큰(스펙 §6-2·§6-1): `AppSizes.numberFieldTop/Padding/Underline, numberNoteTop, numberSaveTop, clearLinkMinHeight, settings*`, `AppTextStyles.numberField, numberFieldEmpty, numberUnit, clearLink, settingsTitle, settingsRowLabel, settingsRowSub, settingsValueUnset, settingsValueSet, settingsNote, segmentOn, segmentOff, extraRowLabel, extraRowValue, extraAmount, nudge`. 기존 토큰 재사용: `sheetTitle, sheetButton(52), sheetButtonRadius(13), dotInactive, buttonDisabled, wheelUnselected, weekendNone, rowDivider`.

- [ ] **Step 1: 실패하는 테스트**

```dart
testWidgets('비어 있거나 0이면 저장 비활성, 1 이상이면 onSave(값)', ...);
testWidgets('연차: 두 자리까지 — "123" 입력 뒤 표시 "12"', ...);
testWidgets('시급: 콤마 실시간, 7자리 한도 — "12345678" 입력 뒤 "1,234,567" (Review Focus 2)', ...);
testWidgets('initial이 있으면 채워서 열리고 되돌리기 링크가 보인다 · 없으면 "0" 플레이스홀더, 링크 없음', ...);
testWidgets('viewInsets 300에서도 저장 버튼이 탭 가능', ...); // MediaQuery(data: ..copyWith(viewInsets: EdgeInsets.only(bottom: 300)))
```

- [ ] **Step 2: 실패 확인** → **Step 3: 토큰·시트 구현** → **Step 4: PASS**
- [ ] **Step 5: 커밋** — `숫자 입력 시트 (총 연차 · 시급 공용) + 설정 토큰`

---

### Task 6: 설정 화면 · 라우트 · 톱니

**Files:**
- Modify: `lib/core/routing/route_paths.dart`, `router.dart`, `lib/presentation/shell/tab_shell.dart`, `pubspec.yaml`(package_info_plus, url_launcher), `android/app/src/main/AndroidManifest.xml`
- Create: `lib/presentation/shell/gear_button.dart`, `lib/core/providers/app_info_provider.dart`, `lib/presentation/settings/settings_texts.dart`, `settings_screen.dart`, `settings_controller.dart`, `widgets/settings_section.dart`, `widgets/settings_row.dart`, `widgets/segment_toggle.dart`
- Test: `test/presentation/settings_view_test.dart`, `test/presentation/widgets_test.dart`(톱니)

**Interfaces:**
- Consumes: Task 1 프로바이더, Task 5 시트·토큰
- Produces:
  - `RoutePaths.settings = '/settings'`; `GoRoute(path: '/settings', pageBuilder: CustomTransitionPage(SlideTransition from Offset(1,0), AppDurations.sheetSlide, AppCurves.sheet))`
  - `GearButton({required VoidCallback onTap})` — `TabShell`의 탭 줄을 `Stack`으로 감싸 `Positioned(right: AppSizes.gearRight)`. `PillTabs`는 그대로 `Center`.
  - `appVersionProvider` (`Future<String>`, `PackageInfo.fromPlatform().version`)
  - `SettingsView({required AppSettings settings, required int year, required String version, required SettingsCallbacks callbacks})` 순수 위젯 — 연차 행은 `settings.annualLeaveDaysOf(year)`를 보여준다(`year`는 `clockProvider` 기준 올해). `SettingsCallbacks(onBack, onWeekStart(WeekStart), onTapAnnual, onTapWage, onExport, onImport, onPrivacy)`
  - `SettingsController` (`@riverpod class`): `setWeekStart(WeekStart)`, `setAnnualLeaveDays(int year, int? days)`, `setHourlyWage(int?)` — 현재 값 `copyWith`/`withAnnualLeaveDays` 후 `save`
  - `SettingsTexts`: 스펙 §6-1 문구 전부 + `lastExportLine(DateTime?)` → "아직 내보낸 적 없어요" / "마지막 내보내기 10월 24일"(`formatDateShort` 아님 — "n월 n일"만), `annualValue(int?)` → "사용 안 함"/"15일", `wageValue(int?)` → "사용 안 함"/"12,500원", `privacyUrl`
  - 처리방침: `launchUrl(Uri.parse(SettingsTexts.privacyUrl), mode: LaunchMode.externalApplication)`. 매니페스트 `<queries>`에 `<intent><action android:name="android.intent.action.VIEW"/><data android:scheme="https"/></intent>`.

- [ ] **Step 1: 실패하는 테스트**

```dart
testWidgets('빈 상태 — 두 보조 설명과 "사용 안 함" 둘, "아직 내보낸 적 없어요", 버전', ...);
testWidgets('채운 상태 — "15일" · "12,500원" · "마지막 내보내기 10월 24일", 보조 설명 없음', ...);
testWidgets('세그먼트 "일" 탭 → onWeekStart(sunday)', ...);
testWidgets('폭 320·600에서 overflow 없음', ...);  // tester.takeException() == null
testWidgets('TabShell — 톱니가 있고 PillTabs 중심 x == 화면 중심', ...); // widgets_test.dart
```

- [ ] **Step 2: 실패 확인** → **Step 3: 구현** (화면에서 연차·시급 행 탭 → `showNumberInputSheet(... onSave: (v) => controller.setAnnualLeaveDays(year, v), onClear: () => controller.setAnnualLeaveDays(year, null))`; 내보내기/가져오기는 Task 9까지 빈 콜백) → **Step 4: PASS + `flutter analyze`**
- [ ] **Step 5: 시뮬레이터 확인** — `flutter run --flavor dev`로 톱니 → 설정 → 시트 → 키패드 위 시트 위치 눈으로 확인.
- [ ] **Step 6: 커밋** — `설정 화면: 톱니 진입, 시작 요일 · 총 연차 · 시급 · 앱 정보`

---

### Task 7: 월간 탭 카드 2종

**Files:**
- Modify: `lib/presentation/month/month_screen.dart`, `month_texts.dart`
- Create: `lib/presentation/month/widgets/extra_work_card.dart`, `widgets/leave_card.dart`
- Test: `test/presentation/month_screen_test.dart`

**Interfaces:**
- Consumes: `MonthState.extraWork/leave` (Task 4), `SettingsController` (Task 6), `showNumberInputSheet` (Task 5), `SummaryRow`(today/widgets — 3칸에 그대로 쓴다)
- Produces:
  - `ExtraWorkCard({required MonthExtraWork extraWork, required String title, required VoidCallback onTapNudge})`, `LeaveCard({required MonthLeave leave, required VoidCallback onTapNudge})`
  - `MonthView({..., required VoidCallback onOpenWage, required VoidCallback onOpenAnnual})` — 카드는 범례 아래 `cardGap` 간격, 수당 → 연차 순
  - `MonthTexts`: `extraWorkTitle(month)` "10월 주말·공휴일 근무", `weekendLabel` "주말", `holidayLabel` "공휴일", `amountLabel` "예상 금액", `wageNudge`, `leaveTitle(year)` "2026년 연차", `leaveLabels` ["총 연차","사용","잔여"], `overLabel` "초과", `plannedLine(halfDays)` "예정 1.5일 포함", `leaveNudge`, 값은 `formatHm`·`formatWon`·`formatLeaveDays`, 없음 "—"
  - `LeaveCard`는 `SummaryRow`를 그대로 쓰지 못한다(사용 칸 아래 줄) — 같은 토큰으로 3칸을 직접 그린다. 예정 줄 스타일 `AppTextStyles.plannedLine`(12 `subtle`), 위 간격 `AppSizes.plannedLineTop`(3).
  - `MonthScreen`: `onOpenWage` → 시급 시트(`initial: settings.hourlyWage`), `onOpenAnnual` → 연차 시트, 저장은 `setAnnualLeaveDays(state.month.year, v)` — **카드의 해**

- [ ] **Step 1: 실패하는 테스트**

```dart
testWidgets('extraWork null이면 수당 카드 없음, leave null이면 연차 카드 없음', ...);
testWidgets('수당 카드 — 주말 7h, 공휴일 0이면 공휴일 행 없음, payWon 206250 → "206,250원"', ...);
testWidgets('수당 카드 — payWon null이면 유도 줄, 탭 → onOpenWage', ...);
testWidgets('연차 카드 — total 15 used 15(반일) → "15일" "7.5일" "7.5일"; remaining -3 → 라벨 "초과" 값 "1.5일"', ...);
testWidgets('연차 카드 — plannedHalfDays 3 → "예정 1.5일 포함", 0이면 그 줄 없음. 세 칸 값의 y가 같다', ...);
testWidgets('연차 카드 — total null → "—" 둘 + 유도 줄, 탭 → onOpenAnnual', ...);
testWidgets('폭 320~600 8종에서 카드 overflow 없음', ...);
```

- [ ] **Step 2: 실패 확인** → **Step 3: 구현** → **Step 4: PASS**
- [ ] **Step 5: 커밋** — `월간 탭: 주말·공휴일 수당 카드, 연차 카드`

---

### Task 8: 백업 코덱 · 복원 저장소

**Files:**
- Create: `lib/domain/model/backup_snapshot.dart`, `lib/domain/backup/backup_codec.dart`, `lib/domain/repository/backup_repository.dart`, `lib/data/repository/drift_backup_repository.dart`
- Modify: `lib/core/providers/database_providers.dart`
- Test: `test/domain/backup_codec_test.dart`, `test/data/drift_backup_repository_test.dart`

**Interfaces:**
- Produces:
  - `BackupSnapshot({required DateTime exportedAt, DateTime? firstRecordDate, required WeekStart weekStart, required Map<int, int> annualLeaveDaysByYear, int? hourlyWage, required List<WorkRecord> records})` (freezed, JSON은 코덱이 직접 — 맵 키는 문자열 해)
  - `String encodeBackup(BackupSnapshot s)` — 스펙 §5 모양, `records`는 `WorkRecord.toJson`
  - `BackupSnapshot decodeBackup(String text)` — 실패 시 `BackupFormatException(String reason)` (`implements Exception`)
  - `abstract interface class BackupRepository { Future<BackupSnapshot> snapshot(DateTime now); Future<void> restore(BackupSnapshot s); Future<int> recordCount(); }`
  - `DriftBackupRepository(AppDatabase db, {WorkRules rules})` — `restore`는 한 트랜잭션: 기록 전부 삭제 → `sanitizeRecord` 거쳐 삽입 → `first_record_date` = 파일 값 ?? 최소 날짜 ?? 삭제 → 설정 세 키 덮어쓰기(`last_export_date` 행은 그대로)
  - `backupRepositoryProvider` (keepAlive)

- [ ] **Step 1: 실패하는 테스트**

```dart
test('encode → decode 왕복 동일', ...);
test('decode 실패 — JSON 아님 / app 다름 / format 2 / records가 배열 아님 / 레코드 date 없음 → BackupFormatException', ...);
test('restore — 기존 3건이 파일 2건으로 바뀌고 첫 기록일은 파일 값, 설정 세 값 덮어쓰고 last_export_date 유지', ...);
test('restore — firstRecordDate null이면 최소 날짜, 기록 0건이면 first_record_date 행 삭제', ...);
test('restore — 오늘 출근만 찍힌 기록이 그대로 복원된다 (Review Focus 1)', ...);
test('snapshot — 현재 기록·첫 기록일·설정이 담기고 lastExportDate는 담기지 않는다', ...);
```

- [ ] **Step 2: 실패 확인** → **Step 3: 구현** → **Step 4: PASS**
- [ ] **Step 5: 커밋** — `백업: JSON 코덱과 복원 저장소`

---

### Task 9: 내보내기 · 가져오기 UI

**Files:**
- Modify: `pubspec.yaml`(share_plus, file_picker, path_provider), `lib/presentation/settings/settings_controller.dart`, `settings_screen.dart`, `settings_texts.dart`
- Create: `lib/presentation/settings/backup_files.dart`
- Test: `test/presentation/settings_backup_flow_test.dart`

**Interfaces:**
- Consumes: Task 8 저장소·코덱, `showConfirmDialog`, `showAppToast`
- Produces:
  - `abstract interface class BackupFiles { Future<bool> shareJson({required String fileName, required String content}); Future<String?> pickJson(); }` — `shareJson`은 공유 시트 결과가 `dismissed`가 아니면 true; `pickJson`은 취소 시 null. 기본 구현 `PlatformBackupFiles`(share_plus `Share.shareXFiles`, path_provider 임시 폴더, file_picker `FileType.any`). `backupFilesProvider`(테스트에서 override).
  - `SettingsController.exportBackup(DateTime now) → Future<bool>` — snapshot → encode → shareJson → true면 `lastExportDate = dateOnly(now)` 저장
  - `SettingsController.pickBackup() → Future<BackupPick>` — `sealed class BackupPick { cancelled; invalid; ready(BackupSnapshot, int currentCount) }`
  - `SettingsController.restoreBackup(BackupSnapshot)`
  - 화면 흐름: 내보내기 → true면 토스트 `SettingsTexts.exportDone`("내보낼 파일을 만들었어요"); 가져오기 → cancelled 무시, invalid 토스트 `importFailed`, ready → `showConfirmDialog(title: importTitle, message: importMessage(n), confirmLabel: importConfirm)` → 확인이면 restore → 토스트 `importDone`("기록을 가져왔어요")

- [ ] **Step 1: 실패하는 테스트** — `backupFilesProvider`를 Fake로 override, DB는 인메모리.

```dart
testWidgets('내보내기 — 공유 성공이면 토스트와 "마지막 내보내기 n월 n일", 닫힘이면 둘 다 없음 (Review Focus 5)', ...);
testWidgets('가져오기 — 취소면 아무것도 없음, 깨진 파일이면 실패 토스트', ...);
testWidgets('가져오기 — 정상 파일이면 "지금 기록 3건이 파일 내용으로 바뀌어요. 되돌릴 수 없어요." → 가져오기 → 기록 교체 + 성공 토스트', ...);
```

- [ ] **Step 2: 실패 확인** → **Step 3: 구현** → **Step 4: PASS**
- [ ] **Step 5: 실기기/시뮬레이터 확인** — iOS 시뮬레이터에서 내보내기 → 파일 앱 저장 → 가져오기 왕복. Android 에뮬레이터에서 같은 왕복.
- [ ] **Step 6: 커밋** — `설정: 기록 내보내기 · 가져오기`

---

### Task 10: 마무리 — CLAUDE.md · 시드 · 스모크

**Files:**
- Modify: `CLAUDE.md`, `lib/data/seed/debug_seed.dart`(+ `presentation/debug/seed_picker_sheet.dart`), `test_driver/app.dart`

- [ ] **Step 1: 디버그 시드** — '두 달치 기록' 시드가 `AppSettings(annualLeaveDaysByYear: {올해: 15}, hourlyWage: 12500)`도 넣는다(카드가 보이는 상태를 바로 확인). `test/data/debug_seed_test.dart`에 설정값 단언 추가.
- [ ] **Step 2: 스모크 드라이브** — `test_driver/app.dart`에 설정 화면 스크린샷 1장(`settings.png`)과 월간 카드가 보이는 월간 스크린샷. `flutter drive --flavor dev --target test_driver/app.dart -d <시뮬레이터>` 통과.
- [ ] **Step 3: CLAUDE.md** — 스펙 §9 항목 반영. "백업·내보내기는 아직 없다" 문구 삭제.
- [ ] **Step 4: 전체 검증** — `flutter analyze` 깨끗, `flutter test` 전부 PASS.
- [ ] **Step 5: 커밋** — `문서·시드: 설정 · 연차 · 수당 · 백업 반영`

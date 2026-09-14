# 오늘 화면 설계 — 계산 규칙 + Drift + 오늘 화면 5상태

작성일: 2026-09-14
디자인 원본: `docs/specs/design-handoff-today-screen.md` (핸드오프 README 사본), 목업 `~/Downloads/design_handoff_today_screen/오늘 화면 상태 4종.dc.html`
계산 규칙 원본: `CLAUDE.md` — 계산이 충돌하면 CLAUDE.md, 시각 표현이 충돌하면 핸드오프가 기준.

## 목표

출퇴근을 버튼으로 찍고 **이번 주 잔여 시간**을 보여주는 오늘 화면을 끝까지 동작하게 만든다.
도메인 계산 → Drift 저장 → 화면 순서로, 계산 규칙은 화면보다 먼저 테스트로 고정한다.

디자인 측 전달 사항 (그대로 지킨다):
- 폰트는 Pretendard.
- README의 색상·타이포·고정 높이를 그대로 지킨다.
- **상태가 바뀌어도 주 버튼의 Y 좌표가 움직이지 않는다.**
- HTML은 레퍼런스다. 복사하지 않고 Flutter 위젯으로 다시 만든다.

사용자 측 전달 사항:
- 다양한 모바일 해상도에서 비슷하게 보이는 것이 목표. **SafeArea(노치·홈 인디케이터) 처리를 확실히** 한다.

## 범위

포함:
- `domain/` 모델·규칙·계산 함수 + 단위 테스트
- `data/` Drift 데이터베이스·리포지토리·디버그 시드
- `presentation/today/` 오늘 화면 5상태, 디자인 토큰, SizeConfig
- Pretendard 폰트·로고 에셋 등록

제외 (다음 라운드):
- 기록 입력/수정 바텀시트 — "시간 수정하기", "기록하기 →"는 자리만 두고 무반응(TODO).
- 주간/월간 탭 — 알약 탭은 3개 다 그리되 "오늘"만 활성, 나머지는 무반응.
- 스플래시, 앱 아이콘.

## 접근 방식

**`watchAll()` 스트림 하나 + 순수 함수 파생.** Drift에서 전체 기록을 스트림 하나로 흘리고,
오늘 화면 상태 전부를 `(records, now, rules) → TodayState` 순수 함수로 도출한다.

- 데이터가 하루 1행(1년 365행)이라 전체 로드가 비용이 아니다.
- 화면이 보는 진실이 하나라 화면 간 불일치가 원천 차단된다. 나중에 주간/월간 화면도 같은 스트림을 쓴다.
- 계산은 Flutter 없이 테스트한다.
- 파생값(phase, 첫 기록일, 잔여 등)은 어디에도 저장하지 않는다.

기각한 대안: 쿼리별 StreamProvider 조합(로딩 상태 조합이 지저분, 이득 없음),
README의 `phase/dayType`을 Notifier 메모리 상태로 보관(파생값 저장 금지와 충돌, 자정 리셋을 손으로 처리해야 함).

---

## 1. 도메인 (`lib/domain/`, 순수 Dart — `package:flutter` import 금지)

### 1.1 모델 (`model/`)

```dart
enum WorkType { normal, halfDay, dayOff, holiday }

@freezed
abstract class WorkRecord with _$WorkRecord {
  const factory WorkRecord({
    required DateTime date,   // 날짜만. 시분초 0, local
    DateTime? clockIn,
    DateTime? clockOut,
    @Default(WorkType.normal) WorkType type,
  }) = _WorkRecord;
  factory WorkRecord.fromJson(Map<String, Object?> json) => _$WorkRecordFromJson(json);
}
```

- 주말 근무도 `normal`. 주말 여부는 `date.weekday`로 판단.
- `date`가 기본키. 하루 기록은 하나.

### 1.2 규칙 값 (`rules/work_rules.dart`)

CLAUDE.md의 `WorkRules` 그대로. 모든 계산 함수는 `WorkRules`를 인자로 받는다.

```dart
class WorkRules {
  const WorkRules({
    this.weeklyTargetMinutes  = 2400,
    this.lunchBreakMinutes    = 60,
    this.halfDayCreditMinutes = 240,
    this.dayOffCreditMinutes  = 480,
  });
  int get dailyStandardMinutes => dayOffCreditMinutes; // 평일 하루 기준 8h
}
```

### 1.3 계산 함수 (`rules/work_calculator.dart`)

전부 최상위 순수 함수. 시각은 모두 local `DateTime`, 분 단위 `int`.

| 함수 | 규칙 |
|---|---|
| `bool isWeekend(DateTime date)` | `weekday`가 토(6)·일(7) |
| `DateTime mondayOf(DateTime date)` | 그 주 월요일 00:00 |
| `bool deductsLunch(WorkRecord r)` | `type != halfDay && !isWeekend(r.date)` |
| `int? actualMinutes(WorkRecord r, WorkRules rules)` | `dayOff`/`holiday` → `0`. 그 외 `clockIn`·`clockOut` 중 하나라도 없으면 `null`. 아니면 `clockOut − clockIn − (deductsLunch ? lunch : 0)`, 0 미만이면 0 |
| `int? ongoingMinutes(WorkRecord r, DateTime now, WorkRules rules)` | `clockIn` 있고 `clockOut` 없을 때 `max(0, now − clockIn − (deductsLunch ? lunch : 0))`. 그 외 `null` |
| `int standardMinutes(WorkType type, WorkRules rules)` | `normal` 8h, `halfDay` 4h, `dayOff`/`holiday` 0 |
| `int? deltaMinutes(WorkRecord r, WorkRules rules)` | `actualMinutes − standardMinutes`. actual이 null이면 null. 주말이면 null (기준 대비 없음) |
| `DateTime? firstRecordDate(List<WorkRecord>)` | 가장 이른 `date`. 기록 없으면 null. **저장하지 않고 항상 파생** |
| `bool isFirstWeekException(DateTime monday, DateTime? firstRecordDate)` | `firstRecordDate != null && mondayOf(firstRecordDate) == monday && firstRecordDate.weekday != Monday` |
| `WeekSummary weekSummary({records, monday, rules, now})` | 아래 |
| `int? todayTargetMinutes({records, today, rules, now})` | 아래. 첫 주 예외면 null |
| `DateTime? expectedClockOut(WorkRecord today, int todayTarget, WorkRules rules)` | `clockIn + todayTarget + (deductsLunch ? lunch : 0)`. clockIn 없으면 null |
| `List<DateTime> unrecordedWeekdays({records, today})` | 아래 |

**`WeekSummary`** (freezed, domain):

```
targetMinutes: int?        // 첫 주 예외면 null
workedMinutes: int         // 평일 실근무 합. 근무 중인 오늘은 ongoingMinutes 포함
remainingMinutes: int?     // target − worked. target null이면 null
halfDayCount, dayOffCount, holidayCount: int
isFirstWeekException: bool
firstRecordDate: DateTime?
```

목표 계산: 월~금 5일을 순회. 그날 기록이 있으면 그 `type`의 기준시간(8h/4h/0), **없으면 `normal`로 간주해 8h**.
`target = Σ 기준시간` (= 40h − 반차×4h − 연차×8h − 공휴일×8h와 동치).
실적: 월~금 기록의 `actualMinutes ?? ongoingMinutes ?? 0` 합. **주말 기록은 실적에도 목표에도 넣지 않는다.**
첫 주 예외면 `targetMinutes`·`remainingMinutes`는 null, `workedMinutes`만 채운다.

**오늘 목표 (`todayTargetMinutes`)** — 사용자 합의 규칙:

```
남은 평일 기준 = Σ(오늘 이후 이번 주 평일의 기준시간)   // 기록 없으면 normal 8h
오늘 목표     = (주간 목표 − 오늘을 제외한 주간 실적) − 남은 평일 기준
             = max(0, 오늘 목표)
```

예) 금요일, 목표 36h, 월~목 실적 28h38m → 오늘 목표 7h22m → 09:12 출근이면 17:34 퇴근 (목업과 일치).
반차 체크 시 목표 32h, 오늘 목표 3h22m, 점심 공제 없음 → **12:34** (README 예시의 13:34는 CLAUDE.md 규칙과 맞지 않아 12:34로 확정).
첫 주 예외인 주에는 오늘 목표를 계산하지 않는다 (`null`) — 퇴근 예상 문구를 띄우지 않는다.

**기록 누락 (`unrecordedWeekdays`)**: `firstRecordDate`부터 **어제**까지의 평일 중
기록이 없거나, `type ∈ {normal, halfDay}`인데 `clockIn`·`clockOut` 중 하나라도 없는 날. 최신 날짜가 앞. 첫 기록일이 없으면 빈 리스트.

### 1.4 리포지토리 인터페이스 (`repository/work_record_repository.dart`)

```dart
abstract interface class WorkRecordRepository {
  Stream<List<WorkRecord>> watchAll();
  Future<void> save(WorkRecord record);   // upsert, date 기준
  Future<void> delete(DateTime date);
}
```

이게 전부다. 주간/오늘/누락 필터는 도메인 함수가 한다.

---

## 2. 데이터 (`lib/data/`)

### 2.1 Drift (`database/app_database.dart`)

```dart
class WorkRecords extends Table {
  TextColumn get date => text()();            // 'yyyy-MM-dd', local 기준
  DateTimeColumn get clockIn => dateTime().nullable()();
  DateTimeColumn get clockOut => dateTime().nullable()();
  IntColumn get type => intEnum<WorkType>()();
  @override Set<Column> get primaryKey => {date};
}
```

- `date`를 **문자열 PK**로 두는 이유: `DateTime` 컬럼은 UTC로 저장되어 자정 근처에서 날짜가 밀릴 수 있다. 날짜는 시각이 아니라 키다.
- `clockIn`/`clockOut`은 순간(instant)이므로 `dateTime()` 그대로.
- `schemaVersion = 1`. 마이그레이션 없음.
- 파일 DB는 `drift_flutter`의 `driftDatabase(name: 'soi_duty')`. 테스트는 `NativeDatabase.memory()`.

### 2.2 리포지토리 구현 (`repository/drift_work_record_repository.dart`)

- `watchAll()` = `select(workRecords).watch()` → Row → `WorkRecord` 매핑 (`date` 문자열 ↔ `DateTime(y,m,d)`).
- `save` = `insertOnConflictUpdate`. `delete` = `deleteWhere(date == key)`.
- 매핑은 이 파일 안의 private 확장으로 둔다. DTO 파일을 따로 만들지 않는다 (서버 응답이 아니다).

### 2.3 디버그 시드 (`seed/debug_seed.dart`)

```dart
enum SeedScenario { beforeWork, working, done, dayOff, holiday, firstWeek, withGaps, empty }
Future<void> applySeed(WorkRecordRepository repo, SeedScenario s, {required DateTime today});
```

- 기존 기록을 전부 지우고 시나리오를 넣는다. `today` 기준 상대 날짜로 생성.
- `withGaps`는 이번 주 이전 평일 2일을 비운다. `firstWeek`는 첫 기록일을 이번 주 수요일로 둔다.
- 트리거: `kDebugMode`에서 **날짜 헤더 길게 누르기** → 시나리오 목록 바텀시트. 릴리즈에는 `GestureDetector.onLongPress` 자체가 null.

---

## 3. 프레젠테이션

### 3.1 프로바이더 (`lib/core/providers/` 및 feature)

| 프로바이더 | 종류 | 내용 |
|---|---|---|
| `appDatabase` | `@Riverpod(keepAlive: true)` | `AppDatabase` 생성, `ref.onDispose(close)` |
| `workRecordRepository` | keepAlive | `DriftWorkRecordRepository(db)` |
| `workRules` | keepAlive | `const WorkRules()`. 나중에 설정 화면이 여기를 바꾼다 |
| `allRecords` | `Stream<List<WorkRecord>>` | `repo.watchAll()` |
| `now` | keepAlive `Stream<DateTime>` | 즉시 1회 + 매 분 정각 틱. 자정 넘김·"n분째"·퇴근 예상 갱신은 전부 이걸로 |

테스트에서는 `appDatabase`를 `NativeDatabase.memory()`로, `now`를 고정값으로 오버라이드한다.

### 3.2 `TodayController` (`presentation/today/today_controller.dart`)

```dart
@riverpod
class TodayController extends _$TodayController {
  @override
  Future<TodayState> build() async {
    final records = await ref.watch(allRecordsProvider.future);
    final now = await ref.watch(nowProvider.future);
    final rules = ref.watch(workRulesProvider);
    return buildTodayState(records: records, now: now, rules: rules); // 순수 함수
  }
  Future<void> clockIn();                 // 오늘 record.clockIn = now
  Future<void> clockOut();                // clockOut = now
  Future<void> setHalfDay(bool on);       // type = halfDay / normal
  Future<void> setDayType(WorkType? t);   // dayOff / holiday / null→normal. 출근 전에만
  Future<void> revert();                  // = setDayType(null)
}
```

액션은 `repo.save`만 한다. 저장되면 `allRecords` 스트림이 돌아 `build`가 다시 실행된다.
`buildTodayState`는 `presentation/today/today_state_builder.dart`의 순수 함수 — Flutter 의존 없이 테스트한다.

### 3.3 `TodayState` (freezed)

```
date: DateTime
phase: TodayPhase            // before | working | done
dayType: WorkType?           // dayOff | holiday | null. phase == before일 때만 의미
isHalfDay: bool
clockIn, clockOut: DateTime?
elapsedMinutes: int?         // working일 때 now − clockIn (점심 미공제, "7h 15m째")
expectedClockOut: DateTime?  // before면 09:00 출근 가정, working이면 실제 출근 기준. 첫 주 예외면 null
todayDelta: int?             // done일 때 기준 대비
todayActual: int?            // done일 때 실근무
week: WeekSummary
unrecordedDays: List<DateTime>
```

**숫자로만 들고 문자열 조립은 위젯에서** 한다. 화면 상태 5종은 `(phase, dayType, week.isFirstWeekException)`으로 결정된다:

| 화면 상태 | 조건 |
|---|---|
| 1 출근 전 | `before && dayType == null` |
| 2 근무 중 | `working` |
| 3 퇴근 완료 | `done` |
| 4 연차/공휴일 | `before && dayType != null` |
| 5 첫 주 예외 | `week.isFirstWeekException` — 히어로·상태 문구만 바뀌고 버튼/슬롯은 1~3 규칙을 따른다 |

### 3.4 위젯 (`presentation/today/`)

```
today_screen.dart            ConsumerWidget. AsyncValue 분기, 로딩 중엔 배경색만
widgets/pill_tabs.dart       알약 탭 3개, "오늘"만 선택
widgets/hero_card.dart       라벨 / 54px 값 / 근거 / 진행 바(첫 주 예외면 같은 높이 빈 공간)
widgets/status_card.dart     상태 블록(104) + 주 버튼(56) + 보조 슬롯(38, margin 12)
widgets/status_block.dart    5상태별 내용 (점+문구 / 배지+2줄 / 4칸 요약)
widgets/primary_button.dart  활성/비활성, pressed 색·scale(.985) 애니메이션 .2s/.1s
widgets/soi_checkbox.dart    반차(사각 19, r6) / 연차·공휴일(원형 18) 공용, 히트 영역 세로 44 보장
widgets/type_badge.dart      연차·공휴일 배지
widgets/summary_row.dart     4칸 요약, 기준 대비 색 분기
widgets/first_week_card.dart 첫 주 안내 카드
widgets/unrecorded_card.dart 기록 안 된 날 리스트. 0개면 위젯 자체를 안 그림
```

**레이아웃 불변 규칙**: `status_card`의 세 슬롯은 `SizedBox(height: AppSizes.statusBlock/primaryButton/secondarySlot)`로 감싸 내용과 무관하게 높이를 고정한다. 내용이 넘치면 잘리게 두지 않고 폰트 크기 토큰을 조정한다 — 높이를 늘리지 않는다.

**SafeArea / 스크롤**:
- 루트 `Scaffold(backgroundColor: 화면 배경)` → `SafeArea(bottom: false)` → `Column`.
- 목업의 상단 58은 상태바 포함 값. 실제로는 `SafeArea.top + AppSizes.topInset(8)`.
- 본문은 `Expanded(SingleChildScrollView)`, 하단 패딩 = `20 + MediaQuery.viewPadding.bottom`. 작은 화면에서는 본문이 스크롤된다. 탭·날짜는 고정.

**애니메이션**: 진행 바 너비 `.4s ease`(`AnimatedFractionallySizedBox`), 체크박스 배경·테두리 `.15s`(`AnimatedContainer`), 버튼 배경 `.2s` + pressed scale `.1s`(`AnimatedScale`). 그 외 화면 전환 없음.

### 3.5 디자인 토큰 (`lib/ui/`)

- `app_colors.dart` — README Design Tokens 색상 전부, 이름은 역할 기반 (`screenBackground`, `card`, `cardInner`, `brand`, `brandPressed`, `ink`, `subtle`, `minus`, `dayOffBg/Border/Text`, `holidayBg/Border/Text`, ...).
- `app_sizes.dart` — 간격 스케일, radius, **고정 높이**(`statusBlock 104`, `primaryButton 56`, `secondarySlot 38`, `progressBar 6`, `checkboxSquare 19`, `checkboxRound 18`, `minTapHeight 44`), 디자인 기준폭 `402`.
- `app_text_styles.dart` — README Typography 표 전부. `fontFamily: 'Pretendard'`, `fontFeatures: [FontFeature.tabularFigures()]`, letter-spacing은 `em → px` 변환(`fontSize × em`).
- `app_theme.dart` — `ThemeData(fontFamily: 'Pretendard', scaffoldBackgroundColor, ...)`.
- 위젯 파일에 색·크기·스타일 리터럴을 두지 않는다 (CLAUDE.md 프레젠테이션 규칙).

### 3.6 SizeConfig (`core/presentation/size_config.dart`)

- 기준폭 402 (목업 iPhone 프레임). `scale = min(screenWidth, 상한) / 402`. 태블릿에서 무한히 커지지 않도록 상한(예: 480)을 둔다.
- `extension SizeX on num { double get w => this * scale; double get sp => this * scale; }` — 폭·높이·폰트 모두 같은 비율. `AppSizes`·`AppTextStyles`가 내부에서 `.w`/`.sp`를 적용하므로 위젯은 토큰만 쓴다.
- 앱 루트에서 `MediaQuery`로 1회 초기화(`LayoutBuilder`). 화면 회전은 지원하지 않는다 (세로 고정).

### 3.7 에셋

- Pretendard 정적 OTF `Regular(400)`, `Medium(500)`, `SemiBold(600)`을 GitHub 릴리즈 v1.3.9(OFL 1.1)에서 받아 `assets/fonts/`에 넣고 `pubspec.yaml`의 `fonts:`에 등록.
- `logo-transparent.png`, `mark-transparent.png` → `assets/images/`. 이번 라운드에는 쓰지 않지만 함께 커밋한다.

### 3.8 날짜·시간 표기

`core/presentation/format/` 에 순수 함수:
- `formatHm(int minutes)` → `"7h 22m"`, 음수 `"−7m"`(U+2212), 0 `"0m"`
- `formatClock(DateTime)` → `"09:12"`
- `formatDateTitle(DateTime)` → `"9월 11일 금요일"`, `formatDateShort` → `"9월 4일 금"`
`intl` 없이 직접 만든다.

---

## 4. 테스트

| 대상 | 파일 | 내용 |
|---|---|---|
| 계산 함수 | `test/domain/work_calculator_test.dart` | 일반/반차/주말 점심 공제 · 반차·연차·공휴일 섞인 주의 목표 · 기록 없는 평일 8h · 주말 근무 집계 제외 · 첫 주 예외 판정 · 오늘 목표/퇴근 예상(금요일 17:34, 반차 12:34, 수요일 앞당김) · 기록 누락 범위(첫 기록일~어제, 주말 제외) |
| Drift 리포지토리 | `test/data/drift_work_record_repository_test.dart` | 인메모리 DB. save→watch 방출, upsert, delete, 날짜 키 왕복 |
| 상태 빌더 | `test/presentation/today_state_builder_test.dart` | 기록 조합 → 5개 화면 상태 판정 |
| 컨트롤러 | `test/presentation/today_controller_test.dart` | `ProviderContainer` + 인메모리 DB + 고정 `now`. 출근→working, 퇴근→done, 연차→되돌리기 |
| 위젯 | `test/presentation/today_screen_test.dart` | **5개 상태에서 주 버튼의 `globalToLocal` Y가 전부 동일**. 누락 0개면 카드 없음 |

---

## 5. 파일 목록 (신규)

```
lib/domain/model/work_type.dart
lib/domain/model/work_record.dart
lib/domain/rules/work_rules.dart
lib/domain/rules/work_calculator.dart
lib/domain/rules/week_summary.dart
lib/domain/repository/work_record_repository.dart
lib/data/database/app_database.dart
lib/data/repository/drift_work_record_repository.dart
lib/data/seed/debug_seed.dart
lib/core/providers/database_providers.dart      appDatabase, workRecordRepository, workRules, allRecords
lib/core/providers/clock_provider.dart          now
lib/core/presentation/size_config.dart
lib/core/presentation/format/time_format.dart
lib/core/presentation/format/date_format.dart
lib/ui/app_colors.dart, app_sizes.dart, app_text_styles.dart, app_theme.dart
lib/presentation/today/today_state.dart
lib/presentation/today/today_state_builder.dart
lib/presentation/today/today_controller.dart
lib/presentation/today/today_screen.dart
lib/presentation/today/widgets/*.dart
assets/fonts/Pretendard-{Regular,Medium,SemiBold}.otf
assets/images/{logo,mark}-transparent.png
```

변경: `pubspec.yaml`(fonts), `lib/main.dart`(테마·SizeConfig), `lib/core/routing/router.dart`(플레이스홀더 → `TodayScreen`).

## 6. 확정된 판단들

- 반차 체크 시 퇴근 예상은 **12:34** (점심 공제 없음). README의 13:34는 채택하지 않음.
- 근무 중인 오늘의 진행분은 주간 실적에 **포함**한다 (히어로가 실시간으로 줄어든다).
- 첫 기록일은 저장하지 않고 항상 DB 최소 날짜로 파생한다. 첫 기록을 지우면 첫 주 판정도 따라 바뀐다 — 의도된 동작.
- 기록 입력 시트가 없는 동안 누락일 행과 "시간 수정하기"는 무반응.

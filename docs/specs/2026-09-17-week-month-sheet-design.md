# 2차 설계 — 오늘 화면 변경분 + 시간 수정 시트 + 주간/월간 탭

작성일: 2026-09-17
디자인 원본: `docs/specs/design-handoff-2-weekly-monthly-sheet.md` (핸드오프 README-2 사본),
목업 `~/Downloads/design_handoff_today_screen 2/근무시간 기록 앱.dc.html`
선행 스펙: `docs/specs/2026-09-14-today-screen-design.md` — 거기서 정한 구조(watchAll 스트림 + 순수 함수 파생, 토큰, SizeConfig)를 그대로 잇는다.
계산 규칙 원본: `CLAUDE.md`. 계산이 충돌하면 CLAUDE.md, 시각 표현이 충돌하면 핸드오프가 기준.

## 목표

1차에서 자리만 두었던 것들을 동작하게 만든다.
- 오늘 화면의 "시간 수정" · "출근 취소" · "퇴근 취소" · 기록 안 된 날 행 → **시간 수정 시트**로 연결
- 알약 탭의 **주간** · **월간** 활성화

## 범위

포함:
- §1 오늘 화면 변경분 (보조 슬롯 재구성, 취소 액션)
- §2 시간 수정 시트 (네 진입점 공유)
- §3 주간 탭, §4 월간 탭 (캘린더 + 범례)
- §5 라우팅 (StatefulShellRoute 3 브랜치)
- 도메인·리포지토리 소폭 확장, 디버그 시드 시나리오 추가

제외:
- **월간 리포트** (이번 달 누적·하루 패턴·휴가 사용). 2026-09-17 사용자 결정 — 실사용 후 다시 판단.
  README-2 §4의 "리포트 진입점"도 그리지 않는다. 월간 탭은 기간 네비게이터 → 캘린더 → 범례로 끝난다.
  이유: 카드 1(월 목표·기준 대비)은 CLAUDE.md "월간 초과/부족 합계는 만들지 않는다"와 충돌하고,
  나머지 둘은 데이터가 쌓여야 의미가 있다.
- 스플래시, 앱 아이콘 (별도 라운드)

## CLAUDE.md에 없어서 사용자에게 확정받은 규칙 (2026-09-17)

CLAUDE.md에도 반영한다.

1. **첫 기록일 당기기.** 첫 기록일보다 이른 날짜를 저장하면 첫 기록일을 그 날짜로 당긴다 (`min`).
   수요일에 설치하고 월·화를 나중에 채우면 첫 주 예외가 풀려 정상 계산되고, 기록 누락 탐색 범위도 그만큼 넓어진다.
   기록을 지워도 안 바뀐다는 기존 규칙은 유지.
2. **미래 날짜는 유형만.** 주간 리스트·월간 캘린더에서 미래 날짜를 탭하면 시트가 열리지만 반차/연차/공휴일 칩만 있고 출퇴근 행은 없다.
   미리 찍은 연차·공휴일은 그 주 목표와 퇴근 예상에 바로 반영된다 (계산 함수는 이미 이렇게 동작한다).
3. **연차·공휴일은 시각을 비운다.** 시트에서 연차/공휴일을 고르면 출근·퇴근 행과 계산 내역이 사라지고, 저장 시 `clockIn`·`clockOut`은 `null`.
   다시 해제하면 행이 돌아오고 값은 `--:--`(미입력)에서 시작한다.
4. **자정 넘김 미지원.** 퇴근 < 출근이면 저장 버튼 비활성 + 계산 내역 자리에 "퇴근이 출근보다 빨라요". 같은 시각(0분)은 허용.

## 구현 중 내가 정한 것 (사용자 확인 없이)

- **보조 슬롯 높이 38 → 40, 위 간격 12 → 10.** README-2와 목업이 40/10이고 합(50)이 같아 버튼 Y는 그대로다.
- **출근 취소는 오늘 기록을 삭제한다.** README-2의 "clockIn = null + 반차 해제"를 데이터로 옮기면 빈 normal 기록인데, 그건 없는 것과 같다. 첫 기록일은 규칙대로 남는다.
- **퇴근 취소는 `type`을 유지한다.** 반차로 찍은 날 퇴근을 취소해도 반차는 그대로.
- **저장 결과가 "빈 normal"(시각 둘 다 null, type normal)이면 delete.** 미래 날짜에서 유형을 해제하고 저장하거나, 과거 날짜를 아무것도 안 넣고 저장하는 경우 빈 행을 남기지 않는다.
- **시트의 시각 행은 `null`을 허용한다.** 행을 탭해 휠을 열기 전까지는 `--:--`. 휠을 열면 그 시점에 값이 생긴다(기존 값 또는 00:00). 한 번 생긴 값을 다시 비우는 방법은 두지 않는다 — 오늘의 퇴근을 비우는 건 오늘 화면의 "퇴근 취소", 전부 비우는 건 "이 날 기록 지우기".
- **오늘의 미래 시각 저장을 막지 않는다.** 15:00에 퇴근 18:00을 저장하면 오늘 화면은 퇴근 완료가 된다. 사용자가 의도한 것으로 본다.
- **뒤로 가기 하한.** 주간은 첫 기록일이 속한 주의 월요일, 월간은 첫 기록일이 속한 달까지. 첫 기록일이 없으면 이번 주/이번 달만. ◀도 ▶와 같은 방식(`#DCDFD8`, 무반응)으로 비활성.
- **탭 전환 시 선택한 주/월은 유지된다** (IndexedStack). 앱을 껐다 켜면 이번 주/이번 달.
- **월간 캘린더는 앞뒤를 채워 항상 완전한 주 단위(4~6행)로 그린다.** 다른 달 날짜도 실제 데이터를 보여주고 탭할 수 있다 (숫자만 흐리게).
- **반차인 날의 캘린더 셀은 배지만** 보여준다 (목업과 동일). 배지 + 값을 같이 넣으면 셀 높이 58을 넘는다. 기준 대비는 주간 탭에서 본다.
- **삭제 확인은 앱 토큰으로 만든 작은 다이얼로그.** "이 날 기록을 지울까요?" · 취소 / 지우기.
- **주간 카드 라벨.** 이번 주는 "이번 주 누적", 지난 주들은 "주간 누적". 근거 문구는 §3.
- **행 구분선 색은 README 값(`#E7E9E3`)**. 목업 스크립트의 `#EFF1EC`는 무시.
- **연차·공휴일·반차 배지 글자색은 README 토큰** (목업 스크립트의 미세하게 다른 값은 무시).

---

## 1. 오늘 화면 변경분

### 1.1 보조 슬롯 (높이 40, 위 간격 10)

| 화면 상태 | 내용 |
|---|---|
| 출근 전 | (변경 없음) 라디오형 체크 2개. 주말이면 비움 |
| 근무 중 | 체크박스 "오늘은 반차" · 구분선 · 텍스트 버튼 **출근 취소**. 주말이면 "출근 취소"만 |
| 퇴근 완료 | 텍스트 버튼 **시간 수정** · 구분선 · 텍스트 버튼 **퇴근 취소** |
| 연차/공휴일 | 텍스트 버튼 **되돌리기** 단독. "기록하려면" 접두 문구 삭제 |
| 첫 주 예외 | 위 규칙 그대로 (근무 중이면 근무 중 슬롯) |

**텍스트 버튼** (`widgets/quiet_text_button.dart`): 13 / w500 / brand. 패딩 `8 4`. pressed `opacity .55`. 히트 영역 세로 44.
**구분선**: 1×11, `AppColors.hairline`(#DCDFD8). 항목 간 gap 16.

히트 영역 44 확보 방식은 1차와 같다 (슬롯 레이아웃 박스 44, 위 gap과 카드 하단 패딩에서 인셋 차감). 인셋은 `(44 − 40) / 2 = 2`.

### 1.2 액션

`TodayController`에 추가:

| 메서드 | 동작 |
|---|---|
| `cancelClockIn()` | `repo.delete(today)`. 근무 중 → 출근 전. 반차도 같이 풀린다 |
| `cancelClockOut()` | `record.copyWith(clockOut: null)` 저장. 퇴근 완료 → 근무 중. `type` 유지 |

"시간 수정"과 기록 안 된 날 행은 컨트롤러가 아니라 화면이 시트를 연다 (§2.4). 주 버튼은 퇴근 완료에서 계속 무반응.

`TodayCallbacks`에 `onCancelClockIn`, `onCancelClockOut` 추가. `onEditTime`은 유지하되 이제 시트를 연다.

---

## 2. 시간 수정 시트

### 2.1 진입점 네 곳

| 진입점 | 대상 날짜 |
|---|---|
| 오늘 화면 "시간 수정" | 오늘 |
| 오늘 화면 기록 안 된 날 행 | 그 날짜 |
| 주간 리스트 행 | 그 날짜 |
| 월간 캘린더 셀 | 그 날짜 (다른 달 날짜 포함) |

`showRecordEditSheet(context, ref, date)` 하나. `showModalBottomSheet(useRootNavigator: true, isScrollControlled: true, backgroundColor: transparent, barrierColor: AppColors.scrim)`. 시트 위젯은 `RecordEditSheet`.

### 2.2 시트 상태 (위젯 로컬, 저장 전엔 DB에 안 닿는다)

```dart
class RecordDraft {          // presentation/record_edit/record_draft.dart, 순수 Dart
  final DateTime date;
  final WorkType type;       // normal | halfDay | dayOff | holiday
  final DateTime? clockIn;   // 날짜는 date, 시분만 의미
  final DateTime? clockOut;
  final EditingRow? editing; // null | clockIn | clockOut — 휠이 펼쳐진 행
}
```

파생 (순수 함수, 테스트 대상):
- `isWeekend`, `isFuture(now)` — 날짜에서.
- `showsTypeChips = !isWeekend`
- `showsTimeRows = !isFuture && type ∉ {dayOff, holiday}`
- `isValid = clockIn == null || clockOut == null || !clockOut.isBefore(clockIn)`
- `toRecord()` → `WorkRecord`. `dayOff`/`holiday`면 시각 null. 미래면 시각 null.
- `isEmptyNormal` → `type == normal && clockIn == null && clockOut == null` → 저장 대신 삭제.
- 계산 내역 (`showsTimeRows`일 때만): `actualMinutes`, 점심 공제(반차 "없음 (반차)" / 주말 "없음" / 아니면 `lunchBreakMinutes`), 기준(`standardMinutes`), 기준 대비(`deltaMinutes`). 주말은 근무·점심 공제 두 줄만. 시각이 하나라도 없으면 근무 "—", 기준 대비 "—".

초기값: 해당 날짜 기록이 있으면 그 값, 없으면 `type normal`, 시각 null, `editing null`.

### 2.3 레이아웃 (위→아래) — README-2 §2 수치 그대로

1. 그랩 핸들 38×4
2. 날짜 제목 16/w600. 기록 없으면 "기록 추가"가 아니라 **날짜 그대로** 쓴다 — 어느 날인지가 더 중요하다. (목업의 "기록 추가"는 날짜 없는 진입점용이었고 우리는 그런 진입점이 없다.)
3. 주말 안내 박스 (주말만)
4. 유형 칩 3열 (주말 아닐 때). 미선택 `chipNeutral`(#F0F2ED)/subtle, 선택 시 유형 배지 색. 상호배타, 재탭 해제. 칩 높이는 탭 영역 44 확보.
5. 출근 행 / 퇴근 행 (`showsTimeRows`일 때). 값 `--:--` 또는 `HH:MM`. 선택 행 배경 cardInner, 값 w600 brand.
   행 탭 → `editing` 토글. 휠을 여는 순간 그 행의 값이 null이면 `00:00`으로 채운다.
6. 시각 휠 (`editing != null`): 컨테이너 `margin-top 14, padding 16 14, radius 14, cardInner`, 제목 "출근 시각"/"퇴근 시각" 12/w500 subtle.
   `CupertinoPicker` 2개 (시 0–23, 분 0–59), `itemExtent 44`, 높이 176, `useMagnifier false`, `squeeze 1`, `diameterRatio` 크게(평면에 가깝게), `selectionOverlay`는 card 색 radius 11 띠.
   위아래 페이드는 `ShaderMask(linear-gradient transparent → black 32% → black 68% → transparent)`.
   선택 항목 25/w600 ink, 비선택 20/w500 `wheelUnselected`(#9DA296). `onSelectedItemChanged`로 즉시 값 반영.
   `scrollController: FixedExtentScrollController(initialItem: 현재 값)`.
7. 계산 내역 (`showsTimeRows`일 때). 12.5, lh 1.9. `isValid == false`면 내역 대신 "퇴근이 출근보다 빨라요" 한 줄 (minus 색).
8. 취소 / 저장 1:1, 높이 52. 저장은 `isValid`일 때만 활성 (비활성: buttonDisabled/subtle).
9. "이 날 기록 지우기" — 기존 기록이 있을 때만 표시. 탭 → 확인 다이얼로그 → `repo.delete`.

하단 패딩 30 + `viewPadding.bottom`. 키보드는 안 뜬다(휠만). 시트 내용이 화면보다 길면 스크롤 (`SingleChildScrollView`).

### 2.4 저장 경로

`@riverpod class RecordEditController` (`presentation/record_edit/record_edit_controller.dart`):
- `Future<void> save(RecordDraft draft)` — `draft.isEmptyNormal ? repo.delete(date) : repo.save(draft.toRecord())`
- `Future<void> delete(DateTime date)`

시트는 이걸 `ref.read`로 호출하고 `Navigator.pop`. 저장되면 `allRecords` 스트림이 돌아 오늘·주간·월간이 전부 갱신된다 — 별도 통지 없음.

---

## 3. 주간 탭

### 3.1 상태

`@Riverpod(keepAlive: true) class SelectedWeek` — `DateTime build()` = `mondayOf(clock())`. `prev()` / `next()` / `reset()`. `next()`는 이번 주를 넘지 않고, `prev()`는 하한(첫 기록일의 월요일)을 넘지 않는다. 하한·상한 판단은 순수 함수 `weekNavBounds`.

`@riverpod Future<WeekState> weekState` — `allRecords` + `firstRecordDate` + `now` + `workRules` + `selectedWeek` → `buildWeekState(...)` (순수 함수, `week_state_builder.dart`).

```
WeekState
  monday: DateTime
  isCurrentWeek: bool
  canGoPrev, canGoNext: bool
  summary: WeekSummary            // 기존 weekSummary()
  weekendMinutes: int             // 토·일 actualMinutes 합 (근거 문구 "주말 4h 30m 제외")
  days: List<WeekDay>             // 월~일 7개
  firstRecordDate: DateTime?

WeekDay
  date: DateTime
  record: WorkRecord?
  kind: WeekDayKind               // recorded | working | beforeWork | unrecorded | partial | off | future | weekendRecorded | weekendEmpty
  actualMinutes: int?             // recorded / weekendRecorded
  deltaMinutes: int?              // recorded 평일만
  isToday: bool
```

`kind` 판정 (평일 기준, 주말은 뒤 두 가지):

| kind | 조건 | main | note | 값 |
|---|---|---|---|---|
| off | type ∈ {dayOff, holiday} | "—" + 배지 | "근무 없음" | "—" |
| recorded | in·out 둘 다 있음 | "8h 31m" (+반차 배지) | "09:05 – 18:36" | ±delta |
| working | 오늘, in만 있음 | "근무 중" | "09:12 출근" | "—" |
| partial | 과거, in·out 중 하나만 | "기록 없음" | "09:00 출근 · 퇴근 없음" (있는 쪽만) | "—" |
| beforeWork | 오늘, 기록 없음(또는 in 없음) | "—" | "아직 출근 전" | "—" |
| unrecorded | 과거, 기록 없음 | "기록 없음" | "눌러서 입력" | "—" |
| future | 미래 (유형 없으면) | "—" (faint) | "" | "" |
| weekendRecorded | 주말, in·out 있음 | "4h 30m" | "주 40시간 제외 · 10:00 – 14:30" | "" |
| weekendEmpty | 주말, 그 외 | "—" (weekendNone) | "" | "" |

미래 날짜에 유형이 있으면 `off`(연차/공휴일) 또는 `future`에 반차 배지. 첫 기록일 이전의 과거 평일은 `unrecorded`로 보이되 (그 주까지는 못 가므로 실제로는 첫 주 앞부분만) — 그대로 둔다, 채워 넣을 수 있는 게 맞다.

### 3.2 카드 A — 누적

- 라벨: 이번 주 "이번 주 누적", 아니면 "주간 누적". 첫 주 예외면 "이번 주 기록한 시간".
- 값: `worked` 26/w600 + ` / target` 17/w400 subtle. 첫 주 예외면 값만.
- 근거 (12.5, lh 1.5), ` · `로 잇는다:
  - 이번 주: `남은 7h 22m` (잔여 ≤ 0이면 `목표 달성 · +1h 12m`)
  - 지난 주: `8h 50m 부족` / `1h 12m 초과` / `딱 맞음`
  - 반차·연차·공휴일 차감 문구 (1차 `heroReason`과 같은 규칙)
  - 주말 근무 있으면 `주말 4h 30m 제외`
  - 첫 주 예외: `9월 10일 수요일부터 기록 · 목표 없음`
- 진행 바: 첫 주 예외면 안 그린다 (오늘 화면과 달리 빈 공간도 안 둔다 — 아래 버튼이 없다).

### 3.3 카드 B — 일별 리스트

README-2 §3 카드 B 그대로. 날짜 폭 30 가운데, 값 폭 58 우측, 보조 min-height 16, 행 패딩 `13 18`, 구분선 `rowDivider`, 오늘 행 배경 `todayRow`(#F3F5F1), pressed `listRow`.
행 탭 → `showRecordEditSheet(date)`. **모든 행이 탭 가능** (미래 포함 — 유형만).

### 3.4 기간 네비게이터

`widgets/period_navigator.dart` (주간·월간 공용): ◀ · 라벨(min-width 186, 19/w600) · ▶. 화살표 30×30 원, pressed `tabContainer`, 비활성 `hairline` 색 + 무반응.
주간 라벨: 같은 달 `9월 7일 – 13일`, 다른 달 `8월 31일 – 9월 6일`. (`formatWeekRange` in `date_format.dart`)

---

## 4. 월간 탭

### 4.1 상태

`@Riverpod(keepAlive: true) class SelectedMonth` — `DateTime build()` = 이번 달 1일. `prev()`/`next()`, 하한 첫 기록일의 달, 상한 이번 달.

`@riverpod Future<MonthState> monthState` → `buildMonthState(...)`.

```
MonthState
  month: DateTime                 // 1일
  canGoPrev, canGoNext
  weeks: List<List<MonthCell>>    // 완전한 주 단위, 4~6행 × 7

MonthCell
  date, isCurrentMonth, isToday, isWeekend, isFuture
  type: WorkType?                 // 배지 (normal이면 null)
  value: MonthCellValue           // none | delta(int) | weekendActual(int) | working | unrecorded
  hasBackground: bool             // 평일 && !future && 이번 달
```

`value` 판정: 연차/공휴일/반차 → `none` (배지만). 평일 in·out 있음 → `delta`. 오늘 근무 중 → `working`("···"). 과거 평일 기록 없음/불완전 → `unrecorded`("—"). 주말 in·out 있음 → `weekendActual`. 그 외 `none`.

첫 기록일 이전의 과거 평일도 `unrecorded`로 "—" 표시 (하한이 첫 기록 달이라 그 달 앞부분만 해당).

### 4.2 레이아웃

README-2 §4 카드 A + 범례 그대로. 리포트 진입점 없음.
셀 높이 58, `paddingTop 9`, gap 5, 위 정렬. 숫자 10.5 (`subtle`; 다른 달·주말·미래 `dotInactive`). 배지 `1 5` r4 10/w700. 값 11.5/w500 (주말 11/w400 subtle), 색 규칙 주간과 동일, "—"·"···"는 `faint`.
셀 탭 → 시트. pressed `opacity .6`.
월 라벨 `2026년 9월` (`formatMonthTitle`).

---

## 5. 라우팅·셸

```
StatefulShellRoute.indexedStack
  branch /today  → TodayScreen
  branch /week   → WeekScreen
  branch /month  → MonthScreen
```

`RoutePaths.today = '/today'`, `week`, `month`. `initialLocation: today`.
셸 위젯 `TabShell`: `Scaffold(screenBackground) → SafeArea(bottom: false) → Column[ PillTabs(선택 = 현재 브랜치, onSelected → goBranch), Expanded(child) ]`.
각 화면은 `Column[ 기간 네비게이터 영역, Expanded(SingleChildScrollView(body)) ]`만 그린다. `TodayView`에서 Scaffold·SafeArea·PillTabs를 걷어내고 셸로 올린다 (날짜 헤더 + 롱프레스 시드 트리거는 TodayView에 남는다).
탭 전환 애니메이션 없음 (IndexedStack).

시트는 `useRootNavigator: true`로 셸 위에 뜬다.

---

## 6. 도메인·데이터 변경

### 6.1 도메인 (`domain/rules/`)

- `work_calculator.dart` 추가:
  - `bool isValidClockRange(DateTime? clockIn, DateTime? clockOut)` — 둘 다 있고 out < in이면 false.
  - `int weekendMinutes(records, monday, rules)` — 토·일 `actualMinutes` 합.
  - `DateTime firstOfMonth(DateTime)`, `List<DateTime> calendarDays(DateTime month)` — 월요일 시작, 앞뒤 채운 완전한 주.
- `navigation_bounds.dart` (순수):
  - `DateTime earliestMonday(DateTime? firstRecordDate, DateTime today)`
  - `DateTime earliestMonth(DateTime? firstRecordDate, DateTime today)`

### 6.2 리포지토리

`save()`: 첫 기록일이 없거나 **record.date가 더 이르면** 갱신. 인터페이스 주석·Drift 구현·테스트 수정.
`delete()`는 그대로 (첫 기록일 유지).

### 6.3 디버그 시드

`SeedScenario.history('두 달치 기록')` 추가: 오늘 기준 −8주 ~ 오늘(근무 중). 반차 2, 연차 1, 공휴일 1, 주말 근무 1, 누락 2, 다음 주에 미리 찍은 연차 1. 출퇴근 시각은 날짜 기반 결정적 변동(예: `9:00 + (day % 4) * 7분`)으로 주간·월간에 ±가 골고루 보이게.

---

## 7. 토큰 추가 (`lib/ui/`)

Colors: `hairline #DCDFD8`, `rowDivider #E7E9E3`, `faint #8B9184`, `weekendNone #C9CDC4`, `todayRow #F3F5F1`, `chipNeutral #F0F2ED`, `wheelUnselected #9DA296`, `scrim rgba(22,25,26,.42)`, `sheetShadow rgba(22,25,26,.18)`.
Sizes: 텍스트 버튼 패딩, 구분선 1×11, 네비게이터(패딩 `16 20 14`, 화살표 30, 라벨 min 186), 주간 카드(패딩 20, 값 top 8, 근거 top 7, 바 top 14), 행(패딩 `13 18`, gap 12, 날짜 폭 30, 값 폭 58, 보조 min 16, 배지 `2 7` r5), 캘린더(패딩 `16 14 16`, 요일 헤더 패딩 `14 2 6`, 셀 58 / r10 / top 9 / gap 5, 그리드 gap `4 3`, 배지 `1 5` r4), 범례(칩 13 r4, gap `8 14`), 시트(r24, 패딩 `10 20 30`, 핸들 38×4, 칩 gap 7, 행 패딩 `15 12`, 휠 176/44/r11, 버튼 52 r13 gap 9, 삭제 top 16).
TextStyles: `quietButton 13/500 brand`, `navLabel 19/600 −0.02em`, `weekValue 26/600 −0.03em`, `weekGoal 17/400 subtle`, `rowMain 15/500`, `rowMainDim 15/400 subtle`, `rowNum 15/500 lh1.15`, `rowDow 11.5`, `rowNote 11.5 subtle`, `rowDelta 13.5/500`, `rowBadge 11/600`, `calHeader 10.5 subtle`, `calNum 10.5`, `calBadge 10/700`, `calValue 11.5/500`, `calWeekend 11/400 subtle`, `legend 11.5 subtle`, `sheetTitle 16/600 −0.01em`, `sheetNote 11.5 subtle lh1.5`, `chip 13/600`, `timeLabel 13 subtle`, `timeValue 20/500`, `wheelSelected 25/600 −0.02em`, `wheelItem 20/500 wheelUnselected`, `calcRow 12.5 lh1.9`, `calcNote 11.5 subtle`, `sheetButton 15/600`, `deleteLink 12.5 subtle`.
Durations: `sheetScrim 180ms`, `sheetSlide 260ms cubic(.22,.8,.3,1)`, `wheelItem 120ms`, `chevron 200ms`.

---

## 8. 파일

신규:
```
lib/domain/rules/navigation_bounds.dart
lib/presentation/shell/tab_shell.dart
lib/presentation/shared/period_navigator.dart
lib/presentation/shared/quiet_text_button.dart
lib/presentation/shared/confirm_dialog.dart
lib/presentation/record_edit/record_draft.dart
lib/presentation/record_edit/record_edit_controller.dart
lib/presentation/record_edit/record_edit_sheet.dart
lib/presentation/record_edit/widgets/type_chips.dart
lib/presentation/record_edit/widgets/time_row.dart
lib/presentation/record_edit/widgets/time_wheel.dart
lib/presentation/record_edit/widgets/calc_rows.dart
lib/presentation/record_edit/record_edit_texts.dart
lib/presentation/week/selected_week.dart
lib/presentation/week/week_state.dart
lib/presentation/week/week_state_builder.dart
lib/presentation/week/week_provider.dart
lib/presentation/week/week_screen.dart
lib/presentation/week/week_texts.dart
lib/presentation/week/widgets/week_summary_card.dart
lib/presentation/week/widgets/week_day_row.dart
lib/presentation/month/selected_month.dart
lib/presentation/month/month_state.dart
lib/presentation/month/month_state_builder.dart
lib/presentation/month/month_provider.dart
lib/presentation/month/month_screen.dart
lib/presentation/month/month_texts.dart
lib/presentation/month/widgets/calendar_card.dart
lib/presentation/month/widgets/legend.dart
```
변경: `work_calculator.dart`, `work_record_repository.dart`, `drift_work_record_repository.dart`, `debug_seed.dart`, `router.dart`, `route_paths.dart`, `today_view.dart`, `today_screen.dart`, `today_controller.dart`, `status_card.dart`, `today_texts.dart`, `app_colors/sizes/text_styles.dart`, `date_format.dart`, `CLAUDE.md`.

`domain/`에는 여전히 `package:flutter` import 없음. 시트 초안(`RecordDraft`)은 presentation에 두되 Flutter 의존 없이 테스트한다.

---

## 9. 테스트

| 대상 | 내용 |
|---|---|
| 리포지토리 | 첫 기록일보다 이른 날짜 save → 당겨짐. 늦은 날짜·delete → 안 바뀜 |
| 계산 | `isValidClockRange`, `weekendMinutes`, `calendarDays`(월요일 시작·완전한 주·2026-09는 5행·2026-02는 4행·2026-08는 6행), 네비게이션 하한(첫 기록일 없음/있음) |
| RecordDraft | 연차 선택 시 `toRecord` 시각 null · 미래면 시각 null · `isValid` · `isEmptyNormal` · 계산 내역 값 |
| WeekState | 9가지 kind 판정 각 1건, 근거 문구(이번 주/지난 주 부족·초과·딱 맞음/첫 주), `canGoPrev/Next` |
| MonthState | 셀 value 판정, 다른 달 채움, 배경 규칙 |
| SelectedWeek/Month | prev/next 경계에서 멈춤 |
| TodayController | `cancelClockIn` → 기록 삭제·출근 전, `cancelClockOut` → 근무 중·type 유지 |
| RecordEditController | 빈 normal → delete, 그 외 save |
| 위젯 | 오늘 화면 5상태 버튼 Y 불변 (슬롯 40으로 바뀐 뒤에도), 주간 7행 높이 동일, 시트: out<in이면 저장 비활성·연차 선택 시 시각 행 사라짐 |

---

## 10. CLAUDE.md 반영

- 계산 규칙 > 첫 기록일: "이른 날짜를 저장하면 당긴다" 추가
- 계산 규칙에 "미래 날짜는 유형만", "연차·공휴일은 시각을 비운다", "자정 넘김 미지원" 추가
- 하지 않는 것: "월간 리포트 — 실사용 후 결정" 추가
- 디렉터리: `presentation/shell`, `shared`, `record_edit`, `week`, `month` 반영, `RoutePaths` 3개

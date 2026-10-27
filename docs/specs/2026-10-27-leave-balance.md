# 연차 입력을 "남은 연차 + 기준일"로 (2026-10-27)

브리프: `docs/specs/design-brief-5-leave-balance.md`. 디자인: 소이듀티 캔버스 "브리프 5 · 시안" 페이지(아트보드 `Brief5-Leave`, 마크업은 `Main.dc.html`의 `brief5` 분기), 피드백 반영본(2026-10-27)이 확정.
Handoff 4 스펙(`2026-10-25-settings-leave-pay-backup.md`) §1·§3·§6-2·§6-3의 연차 부분을 이 문서가 대체한다. 수당·백업 흐름·시작 요일은 그대로.

## 0. 왜

- "올해 총 연차"는 연중 설치한 사람에게 틀린 잔여를 보여준다 — 설치 전에 쓴 연차가 앱에 없는데 총에서 빼지 않는다.
- 0.5일 단위가 안 들어간다. 회사 시스템은 "잔여 8.5일"을 보여준다.
- 나중에 반반차(0.25일)가 들어와도 저장·입력을 다시 뜯지 않게 한다.

## 1. 개념

```
입력 = 지금 남은 연차(0.5일 단위, 0 허용) + 기준일(저장한 날, 앱이 자동)
잔여 = 입력값 − 기준일 다음 날부터 찍힌 연차·반차 (미리 찍은 미래 날짜 포함)
```

- 회사 숫자를 **그대로** 넣는다. 기준일 당일 연차는 회사 숫자에 이미 반영된 것으로 보고 빼지 않는다.
- 다시 넣으면 기준일도 그날로 옮겨간다. 1월 1일에 넣으면 총 연차와 같다.
- 해마다 따로 저장(설정 행은 지금 해, 월간 카드는 보고 있는 달의 해). 해당 해 값이 없으면 "사용 안 함".
- 끄는 길은 "사용 안 함으로 되돌리기" 하나. 0은 정상값("다 썼어요" → 이후 연차는 초과).

## 2. 모델과 저장

```dart
@freezed class LeaveBalance { required int remainingMinutes; required DateTime baseDate; }   // baseDate는 날짜만
AppSettings.leaveBalanceByYear: Map<int, LeaveBalance>   // annualLeaveDaysByYear를 대체
```

- **단위는 분.** 연차 1일 = `WorkRules.dayOffCreditMinutes`(480), 반차 = `halfDayCreditMinutes`(240). 입력 단위 `WorkRules.leaveStepMinutes = 240`(0.5일) — 반반차가 오면 120으로.
  일수 ↔ 분 변환은 입력·표시에서만 한다. 8.5일 입력 → 4080분 저장.
- 한도: 0 ≤ 분 ≤ `AppSettings.maxLeaveDays(99) × 480`, 그리고 `leaveStepMinutes`의 배수. `isValidLeaveMinutes(minutes, rules)`.
- Settings 테이블 키(스키마 v2 유지): `leave_remaining_minutes_<year>`(정수) · `leave_base_date_<year>`(`yyyy-MM-dd`). 둘 중 하나라도 없거나 못 읽으면 그 해는 없는 것.
- **옛 키 `annual_leave_days_<year>`**(정수 일)는 읽을 때 `일 × 480분, 기준일 그 해 1월 1일`로 변환한다 — 지금 계산과 완전히 같은 뜻. 새 키가 있으면 새 키가 이긴다.
  저장할 때 옛 키는 전부 지운다(첫 저장에 마이그레이션 끝).

## 3. 계산 (`domain/rules/work_calculator.dart`)

```
leaveMinutesOf(type, rules)             = 연차 480 · 반차 240 · 그 외 0
leaveMinutesUsed(records, year, rules, {after})
                                        = Σ 그 해 기록 중 (after == null || date > after) 인 날의 leaveMinutesOf
올해 사용(미입력 상태)   = leaveMinutesUsed(year)                              — 그 해 전체, 미래 포함
이후 사용(값 있을 때)    = leaveMinutesUsed(year, after: baseDate)
예정                     = leaveMinutesUsed(year, after: max(today, baseDate ?? today))   — 오늘은 예정이 아니다
잔여                     = remainingMinutes − 이후 사용                         — 음수면 초과
```

- `usedLeaveHalfDays`·`plannedLeaveHalfDays`는 지운다.
- 표기 `formatLeaveDays(minutes, dayMinutes)`: 480의 배수면 "15일", 아니면 소수 둘째 자리까지 끝 0 제거 — 4080 → "8.5일", 3960 → "8.25일", 0 → "0일".

## 4. 백업 (`format: 2`)

```json
"settings": { "weekStart": "monday", "leaveBalanceByYear": { "2026": { "remainingMinutes": 4080, "baseDate": "2026-10-26" } }, "hourlyWage": 12500 }
```

- 읽을 수 있는 최대 버전 2. format 1 파일의 `annualLeaveDaysByYear`는 §2와 같은 규칙(일 × 480, 기준일 1/1)으로 받는다.
- 범위 밖(`isValidLeaveMinutes` 실패)·기준일 파싱 실패는 그 해만 버린다. 복원은 `leaveBalanceByYear`를 통째로 덮어쓴다(기존 동작과 같다).

## 5. 화면

### 5-1. 설정 — 연차 행 (Handoff 4 §6-1 행 규격 그대로)

| 상태 | 라벨 | 보조 설명 | 값 |
|---|---|---|---|
| 없음 | 남은 연차 | 알려주시면 월간 탭에서 잔여 연차를 볼 수 있어요 | 사용 안 함 |
| 있음 | 남은 연차 | **10월 26일 기준** | 8.5일 (`brand` 600) |

### 5-2. 숫자 입력 시트 — 연차 변형 (`shared/number_input_sheet.dart` 확장, 시급 시트는 변화 없음)

- 제목 "남은 연차" → **헤드라인** "오늘(10월 26일) 기준 남은 연차" (위 12, 13 `subtle`) → 입력줄(위 4, 패딩 6 2 8).
- 입력줄: OS 숫자 키패드에 **소수점 켬**(`numberWithOptions(decimal: true)`). 정수 2자리 · 점 하나 · 소수 2자리. ","는 "."로 받는다.
  앞자리 0은 하나로("08"→"8"), 점부터 치면 "0.". 빈 값은 "0" 플레이스홀더(`dotInactive`) + 오른쪽 캡션 **"입력 전"**(13 `subtle`) — 0과 구분.
- 0.5 단위가 아니면(8.3, "8." 포함) 저장 비활성. 점이 있고 끝이 점이 아닌데 단위가 안 맞으면 입력줄 아래 **"0.5일 단위로 넣어주세요"**(위 6, 13 `minus`).
- 안내(위 12, 13 `subtle` lh 1.55) 세 줄:
  "회사에서 보여주는 지금 남은 연차를 그대로 넣어주세요." / "오늘이 기준일이 되고, 내일부터 찍는 연차를 빼서 보여드려요." / "신청해 둔 연차도 아직 안 쓴 것으로 쳐서 넣어주세요."
  **그 해에 오늘보다 뒤인 연차·반차가 찍혀 있으면** 넷째 줄 "이 뒤로 찍어둔 연차 1.5일은 여기서 빼서 보여드려요." (`brand`, 굵기 같음).
- "1월~12월 기준이에요" 줄은 없앤다. 저장(위 12) 활성 = 빈 값 아니고 단위 맞음 — **0 포함**. "사용 안 함으로 되돌리기"는 값이 있을 때, 그대로.
- 저장 = `LeaveBalance(remainingMinutes: round(일 × 480), baseDate: 오늘)`. 열 때 현재 값으로 채운다(4080 → "8.5", 7200 → "15").
- **본문은 스크롤, 저장·되돌리기는 키보드 위 고정** — 높이가 모자란 기기(360×640 안드로이드)에서 제목이 잘리지 않게. 시급 시트도 같은 구조를 타지만 보이는 변화는 없다.

### 5-3. 월간 연차 카드 (Handoff 4 §6-3 카드 규격 그대로, 라벨·줄만)

- 제목 "2026년 연차" → 값이 있으면 아래 **"10월 26일 기준"**(위 4, 13 `subtle` lh 1.45). 1월 1일 기준이어도 라벨은 같다(이 줄이 "1월 1일 기준"을 말한다).
- 3칸: **남은 연차** | **올해 사용**(없음) / **이후 사용**(있음) + "예정 n일 포함" | **지금 잔여** / **초과**.
  없음 → 1칸 "미입력", 3칸 "—", 유도 줄 "지금 남은 연차를 알려주시면 잔여를 보여드려요" → 연차 시트(**카드의 해**에 저장, 기준일은 오늘).
- 이후 사용 0은 "0일". 초과는 값 `minus`.

## 6. 시드·드라이버

- '두 달치 기록' 시드: 올해 `LeaveBalance(15일, 기준일 1월 1일)` + 시급 12,500. 드라이버 스크린샷은 바뀐 카드를 그대로 담는다.

## 7. 하지 않는 것

- 반반차 유형. 기준일 직접 선택. 연차 기준일(입사일) 설정. 1~12월 외 기간.

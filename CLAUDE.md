# SOI DUTY

주 40시간 유연근무 기준 근무시간 기록 앱. Flutter, 서버 없이 로컬로만 동작.

출퇴근을 버튼으로 찍어서 **"이번 주에 얼마나 더 채워야 하는지"**를 파악하는 게 목적이다.
누적 근무시간을 보여주는 앱이 아니라 **잔여 시간**을 보여주는 앱이다.

화면 디자인은 Claude Design 핸드오프로 전달된다. 이 문서는 디자인에 담기지 않는
계산 규칙과 구조를 정의한다. 둘이 충돌하면 계산은 이 문서가, 시각 표현은 디자인이 기준이다.

---

## 계산 규칙

### 근무 유형

| 유형 | 점심 공제 | 그날 기준시간 | 출퇴근 입력 |
|---|---|---|---|
| 일반 (normal) | 60분 | 8h | 필요 |
| 반차 (halfDay) | 없음 | 4h | 필요 |
| 연차 (dayOff) | — | 0h | 불필요 |
| 공휴일 (holiday) | — | 0h | 불필요 |

`normal`이 기본값이다. UI에 "일반"이라는 선택지를 두지 않는다.
반차·연차·공휴일 중 아무것도 켜지 않은 상태가 곧 일반이다.

### 하루 실근무 시간

```
일반   = 퇴근 - 출근 - 60분
반차   = 퇴근 - 출근          (점심 공제 없음)
주말   = 퇴근 - 출근          (점심 공제 없음)
연차   = 0
공휴일 = 0
```

점심 공제 조건은 "반차가 아니고, 주말이 아닐 것".

### 주간 목표와 잔여

```
주간 목표 = 40h - (반차 × 4h) - (연차 × 8h) - (공휴일 × 8h)
주간 실적 = 평일 실근무 합계
잔여     = 목표 - 실적
```

- 기록이 아예 없는 평일은 `normal`로 간주해 목표에 8h가 그대로 들어간다.
  그래야 기록이 빠진 날이 잔여에서 부당하게 사라지지 않는다.
- 주 단위로 리셋된다. 이월 없음.
- **월간 초과/부족 합계는 만들지 않는다.** 주마다 정산이 끝나므로
  +2h인 주와 -2h인 주는 상쇄되지 않는다. 합산하면 틀린 값이 된다.

### 주말

- 주 40시간 계산에 들어가지 않는다 — 실적에도, 목표에도.
- 기록 누락으로 잡지 않는다. 안 찍어도 정상이다.
- 기록은 가능하다. 그날 근무시간만 있고 기준 대비 ±는 없다.

### 기록 누락

- 출퇴근 중 하나라도 비어 있는 평일.
- 탐색 범위는 **첫 기록일 이후부터 어제까지.** 앱 설치 전 날짜는 대상이 아니다.
- 주말은 대상이 아니다.

### 첫 주 예외

첫 기록일이 그 주의 월요일이 아니면 **그 주만 잔여 계산을 하지 않는다.**
목표 없이 실적만 표시한다. 없는 데이터를 8h 등으로 추측해 채우지 않는다.
다음 주부터는 정상 계산. 이 분기는 설치 후 한 번만 탄다.

### 퇴근 예상 시각

근무 중 상태에서만 계산한다. 출근 전에는 출근 시각을 가정하지 않고 안내도 띄우지 않는다.

```
남은 평일 기준 = Σ(오늘 이후 이번 주 평일의 기준시간)   // 기록 없는 날은 normal 8h
오늘 목표     = max(0, (주간 목표 − 오늘 제외 주간 실적) − 남은 평일 기준)
퇴근 예상     = 출근 + 오늘 목표 + 점심 공제(해당 시)
```

앞선 날에 많이 했으면 오늘 목표가 줄고, 모자라면 는다. 첫 주 예외인 주에는 계산하지 않는다.

### 근무 중인 오늘

출근만 찍고 퇴근을 안 찍은 오늘은 `현재 − 출근 − 점심 공제(해당 시)`를 주간 실적에 실시간으로 넣는다.
잔여 시간은 1분 단위로 줄어든다.

### 첫 기록일

최초 기록을 저장하는 시점에 별도로 저장한다. DB에서 파생하지 않는다.
이후 기록을 지워도 첫 기록일은 바뀌지 않는다.

### 설정 가능성

아래 값들은 회사마다 다르다. 상수를 코드 곳곳에 흩뿌리지 않는다.
지금은 기본값으로만 쓰지만 나중에 설정 화면으로 뺄 수 있도록 **인스턴스**로 둔다.

```dart
class WorkRules {
  const WorkRules({
    this.weeklyTargetMinutes   = 2400,  // 40h
    this.lunchBreakMinutes     = 60,
    this.halfDayCreditMinutes  = 240,   // 4h
    this.dayOffCreditMinutes   = 480,   // 8h
  });
}
```

계산 함수는 `WorkRules`를 인자로 받는다. 모델 안에 규칙 값을 박지 않는다.

```dart
int? actualMinutes(WorkRecord record, WorkRules rules)
```

---

## 데이터 모델

```dart
enum WorkType { normal, halfDay, dayOff, holiday }

@freezed
class WorkRecord with _$WorkRecord {
  const factory WorkRecord({
    required DateTime date,   // 날짜만, 시분은 0
    DateTime? clockIn,
    DateTime? clockOut,
    @Default(WorkType.normal) WorkType type,
  }) = _WorkRecord;
}
```

- **주말 근무도 `normal`로 저장한다.** 주말 여부는 `date.weekday`로 판단하고
  집계에서 필터링한다. `enum`에 주말을 넣지 않는다 — 날짜만 보면 알 수 있는 정보다.
- **파생값은 저장하지 않는다.** 근무시간·잔여시간·기준 대비는 항상 계산으로 도출한다.
  규칙이 바뀌어도 데이터 마이그레이션이 필요 없어야 한다.
- `date`가 기본키. 하루에 기록은 하나뿐이다.

---

## 스택

- **상태관리: Riverpod** — 코드젠 방식(`@riverpod` 어노테이션)으로 통일.
  `StateNotifierProvider` 등 구버전 문법을 섞지 않는다.
- **DI는 Riverpod이 겸해도 되지만 구현형태 따라 get_it을 써도 된다. 하지만 절대 혼용하지 않는다. 주입 경로가 둘이면 안된다.** 
- **모델: freezed + json_annotation**
- **로컬 저장: Drift** — 쿼리 결과를 스트림으로 흘려주므로 `StreamProvider`와 맞물린다.
  한 화면에서 기록을 고치면 다른 화면의 집계가 자동 갱신되는 게 이 앱의 핵심 요구사항이다.
- **반응형 사이즈: 커스텀 SizeConfig** (비율 기반)
- **아키텍처: Clean Architecture** (presentation / domain / data)
  UseCase 레이어는 두지 않아도 되지만 필요하다면 사용해도 괜찮다. 

### Repository

Repository 인터페이스(Port)는 둔다. 나중에 백업·내보내기 구현이 붙을 때를 위한 것이다.

**Fake 구현체는 만들지 않는다.** Fake는 보통 UI를 미완성 데이터 소스에서 떼어놓기
위한 것인데, Drift는 로컬이라 항상 준비돼 있고 네트워크 대기도 실패도 없다.
테스트가 필요하면 `NativeDatabase.memory()` 로 실제 Drift를 인메모리 구동한다.

대신 **디버그용 시드 함수**를 둔다. 오늘 화면의 상태들, 첫 주 예외,
기록 누락이 있는 주 같은 상황을 손으로 만들지 않고 바로 확인하기 위한 것이다.
릴리즈 빌드에는 포함하지 않는다.

### 테스트

계산 규칙이 이 앱의 전부다. 화면보다 계산을 먼저 검증한다.
최소한 아래는 테스트로 고정한다.

- 일반/반차/주말의 점심 공제 분기
- 반차·연차·공휴일이 섞인 주의 목표 계산
- 기록이 없는 평일이 목표에 8h로 잡히는지
- 주말 근무가 주간 집계에서 빠지는지
- 첫 주 예외 판정 (월요일 시작 여부)

---

## 하지 않는 것

- **서버·로그인·Firebase.** 완전 로컬로 동작한다.
- **공휴일 자동 조회.** 하드코딩도 API도 하지 않는다. 사용자가 직접 찍는다.
  연말마다 공휴일 목록 갱신용 앱 업데이트를 내고 싶지 않다.
- **크래시 리포팅.** 출시를 결정할 때 다시 판단한다.
- **자동 위치 기반 출퇴근.** 버튼으로만 찍는다.
- **월간 초과/부족 합계.** 주 단위 리셋 구조와 맞지 않는다.
- **파생값 저장.** 언제나 계산.

---

## 프레젠테션 규칙 

- 색상, 텍스트 스타일, 사이즈 등을 하드코딩 하지  않는다. 


---

## 디렉터리

Clean Architecture, 단일 패키지. DI는 Riverpod 프로바이더가 겸한다 (`core/di/` 없음).

```
lib/
├─ main.dart                 ProviderScope + MaterialApp.router
├─ core/routing/             router.dart(@riverpod GoRouter), route_paths.dart
├─ core/presentation/        SizeConfig, 공용 위젯
├─ ui/                       색상·타이포 토큰
├─ domain/model/             WorkRecord, WorkType (freezed)
├─ domain/rules/             WorkRules + 계산 함수 (순수 Dart, 테스트 1순위)
├─ domain/repository/        Repository 인터페이스
├─ data/database/            Drift 테이블·AppDatabase
├─ data/repository/          Drift 구현체
├─ data/seed/                디버그 시드 (kDebugMode 가드)
└─ presentation/<feature>/   @riverpod Notifier + Screen
assets/images/, assets/fonts/
```

- `domain/`에는 `package:flutter` import 금지.
- 코드젠: `dart run build_runner build --delete-conflicting-outputs`
- `riverpod_lint`는 pubspec이 아니라 `analysis_options.yaml`의 `plugins:`로 설치한다.

## Flavor

`dev` / `prod` 두 개. 코드는 같고 번들 ID·앱 이름만 다르다 (`com.nuyoes.soiduty.dev` "소이듀티 dev" / `com.nuyoes.soiduty` "소이듀티").
실사용 앱과 시드 테스트용 앱을 폰에 나란히 설치하기 위한 것이지, 서버 환경 분리가 아니다.
**flavor 없이 `flutter run`/`flutter build` 하면 실패한다.** 항상 `--flavor dev` 또는 `--flavor prod`.
flavor 설정은 `pubspec.yaml`의 `flavorizr:` 블록이 정본이고 `dart run flutter_flavorizr -f`로 재생성한다
(재생성 후 iOS `ASSETCATALOG_COMPILER_APPICON_NAME`은 `AppIcon`으로 되돌린다 — 아이콘은 flavor 공용).

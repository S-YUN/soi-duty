# 오늘 화면 구현 플랜

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 출퇴근을 찍고 이번 주 잔여 시간을 보여주는 오늘 화면을 계산 규칙 → Drift 저장 → 화면 순서로 끝까지 동작하게 만든다.

**Architecture:** Drift `watchAll()` 스트림 하나를 Riverpod `StreamProvider`로 흘리고, `(records, firstRecordDate, now, rules) → TodayState` 순수 함수로 화면 상태를 도출한다. 액션은 리포지토리 `save`만 하고 스트림이 돌아 화면이 갱신된다. 디자인 수치는 `lib/ui/` 토큰 + `SizeConfig`(기준폭 402 비율)로만 쓴다.

**Tech Stack:** Flutter 3.47 / Dart 3.13, flutter_riverpod 3 + riverpod_generator 4, freezed 4, drift 2.35 + drift_flutter, go_router 18, build_runner.

**Spec:** `docs/specs/2026-09-14-today-screen-design.md` (디자인 수치 원본: `docs/specs/design-handoff-today-screen.md`)

## Global Constraints

- 계산 규칙의 출처는 `CLAUDE.md`뿐이다. 목업 숫자·핸드오프 README의 "계산 규칙" 문단에서 규칙을 만들지 않는다. 없는 규칙이 필요하면 멈추고 사용자에게 묻는다.
- `lib/domain/` 에는 `package:flutter` import 금지.
- 위젯 파일에 색·크기·텍스트 스타일 리터럴 금지. 전부 `lib/ui/` 토큰 경유.
- 상태 블록 104 · 주 버튼 56 · 보조 슬롯 38(+margin 12) 고정 높이. **상태가 바뀌어도 주 버튼 Y 좌표가 움직이지 않는다.**
- HTML 목업은 복사하지 않는다. Flutter 위젯으로 다시 만든다.
- SafeArea: 상단 `SafeArea.top + 8`, 하단 스크롤 패딩에 `MediaQuery.padding.bottom` 더함.
- 상태관리·DI는 Riverpod 코드젠(`@riverpod`)만. get_it·provider·ChangeNotifier 안 씀.
- 코드젠: `dart run build_runner build --delete-conflicting-outputs`
- 커밋: 각 태스크 끝에 커밋. 메시지는 한국어, 마지막 줄 `Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>`.
- 테스트 날짜 픽스처: **2026-09-14(월) ~ 09-18(금), 09-19(토), 09-20(일)**, 이전 주 월요일 09-07.

---

## 파일 구조

```
lib/
├─ main.dart                                   ProviderScope + 테마 + SizeConfig 초기화 + 세로 고정
├─ core/
│  ├─ routing/router.dart                      '/' → TodayScreen
│  ├─ providers/database_providers.dart        appDatabase, workRecordRepository, workRules, allRecords, firstRecordDate
│  ├─ providers/clock_provider.dart            clock (DateTime Function()), now (1분 틱 Stream)
│  └─ presentation/
│     ├─ size_config.dart                      SizeConfig + `num.w/.sp`
│     └─ format/time_format.dart               formatHm, formatSignedHm, formatClock
│     └─ format/date_format.dart               formatDateTitle, formatDateShort
├─ ui/
│  ├─ app_colors.dart                          색상 토큰
│  ├─ app_sizes.dart                           간격·radius·고정 높이 토큰 (.w 적용 getter)
│  ├─ app_text_styles.dart                     타이포 토큰 (.sp 적용 getter)
│  ├─ app_decorations.dart                     카드 BoxDecoration
│  └─ app_theme.dart                           ThemeData
├─ domain/
│  ├─ model/work_type.dart
│  ├─ model/work_record.dart                   freezed + json
│  ├─ rules/work_rules.dart
│  ├─ rules/week_summary.dart                  freezed
│  ├─ rules/work_calculator.dart               순수 계산 함수
│  └─ repository/work_record_repository.dart   인터페이스
├─ data/
│  ├─ database/app_database.dart               Drift 테이블 + AppDatabase
│  ├─ repository/drift_work_record_repository.dart
│  └─ seed/debug_seed.dart                     SeedScenario + applySeed
└─ presentation/
   ├─ today/today_state.dart                   TodayState, TodayPhase, TodayScreenState
   ├─ today/today_state_builder.dart           buildTodayState (순수)
   ├─ today/today_controller.dart              @riverpod TodayController
   ├─ today/today_texts.dart                   화면 문구 조립 (순수)
   ├─ today/today_view.dart                    상태+콜백 → 화면 (순수 위젯)
   ├─ today/today_screen.dart                  ConsumerWidget, 컨트롤러 연결
   ├─ today/widgets/{pill_tabs,primary_button,soi_checkbox,type_badge,summary_row,
   │                 hero_card,status_block,status_card,first_week_card,unrecorded_card}.dart
   └─ debug/seed_picker_sheet.dart             kDebugMode 시나리오 피커
test/
├─ helpers/records.dart                        날짜·기록 픽스처 헬퍼
├─ domain/work_calculator_test.dart
├─ data/drift_work_record_repository_test.dart
├─ presentation/today_state_builder_test.dart
├─ presentation/today_controller_test.dart
├─ presentation/today_view_test.dart           버튼 Y 불변 테스트
├─ core/format_test.dart
└─ widget_test.dart                            부팅 스모크 (인메모리 DB 오버라이드)
```

---

### Task 1: 에셋 · 디자인 토큰 · SizeConfig · 테마

**Files:**
- Create: `assets/fonts/Pretendard-{Regular,Medium,SemiBold}.otf`, `assets/fonts/OFL.txt`
- Create: `assets/images/logo-transparent.png`, `assets/images/mark-transparent.png`
- Create: `lib/core/presentation/size_config.dart`
- Create: `lib/ui/app_colors.dart`, `lib/ui/app_sizes.dart`, `lib/ui/app_text_styles.dart`, `lib/ui/app_decorations.dart`, `lib/ui/app_theme.dart`
- Modify: `pubspec.yaml` (fonts), `lib/main.dart`
- Test: `test/core/size_config_test.dart`

**Interfaces:**
- Produces: `SizeConfig.init(double screenWidth)`, `SizeConfig.scale`, `extension SizeX on num { double get w; double get sp; }`, `AppColors.*`(const Color), `AppSizes.*`(double getter), `AppTextStyles.*`(TextStyle getter), `AppDecorations.card`, `AppTheme.light`.

- [ ] **Step 1: Pretendard 폰트와 로고 복사**

```bash
S=/private/tmp/claude-501/-Users-seoyun-development-soi-duty/7f6404d5-4adb-4212-86a8-7d0036159b95/scratchpad
cd "$S" && curl -sL -o pretendard.zip https://github.com/orioncactus/pretendard/releases/download/v1.3.9/Pretendard-1.3.9.zip && unzip -qo pretendard.zip -d pretendard
find pretendard -name 'Pretendard-Regular.otf' -o -name 'Pretendard-Medium.otf' -o -name 'Pretendard-SemiBold.otf' -o -iname 'LICENSE*'
```
찾은 경로에서 복사 (경로는 위 find 출력으로 확인):
```bash
cd /Users/seoyun/development/soi_duty
cp "$S"/pretendard/**/Pretendard-Regular.otf "$S"/pretendard/**/Pretendard-Medium.otf "$S"/pretendard/**/Pretendard-SemiBold.otf assets/fonts/
cp "$(find "$S/pretendard" -iname 'LICENSE*' | head -1)" assets/fonts/OFL.txt
cp ~/Downloads/design_handoff_today_screen/logo-transparent.png ~/Downloads/design_handoff_today_screen/mark-transparent.png assets/images/
rm assets/fonts/.gitkeep assets/images/.gitkeep
ls -la assets/fonts assets/images
```
Expected: otf 3개 + OFL.txt, png 2개.

- [ ] **Step 2: pubspec.yaml에 폰트 등록**

`pubspec.yaml`의 주석 처리된 `fonts:` 블록을 아래로 교체:
```yaml
  fonts:
    - family: Pretendard
      fonts:
        - asset: assets/fonts/Pretendard-Regular.otf
          weight: 400
        - asset: assets/fonts/Pretendard-Medium.otf
          weight: 500
        - asset: assets/fonts/Pretendard-SemiBold.otf
          weight: 600
```

- [ ] **Step 3: SizeConfig 테스트 작성**

`test/core/size_config_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/core/presentation/size_config.dart';

void main() {
  test('기준폭 402에서는 1:1', () {
    SizeConfig.init(402);
    expect(20.w, 20);
    expect(13.5.sp, 13.5);
  });

  test('좁은 화면은 비례 축소', () {
    SizeConfig.init(201);
    expect(20.w, 10);
  });

  test('상한 480을 넘는 폭은 480으로 고정', () {
    SizeConfig.init(1000);
    expect(SizeConfig.scale, 480 / 402);
  });
}
```

- [ ] **Step 4: 실패 확인**

Run: `flutter test test/core/size_config_test.dart`
Expected: 컴파일 에러 (size_config.dart 없음)

- [ ] **Step 5: SizeConfig 구현**

`lib/core/presentation/size_config.dart`:
```dart
import 'dart:math' as math;

/// 디자인 기준폭(402) 대비 비율로 크기를 환산한다.
/// 앱 루트에서 [init]을 한 번 호출하고, 토큰은 `.w` / `.sp`로 값을 꺼낸다.
abstract final class SizeConfig {
  static const double designWidth = 402;
  static const double maxScaledWidth = 480;

  static double _scale = 1;
  static double get scale => _scale;

  static void init(double screenWidth) {
    _scale = math.min(screenWidth, maxScaledWidth) / designWidth;
  }
}

extension SizeX on num {
  /// 폭·높이·간격·radius
  double get w => this * SizeConfig.scale;

  /// 폰트 크기
  double get sp => this * SizeConfig.scale;
}
```

- [ ] **Step 6: 통과 확인**

Run: `flutter test test/core/size_config_test.dart`
Expected: 3 passed

- [ ] **Step 7: 색상 토큰**

`lib/ui/app_colors.dart`:
```dart
import 'dart:ui';

/// 디자인 핸드오프 Design Tokens > Colors. 역할 기반 이름.
abstract final class AppColors {
  static const screenBackground = Color(0xFFE9EBE6);
  static const card = Color(0xFFFCFCFB);
  static const cardInner = Color(0xFFF1F3EE);
  static const listRow = Color(0xFFEFF1EC);
  static const listRowPressed = Color(0xFFE7EAE4);
  static const tabContainer = Color(0xFFE1E4DD);
  static const divider = Color(0xFFE4E7E0);
  static const ink = Color(0xFF16191A);
  static const subtle = Color(0xFF5F6559);
  static const brand = Color(0xFF2C5A4C);
  static const brandPressed = Color(0xFF24483E);
  static const brandDeep = Color(0xFF1B473A);
  static const mint = Color(0xFF9FD3B4);
  static const onBrand = Color(0xFFF4F6F3);
  static const buttonDisabled = Color(0xFFEDEFEA);
  static const minus = Color(0xFFA8503F);
  static const dayOffBackground = Color(0xFFDFD2DD);
  static const dayOffBorder = Color(0xFFD3C2D0);
  static const dayOffText = Color(0xFF5C4459);
  static const holidayBackground = Color(0xFFE6CFC6);
  static const holidayBorder = Color(0xFFDCBFB4);
  static const holidayText = Color(0xFF7A4536);
  static const halfDayBackground = Color(0xFFE5DCBB);
  static const halfDayText = Color(0xFF6A5C2E);
  static const checkboxBorder = Color(0xFFCFD3CA);
  static const dotInactive = Color(0xFFC3C7BE);

  // 그림자·글로우 (알파 포함)
  static const cardShadow = Color(0x0D16191A); // rgba(22,25,26,.05)
  static const tabShadow = Color(0x1716191A); // rgba(22,25,26,.09)
  static const dotGlow = Color(0x242C5A4C); // rgba(44,90,76,.14)
}
```

- [ ] **Step 8: 사이즈 토큰**

`lib/ui/app_sizes.dart`:
```dart
import 'package:flutter/widgets.dart';

import '../core/presentation/size_config.dart';

/// 간격·radius·고정 높이. 전부 SizeConfig 비율이 적용된 getter.
abstract final class AppSizes {
  // 화면 골격
  static double get topInset => 8.w;
  static double get screenHPadding => 20.w;
  static EdgeInsets get datePadding => EdgeInsets.fromLTRB(20.w, 18.w, 20.w, 14.w);
  static EdgeInsets get bodyPadding => EdgeInsets.fromLTRB(16.w, 4.w, 16.w, 20.w);
  static double get cardGap => 12.w;

  // 알약 탭
  static double get tabPadding => 3.w;
  static double get tabGap => 2.w;
  static double get tabItemVPadding => 9.w;

  // 카드
  static double get cardRadius => 20.w;
  static EdgeInsets get heroPadding => EdgeInsets.fromLTRB(22.w, 24.w, 22.w, 22.w);
  static EdgeInsets get statusCardPadding => EdgeInsets.fromLTRB(18.w, 16.w, 18.w, 18.w);
  static EdgeInsets get firstWeekCardPadding => EdgeInsets.symmetric(vertical: 14.w, horizontal: 16.w);
  static EdgeInsets get unrecordedCardPadding => EdgeInsets.fromLTRB(16.w, 15.w, 16.w, 12.w);

  // 히어로
  static double get heroValueTop => 8.w;
  static double get heroReasonTop => 9.w;
  static double get progressBarTop => 18.w;
  static double get progressBar => 6.w;

  // 상태 카드 고정 높이 — 다섯 상태에서 동일
  static double get statusBlock => 104.w;
  static double get primaryButton => 56.w;
  static double get secondarySlot => 38.w;
  static double get secondarySlotGap => 12.w;
  static double get statusBlockGap => 10.w;
  static double get buttonRadius => 14.w;

  // 상태 블록 내부
  static double get dot => 7.w;
  static double get dotGlow => 3.w;
  static double get dotGap => 7.w;
  static EdgeInsets get badgePadding => EdgeInsets.symmetric(vertical: 7.w, horizontal: 14.w);
  static double get badgeBorder => 1.w;

  // 4칸 요약
  static double get summaryRadius => 12.w;
  static EdgeInsets get summaryCellPadding => EdgeInsets.symmetric(vertical: 10.w, horizontal: 4.w);
  static double get summaryValueTop => 3.w;
  static double get summaryDivider => 1.w;

  // 체크박스
  static double get checkboxSquare => 19.w;
  static double get checkboxRound => 18.w;
  static double get checkboxSquareRadius => 6.w;
  static double get checkboxBorderOff => 1.5.w;
  static double get checkboxBorderOn => 1.w;
  static double get checkboxIcon => 12.sp;
  static double get checkboxGap => 9.w;
  static double get checkRowRadius => 11.w;
  static EdgeInsets get checkRowPadding => EdgeInsets.symmetric(vertical: 7.w, horizontal: 10.w);
  static double get dayTypeRowRadius => 10.w;
  static double get dayTypeGap => 18.w;
  static double get minTapHeight => 44.w;
  static double get linkGap => 6.w;

  // 기록 안 된 날
  static EdgeInsets get unrecordedTitlePadding => EdgeInsets.fromLTRB(2.w, 0, 2.w, 9.w);
  static double get unrecordedRowGap => 6.w;
  static double get unrecordedRowRadius => 12.w;
  static EdgeInsets get unrecordedRowPadding => EdgeInsets.symmetric(vertical: 12.w, horizontal: 14.w);

  static double get pill => 999.w;
  static Offset get shadowOffset => Offset(0, 1.w);
  static double get shadowBlur => 2.w;
}

/// 애니메이션 시간. 핸드오프 Interactions 표.
abstract final class AppDurations {
  static const progressBar = Duration(milliseconds: 400);
  static const checkbox = Duration(milliseconds: 150);
  static const buttonColor = Duration(milliseconds: 200);
  static const buttonScale = Duration(milliseconds: 100);
}

abstract final class AppScales {
  static const buttonPressed = 0.985;
  static const rowPressed = 0.99;
}
```

- [ ] **Step 9: 텍스트 스타일 토큰**

`lib/ui/app_text_styles.dart`:
```dart
import 'dart:ui';

import 'package:flutter/painting.dart';

import '../core/presentation/size_config.dart';
import 'app_colors.dart';

/// 디자인 핸드오프 Typography 표. letter-spacing은 em → px 환산.
abstract final class AppTextStyles {
  static const fontFamily = 'Pretendard';

  static TextStyle _style(
    double size,
    FontWeight weight, {
    double? letterSpacingEm,
    double? height,
    Color color = AppColors.ink,
  }) {
    final fontSize = size.sp;
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: weight,
      letterSpacing: letterSpacingEm == null ? null : fontSize * letterSpacingEm,
      height: height,
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  static TextStyle get heroValue =>
      _style(54, FontWeight.w600, letterSpacingEm: -0.04, height: 1.02, color: AppColors.brand);
  static TextStyle get dateTitle => _style(22, FontWeight.w600, letterSpacingEm: -0.03);
  static TextStyle get primaryButton => _style(16.5, FontWeight.w600, color: AppColors.onBrand);
  static TextStyle get primaryButtonDisabled => _style(16.5, FontWeight.w600, color: AppColors.subtle);
  static TextStyle get statusMain => _style(15, FontWeight.w500, letterSpacingEm: -0.01);
  static TextStyle get summaryValue => _style(14.5, FontWeight.w600, letterSpacingEm: -0.01);
  static TextStyle get summaryLabel => _style(11, FontWeight.w400, color: AppColors.subtle);
  static TextStyle get tabSelected => _style(13.5, FontWeight.w600);
  static TextStyle get tabUnselected => _style(13.5, FontWeight.w500, color: AppColors.subtle);
  static TextStyle get body => _style(13.5, FontWeight.w400, color: AppColors.subtle);
  static TextStyle get bodyInk => _style(13.5, FontWeight.w400);
  static TextStyle get bodyParagraph => _style(13.5, FontWeight.w400, height: 1.55, color: AppColors.subtle);
  static TextStyle get label => _style(13, FontWeight.w500, color: AppColors.subtle);
  static TextStyle get reason => _style(13, FontWeight.w400, color: AppColors.subtle);
  static TextStyle get caption => _style(12.5, FontWeight.w400, color: AppColors.subtle);
  static TextStyle get captionMedium => _style(12.5, FontWeight.w500, color: AppColors.subtle);
  static TextStyle get captionParagraph => _style(12.5, FontWeight.w400, height: 1.55, color: AppColors.subtle);
  static TextStyle get link => _style(12.5, FontWeight.w400, color: AppColors.subtle,)
      .copyWith(decoration: TextDecoration.underline, decorationColor: AppColors.subtle);
  static TextStyle get linkBrand => _style(12.5, FontWeight.w600, color: AppColors.brand)
      .copyWith(decoration: TextDecoration.underline, decorationColor: AppColors.brand);
  static TextStyle get badge => _style(12.5, FontWeight.w600);

  /// 반차 체크박스 라벨 (13.5)
  static TextStyle checkLabel({required bool checked}) => _style(
        13.5,
        checked ? FontWeight.w600 : FontWeight.w500,
        letterSpacingEm: -0.01,
        color: checked ? AppColors.brand : AppColors.subtle,
      );

  /// 연차·공휴일 라디오형 라벨 (13)
  static TextStyle dayTypeLabel({required bool checked}) => _style(
        13,
        checked ? FontWeight.w600 : FontWeight.w500,
        letterSpacingEm: -0.01,
        color: checked ? AppColors.brand : AppColors.subtle,
      );
}
```

- [ ] **Step 10: 데코레이션 + 테마**

`lib/ui/app_decorations.dart`:
```dart
import 'package:flutter/painting.dart';

import 'app_colors.dart';
import 'app_sizes.dart';

abstract final class AppDecorations {
  static BoxDecoration get card => BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        boxShadow: [
          BoxShadow(color: AppColors.cardShadow, offset: AppSizes.shadowOffset, blurRadius: AppSizes.shadowBlur),
        ],
      );
}
```

`lib/ui/app_theme.dart`:
```dart
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        fontFamily: AppTextStyles.fontFamily,
        scaffoldBackgroundColor: AppColors.screenBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.brand,
          surface: AppColors.card,
        ),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      );
}
```

- [ ] **Step 11: main.dart — 테마·SizeConfig·세로 고정**

`lib/main.dart` 전체 교체:
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/presentation/size_config.dart';
import 'core/routing/router.dart';
import 'ui/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ProviderScope(child: SoiDutyApp()));
}

class SoiDutyApp extends ConsumerWidget {
  const SoiDutyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'SOI DUTY',
      theme: AppTheme.light,
      routerConfig: router,
      builder: (context, child) {
        SizeConfig.init(MediaQuery.sizeOf(context).width);
        return child!;
      },
    );
  }
}
```

- [ ] **Step 12: 검증 + 커밋**

Run: `flutter pub get && flutter analyze && flutter test`
Expected: No issues, 모든 테스트 통과 (기존 widget_test 포함)

```bash
git add -A
git commit -m "에셋·디자인 토큰·SizeConfig·테마

- Pretendard 400/500/600 OTF (OFL) + 로고 PNG 등록
- lib/ui 색상·사이즈·타이포·데코 토큰, 전부 SizeConfig 비율 경유
- 앱 루트에서 SizeConfig 초기화, 세로 고정

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
```

---

### Task 2: 도메인 모델 · WorkRules · WeekSummary

**Files:**
- Create: `lib/domain/model/work_type.dart`, `lib/domain/model/work_record.dart`, `lib/domain/rules/work_rules.dart`, `lib/domain/rules/week_summary.dart`
- Test: `test/domain/work_record_test.dart`

**Interfaces:**
- Produces:
  - `enum WorkType { normal, halfDay, dayOff, holiday }`
  - `WorkRecord({required DateTime date, DateTime? clockIn, DateTime? clockOut, WorkType type = normal})` + `fromJson/toJson/copyWith`
  - `WorkRules({weeklyTargetMinutes=2400, lunchBreakMinutes=60, halfDayCreditMinutes=240, dayOffCreditMinutes=480})`, `int get dailyStandardMinutes`
  - `WeekSummary({int? targetMinutes, required int workedMinutes, int? remainingMinutes, required int halfDayCount, required int dayOffCount, required int holidayCount, required bool isFirstWeekException})`

- [ ] **Step 1: 테스트 작성**

`test/domain/work_record_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/domain/model/work_record.dart';
import 'package:soi_duty/domain/model/work_type.dart';
import 'package:soi_duty/domain/rules/work_rules.dart';

void main() {
  test('기본 type은 normal', () {
    final r = WorkRecord(date: DateTime(2026, 9, 14));
    expect(r.type, WorkType.normal);
    expect(r.clockIn, isNull);
  });

  test('json 왕복', () {
    final r = WorkRecord(
      date: DateTime(2026, 9, 14),
      clockIn: DateTime(2026, 9, 14, 9, 12),
      clockOut: DateTime(2026, 9, 14, 18, 5),
      type: WorkType.halfDay,
    );
    expect(WorkRecord.fromJson(r.toJson()), r);
  });

  test('WorkRules 기본값', () {
    const rules = WorkRules();
    expect(rules.weeklyTargetMinutes, 2400);
    expect(rules.lunchBreakMinutes, 60);
    expect(rules.halfDayCreditMinutes, 240);
    expect(rules.dayOffCreditMinutes, 480);
    expect(rules.dailyStandardMinutes, 480);
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/domain/work_record_test.dart`
Expected: 컴파일 에러

- [ ] **Step 3: 구현**

`lib/domain/model/work_type.dart`:
```dart
/// 근무 유형. 주말은 넣지 않는다 — date.weekday로 안다.
enum WorkType { normal, halfDay, dayOff, holiday }
```

`lib/domain/model/work_record.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

import 'work_type.dart';

part 'work_record.freezed.dart';
part 'work_record.g.dart';

@freezed
abstract class WorkRecord with _$WorkRecord {
  const factory WorkRecord({
    /// 날짜만. 시분초 0, local.
    required DateTime date,
    DateTime? clockIn,
    DateTime? clockOut,
    @Default(WorkType.normal) WorkType type,
  }) = _WorkRecord;

  factory WorkRecord.fromJson(Map<String, Object?> json) => _$WorkRecordFromJson(json);
}
```

`lib/domain/rules/work_rules.dart`:
```dart
/// 회사마다 다른 값. 계산 함수는 항상 이 인스턴스를 인자로 받는다.
class WorkRules {
  const WorkRules({
    this.weeklyTargetMinutes = 2400,
    this.lunchBreakMinutes = 60,
    this.halfDayCreditMinutes = 240,
    this.dayOffCreditMinutes = 480,
  });

  final int weeklyTargetMinutes;
  final int lunchBreakMinutes;
  final int halfDayCreditMinutes;
  final int dayOffCreditMinutes;

  /// 평일 하루 기준시간 (8h). 연차 1일 차감량과 같다.
  int get dailyStandardMinutes => dayOffCreditMinutes;
}
```

`lib/domain/rules/week_summary.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'week_summary.freezed.dart';

@freezed
abstract class WeekSummary with _$WeekSummary {
  const factory WeekSummary({
    /// 첫 주 예외면 null
    int? targetMinutes,
    required int workedMinutes,
    /// target − worked. target이 null이면 null
    int? remainingMinutes,
    required int halfDayCount,
    required int dayOffCount,
    required int holidayCount,
    required bool isFirstWeekException,
  }) = _WeekSummary;
}
```

- [ ] **Step 4: 코드젠 + 통과 확인**

Run: `dart run build_runner build --delete-conflicting-outputs && flutter test test/domain/work_record_test.dart`
Expected: 3 passed

- [ ] **Step 5: 커밋**

```bash
git add -A
git commit -m "도메인 모델: WorkType, WorkRecord, WorkRules, WeekSummary

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
```

---

### Task 3: 계산 함수 — 하루 단위 (점심 공제·실근무·진행분·기준 대비)

**Files:**
- Create: `lib/domain/rules/work_calculator.dart`
- Create: `test/helpers/records.dart`
- Test: `test/domain/work_calculator_test.dart`

**Interfaces:**
- Produces (모두 최상위 함수, `work_calculator.dart`):
  - `DateTime dateOnly(DateTime d)`
  - `bool isWeekend(DateTime d)`
  - `DateTime mondayOf(DateTime d)`
  - `bool deductsLunch(WorkRecord r)`
  - `int standardMinutes(WorkType type, WorkRules rules)`
  - `int? actualMinutes(WorkRecord r, WorkRules rules)`
  - `int? ongoingMinutes(WorkRecord r, DateTime now, WorkRules rules)`
  - `int? deltaMinutes(WorkRecord r, WorkRules rules)`
- 테스트 헬퍼 `test/helpers/records.dart`: `DateTime d(int day, [int hour = 0, int minute = 0])` (2026년 9월), `WorkRecord rec(int day, {int? inH, int? inM, int? outH, int? outM, WorkType type = WorkType.normal})`

- [ ] **Step 1: 테스트 헬퍼**

`test/helpers/records.dart`:
```dart
import 'package:soi_duty/domain/model/work_record.dart';
import 'package:soi_duty/domain/model/work_type.dart';

/// 2026년 9월 기준. 14(월) 15(화) 16(수) 17(목) 18(금) 19(토) 20(일), 이전 주 월요일 7.
DateTime d(int day, [int hour = 0, int minute = 0]) => DateTime(2026, 9, day, hour, minute);

WorkRecord rec(
  int day, {
  int? inH,
  int? inM,
  int? outH,
  int? outM,
  WorkType type = WorkType.normal,
}) =>
    WorkRecord(
      date: d(day),
      clockIn: inH == null ? null : d(day, inH, inM ?? 0),
      clockOut: outH == null ? null : d(day, outH, outM ?? 0),
      type: type,
    );
```

- [ ] **Step 2: 테스트 작성**

`test/domain/work_calculator_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/domain/model/work_type.dart';
import 'package:soi_duty/domain/rules/work_calculator.dart';
import 'package:soi_duty/domain/rules/work_rules.dart';

import '../helpers/records.dart';

const rules = WorkRules();

void main() {
  group('날짜 유틸', () {
    test('isWeekend', () {
      expect(isWeekend(d(18)), isFalse); // 금
      expect(isWeekend(d(19)), isTrue); // 토
      expect(isWeekend(d(20)), isTrue); // 일
    });

    test('mondayOf', () {
      expect(mondayOf(d(16, 13, 30)), d(14));
      expect(mondayOf(d(14)), d(14));
      expect(mondayOf(d(20)), d(14));
    });

    test('dateOnly', () {
      expect(dateOnly(d(16, 13, 30)), d(16));
    });
  });

  group('점심 공제', () {
    test('일반 평일은 공제', () => expect(deductsLunch(rec(14)), isTrue));
    test('반차는 공제 없음', () => expect(deductsLunch(rec(14, type: WorkType.halfDay)), isFalse));
    test('주말은 공제 없음', () => expect(deductsLunch(rec(19)), isFalse));
  });

  group('standardMinutes', () {
    test('유형별 기준시간', () {
      expect(standardMinutes(WorkType.normal, rules), 480);
      expect(standardMinutes(WorkType.halfDay, rules), 240);
      expect(standardMinutes(WorkType.dayOff, rules), 0);
      expect(standardMinutes(WorkType.holiday, rules), 0);
    });
  });

  group('actualMinutes', () {
    test('일반: 퇴근 − 출근 − 60분', () {
      expect(actualMinutes(rec(14, inH: 9, outH: 18), rules), 480);
    });
    test('반차: 점심 공제 없음', () {
      expect(actualMinutes(rec(14, inH: 9, outH: 13, type: WorkType.halfDay), rules), 240);
    });
    test('주말: 점심 공제 없음', () {
      expect(actualMinutes(rec(19, inH: 10, outH: 14), rules), 240);
    });
    test('연차·공휴일은 출퇴근과 무관하게 0', () {
      expect(actualMinutes(rec(14, type: WorkType.dayOff), rules), 0);
      expect(actualMinutes(rec(14, inH: 9, outH: 18, type: WorkType.holiday), rules), 0);
    });
    test('출퇴근 중 하나라도 없으면 null', () {
      expect(actualMinutes(rec(14, inH: 9), rules), isNull);
      expect(actualMinutes(rec(14, outH: 18), rules), isNull);
      expect(actualMinutes(rec(14), rules), isNull);
    });
    test('공제 후 음수면 0', () {
      expect(actualMinutes(rec(14, inH: 9, outH: 9, outM: 30), rules), 0);
    });
  });

  group('ongoingMinutes', () {
    test('오늘 출근만 찍었으면 현재까지 − 점심', () {
      expect(ongoingMinutes(rec(14, inH: 9), d(14, 12), rules), 120);
    });
    test('점심 공제 전이면 0', () {
      expect(ongoingMinutes(rec(14, inH: 9), d(14, 9, 30), rules), 0);
    });
    test('반차면 점심 공제 없음', () {
      expect(ongoingMinutes(rec(14, inH: 9, type: WorkType.halfDay), d(14, 12), rules), 180);
    });
    test('오늘이 아니면 null (과거 미완 기록은 진행분이 아님)', () {
      expect(ongoingMinutes(rec(14, inH: 9), d(15, 12), rules), isNull);
    });
    test('퇴근 찍었으면 null', () {
      expect(ongoingMinutes(rec(14, inH: 9, outH: 18), d(14, 19), rules), isNull);
    });
    test('출근 안 찍었으면 null', () {
      expect(ongoingMinutes(rec(14), d(14, 12), rules), isNull);
    });
  });

  group('deltaMinutes', () {
    test('일반: 실근무 − 8h', () {
      expect(deltaMinutes(rec(14, inH: 9, inM: 12, outH: 18, outM: 5), rules), -7);
    });
    test('반차: 실근무 − 4h', () {
      expect(deltaMinutes(rec(14, inH: 9, outH: 13, outM: 10, type: WorkType.halfDay), rules), 10);
    });
    test('주말은 기준 대비 없음', () {
      expect(deltaMinutes(rec(19, inH: 10, outH: 14), rules), isNull);
    });
    test('실근무 없으면 null', () {
      expect(deltaMinutes(rec(14, inH: 9), rules), isNull);
    });
  });
}
```

- [ ] **Step 3: 실패 확인**

Run: `flutter test test/domain/work_calculator_test.dart`
Expected: 컴파일 에러

- [ ] **Step 4: 구현**

`lib/domain/rules/work_calculator.dart`:
```dart
import 'dart:math' as math;

import '../model/work_record.dart';
import '../model/work_type.dart';
import 'work_rules.dart';

// ---- 날짜 유틸 ----

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

bool isWeekend(DateTime d) => d.weekday >= DateTime.saturday;

DateTime mondayOf(DateTime d) {
  final day = dateOnly(d);
  return DateTime(day.year, day.month, day.day - (day.weekday - DateTime.monday));
}

// ---- 하루 단위 ----

/// 점심 공제 조건: 반차가 아니고, 주말이 아닐 것.
bool deductsLunch(WorkRecord r) => r.type != WorkType.halfDay && !isWeekend(r.date);

/// 그날 기준시간.
int standardMinutes(WorkType type, WorkRules rules) => switch (type) {
      WorkType.normal => rules.dailyStandardMinutes,
      WorkType.halfDay => rules.halfDayCreditMinutes,
      WorkType.dayOff || WorkType.holiday => 0,
    };

/// 하루 실근무. 연차·공휴일은 0, 출퇴근이 비면 null.
int? actualMinutes(WorkRecord r, WorkRules rules) {
  if (r.type == WorkType.dayOff || r.type == WorkType.holiday) return 0;
  final clockIn = r.clockIn;
  final clockOut = r.clockOut;
  if (clockIn == null || clockOut == null) return null;
  final raw = clockOut.difference(clockIn).inMinutes;
  final lunch = deductsLunch(r) ? rules.lunchBreakMinutes : 0;
  return math.max(0, raw - lunch);
}

/// 근무 중인 오늘의 진행분. 오늘이 아니거나 출근·퇴근 조건이 안 맞으면 null.
int? ongoingMinutes(WorkRecord r, DateTime now, WorkRules rules) {
  if (dateOnly(now) != r.date) return null;
  final clockIn = r.clockIn;
  if (clockIn == null || r.clockOut != null) return null;
  final raw = now.difference(clockIn).inMinutes;
  final lunch = deductsLunch(r) ? rules.lunchBreakMinutes : 0;
  return math.max(0, raw - lunch);
}

/// 기준 대비 (실근무 − 그날 기준시간). 주말은 기준이 없으므로 null.
int? deltaMinutes(WorkRecord r, WorkRules rules) {
  if (isWeekend(r.date)) return null;
  final actual = actualMinutes(r, rules);
  if (actual == null) return null;
  return actual - standardMinutes(r.type, rules);
}
```

- [ ] **Step 5: 통과 확인**

Run: `flutter test test/domain/work_calculator_test.dart`
Expected: 모두 passed

- [ ] **Step 6: 커밋**

```bash
git add -A
git commit -m "계산 함수: 점심 공제·실근무·진행분·기준 대비

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
```

---

### Task 4: 계산 함수 — 주간 집계 · 첫 주 예외

**Files:**
- Modify: `lib/domain/rules/work_calculator.dart`
- Modify: `test/domain/work_calculator_test.dart`

**Interfaces:**
- Produces:
  - `bool isFirstWeekException(DateTime monday, DateTime? firstRecordDate)`
  - `WeekSummary weekSummary({required List<WorkRecord> records, required DateTime monday, required WorkRules rules, required DateTime now, required DateTime? firstRecordDate})`

- [ ] **Step 1: 테스트 추가**

`test/domain/work_calculator_test.dart`의 `main()` 끝에 추가 (import에 `package:soi_duty/domain/model/work_record.dart` 추가):
```dart
  group('isFirstWeekException', () {
    test('첫 기록일이 이번 주 수요일이면 예외', () {
      expect(isFirstWeekException(d(14), d(16)), isTrue);
    });
    test('첫 기록일이 이번 주 월요일이면 정상', () {
      expect(isFirstWeekException(d(14), d(14)), isFalse);
    });
    test('첫 기록일이 지난 주면 정상 (예외는 그 주만)', () {
      expect(isFirstWeekException(d(14), d(9)), isFalse);
    });
    test('첫 기록일이 없으면 정상', () {
      expect(isFirstWeekException(d(14), null), isFalse);
    });
  });

  group('weekSummary', () {
    WeekSummary week(List<WorkRecord> records, {DateTime? now, DateTime? first}) => weekSummary(
          records: records,
          monday: d(14),
          rules: rules,
          now: now ?? d(18, 23),
          firstRecordDate: first ?? d(7),
        );

    test('평일 5일 전부 일반이면 목표 40h', () {
      final s = week([for (var day = 14; day <= 18; day++) rec(day, inH: 9, outH: 18)]);
      expect(s.targetMinutes, 2400);
      expect(s.workedMinutes, 2400);
      expect(s.remainingMinutes, 0);
    });

    test('반차·연차·공휴일이 섞이면 목표에서 차감', () {
      final s = week([
        rec(14, inH: 9, outH: 18),
        rec(15, inH: 9, outH: 13, type: WorkType.halfDay),
        rec(16, type: WorkType.dayOff),
        rec(17, type: WorkType.holiday),
        rec(18, inH: 9, outH: 18),
      ]);
      expect(s.targetMinutes, 2400 - 240 - 480 - 480);
      expect(s.halfDayCount, 1);
      expect(s.dayOffCount, 1);
      expect(s.holidayCount, 1);
      expect(s.workedMinutes, 480 + 240 + 0 + 0 + 480);
    });

    test('기록이 없는 평일은 normal로 간주해 목표 8h 유지', () {
      final s = week([rec(14, inH: 9, outH: 18), rec(15, inH: 9, outH: 18)]);
      expect(s.targetMinutes, 2400);
      expect(s.workedMinutes, 960);
      expect(s.remainingMinutes, 1440);
    });

    test('주말 근무는 실적에도 목표에도 안 들어감', () {
      final s = week([rec(14, inH: 9, outH: 18), rec(19, inH: 10, outH: 14)]);
      expect(s.targetMinutes, 2400);
      expect(s.workedMinutes, 480);
    });

    test('근무 중인 오늘의 진행분 포함', () {
      final s = week([rec(14, inH: 9, outH: 18), rec(15, inH: 9)], now: d(15, 12));
      expect(s.workedMinutes, 480 + 120);
    });

    test('출퇴근이 빈 과거 기록은 0으로 집계 (목표는 그대로 8h)', () {
      final s = week([rec(14, inH: 9)], now: d(18, 23));
      expect(s.workedMinutes, 0);
      expect(s.targetMinutes, 2400);
    });

    test('첫 주 예외면 목표·잔여 없이 실적만', () {
      final s = week([rec(16, inH: 9, outH: 18), rec(17, inH: 9, outH: 18)], first: d(16));
      expect(s.isFirstWeekException, isTrue);
      expect(s.targetMinutes, isNull);
      expect(s.remainingMinutes, isNull);
      expect(s.workedMinutes, 960);
    });

    test('다른 주의 기록은 무시', () {
      final s = week([rec(7, inH: 9, outH: 18), rec(14, inH: 9, outH: 18)]);
      expect(s.workedMinutes, 480);
    });
  });
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/domain/work_calculator_test.dart`
Expected: 컴파일 에러 (함수 없음)

- [ ] **Step 3: 구현**

`lib/domain/rules/work_calculator.dart` 끝에 추가 (import에 `week_summary.dart` 추가):
```dart
// ---- 주간 ----

/// 첫 기록일이 그 주의 월요일이 아니면, 그 주만 잔여 계산을 하지 않는다.
bool isFirstWeekException(DateTime monday, DateTime? firstRecordDate) {
  if (firstRecordDate == null) return false;
  final first = dateOnly(firstRecordDate);
  return mondayOf(first) == dateOnly(monday) && first.weekday != DateTime.monday;
}

/// 월~금 5일을 순회한다. 기록이 없는 평일은 normal(8h)로 간주한다.
Iterable<DateTime> weekdaysOf(DateTime monday) sync* {
  final start = dateOnly(monday);
  for (var i = 0; i < 5; i++) {
    yield DateTime(start.year, start.month, start.day + i);
  }
}

Map<DateTime, WorkRecord> recordsByDate(List<WorkRecord> records) =>
    {for (final r in records) dateOnly(r.date): r};

WeekSummary weekSummary({
  required List<WorkRecord> records,
  required DateTime monday,
  required WorkRules rules,
  required DateTime now,
  required DateTime? firstRecordDate,
}) {
  final byDate = recordsByDate(records);
  final firstWeek = isFirstWeekException(monday, firstRecordDate);

  var target = 0;
  var worked = 0;
  var halfDays = 0;
  var dayOffs = 0;
  var holidays = 0;

  for (final day in weekdaysOf(monday)) {
    final r = byDate[day];
    final type = r?.type ?? WorkType.normal;
    target += standardMinutes(type, rules);
    switch (type) {
      case WorkType.halfDay:
        halfDays++;
      case WorkType.dayOff:
        dayOffs++;
      case WorkType.holiday:
        holidays++;
      case WorkType.normal:
        break;
    }
    if (r != null) {
      worked += actualMinutes(r, rules) ?? ongoingMinutes(r, now, rules) ?? 0;
    }
  }

  return WeekSummary(
    targetMinutes: firstWeek ? null : target,
    workedMinutes: worked,
    remainingMinutes: firstWeek ? null : target - worked,
    halfDayCount: halfDays,
    dayOffCount: dayOffs,
    holidayCount: holidays,
    isFirstWeekException: firstWeek,
  );
}
```

- [ ] **Step 4: 통과 확인**

Run: `flutter test test/domain/work_calculator_test.dart`
Expected: 모두 passed

- [ ] **Step 5: 커밋**

```bash
git add -A
git commit -m "계산 함수: 주간 집계·첫 주 예외

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
```

---

### Task 5: 계산 함수 — 오늘 목표 · 퇴근 예상 · 기록 누락

**Files:**
- Modify: `lib/domain/rules/work_calculator.dart`
- Modify: `test/domain/work_calculator_test.dart`

**Interfaces:**
- Produces:
  - `int? todayTargetMinutes({required List<WorkRecord> records, required DateTime today, required WorkRules rules, required DateTime now, required DateTime? firstRecordDate})`
  - `DateTime? expectedClockOut(WorkRecord today, int todayTarget, WorkRules rules)`
  - `List<DateTime> unrecordedWeekdays({required List<WorkRecord> records, required DateTime today, required DateTime? firstRecordDate})`

- [ ] **Step 1: 테스트 추가**

`main()` 끝에 추가:
```dart
  group('todayTargetMinutes (CLAUDE.md 퇴근 예상 시각)', () {
    int? target(List<WorkRecord> records, int day, {DateTime? first}) => todayTargetMinutes(
          records: records,
          today: d(day),
          rules: rules,
          now: d(day, 12),
          firstRecordDate: first ?? d(7),
        );

    test('앞선 날이 정확히 8h씩이면 오늘 목표 8h', () {
      expect(target([rec(14, inH: 9, outH: 18), rec(15, inH: 9, outH: 18), rec(16, inH: 9)], 16), 480);
    });

    test('앞선 날 초과분만큼 오늘 목표가 줄어든다', () {
      // 월 9h, 화 8h → 1h 초과 → 수 7h
      expect(target([rec(14, inH: 9, outH: 19), rec(15, inH: 9, outH: 18), rec(16, inH: 9)], 16), 420);
    });

    test('앞선 날 부족분만큼 오늘 목표가 늘어난다', () {
      // 월 7h → 수 9h
      expect(target([rec(14, inH: 9, outH: 17), rec(15, inH: 9, outH: 18), rec(16, inH: 9)], 16), 540);
    });

    test('오늘이 반차면 목표가 4h 기준으로 줄고 남은 평일은 8h 유지', () {
      final r = [rec(14, inH: 9, outH: 18), rec(15, inH: 9, outH: 18), rec(16, inH: 9, type: WorkType.halfDay)];
      // 목표 2160 − 960 − (목·금 960) = 240
      expect(target(r, 16), 240);
    });

    test('남은 평일에 연차가 있으면 그날은 0으로 뺀다', () {
      final r = [rec(14, inH: 9, outH: 18), rec(15, inH: 9, outH: 18), rec(16, inH: 9), rec(17, type: WorkType.dayOff)];
      // 목표 1920 − 960 − (금 480) = 480
      expect(target(r, 16), 480);
    });

    test('마지막 평일(금)은 잔여 전부', () {
      final r = [for (var day = 14; day <= 17; day++) rec(day, inH: 9, outH: 17, outM: 30), rec(18, inH: 9)];
      // 월~목 각 7.5h = 1800 → 2400 − 1800 = 600
      expect(target(r, 18), 600);
    });

    test('이미 채웠으면 0 (음수 없음)', () {
      expect(target([rec(14, inH: 9, outH: 22), rec(15, inH: 9, outH: 22), rec(16, inH: 9)], 16), 0);
    });

    test('오늘의 진행분은 계산에서 제외 (오늘 목표를 구하는 중이므로)', () {
      final r = [rec(14, inH: 9, outH: 18), rec(15, inH: 9, outH: 18), rec(16, inH: 9)];
      expect(
        todayTargetMinutes(records: r, today: d(16), rules: rules, now: d(16, 15), firstRecordDate: d(7)),
        480,
      );
    });

    test('첫 주 예외면 null', () {
      expect(target([rec(16, inH: 9)], 16, first: d(16)), isNull);
    });

    test('주말이면 null', () {
      expect(target([rec(19, inH: 9)], 19), isNull);
    });
  });

  group('expectedClockOut', () {
    test('일반: 출근 + 오늘 목표 + 점심', () {
      expect(expectedClockOut(rec(16, inH: 9, inM: 12), 420, rules), d(16, 17, 12));
    });
    test('반차: 점심 없음', () {
      expect(expectedClockOut(rec(16, inH: 9, inM: 12, type: WorkType.halfDay), 240, rules), d(16, 13, 12));
    });
    test('출근 없으면 null', () {
      expect(expectedClockOut(rec(16), 480, rules), isNull);
    });
  });

  group('unrecordedWeekdays', () {
    test('첫 기록일부터 어제까지의 평일 중 비거나 불완전한 날, 최신순', () {
      final r = [
        rec(7, inH: 9, outH: 18),
        rec(8, inH: 9, outH: 18),
        rec(10, inH: 9), // 퇴근 누락
        rec(14, inH: 9, outH: 18),
        rec(16, inH: 9), // 오늘, 대상 아님
      ];
      expect(
        unrecordedWeekdays(records: r, today: d(16), firstRecordDate: d(7)),
        [d(15), d(11), d(10), d(9)],
      );
    });

    test('주말은 대상이 아니다', () {
      final r = [rec(11, inH: 9, outH: 18), rec(14, inH: 9, outH: 18)];
      expect(unrecordedWeekdays(records: r, today: d(15), firstRecordDate: d(11)), isEmpty);
    });

    test('연차·공휴일은 출퇴근이 없어도 누락이 아니다', () {
      final r = [rec(14, type: WorkType.dayOff), rec(15, type: WorkType.holiday)];
      expect(unrecordedWeekdays(records: r, today: d(16), firstRecordDate: d(14)), isEmpty);
    });

    test('첫 기록일 이전은 대상이 아니다', () {
      expect(unrecordedWeekdays(records: [rec(16, inH: 9)], today: d(17), firstRecordDate: d(16)), isEmpty);
    });

    test('첫 기록일이 없으면 빈 리스트', () {
      expect(unrecordedWeekdays(records: const [], today: d(16), firstRecordDate: null), isEmpty);
    });
  });
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/domain/work_calculator_test.dart`
Expected: 컴파일 에러

- [ ] **Step 3: 구현**

`work_calculator.dart` 끝에 추가:
```dart
// ---- 오늘 목표 · 퇴근 예상 (CLAUDE.md "퇴근 예상 시각") ----

/// 오늘 목표 = max(0, (주간 목표 − 오늘 제외 주간 실적) − 오늘 이후 평일 기준시간 합).
/// 첫 주 예외·주말이면 null.
int? todayTargetMinutes({
  required List<WorkRecord> records,
  required DateTime today,
  required WorkRules rules,
  required DateTime now,
  required DateTime? firstRecordDate,
}) {
  final day = dateOnly(today);
  if (isWeekend(day)) return null;
  final monday = mondayOf(day);
  if (isFirstWeekException(monday, firstRecordDate)) return null;

  final byDate = recordsByDate(records);
  var target = 0;
  var workedExcludingToday = 0;
  var remainingStandard = 0;

  for (final weekday in weekdaysOf(monday)) {
    final r = byDate[weekday];
    final type = r?.type ?? WorkType.normal;
    target += standardMinutes(type, rules);
    if (weekday.isBefore(day)) {
      if (r != null) workedExcludingToday += actualMinutes(r, rules) ?? 0;
    } else if (weekday.isAfter(day)) {
      remainingStandard += standardMinutes(type, rules);
    }
  }

  return math.max(0, target - workedExcludingToday - remainingStandard);
}

/// 퇴근 예상 = 출근 + 오늘 목표 + 점심 공제(해당 시).
DateTime? expectedClockOut(WorkRecord today, int todayTarget, WorkRules rules) {
  final clockIn = today.clockIn;
  if (clockIn == null) return null;
  final lunch = deductsLunch(today) ? rules.lunchBreakMinutes : 0;
  return clockIn.add(Duration(minutes: todayTarget + lunch));
}

// ---- 기록 누락 ----

/// 첫 기록일 ~ 어제의 평일 중 기록이 없거나, 출퇴근이 필요한 유형인데 하나라도 빈 날. 최신순.
List<DateTime> unrecordedWeekdays({
  required List<WorkRecord> records,
  required DateTime today,
  required DateTime? firstRecordDate,
}) {
  if (firstRecordDate == null) return const [];
  final byDate = recordsByDate(records);
  final end = dateOnly(today);
  final result = <DateTime>[];

  var cursor = dateOnly(firstRecordDate);
  while (cursor.isBefore(end)) {
    if (!isWeekend(cursor)) {
      final r = byDate[cursor];
      final needsClock = r == null || r.type == WorkType.normal || r.type == WorkType.halfDay;
      final incomplete = r == null || r.clockIn == null || r.clockOut == null;
      if (needsClock && incomplete) result.add(cursor);
    }
    cursor = DateTime(cursor.year, cursor.month, cursor.day + 1);
  }
  return result.reversed.toList();
}
```

- [ ] **Step 4: 통과 확인**

Run: `flutter test test/domain/work_calculator_test.dart`
Expected: 모두 passed

- [ ] **Step 5: 커밋**

```bash
git add -A
git commit -m "계산 함수: 오늘 목표·퇴근 예상·기록 누락

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
```

---

### Task 6: 리포지토리 인터페이스 · Drift DB · 구현체

**Files:**
- Create: `lib/domain/repository/work_record_repository.dart`
- Create: `lib/data/database/app_database.dart`
- Create: `lib/data/repository/drift_work_record_repository.dart`
- Test: `test/data/drift_work_record_repository_test.dart`

**Interfaces:**
- Produces:
  - `abstract interface class WorkRecordRepository { Stream<List<WorkRecord>> watchAll(); Stream<DateTime?> watchFirstRecordDate(); Future<void> save(WorkRecord record); Future<void> delete(DateTime date); }`
  - `AppDatabase(QueryExecutor e)` — 테이블 `workRecords`(row: `WorkRecordRow`), `settings`(row: `SettingRow`)
  - `DriftWorkRecordRepository(AppDatabase db)`, `static const firstRecordDateKey = 'first_record_date'`
  - `String dateKey(DateTime)` / `DateTime parseDateKey(String)` (repository 파일 최상위)

- [ ] **Step 1: 테스트 작성**

`test/data/drift_work_record_repository_test.dart`:
```dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/data/database/app_database.dart';
import 'package:soi_duty/data/repository/drift_work_record_repository.dart';
import 'package:soi_duty/domain/model/work_type.dart';

import '../helpers/records.dart';

void main() {
  late AppDatabase db;
  late DriftWorkRecordRepository repo;

  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftWorkRecordRepository(db);
  });

  tearDown(() => db.close());

  test('처음엔 비어 있다', () async {
    expect(await repo.watchAll().first, isEmpty);
    expect(await repo.watchFirstRecordDate().first, isNull);
  });

  test('save 후 watchAll이 방출하고 날짜·시각·유형이 왕복된다', () async {
    final r = rec(14, inH: 9, inM: 12, outH: 18, outM: 5, type: WorkType.halfDay);
    await repo.save(r);
    final all = await repo.watchAll().first;
    expect(all, [r]);
  });

  test('같은 날짜에 두 번 save하면 갱신 (행 하나)', () async {
    await repo.save(rec(14, inH: 9));
    await repo.save(rec(14, inH: 9, outH: 18));
    final all = await repo.watchAll().first;
    expect(all.length, 1);
    expect(all.single.clockOut, d(14, 18));
  });

  test('delete', () async {
    await repo.save(rec(14, inH: 9));
    await repo.delete(d(14));
    expect(await repo.watchAll().first, isEmpty);
  });

  test('첫 save가 첫 기록일을 기록하고, 이후 save·delete로 바뀌지 않는다', () async {
    await repo.save(rec(16, inH: 9));
    expect(await repo.watchFirstRecordDate().first, d(16));

    await repo.save(rec(14, inH: 9)); // 더 이른 날짜를 저장해도
    expect(await repo.watchFirstRecordDate().first, d(16));

    await repo.delete(d(16)); // 첫 기록을 지워도
    expect(await repo.watchFirstRecordDate().first, d(16));
  });

  test('watchAll은 변경마다 다시 방출한다', () async {
    final emissions = <int>[];
    final sub = repo.watchAll().listen((l) => emissions.add(l.length));
    await Future<void>.delayed(Duration.zero);
    await repo.save(rec(14, inH: 9));
    await Future<void>.delayed(Duration.zero);
    await repo.save(rec(15, inH: 9));
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();
    expect(emissions, [0, 1, 2]);
  });

  test('dateKey 왕복', () {
    expect(dateKey(d(3)), '2026-09-03');
    expect(parseDateKey('2026-09-03'), d(3));
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/data/drift_work_record_repository_test.dart`
Expected: 컴파일 에러

- [ ] **Step 3: 인터페이스**

`lib/domain/repository/work_record_repository.dart`:
```dart
import '../model/work_record.dart';

abstract interface class WorkRecordRepository {
  Stream<List<WorkRecord>> watchAll();

  /// 최초 save 시점에 저장된 날짜. 이후 바뀌지 않는다.
  Stream<DateTime?> watchFirstRecordDate();

  /// date 기준 upsert. 첫 기록일이 비어 있으면 record.date로 채운다.
  Future<void> save(WorkRecord record);

  Future<void> delete(DateTime date);
}
```

- [ ] **Step 4: Drift DB**

`lib/data/database/app_database.dart`:
```dart
import 'package:drift/drift.dart';

import '../../domain/model/work_type.dart';

part 'app_database.g.dart';

@DataClassName('WorkRecordRow')
class WorkRecords extends Table {
  /// 'yyyy-MM-dd'. DateTime 컬럼은 UTC로 저장돼 날짜가 밀릴 수 있어 문자열 키를 쓴다.
  TextColumn get date => text()();
  DateTimeColumn get clockIn => dateTime().nullable()();
  DateTimeColumn get clockOut => dateTime().nullable()();
  IntColumn get type => intEnum<WorkType>()();

  @override
  Set<Column<Object>> get primaryKey => {date};
}

@DataClassName('SettingRow')
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DriftDatabase(tables: [WorkRecords, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;
}
```

- [ ] **Step 5: 구현체**

`lib/data/repository/drift_work_record_repository.dart`:
```dart
import 'package:drift/drift.dart';

import '../../domain/model/work_record.dart';
import '../../domain/repository/work_record_repository.dart';
import '../database/app_database.dart';

String dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime parseDateKey(String key) {
  final parts = key.split('-').map(int.parse).toList();
  return DateTime(parts[0], parts[1], parts[2]);
}

class DriftWorkRecordRepository implements WorkRecordRepository {
  DriftWorkRecordRepository(this._db);

  static const firstRecordDateKey = 'first_record_date';

  final AppDatabase _db;

  @override
  Stream<List<WorkRecord>> watchAll() =>
      _db.select(_db.workRecords).watch().map((rows) => rows.map(_toDomain).toList());

  @override
  Stream<DateTime?> watchFirstRecordDate() => (_db.select(_db.settings)
        ..where((s) => s.key.equals(firstRecordDateKey)))
      .watchSingleOrNull()
      .map((row) => row == null ? null : parseDateKey(row.value));

  @override
  Future<void> save(WorkRecord record) => _db.transaction(() async {
        await _db.into(_db.workRecords).insertOnConflictUpdate(_toCompanion(record));
        final first = await (_db.select(_db.settings)..where((s) => s.key.equals(firstRecordDateKey)))
            .getSingleOrNull();
        if (first == null) {
          await _db.into(_db.settings).insert(
                SettingsCompanion.insert(key: firstRecordDateKey, value: dateKey(record.date)),
              );
        }
      });

  @override
  Future<void> delete(DateTime date) =>
      (_db.delete(_db.workRecords)..where((t) => t.date.equals(dateKey(date)))).go();

  static WorkRecord _toDomain(WorkRecordRow row) => WorkRecord(
        date: parseDateKey(row.date),
        clockIn: row.clockIn,
        clockOut: row.clockOut,
        type: row.type,
      );

  static WorkRecordsCompanion _toCompanion(WorkRecord r) => WorkRecordsCompanion.insert(
        date: dateKey(r.date),
        clockIn: Value(r.clockIn),
        clockOut: Value(r.clockOut),
        type: r.type,
      );
}
```

- [ ] **Step 6: 코드젠 + 통과 확인**

Run: `dart run build_runner build --delete-conflicting-outputs && flutter test test/data/drift_work_record_repository_test.dart`
Expected: 모두 passed. (`insertOnConflictUpdate`가 `save`에서 upsert를 담당한다.)

- [ ] **Step 7: 커밋**

```bash
git add -A
git commit -m "Drift 데이터베이스와 WorkRecordRepository 구현

- date 문자열 PK, settings 테이블에 첫 기록일 저장
- 인메모리 DB로 왕복·upsert·첫 기록일 불변 테스트

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
```

---

### Task 7: 디버그 시드

**Files:**
- Create: `lib/data/seed/debug_seed.dart`
- Test: `test/data/debug_seed_test.dart`

**Interfaces:**
- Produces: `enum SeedScenario { empty, beforeWork, working, done, dayOff, holiday, firstWeek, withGaps }` (각각 `String get label`), `Future<void> applySeed(AppDatabase db, SeedScenario scenario, {required DateTime today})`

- [ ] **Step 1: 테스트 작성**

`test/data/debug_seed_test.dart`:
```dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/data/database/app_database.dart';
import 'package:soi_duty/data/repository/drift_work_record_repository.dart';
import 'package:soi_duty/data/seed/debug_seed.dart';
import 'package:soi_duty/domain/model/work_type.dart';
import 'package:soi_duty/domain/rules/work_calculator.dart';

import '../helpers/records.dart';

void main() {
  late AppDatabase db;
  late DriftWorkRecordRepository repo;

  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftWorkRecordRepository(db);
  });
  tearDown(() => db.close());

  final today = d(16); // 수요일

  test('empty는 기록과 첫 기록일을 모두 지운다', () async {
    await repo.save(rec(14, inH: 9));
    await applySeed(db, SeedScenario.empty, today: today);
    expect(await repo.watchAll().first, isEmpty);
    expect(await repo.watchFirstRecordDate().first, isNull);
  });

  test('working은 오늘 출근만 찍힌 기록을 만든다', () async {
    await applySeed(db, SeedScenario.working, today: today);
    final all = await repo.watchAll().first;
    final todayRec = all.singleWhere((r) => r.date == today);
    expect(todayRec.clockIn, isNotNull);
    expect(todayRec.clockOut, isNull);
  });

  test('done은 오늘 출퇴근이 모두 있다', () async {
    await applySeed(db, SeedScenario.done, today: today);
    final all = await repo.watchAll().first;
    final todayRec = all.singleWhere((r) => r.date == today);
    expect(todayRec.clockIn, isNotNull);
    expect(todayRec.clockOut, isNotNull);
  });

  test('dayOff / holiday는 오늘 유형만 있다', () async {
    await applySeed(db, SeedScenario.dayOff, today: today);
    var all = await repo.watchAll().first;
    expect(all.singleWhere((r) => r.date == today).type, WorkType.dayOff);
    await applySeed(db, SeedScenario.holiday, today: today);
    all = await repo.watchAll().first;
    expect(all.singleWhere((r) => r.date == today).type, WorkType.holiday);
  });

  test('firstWeek는 첫 기록일이 이번 주 월요일이 아니다', () async {
    await applySeed(db, SeedScenario.firstWeek, today: d(18));
    final first = await repo.watchFirstRecordDate().first;
    expect(isFirstWeekException(mondayOf(d(18)), first), isTrue);
  });

  test('withGaps는 이전 평일에 누락이 있다', () async {
    await applySeed(db, SeedScenario.withGaps, today: today);
    final all = await repo.watchAll().first;
    final first = await repo.watchFirstRecordDate().first;
    expect(unrecordedWeekdays(records: all, today: today, firstRecordDate: first), isNotEmpty);
  });

  test('시드를 다시 적용하면 이전 기록이 남지 않는다', () async {
    await applySeed(db, SeedScenario.withGaps, today: today);
    await applySeed(db, SeedScenario.beforeWork, today: today);
    final all = await repo.watchAll().first;
    expect(all.any((r) => r.date == today), isFalse);
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/data/debug_seed_test.dart`
Expected: 컴파일 에러

- [ ] **Step 3: 구현**

`lib/data/seed/debug_seed.dart`:
```dart
import '../../domain/model/work_record.dart';
import '../../domain/model/work_type.dart';
import '../../domain/rules/work_calculator.dart';
import '../database/app_database.dart';
import '../repository/drift_work_record_repository.dart';

/// 오늘 화면의 상태들을 손으로 만들지 않고 바로 확인하기 위한 시드.
/// 릴리즈 빌드에서는 호출 경로 자체가 없다 (kDebugMode 가드는 호출부 책임).
enum SeedScenario {
  empty('비우기'),
  beforeWork('출근 전'),
  working('근무 중'),
  done('퇴근 완료'),
  dayOff('연차'),
  holiday('공휴일'),
  firstWeek('첫 주 예외'),
  withGaps('기록 누락 있는 주');

  const SeedScenario(this.label);
  final String label;
}

/// 기존 기록과 첫 기록일을 전부 지우고 시나리오를 넣는다.
/// 기록은 이른 날짜부터 저장해 첫 기록일이 자연스럽게 잡히게 한다.
Future<void> applySeed(AppDatabase db, SeedScenario scenario, {required DateTime today}) async {
  await db.transaction(() async {
    await db.delete(db.workRecords).go();
    await db.delete(db.settings).go();
  });
  final repo = DriftWorkRecordRepository(db);
  final day = dateOnly(today);
  for (final r in _records(scenario, day)) {
    await repo.save(r);
  }
}

List<WorkRecord> _records(SeedScenario scenario, DateTime today) {
  final monday = mondayOf(today);
  final lastMonday = DateTime(monday.year, monday.month, monday.day - 7);

  WorkRecord full(DateTime date, {int inH = 9, int inM = 0, int outH = 18, int outM = 0}) => WorkRecord(
        date: date,
        clockIn: DateTime(date.year, date.month, date.day, inH, inM),
        clockOut: DateTime(date.year, date.month, date.day, outH, outM),
      );

  /// 지난 주 월~금 + 이번 주 오늘 이전 평일을 전부 채운다.
  List<WorkRecord> filledPast() => [
        for (final d in weekdaysOf(lastMonday)) full(d),
        for (final d in weekdaysOf(monday))
          if (d.isBefore(today)) full(d, outH: 18, outM: 20),
      ];

  switch (scenario) {
    case SeedScenario.empty:
      return const [];
    case SeedScenario.beforeWork:
      return filledPast();
    case SeedScenario.working:
      return [
        ...filledPast(),
        WorkRecord(date: today, clockIn: DateTime(today.year, today.month, today.day, 9, 12)),
      ];
    case SeedScenario.done:
      return [...filledPast(), full(today, inH: 9, inM: 12, outH: 18, outM: 5)];
    case SeedScenario.dayOff:
      return [...filledPast(), WorkRecord(date: today, type: WorkType.dayOff)];
    case SeedScenario.holiday:
      return [...filledPast(), WorkRecord(date: today, type: WorkType.holiday)];
    case SeedScenario.firstWeek:
      // 첫 기록일 = 이번 주 수요일. 오늘이 수요일 이전이면 오늘.
      final wednesday = DateTime(monday.year, monday.month, monday.day + 2);
      final first = wednesday.isAfter(today) ? today : wednesday;
      return [
        for (final d in weekdaysOf(monday))
          if (!d.isBefore(first) && d.isBefore(today)) full(d),
        WorkRecord(date: today, clockIn: DateTime(today.year, today.month, today.day, 9, 12)),
      ];
    case SeedScenario.withGaps:
      // 지난 주 수요일은 비우고, 금요일은 퇴근 누락.
      final wed = DateTime(lastMonday.year, lastMonday.month, lastMonday.day + 2);
      final fri = DateTime(lastMonday.year, lastMonday.month, lastMonday.day + 4);
      return [
        for (final d in weekdaysOf(lastMonday))
          if (d == fri)
            WorkRecord(date: d, clockIn: DateTime(d.year, d.month, d.day, 9))
          else if (d != wed)
            full(d),
        for (final d in weekdaysOf(monday))
          if (d.isBefore(today)) full(d),
        WorkRecord(date: today, clockIn: DateTime(today.year, today.month, today.day, 9, 12)),
      ];
  }
}
```

- [ ] **Step 4: 통과 확인**

Run: `flutter test test/data/debug_seed_test.dart`
Expected: 모두 passed

- [ ] **Step 5: 커밋**

```bash
git add -A
git commit -m "디버그 시드 시나리오

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
```

---

### Task 8: 프로바이더 · TodayState · buildTodayState

**Files:**
- Create: `lib/core/providers/database_providers.dart`, `lib/core/providers/clock_provider.dart`
- Create: `lib/presentation/today/today_state.dart`, `lib/presentation/today/today_state_builder.dart`
- Test: `test/presentation/today_state_builder_test.dart`

**Interfaces:**
- Produces:
  - 프로바이더: `appDatabaseProvider`(AppDatabase, keepAlive), `workRecordRepositoryProvider`(WorkRecordRepository, keepAlive), `workRulesProvider`(WorkRules, keepAlive), `allRecordsProvider`(Stream), `firstRecordDateProvider`(Stream), `clockProvider`(`Clock` = `DateTime Function()`, keepAlive), `nowProvider`(Stream<DateTime>, keepAlive)
  - `enum TodayPhase { before, working, done }`
  - `enum TodayScreenState { beforeWork, working, done, dayType }`
  - `TodayState` 필드: `date, record(WorkRecord?), phase, dayType(WorkType?), isHalfDay, clockIn, clockOut, elapsedMinutes(int?), expectedClockOut(DateTime?), todayActual(int?), todayDelta(int?), week(WeekSummary), unrecordedDays(List<DateTime>), firstRecordDate(DateTime?)`; getter `screenState`, `isWeekend`, `isFirstWeek`
  - `TodayState buildTodayState({required List<WorkRecord> records, required DateTime? firstRecordDate, required DateTime now, required WorkRules rules})`

- [ ] **Step 1: 테스트 작성**

`test/presentation/today_state_builder_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/domain/model/work_record.dart';
import 'package:soi_duty/domain/model/work_type.dart';
import 'package:soi_duty/domain/rules/work_rules.dart';
import 'package:soi_duty/presentation/today/today_state.dart';
import 'package:soi_duty/presentation/today/today_state_builder.dart';

import '../helpers/records.dart';

void main() {
  const rules = WorkRules();
  final past = [rec(14, inH: 9, outH: 18), rec(15, inH: 9, outH: 18)];

  TodayState build(List<WorkRecord> records, {DateTime? now, DateTime? first}) => buildTodayState(
        records: records,
        firstRecordDate: first ?? d(7),
        now: now ?? d(16, 12),
        rules: rules,
      );

  test('기록 없음 → 출근 전', () {
    final s = build(past);
    expect(s.date, d(16));
    expect(s.phase, TodayPhase.before);
    expect(s.screenState, TodayScreenState.beforeWork);
    expect(s.record, isNull);
    expect(s.expectedClockOut, isNull);
    expect(s.week.remainingMinutes, 2400 - 960);
  });

  test('출근만 → 근무 중, 경과·퇴근 예상 있음', () {
    final s = build([...past, rec(16, inH: 9, inM: 12)], now: d(16, 16, 27));
    expect(s.phase, TodayPhase.working);
    expect(s.screenState, TodayScreenState.working);
    expect(s.elapsedMinutes, 7 * 60 + 15);
    expect(s.expectedClockOut, d(16, 18, 12)); // 09:12 + 8h + 1h
    expect(s.week.workedMinutes, 960 + (7 * 60 + 15 - 60));
  });

  test('반차 근무 중 → isHalfDay, 퇴근 예상에 점심 없음', () {
    final s = build([...past, rec(16, inH: 9, inM: 12, type: WorkType.halfDay)]);
    expect(s.isHalfDay, isTrue);
    expect(s.expectedClockOut, d(16, 13, 12)); // 09:12 + 4h
  });

  test('출퇴근 모두 → 퇴근 완료, 오늘 실근무·기준 대비', () {
    final s = build([...past, rec(16, inH: 9, inM: 12, outH: 18, outM: 5)], now: d(16, 19));
    expect(s.phase, TodayPhase.done);
    expect(s.screenState, TodayScreenState.done);
    expect(s.todayActual, 8 * 60 + 53 - 60);
    expect(s.todayDelta, -7);
    expect(s.expectedClockOut, isNull);
  });

  test('연차 → dayType 화면', () {
    final s = build([...past, rec(16, type: WorkType.dayOff)]);
    expect(s.phase, TodayPhase.before);
    expect(s.dayType, WorkType.dayOff);
    expect(s.screenState, TodayScreenState.dayType);
    expect(s.week.targetMinutes, 2400 - 480);
  });

  test('첫 주 예외 → isFirstWeek, 목표·퇴근 예상 없음', () {
    final s = build([rec(16, inH: 9, inM: 12)], first: d(16));
    expect(s.isFirstWeek, isTrue);
    expect(s.week.targetMinutes, isNull);
    expect(s.expectedClockOut, isNull);
    expect(s.screenState, TodayScreenState.working);
  });

  test('기록 누락 리스트가 채워진다', () {
    final s = build([rec(14, inH: 9, outH: 18)], now: d(16, 12), first: d(14));
    expect(s.unrecordedDays, [d(15)]);
  });

  test('주말 → isWeekend, 퇴근 예상 없음', () {
    final s = build([rec(19, inH: 10)], now: d(19, 12));
    expect(s.isWeekend, isTrue);
    expect(s.phase, TodayPhase.working);
    expect(s.expectedClockOut, isNull);
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/presentation/today_state_builder_test.dart`
Expected: 컴파일 에러

- [ ] **Step 3: 프로바이더**

`lib/core/providers/database_providers.dart`:
```dart
import 'package:drift_flutter/drift_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/database/app_database.dart';
import '../../data/repository/drift_work_record_repository.dart';
import '../../domain/model/work_record.dart';
import '../../domain/repository/work_record_repository.dart';
import '../../domain/rules/work_rules.dart';

part 'database_providers.g.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase(driftDatabase(name: 'soi_duty'));
  ref.onDispose(db.close);
  return db;
}

@Riverpod(keepAlive: true)
WorkRecordRepository workRecordRepository(Ref ref) =>
    DriftWorkRecordRepository(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
WorkRules workRules(Ref ref) => const WorkRules();

@riverpod
Stream<List<WorkRecord>> allRecords(Ref ref) => ref.watch(workRecordRepositoryProvider).watchAll();

@riverpod
Stream<DateTime?> firstRecordDate(Ref ref) =>
    ref.watch(workRecordRepositoryProvider).watchFirstRecordDate();
```

`lib/core/providers/clock_provider.dart`:
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clock_provider.g.dart';

typedef Clock = DateTime Function();

/// 액션이 시각을 찍을 때 쓰는 시계. 테스트에서 고정값으로 오버라이드한다.
@Riverpod(keepAlive: true)
Clock clock(Ref ref) => DateTime.now;

/// 즉시 1회, 이후 매 분 정각에 방출. 자정 넘김·경과 시간·퇴근 예상 갱신은 전부 이걸로.
@Riverpod(keepAlive: true)
Stream<DateTime> now(Ref ref) async* {
  final clock = ref.watch(clockProvider);
  yield clock();
  while (true) {
    final t = clock();
    final nextMinute = DateTime(t.year, t.month, t.day, t.hour, t.minute + 1);
    await Future<void>.delayed(nextMinute.difference(t));
    yield clock();
  }
}
```

- [ ] **Step 4: TodayState**

`lib/presentation/today/today_state.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/model/work_record.dart';
import '../../domain/model/work_type.dart';
import '../../domain/rules/week_summary.dart';
import '../../domain/rules/work_calculator.dart' as calc;

part 'today_state.freezed.dart';

enum TodayPhase { before, working, done }

/// 화면 5상태 중 버튼·슬롯 구성을 결정하는 4가지. 첫 주 예외는 [TodayState.isFirstWeek]로 겹쳐 본다.
enum TodayScreenState { beforeWork, working, done, dayType }

@freezed
abstract class TodayState with _$TodayState {
  const TodayState._();

  const factory TodayState({
    required DateTime date,
    WorkRecord? record,
    required TodayPhase phase,
    WorkType? dayType,
    required bool isHalfDay,
    DateTime? clockIn,
    DateTime? clockOut,
    /// working일 때 now − clockIn (점심 미공제)
    int? elapsedMinutes,
    /// working일 때만. 첫 주 예외·주말이면 null
    DateTime? expectedClockOut,
    int? todayActual,
    int? todayDelta,
    required WeekSummary week,
    required List<DateTime> unrecordedDays,
    DateTime? firstRecordDate,
  }) = _TodayState;

  bool get isWeekend => calc.isWeekend(date);
  bool get isFirstWeek => week.isFirstWeekException;

  TodayScreenState get screenState => switch (phase) {
        TodayPhase.working => TodayScreenState.working,
        TodayPhase.done => TodayScreenState.done,
        TodayPhase.before => dayType == null ? TodayScreenState.beforeWork : TodayScreenState.dayType,
      };
}
```

- [ ] **Step 5: buildTodayState**

`lib/presentation/today/today_state_builder.dart`:
```dart
import '../../domain/model/work_record.dart';
import '../../domain/model/work_type.dart';
import '../../domain/rules/work_calculator.dart';
import '../../domain/rules/work_rules.dart';
import 'today_state.dart';

/// (기록 전체, 첫 기록일, 현재 시각, 규칙) → 오늘 화면 상태. 순수 함수.
TodayState buildTodayState({
  required List<WorkRecord> records,
  required DateTime? firstRecordDate,
  required DateTime now,
  required WorkRules rules,
}) {
  final today = dateOnly(now);
  final record = recordsByDate(records)[today];

  final phase = switch (record) {
    null => TodayPhase.before,
    WorkRecord(clockIn: null) => TodayPhase.before,
    WorkRecord(clockOut: null) => TodayPhase.working,
    _ => TodayPhase.done,
  };

  final type = record?.type ?? WorkType.normal;
  final dayType = (type == WorkType.dayOff || type == WorkType.holiday) ? type : null;

  final week = weekSummary(
    records: records,
    monday: mondayOf(today),
    rules: rules,
    now: now,
    firstRecordDate: firstRecordDate,
  );

  DateTime? expected;
  if (phase == TodayPhase.working && record != null) {
    final target = todayTargetMinutes(
      records: records,
      today: today,
      rules: rules,
      now: now,
      firstRecordDate: firstRecordDate,
    );
    if (target != null) expected = expectedClockOut(record, target, rules);
  }

  return TodayState(
    date: today,
    record: record,
    phase: phase,
    dayType: dayType,
    isHalfDay: type == WorkType.halfDay,
    clockIn: record?.clockIn,
    clockOut: record?.clockOut,
    elapsedMinutes: phase == TodayPhase.working ? now.difference(record!.clockIn!).inMinutes : null,
    expectedClockOut: expected,
    todayActual: phase == TodayPhase.done ? actualMinutes(record!, rules) : null,
    todayDelta: phase == TodayPhase.done ? deltaMinutes(record!, rules) : null,
    week: week,
    unrecordedDays: unrecordedWeekdays(records: records, today: today, firstRecordDate: firstRecordDate),
    firstRecordDate: firstRecordDate,
  );
}
```

- [ ] **Step 6: 코드젠 + 통과 확인**

Run: `dart run build_runner build --delete-conflicting-outputs && flutter test test/presentation/today_state_builder_test.dart && flutter analyze`
Expected: 모두 passed, No issues

- [ ] **Step 7: 커밋**

```bash
git add -A
git commit -m "프로바이더·TodayState·buildTodayState

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
```

---

### Task 9: TodayController

**Files:**
- Create: `lib/presentation/today/today_controller.dart`
- Test: `test/presentation/today_controller_test.dart`

**Interfaces:**
- Produces: `todayControllerProvider` (`AsyncValue<TodayState>`), notifier 메서드 `clockIn()`, `clockOut()`, `setHalfDay(bool)`, `setDayType(WorkType?)`, `revert()`

- [ ] **Step 1: 테스트 작성**

`test/presentation/today_controller_test.dart`:
```dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/core/providers/clock_provider.dart';
import 'package:soi_duty/core/providers/database_providers.dart';
import 'package:soi_duty/data/database/app_database.dart';
import 'package:soi_duty/domain/model/work_type.dart';
import 'package:soi_duty/presentation/today/today_controller.dart';
import 'package:soi_duty/presentation/today/today_state.dart';

import '../helpers/records.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  final now = d(16, 9, 12);

  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer.test(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(() => now),
        nowProvider.overrideWith((ref) => Stream.value(now)),
      ],
    );
    // autoDispose 프로바이더가 테스트 중 사라지지 않게 구독을 유지한다.
    container.listen(todayControllerProvider, (_, __) {});
  });

  tearDown(() => db.close());

  Future<TodayState> waitFor(bool Function(TodayState) test) async {
    for (var i = 0; i < 50; i++) {
      final s = await container.read(todayControllerProvider.future);
      if (test(s)) return s;
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    fail('상태가 기대대로 바뀌지 않음');
  }

  TodayController notifier() => container.read(todayControllerProvider.notifier);

  test('초기 상태는 출근 전', () async {
    final s = await container.read(todayControllerProvider.future);
    expect(s.phase, TodayPhase.before);
  });

  test('clockIn → 근무 중, 출근 시각은 clock 값', () async {
    await notifier().clockIn();
    final s = await waitFor((s) => s.phase == TodayPhase.working);
    expect(s.clockIn, now);
  });

  test('clockOut → 퇴근 완료', () async {
    await notifier().clockIn();
    await waitFor((s) => s.phase == TodayPhase.working);
    await notifier().clockOut();
    final s = await waitFor((s) => s.phase == TodayPhase.done);
    expect(s.clockOut, now);
  });

  test('setHalfDay는 출근 기록을 유지한 채 유형만 바꾼다', () async {
    await notifier().clockIn();
    await waitFor((s) => s.phase == TodayPhase.working);
    await notifier().setHalfDay(true);
    final s = await waitFor((s) => s.isHalfDay);
    expect(s.clockIn, now);
    await notifier().setHalfDay(false);
    await waitFor((s) => !s.isHalfDay);
  });

  test('setDayType(dayOff) → dayType 화면, revert → 출근 전', () async {
    await notifier().setDayType(WorkType.dayOff);
    await waitFor((s) => s.screenState == TodayScreenState.dayType);
    await notifier().revert();
    final s = await waitFor((s) => s.screenState == TodayScreenState.beforeWork);
    expect(s.record?.type, WorkType.normal);
  });

  test('첫 기록이 첫 기록일을 만든다', () async {
    await notifier().clockIn();
    final s = await waitFor((s) => s.firstRecordDate != null);
    expect(s.firstRecordDate, d(16));
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/presentation/today_controller_test.dart`
Expected: 컴파일 에러

- [ ] **Step 3: 구현**

`lib/presentation/today/today_controller.dart`:
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/clock_provider.dart';
import '../../core/providers/database_providers.dart';
import '../../domain/model/work_record.dart';
import '../../domain/model/work_type.dart';
import '../../domain/rules/work_calculator.dart';
import 'today_state.dart';
import 'today_state_builder.dart';

part 'today_controller.g.dart';

@riverpod
class TodayController extends _$TodayController {
  @override
  Future<TodayState> build() async {
    final records = await ref.watch(allRecordsProvider.future);
    final firstRecordDate = await ref.watch(firstRecordDateProvider.future);
    final now = await ref.watch(nowProvider.future);
    final rules = ref.watch(workRulesProvider);
    return buildTodayState(records: records, firstRecordDate: firstRecordDate, now: now, rules: rules);
  }

  Future<void> clockIn() => _saveToday((r, now) => r.copyWith(clockIn: now));

  Future<void> clockOut() => _saveToday((r, now) => r.copyWith(clockOut: now));

  Future<void> setHalfDay(bool on) =>
      _saveToday((r, _) => r.copyWith(type: on ? WorkType.halfDay : WorkType.normal));

  /// dayOff / holiday / null(→ normal). 출근 전 상태에서만 UI가 호출한다.
  Future<void> setDayType(WorkType? type) => _saveToday((r, _) => r.copyWith(type: type ?? WorkType.normal));

  Future<void> revert() => setDayType(null);

  Future<void> _saveToday(WorkRecord Function(WorkRecord record, DateTime now) update) async {
    final now = ref.read(clockProvider)();
    final current = await future;
    final base = current.record ?? WorkRecord(date: dateOnly(now));
    await ref.read(workRecordRepositoryProvider).save(update(base, now));
  }
}
```

- [ ] **Step 4: 코드젠 + 통과 확인**

Run: `dart run build_runner build --delete-conflicting-outputs && flutter test test/presentation/today_controller_test.dart`
Expected: 모두 passed. `ProviderContainer.test`가 없다는 에러가 나면 `ProviderContainer(overrides: ...)` + `addTearDown(container.dispose)`로 바꾼다.

- [ ] **Step 5: 커밋**

```bash
git add -A
git commit -m "TodayController: 출퇴근·반차·연차/공휴일 액션

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
```

---

### Task 10: 포맷 함수 · 화면 문구

**Files:**
- Create: `lib/core/presentation/format/time_format.dart`, `lib/core/presentation/format/date_format.dart`
- Create: `lib/presentation/today/today_texts.dart`
- Test: `test/core/format_test.dart`, `test/presentation/today_texts_test.dart`

**Interfaces:**
- Produces:
  - `String formatHm(int minutes)` → `"7h 22m"`, `"36h"`, `"22m"`, `"0m"`, 음수 `"−7m"`(U+2212)
  - `String formatSignedHm(int minutes)` → `"+10m"`, `"−7m"`, `"0m"`
  - `String formatClock(DateTime)` → `"09:12"`
  - `String formatDateTitle(DateTime)` → `"9월 11일 금요일"`, `String formatDateShort(DateTime)` → `"9월 4일 금"`
  - `TodayTexts` (static): `heroLabel(TodayState)`, `heroValue(TodayState)`, `heroReason(TodayState, WorkRules)`, `double? progress(TodayState)`, `statusMain(TodayState)`, `statusSub(TodayState)`, `buttonLabel(TodayState)`, `dayTypeMessage(WorkType)`, `unrecordedTitle(int)`, 상수 문구들

- [ ] **Step 1: 테스트 작성**

`test/core/format_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/core/presentation/format/date_format.dart';
import 'package:soi_duty/core/presentation/format/time_format.dart';

void main() {
  test('formatHm', () {
    expect(formatHm(442), '7h 22m');
    expect(formatHm(2160), '36h');
    expect(formatHm(22), '22m');
    expect(formatHm(0), '0m');
    expect(formatHm(-7), '−7m');
    expect(formatHm(-130), '−2h 10m');
  });

  test('formatSignedHm', () {
    expect(formatSignedHm(10), '+10m');
    expect(formatSignedHm(-7), '−7m');
    expect(formatSignedHm(0), '0m');
  });

  test('formatClock', () {
    expect(formatClock(DateTime(2026, 9, 11, 9, 5)), '09:05');
    expect(formatClock(DateTime(2026, 9, 11, 18, 30)), '18:30');
  });

  test('formatDateTitle / formatDateShort', () {
    expect(formatDateTitle(DateTime(2026, 9, 11)), '9월 11일 금요일');
    expect(formatDateShort(DateTime(2026, 9, 4)), '9월 4일 금');
    expect(formatDateShort(DateTime(2026, 9, 20)), '9월 20일 일');
  });
}
```

`test/presentation/today_texts_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/domain/model/work_type.dart';
import 'package:soi_duty/domain/rules/work_rules.dart';
import 'package:soi_duty/presentation/today/today_state_builder.dart';
import 'package:soi_duty/presentation/today/today_texts.dart';

import '../helpers/records.dart';

void main() {
  const rules = WorkRules();
  final past = [rec(14, inH: 9, outH: 18), rec(15, inH: 9, outH: 13, type: WorkType.halfDay)];

  test('히어로: 정상 주', () {
    final s = buildTodayState(records: past, firstRecordDate: d(7), now: d(16, 12), rules: rules);
    expect(TodayTexts.heroLabel(s), '이번 주 남은 시간');
    expect(TodayTexts.heroValue(s), '24h');
    expect(TodayTexts.heroReason(s, rules), '12h / 36h · 반차 1회');
    expect(TodayTexts.progress(s), closeTo(720 / 2160, 0.0001));
  });

  test('히어로: 연차 문구', () {
    final s = buildTodayState(
      records: [rec(14, inH: 9, outH: 18), rec(16, type: WorkType.dayOff)],
      firstRecordDate: d(7),
      now: d(16, 12),
      rules: rules,
    );
    expect(TodayTexts.heroReason(s, rules), '8h / 32h · 연차 1일로 목표 8h 차감');
  });

  test('히어로: 첫 주 예외', () {
    final s = buildTodayState(records: [rec(16, inH: 9)], firstRecordDate: d(16), now: d(16, 12), rules: rules);
    expect(TodayTexts.heroLabel(s), '이번 주 기록한 시간');
    expect(TodayTexts.heroReason(s, rules), '9월 16일 수요일부터 기록');
    expect(TodayTexts.progress(s), isNull);
  });

  test('상태 문구: 근무 중', () {
    final s = buildTodayState(
      records: [...past, rec(16, inH: 9, inM: 12)],
      firstRecordDate: d(7),
      now: d(16, 16, 27),
      rules: rules,
    );
    expect(TodayTexts.statusMain(s), '오늘 18:12에 퇴근하면 딱 맞아');
    expect(TodayTexts.statusSub(s), '09:12 출근 · 7h 15m째');
    expect(TodayTexts.buttonLabel(s), '퇴근하기');
  });

  test('상태 문구: 첫 주 근무 중', () {
    final s = buildTodayState(records: [rec(16, inH: 9, inM: 12)], firstRecordDate: d(16), now: d(16, 12), rules: rules);
    expect(TodayTexts.statusMain(s), '오늘 기록 중 · 이번 주는 목표 없이 실적만');
  });

  test('버튼 라벨', () {
    expect(TodayTexts.buttonLabel(buildTodayState(records: past, firstRecordDate: d(7), now: d(16, 8), rules: rules)), '출근하기');
    expect(
      TodayTexts.buttonLabel(buildTodayState(records: [rec(16, inH: 9, outH: 18)], firstRecordDate: d(7), now: d(16, 19), rules: rules)),
      '오늘 퇴근 완료',
    );
  });

  test('연차/공휴일 안내', () {
    expect(TodayTexts.dayTypeMessage(WorkType.dayOff), '오늘은 연차로 처리돼 있어요\n근무 기록은 남기지 않습니다');
    expect(TodayTexts.dayTypeMessage(WorkType.holiday), '오늘은 공휴일로 처리돼 있어요\n근무 기록은 남기지 않습니다');
  });

  test('기록 안 된 날 타이틀', () {
    expect(TodayTexts.unrecordedTitle(2), '기록 안 된 날 2개');
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/core/format_test.dart test/presentation/today_texts_test.dart`
Expected: 컴파일 에러

- [ ] **Step 3: 포맷 함수**

`lib/core/presentation/format/time_format.dart`:
```dart
const _minus = '−';

/// 442 → "7h 22m", 2160 → "36h", 22 → "22m", 0 → "0m", 음수는 "−" 접두.
String formatHm(int minutes) {
  final negative = minutes < 0;
  final abs = minutes.abs();
  final h = abs ~/ 60;
  final m = abs % 60;
  final body = h > 0 ? (m > 0 ? '${h}h ${m}m' : '${h}h') : '${m}m';
  return negative ? '$_minus$body' : body;
}

/// 기준 대비용. 양수는 "+", 음수는 "−", 0은 부호 없음.
String formatSignedHm(int minutes) {
  if (minutes > 0) return '+${formatHm(minutes)}';
  return formatHm(minutes);
}

String formatClock(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
```

`lib/core/presentation/format/date_format.dart`:
```dart
const _weekdayShort = ['월', '화', '수', '목', '금', '토', '일'];

String _weekday(DateTime d) => _weekdayShort[d.weekday - DateTime.monday];

/// "9월 11일 금요일"
String formatDateTitle(DateTime d) => '${d.month}월 ${d.day}일 ${_weekday(d)}요일';

/// "9월 4일 금"
String formatDateShort(DateTime d) => '${d.month}월 ${d.day}일 ${_weekday(d)}';
```

- [ ] **Step 4: 화면 문구**

`lib/presentation/today/today_texts.dart`:
```dart
import '../../core/presentation/format/date_format.dart';
import '../../core/presentation/format/time_format.dart';
import '../../domain/model/work_type.dart';
import '../../domain/rules/work_rules.dart';
import 'today_state.dart';

/// 오늘 화면의 모든 문구. 숫자(TodayState) → 문자열 조립은 여기서만 한다.
abstract final class TodayTexts {
  static const tabs = ['오늘', '주간', '월간'];
  static const beforeWork = '아직 출근 전';
  static const doneTitle = '오늘 기록 완료';
  static const halfDay = '오늘은 반차';
  static const dayOff = '오늘은 연차';
  static const holiday = '오늘은 공휴일';
  static const editTime = '시간 수정하기';
  static const revertPrefix = '기록하려면';
  static const revert = '되돌리기';
  static const record = '기록하기 →';
  static const firstWeekNotice =
      '첫 기록일이 월요일이 아니라 이번 주는 목표를 세우지 않아요. 기록한 시간만 그대로 보여드립니다. 다음 주부터 주 40시간 기준으로 계산돼요.';
  static const summaryLabels = ['출근', '퇴근', '근무', '기준 대비'];
  static const firstWeekWorking = '오늘 기록 중 · 이번 주는 목표 없이 실적만';

  static String heroLabel(TodayState s) => s.isFirstWeek ? '이번 주 기록한 시간' : '이번 주 남은 시간';

  static String heroValue(TodayState s) =>
      formatHm(s.isFirstWeek ? s.week.workedMinutes : (s.week.remainingMinutes ?? 0));

  static String heroReason(TodayState s, WorkRules rules) {
    if (s.isFirstWeek) {
      final first = s.firstRecordDate;
      return first == null ? '' : '${formatDateTitle(first)}부터 기록';
    }
    final w = s.week;
    final parts = ['${formatHm(w.workedMinutes)} / ${formatHm(w.targetMinutes ?? 0)}'];
    if (w.halfDayCount > 0) parts.add('반차 ${w.halfDayCount}회');
    if (w.dayOffCount > 0) {
      parts.add('연차 ${w.dayOffCount}일로 목표 ${formatHm(w.dayOffCount * rules.dayOffCreditMinutes)} 차감');
    }
    if (w.holidayCount > 0) {
      parts.add('공휴일 ${w.holidayCount}일로 목표 ${formatHm(w.holidayCount * rules.dayOffCreditMinutes)} 차감');
    }
    return parts.join(' · ');
  }

  /// 진행률 0..1. 첫 주 예외면 null (바를 그리지 않는다).
  static double? progress(TodayState s) {
    final target = s.week.targetMinutes;
    if (target == null || target == 0) return null;
    return (s.week.workedMinutes / target).clamp(0.0, 1.0);
  }

  static String statusMain(TodayState s) {
    if (s.isFirstWeek) return firstWeekWorking;
    final expected = s.expectedClockOut;
    return expected == null ? '' : '오늘 ${formatClock(expected)}에 퇴근하면 딱 맞아';
  }

  static String statusSub(TodayState s) {
    final clockIn = s.clockIn;
    final elapsed = s.elapsedMinutes;
    if (clockIn == null || elapsed == null) return '';
    return '${formatClock(clockIn)} 출근 · ${formatHm(elapsed)}째';
  }

  static String buttonLabel(TodayState s) => switch (s.screenState) {
        TodayScreenState.beforeWork || TodayScreenState.dayType => '출근하기',
        TodayScreenState.working => '퇴근하기',
        TodayScreenState.done => '오늘 퇴근 완료',
      };

  static String dayTypeMessage(WorkType type) {
    final name = type == WorkType.dayOff ? '연차' : '공휴일';
    return '오늘은 $name로 처리돼 있어요\n근무 기록은 남기지 않습니다';
  }

  static String badgeLabel(WorkType type) => type == WorkType.dayOff ? '연차' : '공휴일';

  static String unrecordedTitle(int count) => '기록 안 된 날 $count개';
}
```

- [ ] **Step 5: 통과 확인**

Run: `flutter test test/core/format_test.dart test/presentation/today_texts_test.dart`
Expected: 모두 passed

- [ ] **Step 6: 커밋**

```bash
git add -A
git commit -m "시간·날짜 포맷과 오늘 화면 문구

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
```

---

### Task 11: 소형 위젯 (탭 · 버튼 · 체크박스 · 배지 · 요약 행)

**Files:**
- Create: `lib/presentation/today/widgets/pill_tabs.dart`, `primary_button.dart`, `soi_checkbox.dart`, `type_badge.dart`, `summary_row.dart`
- Test: `test/presentation/widgets_test.dart`

**Interfaces:**
- Produces:
  - `PillTabs({required List<String> labels, required int selectedIndex, ValueChanged<int>? onSelected})`
  - `PrimaryButton({required String label, VoidCallback? onPressed})` — `onPressed == null`이면 비활성 스타일, 높이 `AppSizes.primaryButton`
  - `enum SoiCheckShape { square, round }`, `SoiCheckbox({required String label, required bool checked, required ValueChanged<bool> onChanged, required SoiCheckShape shape})`
  - `TypeBadge({required WorkType type})`
  - `SummaryRow({required List<String> labels, required List<String> values, Color? Function(int index)? valueColor})`

- [ ] **Step 1: 테스트 작성**

`test/presentation/widgets_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/core/presentation/size_config.dart';
import 'package:soi_duty/domain/model/work_type.dart';
import 'package:soi_duty/presentation/today/widgets/pill_tabs.dart';
import 'package:soi_duty/presentation/today/widgets/primary_button.dart';
import 'package:soi_duty/presentation/today/widgets/soi_checkbox.dart';
import 'package:soi_duty/presentation/today/widgets/summary_row.dart';
import 'package:soi_duty/presentation/today/widgets/type_badge.dart';
import 'package:soi_duty/ui/app_colors.dart';
import 'package:soi_duty/ui/app_sizes.dart';

Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  setUp(() => SizeConfig.init(402));

  testWidgets('PrimaryButton 높이 56, 비활성이면 탭 무반응', (tester) async {
    var taps = 0;
    await tester.pumpWidget(wrap(PrimaryButton(label: '출근하기', onPressed: () => taps++)));
    expect(tester.getSize(find.byType(PrimaryButton)).height, AppSizes.primaryButton);
    await tester.tap(find.text('출근하기'));
    expect(taps, 1);

    await tester.pumpWidget(wrap(const PrimaryButton(label: '오늘 퇴근 완료')));
    await tester.tap(find.text('오늘 퇴근 완료'));
    expect(taps, 1);
  });

  testWidgets('SoiCheckbox 탭하면 반전값 콜백, 히트 영역 44 이상', (tester) async {
    bool? received;
    await tester.pumpWidget(wrap(SoiCheckbox(
      label: '오늘은 반차',
      checked: false,
      onChanged: (v) => received = v,
      shape: SoiCheckShape.square,
    )));
    expect(tester.getSize(find.byType(SoiCheckbox)).height, greaterThanOrEqualTo(AppSizes.minTapHeight));
    await tester.tap(find.text('오늘은 반차'));
    expect(received, isTrue);
  });

  testWidgets('PillTabs 선택 콜백', (tester) async {
    int? selected;
    await tester.pumpWidget(wrap(PillTabs(labels: const ['오늘', '주간'], selectedIndex: 0, onSelected: (i) => selected = i)));
    await tester.tap(find.text('주간'));
    expect(selected, 1);
  });

  testWidgets('TypeBadge 라벨', (tester) async {
    await tester.pumpWidget(wrap(const TypeBadge(type: WorkType.holiday)));
    expect(find.text('공휴일'), findsOneWidget);
  });

  testWidgets('SummaryRow 4칸과 값 색', (tester) async {
    await tester.pumpWidget(wrap(SummaryRow(
      labels: const ['출근', '퇴근', '근무', '기준 대비'],
      values: const ['09:12', '18:05', '7h 53m', '−7m'],
      valueColor: (i) => i == 3 ? AppColors.minus : null,
    )));
    expect(find.text('−7m'), findsOneWidget);
    final text = tester.widget<Text>(find.text('−7m'));
    expect(text.style?.color, AppColors.minus);
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/presentation/widgets_test.dart`
Expected: 컴파일 에러

- [ ] **Step 3: PillTabs**

`lib/presentation/today/widgets/pill_tabs.dart`:
```dart
import 'package:flutter/material.dart';

import '../../../ui/app_colors.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';

class PillTabs extends StatelessWidget {
  const PillTabs({super.key, required this.labels, required this.selectedIndex, this.onSelected});

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int>? onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.tabPadding),
      decoration: BoxDecoration(
        color: AppColors.tabContainer,
        borderRadius: BorderRadius.circular(AppSizes.pill),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0) SizedBox(width: AppSizes.tabGap),
            Expanded(child: _Tab(label: labels[i], selected: i == selectedIndex, onTap: () => onSelected?.call(i))),
          ],
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppSizes.tabItemVPadding),
        alignment: Alignment.center,
        decoration: selected
            ? BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppSizes.pill),
                boxShadow: [
                  BoxShadow(color: AppColors.tabShadow, offset: AppSizes.shadowOffset, blurRadius: AppSizes.shadowBlur),
                ],
              )
            : null,
        child: Text(label, style: selected ? AppTextStyles.tabSelected : AppTextStyles.tabUnselected),
      ),
    );
  }
}
```

- [ ] **Step 4: PrimaryButton**

`lib/presentation/today/widgets/primary_button.dart`:
```dart
import 'package:flutter/material.dart';

import '../../../ui/app_colors.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';

/// 주 버튼. 높이 고정(AppSizes.primaryButton). onPressed가 null이면 비활성.
class PrimaryButton extends StatefulWidget {
  const PrimaryButton({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  var _pressed = false;

  bool get _enabled => widget.onPressed != null;

  void _setPressed(bool v) {
    if (_enabled && _pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final color = !_enabled
        ? AppColors.buttonDisabled
        : _pressed
            ? AppColors.brandPressed
            : AppColors.brand;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? AppScales.buttonPressed : 1,
        duration: AppDurations.buttonScale,
        child: AnimatedContainer(
          duration: AppDurations.buttonColor,
          height: AppSizes.primaryButton,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(AppSizes.buttonRadius)),
          child: Text(
            widget.label,
            style: _enabled ? AppTextStyles.primaryButton : AppTextStyles.primaryButtonDisabled,
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: SoiCheckbox**

`lib/presentation/today/widgets/soi_checkbox.dart`:
```dart
import 'package:flutter/material.dart';

import '../../../ui/app_colors.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';

enum SoiCheckShape { square, round }

/// 반차(square, 19) / 연차·공휴일(round, 18) 공용 체크. 행 전체가 탭 영역, 세로 44 확보.
class SoiCheckbox extends StatelessWidget {
  const SoiCheckbox({
    super.key,
    required this.label,
    required this.checked,
    required this.onChanged,
    required this.shape,
  });

  final String label;
  final bool checked;
  final ValueChanged<bool> onChanged;
  final SoiCheckShape shape;

  @override
  Widget build(BuildContext context) {
    final isSquare = shape == SoiCheckShape.square;
    final boxSize = isSquare ? AppSizes.checkboxSquare : AppSizes.checkboxRound;
    final boxRadius = isSquare ? AppSizes.checkboxSquareRadius : AppSizes.pill;
    final rowRadius = isSquare ? AppSizes.checkRowRadius : AppSizes.dayTypeRowRadius;
    final labelStyle = isSquare
        ? AppTextStyles.checkLabel(checked: checked)
        : AppTextStyles.dayTypeLabel(checked: checked);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!checked),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: AppSizes.minTapHeight),
        child: Center(
          child: AnimatedContainer(
            duration: AppDurations.checkbox,
            padding: AppSizes.checkRowPadding,
            decoration: BoxDecoration(
              color: checked ? AppColors.cardInner : Colors.transparent,
              borderRadius: BorderRadius.circular(rowRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: AppDurations.checkbox,
                  width: boxSize,
                  height: boxSize,
                  decoration: BoxDecoration(
                    color: checked ? AppColors.brand : AppColors.card,
                    borderRadius: BorderRadius.circular(boxRadius),
                    border: Border.all(
                      color: checked ? AppColors.brand : AppColors.checkboxBorder,
                      width: checked ? AppSizes.checkboxBorderOn : AppSizes.checkboxBorderOff,
                    ),
                  ),
                  child: checked ? Icon(Icons.check, size: AppSizes.checkboxIcon, color: AppColors.onBrand) : null,
                ),
                SizedBox(width: AppSizes.checkboxGap),
                Text(label, style: labelStyle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 6: TypeBadge · SummaryRow**

`lib/presentation/today/widgets/type_badge.dart`:
```dart
import 'package:flutter/material.dart';

import '../../../domain/model/work_type.dart';
import '../../../ui/app_colors.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';
import '../today_texts.dart';

class TypeBadge extends StatelessWidget {
  const TypeBadge({super.key, required this.type});

  final WorkType type;

  @override
  Widget build(BuildContext context) {
    final isDayOff = type == WorkType.dayOff;
    return Container(
      padding: AppSizes.badgePadding,
      decoration: BoxDecoration(
        color: isDayOff ? AppColors.dayOffBackground : AppColors.holidayBackground,
        borderRadius: BorderRadius.circular(AppSizes.pill),
        border: Border.all(
          color: isDayOff ? AppColors.dayOffBorder : AppColors.holidayBorder,
          width: AppSizes.badgeBorder,
        ),
      ),
      child: Text(
        TodayTexts.badgeLabel(type),
        style: AppTextStyles.badge.copyWith(color: isDayOff ? AppColors.dayOffText : AppColors.holidayText),
      ),
    );
  }
}
```

`lib/presentation/today/widgets/summary_row.dart`:
```dart
import 'package:flutter/material.dart';

import '../../../ui/app_colors.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';

/// 퇴근 완료 상태의 4칸 요약. 칸 사이 1px 구분선.
class SummaryRow extends StatelessWidget {
  const SummaryRow({super.key, required this.labels, required this.values, this.valueColor})
      : assert(labels.length == values.length);

  final List<String> labels;
  final List<String> values;
  final Color? Function(int index)? valueColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.summaryRadius),
      child: Container(
        color: AppColors.cardInner,
        child: IntrinsicHeight(
          child: Row(
            children: [
              for (var i = 0; i < labels.length; i++) ...[
                if (i > 0) Container(width: AppSizes.summaryDivider, color: AppColors.divider),
                Expanded(
                  child: Padding(
                    padding: AppSizes.summaryCellPadding,
                    child: Column(
                      children: [
                        Text(labels[i], style: AppTextStyles.summaryLabel),
                        SizedBox(height: AppSizes.summaryValueTop),
                        Text(
                          values[i],
                          style: AppTextStyles.summaryValue.copyWith(color: valueColor?.call(i)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 7: 통과 확인 + 커밋**

Run: `flutter test test/presentation/widgets_test.dart && flutter analyze`
Expected: 모두 passed, No issues

```bash
git add -A
git commit -m "오늘 화면 소형 위젯: 알약 탭·주 버튼·체크박스·배지·요약 행

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
```

---

### Task 12: 카드 위젯 (히어로 · 상태 카드 · 첫 주 안내 · 기록 안 된 날)

**Files:**
- Create: `lib/presentation/today/widgets/hero_card.dart`, `status_block.dart`, `status_card.dart`, `first_week_card.dart`, `unrecorded_card.dart`
- Create: `lib/presentation/today/today_view.dart`
- Test: `test/presentation/today_view_test.dart`

**Interfaces:**
- Produces:
  - `HeroCard({required TodayState state, required WorkRules rules})`
  - `StatusBlock({required TodayState state})` — `SizedBox(height: AppSizes.statusBlock)`
  - `StatusCard({required TodayState state, required TodayCallbacks callbacks})`
  - `FirstWeekCard()`
  - `UnrecordedCard({required List<DateTime> days, required ValueChanged<DateTime> onTap})`
  - `class TodayCallbacks { onClockIn, onClockOut, onHalfDayChanged(bool), onDayTypeChanged(WorkType?), onRevert, onEditTime, onUnrecordedTap(DateTime), onDateLongPress(VoidCallback?) }` (모두 `required` VoidCallback/ValueChanged, `onDateLongPress`만 nullable)
  - `TodayView({required TodayState state, required WorkRules rules, required TodayCallbacks callbacks})` — 화면 전체(탭·날짜·본문), 프로바이더 의존 없음

- [ ] **Step 1: 테스트 작성 — 버튼 Y 불변**

`test/presentation/today_view_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/core/presentation/size_config.dart';
import 'package:soi_duty/domain/model/work_record.dart';
import 'package:soi_duty/domain/model/work_type.dart';
import 'package:soi_duty/domain/rules/work_rules.dart';
import 'package:soi_duty/presentation/today/today_state.dart';
import 'package:soi_duty/presentation/today/today_state_builder.dart';
import 'package:soi_duty/presentation/today/today_view.dart';
import 'package:soi_duty/presentation/today/widgets/first_week_card.dart';
import 'package:soi_duty/presentation/today/widgets/primary_button.dart';
import 'package:soi_duty/presentation/today/widgets/unrecorded_card.dart';
import 'package:soi_duty/ui/app_theme.dart';

import '../helpers/records.dart';

const rules = WorkRules();

TodayCallbacks noop() => TodayCallbacks(
      onClockIn: () {},
      onClockOut: () {},
      onHalfDayChanged: (_) {},
      onDayTypeChanged: (_) {},
      onRevert: () {},
      onEditTime: () {},
      onUnrecordedTap: (_) {},
      onDateLongPress: null,
    );

TodayState stateOf(List<WorkRecord> records, {DateTime? now, DateTime? first}) =>
    buildTodayState(records: records, firstRecordDate: first ?? d(7), now: now ?? d(16, 12), rules: rules);

Future<void> pumpView(WidgetTester tester, TodayState state) async {
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.light,
    home: TodayView(state: state, rules: rules, callbacks: noop()),
  ));
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  final past = [rec(14, inH: 9, outH: 18), rec(15, inH: 9, outH: 18)];

  setUp(() {
    SizeConfig.init(402);
  });

  final fixtures = <String, TodayState>{
    '출근 전': stateOf(past),
    '근무 중': stateOf([...past, rec(16, inH: 9, inM: 12)]),
    '퇴근 완료': stateOf([...past, rec(16, inH: 9, inM: 12, outH: 18, outM: 5)], now: d(16, 19)),
    '연차': stateOf([...past, rec(16, type: WorkType.dayOff)]),
    '첫 주 예외': stateOf([rec(16, inH: 9, inM: 12)], first: d(16)),
  };

  testWidgets('다섯 상태에서 주 버튼의 Y 좌표가 같다', (tester) async {
    tester.view.physicalSize = const Size(402 * 3, 874 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final ys = <String, double>{};
    for (final entry in fixtures.entries) {
      await pumpView(tester, entry.value);
      ys[entry.key] = tester.getTopLeft(find.byType(PrimaryButton)).dy;
    }
    final distinct = ys.values.toSet();
    expect(distinct.length, 1, reason: '버튼 Y가 상태마다 다름: $ys');
  });

  testWidgets('기록 누락이 없으면 카드가 없고, 있으면 있다', (tester) async {
    await pumpView(tester, stateOf(past));
    expect(find.byType(UnrecordedCard), findsNothing);

    await pumpView(tester, stateOf([rec(14, inH: 9, outH: 18)], first: d(14)));
    expect(find.byType(UnrecordedCard), findsOneWidget);
    expect(find.text('기록 안 된 날 1개'), findsOneWidget);
  });

  testWidgets('첫 주 예외에서만 안내 카드', (tester) async {
    await pumpView(tester, stateOf(past));
    expect(find.byType(FirstWeekCard), findsNothing);
    await pumpView(tester, fixtures['첫 주 예외']!);
    expect(find.byType(FirstWeekCard), findsOneWidget);
  });

  testWidgets('상태별 버튼 라벨과 보조 슬롯', (tester) async {
    await pumpView(tester, fixtures['출근 전']!);
    expect(find.text('출근하기'), findsOneWidget);
    expect(find.text('오늘은 연차'), findsOneWidget);
    expect(find.text('오늘은 공휴일'), findsOneWidget);

    await pumpView(tester, fixtures['근무 중']!);
    expect(find.text('퇴근하기'), findsOneWidget);
    expect(find.text('오늘은 반차'), findsOneWidget);

    await pumpView(tester, fixtures['퇴근 완료']!);
    expect(find.text('오늘 퇴근 완료'), findsOneWidget);
    expect(find.text('시간 수정하기'), findsOneWidget);

    await pumpView(tester, fixtures['연차']!);
    expect(find.text('되돌리기'), findsOneWidget);
    expect(find.text('연차'), findsOneWidget);
  });

  testWidgets('콜백 연결: 출근하기 탭', (tester) async {
    var clockedIn = false;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: TodayView(
        state: fixtures['출근 전']!,
        rules: rules,
        callbacks: TodayCallbacks(
          onClockIn: () => clockedIn = true,
          onClockOut: () {},
          onHalfDayChanged: (_) {},
          onDayTypeChanged: (_) {},
          onRevert: () {},
          onEditTime: () {},
          onUnrecordedTap: (_) {},
          onDateLongPress: null,
        ),
      ),
    ));
    await tester.tap(find.text('출근하기'));
    expect(clockedIn, isTrue);
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/presentation/today_view_test.dart`
Expected: 컴파일 에러

- [ ] **Step 3: HeroCard**

`lib/presentation/today/widgets/hero_card.dart`:
```dart
import 'package:flutter/material.dart';

import '../../../domain/rules/work_rules.dart';
import '../../../ui/app_colors.dart';
import '../../../ui/app_decorations.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';
import '../today_state.dart';
import '../today_texts.dart';

class HeroCard extends StatelessWidget {
  const HeroCard({super.key, required this.state, required this.rules});

  final TodayState state;
  final WorkRules rules;

  @override
  Widget build(BuildContext context) {
    final progress = TodayTexts.progress(state);
    return Container(
      width: double.infinity,
      padding: AppSizes.heroPadding,
      decoration: AppDecorations.card,
      child: Column(
        children: [
          Text(TodayTexts.heroLabel(state), style: AppTextStyles.label, textAlign: TextAlign.center),
          SizedBox(height: AppSizes.heroValueTop),
          Text(TodayTexts.heroValue(state), style: AppTextStyles.heroValue, textAlign: TextAlign.center),
          SizedBox(height: AppSizes.heroReasonTop),
          Text(TodayTexts.heroReason(state, rules), style: AppTextStyles.reason, textAlign: TextAlign.center),
          SizedBox(height: AppSizes.progressBarTop),
          // 첫 주 예외에서는 바를 그리지 않지만 같은 높이를 유지한다 — 아래 버튼이 움직이지 않도록.
          SizedBox(
            height: AppSizes.progressBar,
            child: progress == null ? null : _ProgressBar(value: progress),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.pill),
      child: Stack(
        children: [
          Container(color: AppColors.divider),
          AnimatedFractionallySizedBox(
            duration: AppDurations.progressBar,
            curve: Curves.ease,
            alignment: Alignment.centerLeft,
            widthFactor: value,
            child: Container(
              decoration: BoxDecoration(color: AppColors.brand, borderRadius: BorderRadius.circular(AppSizes.pill)),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: StatusBlock**

`lib/presentation/today/widgets/status_block.dart`:
```dart
import 'package:flutter/material.dart';

import '../../../core/presentation/format/time_format.dart';
import '../../../ui/app_colors.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';
import '../today_state.dart';
import '../today_texts.dart';
import 'summary_row.dart';
import 'type_badge.dart';

/// 상태 카드 상단 블록. 높이 104 고정, 내용만 상태별로 바뀐다.
class StatusBlock extends StatelessWidget {
  const StatusBlock({super.key, required this.state});

  final TodayState state;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.statusBlock,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _children(),
      ),
    );
  }

  List<Widget> _children() {
    final gap = SizedBox(height: AppSizes.statusBlockGap);
    switch (state.screenState) {
      case TodayScreenState.beforeWork:
        return [_DotLine(active: false, text: TodayTexts.beforeWork, style: AppTextStyles.body)];
      case TodayScreenState.working:
        final main = TodayTexts.statusMain(state);
        return [
          if (main.isNotEmpty) ...[
            Text(main, style: AppTextStyles.statusMain, textAlign: TextAlign.center),
            gap,
          ],
          _DotLine(active: true, text: TodayTexts.statusSub(state), style: AppTextStyles.caption),
        ];
      case TodayScreenState.done:
        final delta = state.todayDelta;
        return [
          Text(TodayTexts.doneTitle, style: AppTextStyles.reason, textAlign: TextAlign.center),
          gap,
          SummaryRow(
            labels: TodayTexts.summaryLabels,
            values: [
              state.clockIn == null ? '' : formatClock(state.clockIn!),
              state.clockOut == null ? '' : formatClock(state.clockOut!),
              state.todayActual == null ? '' : formatHm(state.todayActual!),
              delta == null ? '—' : formatSignedHm(delta),
            ],
            valueColor: (i) => i != 3 || delta == null
                ? null
                : delta < 0
                    ? AppColors.minus
                    : delta > 0
                        ? AppColors.brand
                        : AppColors.subtle,
          ),
        ];
      case TodayScreenState.dayType:
        final type = state.dayType!;
        return [
          TypeBadge(type: type),
          gap,
          Text(TodayTexts.dayTypeMessage(type), style: AppTextStyles.bodyParagraph, textAlign: TextAlign.center),
        ];
    }
  }
}

class _DotLine extends StatelessWidget {
  const _DotLine({required this.active, required this.text, required this.style});

  final bool active;
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppSizes.dot,
          height: AppSizes.dot,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? AppColors.brand : AppColors.dotInactive,
            boxShadow: active ? [BoxShadow(color: AppColors.dotGlow, spreadRadius: AppSizes.dotGlow)] : null,
          ),
        ),
        SizedBox(width: AppSizes.dotGap),
        Text(text, style: style),
      ],
    );
  }
}
```

- [ ] **Step 5: StatusCard + TodayCallbacks**

`lib/presentation/today/widgets/status_card.dart`:
```dart
import 'package:flutter/material.dart';

import '../../../domain/model/work_type.dart';
import '../../../ui/app_decorations.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';
import '../today_state.dart';
import '../today_texts.dart';
import 'primary_button.dart';
import 'soi_checkbox.dart';
import 'status_block.dart';

/// 화면이 컨트롤러에 넘기는 콜백 묶음. TodayView는 프로바이더를 모른다.
class TodayCallbacks {
  const TodayCallbacks({
    required this.onClockIn,
    required this.onClockOut,
    required this.onHalfDayChanged,
    required this.onDayTypeChanged,
    required this.onRevert,
    required this.onEditTime,
    required this.onUnrecordedTap,
    required this.onDateLongPress,
  });

  final VoidCallback onClockIn;
  final VoidCallback onClockOut;
  final ValueChanged<bool> onHalfDayChanged;
  final ValueChanged<WorkType?> onDayTypeChanged;
  final VoidCallback onRevert;
  final VoidCallback onEditTime;
  final ValueChanged<DateTime> onUnrecordedTap;
  /// 디버그 시드 트리거. 릴리즈에서는 null.
  final VoidCallback? onDateLongPress;
}

/// 상태 블록(104) + 주 버튼(56) + 보조 슬롯(38, 위 12). 다섯 상태에서 높이가 같다.
class StatusCard extends StatelessWidget {
  const StatusCard({super.key, required this.state, required this.callbacks});

  final TodayState state;
  final TodayCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSizes.statusCardPadding,
      decoration: AppDecorations.card,
      child: Column(
        children: [
          StatusBlock(state: state),
          PrimaryButton(label: TodayTexts.buttonLabel(state), onPressed: _primaryAction),
          SizedBox(height: AppSizes.secondarySlotGap),
          SizedBox(
            height: AppSizes.secondarySlot,
            child: OverflowBox(
              // 체크박스 히트 영역(44)이 슬롯(38)보다 커도 레이아웃 높이는 38로 유지한다.
              maxHeight: AppSizes.minTapHeight,
              child: Center(child: _secondary()),
            ),
          ),
        ],
      ),
    );
  }

  VoidCallback? get _primaryAction => switch (state.screenState) {
        TodayScreenState.beforeWork => callbacks.onClockIn,
        TodayScreenState.working => callbacks.onClockOut,
        TodayScreenState.done || TodayScreenState.dayType => null,
      };

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
        if (state.isWeekend) return const SizedBox.shrink();
        return SoiCheckbox(
          label: TodayTexts.halfDay,
          checked: state.isHalfDay,
          onChanged: callbacks.onHalfDayChanged,
          shape: SoiCheckShape.square,
        );
      case TodayScreenState.done:
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: callbacks.onEditTime,
          child: Text(TodayTexts.editTime, style: AppTextStyles.link),
        );
      case TodayScreenState.dayType:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(TodayTexts.revertPrefix, style: AppTextStyles.caption),
            SizedBox(width: AppSizes.linkGap),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: callbacks.onRevert,
              child: Text(TodayTexts.revert, style: AppTextStyles.linkBrand),
            ),
          ],
        );
    }
  }
}
```

- [ ] **Step 6: FirstWeekCard · UnrecordedCard**

`lib/presentation/today/widgets/first_week_card.dart`:
```dart
import 'package:flutter/material.dart';

import '../../../ui/app_decorations.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';
import '../today_texts.dart';

class FirstWeekCard extends StatelessWidget {
  const FirstWeekCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSizes.firstWeekCardPadding,
      decoration: AppDecorations.card,
      child: Text(TodayTexts.firstWeekNotice, style: AppTextStyles.captionParagraph),
    );
  }
}
```

`lib/presentation/today/widgets/unrecorded_card.dart`:
```dart
import 'package:flutter/material.dart';

import '../../../core/presentation/format/date_format.dart';
import '../../../ui/app_colors.dart';
import '../../../ui/app_decorations.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';
import '../today_texts.dart';

/// 기록 안 된 날 리스트. 0개면 호출부가 아예 그리지 않는다.
class UnrecordedCard extends StatelessWidget {
  const UnrecordedCard({super.key, required this.days, required this.onTap});

  final List<DateTime> days;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSizes.unrecordedCardPadding,
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: AppSizes.unrecordedTitlePadding,
            child: Text(TodayTexts.unrecordedTitle(days.length), style: AppTextStyles.captionMedium),
          ),
          for (var i = 0; i < days.length; i++) ...[
            if (i > 0) SizedBox(height: AppSizes.unrecordedRowGap),
            _Row(day: days[i], onTap: () => onTap(days[i])),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatefulWidget {
  const _Row({required this.day, required this.onTap});

  final DateTime day;
  final VoidCallback onTap;

  @override
  State<_Row> createState() => _RowState();
}

class _RowState extends State<_Row> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: AppDurations.checkbox,
        padding: AppSizes.unrecordedRowPadding,
        decoration: BoxDecoration(
          color: _pressed ? AppColors.listRowPressed : AppColors.listRow,
          borderRadius: BorderRadius.circular(AppSizes.unrecordedRowRadius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(formatDateShort(widget.day), style: AppTextStyles.bodyInk),
            Text(TodayTexts.record, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 7: TodayView**

`lib/presentation/today/today_view.dart`:
```dart
import 'package:flutter/material.dart';

import '../../core/presentation/format/date_format.dart';
import '../../domain/rules/work_rules.dart';
import '../../ui/app_colors.dart';
import '../../ui/app_sizes.dart';
import '../../ui/app_text_styles.dart';
import 'today_state.dart';
import 'today_texts.dart';
import 'widgets/first_week_card.dart';
import 'widgets/hero_card.dart';
import 'widgets/pill_tabs.dart';
import 'widgets/status_card.dart';
import 'widgets/unrecorded_card.dart';

export 'widgets/status_card.dart' show TodayCallbacks;

/// 오늘 화면의 순수 UI. 상태와 콜백만 받고 프로바이더를 모른다.
class TodayView extends StatelessWidget {
  const TodayView({super.key, required this.state, required this.rules, required this.callbacks});

  final TodayState state;
  final WorkRules rules;
  final TodayCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(AppSizes.screenHPadding, AppSizes.topInset, AppSizes.screenHPadding, 0),
              child: PillTabs(labels: TodayTexts.tabs, selectedIndex: 0),
            ),
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
        ),
      ),
    );
  }
}
```

- [ ] **Step 8: 통과 확인**

Run: `flutter test test/presentation/today_view_test.dart && flutter analyze`
Expected: 모두 passed, No issues. 버튼 Y 테스트가 실패하면 `reason`에 찍힌 상태별 Y를 보고 **높이가 달라진 슬롯을 고친다** — 버튼을 옮기거나 테스트를 느슨하게 만들지 않는다.

- [ ] **Step 9: 커밋**

```bash
git add -A
git commit -m "오늘 화면 카드 위젯과 TodayView

- 상태 블록 104·버튼 56·보조 슬롯 38 고정, 다섯 상태 버튼 Y 불변 테스트
- SafeArea 상단 + 하단 인셋 스크롤 패딩

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
```

---

### Task 13: TodayScreen · 라우터 · 디버그 시드 피커 · 부팅 테스트

**Files:**
- Create: `lib/presentation/today/today_screen.dart`, `lib/presentation/debug/seed_picker_sheet.dart`
- Modify: `lib/core/routing/router.dart`, `test/widget_test.dart`

**Interfaces:**
- Produces: `TodayScreen()` (ConsumerWidget), `Future<void> showSeedPicker(BuildContext context, WidgetRef ref)`

- [ ] **Step 1: 부팅 테스트 수정**

`test/widget_test.dart` 전체 교체:
```dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soi_duty/core/providers/database_providers.dart';
import 'package:soi_duty/data/database/app_database.dart';
import 'package:soi_duty/main.dart';
import 'package:soi_duty/presentation/today/today_screen.dart';
import 'package:soi_duty/presentation/today/widgets/primary_button.dart';

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  testWidgets('앱이 부팅되고 오늘 화면이 뜬다', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: const SoiDutyApp(),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(TodayScreen), findsOneWidget);
    expect(find.byType(PrimaryButton), findsOneWidget);
    expect(find.text('출근하기'), findsOneWidget);
  });

  testWidgets('출근하기를 누르면 퇴근하기로 바뀐다', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: const SoiDutyApp(),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('출근하기'));
    await tester.pumpAndSettle();
    expect(find.text('퇴근하기'), findsOneWidget);
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/widget_test.dart`
Expected: 컴파일 에러 (TodayScreen 없음)

- [ ] **Step 3: 시드 피커**

`lib/presentation/debug/seed_picker_sheet.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/clock_provider.dart';
import '../../core/providers/database_providers.dart';
import '../../data/seed/debug_seed.dart';

/// 디버그 전용. 날짜 헤더 길게 누르면 열린다. 스타일은 기본 Material — 릴리즈에 안 들어간다.
Future<void> showSeedPicker(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          for (final s in SeedScenario.values)
            ListTile(
              title: Text(s.label),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                final db = ref.read(appDatabaseProvider);
                final today = ref.read(clockProvider)();
                await applySeed(db, s, today: today);
              },
            ),
        ],
      ),
    ),
  );
}
```

- [ ] **Step 4: TodayScreen**

`lib/presentation/today/today_screen.dart`:
```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/database_providers.dart';
import '../../ui/app_colors.dart';
import '../../ui/app_text_styles.dart';
import '../debug/seed_picker_sheet.dart';
import 'today_controller.dart';
import 'today_view.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rules = ref.watch(workRulesProvider);
    final controller = ref.read(todayControllerProvider.notifier);
    final async = ref.watch(todayControllerProvider);

    return async.when(
      // Drift는 로컬이라 첫 프레임 직후 바로 도착한다. 배경색만 보여준다.
      loading: () => const Scaffold(backgroundColor: AppColors.screenBackground),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.screenBackground,
        body: Center(child: Text('$e', style: AppTextStyles.caption)),
      ),
      data: (state) => TodayView(
        state: state,
        rules: rules,
        callbacks: TodayCallbacks(
          onClockIn: controller.clockIn,
          onClockOut: controller.clockOut,
          onHalfDayChanged: controller.setHalfDay,
          onDayTypeChanged: controller.setDayType,
          onRevert: controller.revert,
          // TODO: 기록 입력 시트 (다음 라운드)
          onEditTime: () {},
          onUnrecordedTap: (_) {},
          onDateLongPress: kDebugMode ? () => showSeedPicker(context, ref) : null,
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: 라우터 연결**

`lib/core/routing/router.dart` 전체 교체:
```dart
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../presentation/today/today_screen.dart';
import 'route_paths.dart';

part 'router.g.dart';

@riverpod
GoRouter router(Ref ref) {
  return GoRouter(
    initialLocation: RoutePaths.today,
    routes: [
      GoRoute(
        path: RoutePaths.today,
        builder: (context, state) => const TodayScreen(),
      ),
    ],
  );
}
```

- [ ] **Step 6: 코드젠 + 전체 검증**

Run: `dart run build_runner build --delete-conflicting-outputs && flutter analyze && flutter test`
Expected: No issues, 전체 통과. `ref.read(...notifier)`에 대한 riverpod_lint 경고가 나오면 `ref.watch(todayControllerProvider.notifier)`로 바꾼다.

- [ ] **Step 7: 시뮬레이터에서 실제 확인**

```bash
xcrun simctl list devices available | grep -i iphone | head -3
flutter run -d "iPhone 16 Pro" 2>&1 | head -40 &
```
앱이 뜨면: 출근하기 → 퇴근하기로 바뀌는지, 날짜 길게 눌러 시드 피커가 뜨고 시나리오마다 버튼이 같은 자리에 있는지 눈으로 확인. 스크린샷 저장:
```bash
xcrun simctl io booted screenshot /private/tmp/claude-501/-Users-seoyun-development-soi-duty/7f6404d5-4adb-4212-86a8-7d0036159b95/scratchpad/today.png
```
스크린샷을 Read로 열어 폰트(Pretendard 적용 여부), 상단 SafeArea, 카드 배치를 확인한다. 문제가 있으면 여기서 고친다.

- [ ] **Step 8: 커밋**

```bash
git add -A
git commit -m "오늘 화면 연결: TodayScreen·라우터·디버그 시드 피커

Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>"
```

---

## 자체 점검 결과

- 스펙 §1 도메인 → Task 2–5. §1.4 리포지토리 → Task 6. §2 데이터·시드 → Task 6–7. §3.1 프로바이더 → Task 8. §3.2 컨트롤러 → Task 9. §3.3 TodayState → Task 8. §3.4 위젯·SafeArea·애니메이션 → Task 11–12. §3.5 토큰, §3.6 SizeConfig, §3.7 에셋 → Task 1. §3.8 포맷 → Task 10. §4 테스트 → 각 태스크. §6 확정 규칙 4건 → Task 5(퇴근 예상), Task 4(진행분), Task 6(첫 기록일 저장), Task 12(출근 전 안내 없음).
- 시그니처 일치: `heroReason(TodayState, WorkRules)` — Task 10 정의, Task 12 `HeroCard`가 `heroReason(state, rules)`로 호출. 규칙 상수(8h 차감량)는 `rules.dayOffCreditMinutes`에서만 온다.
- 범위 밖: 기록 입력 시트·주간/월간 탭·스플래시·앱 아이콘. `onEditTime`, `onUnrecordedTap`, 탭 1·2는 무반응.

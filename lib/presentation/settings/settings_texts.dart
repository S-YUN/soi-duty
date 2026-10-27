import '../../core/presentation/format/number_format.dart';
import '../../domain/model/app_settings.dart';
import '../../domain/model/leave_balance.dart';
import '../../domain/rules/work_rules.dart';

/// 설정 화면과 숫자 입력 시트의 모든 문구.
abstract final class SettingsTexts {
  static const title = '설정';
  static const back = '뒤로';

  static const sectionCalendar = '캘린더';
  static const weekStartLabel = '시작 요일';
  static String weekStartOption(WeekStart w) => switch (w) { WeekStart.monday => '월', WeekStart.sunday => '일' };
  static const weekStartNote = '주간 탭과 주 40시간 계산은 월~일 그대로예요';
  static String weekStartChanged(WeekStart w) =>
      switch (w) { WeekStart.monday => '월간 캘린더가 월요일부터 시작해요', WeekStart.sunday => '월간 캘린더가 일요일부터 시작해요' };

  static const sectionLeave = '연차';
  // 남은 연차 + 기준일 (2026-10-27, 브리프 5)
  static const annualLabel = '남은 연차';
  static const annualSub = '알려주시면 월간 탭에서 잔여 연차를 볼 수 있어요';
  static const annualUnit = '일';
  /// 값이 있을 때 행 보조 설명 — 다시 넣을 때 헷갈리지 않게 기준일을 보인다.
  static String annualBaseLine(DateTime d) => '${d.month}월 ${d.day}일 기준';
  /// 시트 제목 아래 한 줄
  static String annualHeadline(DateTime today) => '오늘(${today.month}월 ${today.day}일) 기준 남은 연차';
  static const annualNotes = [
    '회사에서 보여주는 지금 남은 연차를 그대로 넣어주세요.',
    '오늘이 기준일이 되고, 내일부터 찍는 연차를 빼서 보여드려요.',
    '신청해 둔 연차도 아직 안 쓴 것으로 쳐서 넣어주세요.',
  ];
  /// 그 해에 오늘보다 뒤인 연차·반차가 찍혀 있을 때만 — 회사 숫자에 이미 빠져 있을 수 있어 사용자가 맞추게.
  static String annualFutureNote(int minutes, int dayMinutes) => '이 뒤로 찍어둔 연차 ${formatLeaveDays(minutes, dayMinutes)}은 여기서 빼서 보여드려요.';
  /// 빈 입력줄 "0" 옆 — 저장 가능한 0과 구분
  static const annualEmptyCaption = '입력 전';
  static String annualInvalidNote(WorkRules rules) => '${formatLeaveDays(rules.leaveStepMinutes, rules.dayOffCreditMinutes)} 단위로 넣어주세요';
  static final annualMaxDigits = AppSettings.maxLeaveDays.toString().length;
  static const annualDecimalPlaces = 2;

  static const sectionPay = '수당';
  static const wageLabel = '시급';
  static const wageSub = '알려주시면 주말·공휴일 근무 예상 금액을 볼 수 있어요';
  static const wageUnit = '원';
  static const wagePrivacyNote = '이 기기에만 저장돼요. 누구도 해당 내용을 알 수 없어요.';
  static final wageMaxDigits = AppSettings.maxHourlyWage.toString().length;
  static String wageNote(WorkRules rules) => '주말·공휴일 근무 × ${_multiplier(rules.extraWorkPayMultiplier)}배로 계산해요';

  static const sectionData = '데이터';
  static const exportLabel = '내보내기';
  static const exportSub = '기록과 설정을 파일 하나로 저장해요';
  static const importLabel = '가져오기';
  static const importSub = '파일의 기록으로 지금 기록을 바꿔요';
  static String backupFileName(DateTime d) =>
      'soi_duty_backup_${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}.json';
  static const exportDone = '내보낼 파일을 만들었어요';
  static const importTitle = '기록을 가져올까요?';
  static String importMessage(int count) => '지금 기록 $count건이 파일 내용으로 바뀌어요. 되돌릴 수 없어요.';
  static const importConfirm = '가져오기';
  static const importDone = '기록을 가져왔어요';
  static const importFailed = '파일을 읽을 수 없어요. 내보낸 파일이 맞는지 확인해 주세요';
  static const exportFailed = '내보내기에 실패했어요. 다시 시도해 주세요';
  /// 확인까지 한 가져오기가 저장 단계에서 실패 — 트랜잭션이라 기록은 그대로다.
  static const restoreFailed = '기록을 가져오지 못했어요. 지금 기록은 그대로예요';
  static const linkFailed = '링크를 열 수 없어요';
  static String lastExportLine(DateTime? d) =>
      d == null ? '아직 내보낸 적 없어요' : '마지막 내보내기 ${d.year}년 ${d.month}월 ${d.day}일';

  static const sectionApp = '앱 정보';
  static const versionLabel = '버전';
  static const privacyLabel = '개인정보 처리방침';
  static const privacyUrl = 'https://s-yun.github.io/soi-duty/privacy.html';

  static const unset = '사용 안 함';
  static String annualValue(LeaveBalance? b, int dayMinutes) => b == null ? unset : formatLeaveDays(b.remainingMinutes, dayMinutes);
  static String wageValue(int? won) => won == null ? unset : formatWon(won);

  static const save = '저장';
  static const clearLink = '사용 안 함으로 되돌리기';

  /// 1.5 → "1.5", 2.0 → "2"
  static String _multiplier(double m) => m == m.roundToDouble() ? m.toInt().toString() : m.toString();
}

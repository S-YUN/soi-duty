import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/providers/app_info_provider.dart';
import '../../core/providers/clock_provider.dart';
import '../../core/providers/database_providers.dart';
import '../../core/providers/notification_providers.dart';
import '../../domain/model/app_settings.dart';
import '../../domain/rules/work_rules.dart';
import '../../ui/app_colors.dart';
import '../../ui/app_sizes.dart';
import '../../ui/app_text_styles.dart';
import '../notification/notification_prompt.dart';
import '../notification/notification_texts.dart';
import '../shared/app_toast.dart';
import '../shared/confirm_dialog.dart';
import '../shared/number_input_sheet.dart';
import '../shared/stroke_icons.dart';
import 'leave_sheet.dart';
import 'settings_controller.dart';
import 'settings_texts.dart';
import 'widgets/segment_toggle.dart';
import 'widgets/settings_row.dart';
import 'widgets/settings_section.dart';
import 'widgets/soi_switch.dart';

class SettingsCallbacks {
  const SettingsCallbacks({
    required this.onBack,
    required this.onWeekStart,
    required this.onTapAnnual,
    required this.onTapWage,
    required this.onExport,
    required this.onImport,
    required this.onPrivacy,
    required this.onNotificationToggle,
    required this.onOpenNotificationSettings,
    required this.onExactAlarm,
  });

  final VoidCallback onBack;
  final ValueChanged<WeekStart> onWeekStart;
  final VoidCallback onTapAnnual;
  final VoidCallback onTapWage;
  final VoidCallback onExport;
  final VoidCallback onImport;
  final VoidCallback onPrivacy;
  /// 퇴근 알림 켜기/끄기 — 인자는 바꿀 값.
  final ValueChanged<bool> onNotificationToggle;
  /// OS 권한이 꺼져 있을 때의 행 — 안내 다이얼로그 → OS 설정.
  final VoidCallback onOpenNotificationSettings;
  /// "알람 및 리마인더" 행(Android) — 안내 → OS 설정.
  final VoidCallback onExactAlarm;
}

/// 설정 화면. 값은 스트림으로 읽고, 연차·시급은 숫자 시트로 받는다.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(appSettingsProvider);
    // 첫 값이 오기 전에 기본값("사용 안 함")을 번쩍이지 않는다 — 배경만.
    if (!async.hasValue) return const ColoredBox(color: AppColors.screenBackground, child: SizedBox.expand());
    final settings = async.value!;
    final version = ref.watch(appVersionProvider).value ?? '';
    final year = ref.watch(clockProvider)().year;
    final rules = ref.watch(workRulesProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    // 권한 확인이 끝나기 전·실패했을 때는 토글로 둔다 — 켜는 순간 다시 확인한다.
    final permission = ref.watch(notificationPermissionProvider).value ?? NotificationPermission.notDetermined;
    final exactAllowed = ref.watch(exactAlarmAllowedProvider).value ?? true;
    return SettingsView(
      settings: settings,
      notificationPermission: permission,
      exactAlarmAllowed: exactAllowed,
      year: year,
      version: version,
      rules: rules,
      callbacks: SettingsCallbacks(
        onBack: () => context.pop(),
        onWeekStart: (w) => _changeWeekStart(context, ref, settings.weekStart, w),
        onTapAnnual: () => showLeaveBalanceSheet(
          context,
          year: year,
          today: ref.read(clockProvider)(),
          current: settings.leaveBalanceOf(year),
          rules: rules,
          controller: controller,
        ),
        onTapWage: () => showNumberInputSheet(
          context,
          title: SettingsTexts.wageLabel,
          unit: SettingsTexts.wageUnit,
          notes: const [SettingsTexts.wagePrivacyNote],
          lockIcon: true,
          maxDigits: SettingsTexts.wageMaxDigits,
          grouping: true,
          initial: settings.hourlyWage,
          saveLabel: SettingsTexts.save,
          clearLabel: SettingsTexts.clearLink,
          onSave: (v) => controller.setHourlyWage(v.toInt()),
          onClear: () => controller.setHourlyWage(null),
        ),
        onExport: () => _export(context, ref),
        onImport: () => _import(context, ref),
        onPrivacy: () => _openPrivacy(context),
        onNotificationToggle: (on) =>
            on ? enableClockOutNotification(context, ref) : controller.setClockOutNotification(false),
        onOpenNotificationSettings: () => promptOpenNotificationSettings(context, ref),
        onExactAlarm: () => promptExactAlarm(context, ref),
      ),
    );
  }
}

// 플랫폼 예외(임시 폴더 쓰기 실패 · 공유/선택기 오류 · DB 오류)는 토스트로 알린다 — 아무 반응 없이 끝나면 성공으로 착각한다.
Future<void> _export(BuildContext context, WidgetRef ref) async {
  final now = ref.read(clockProvider)();
  final bool shared;
  try {
    shared = await ref.read(settingsControllerProvider.notifier).exportBackup(now);
  } catch (_) {
    if (context.mounted) showAppToast(context, SettingsTexts.exportFailed);
    return;
  }
  if (shared && context.mounted) showAppToast(context, SettingsTexts.exportDone);
}

Future<void> _import(BuildContext context, WidgetRef ref) async {
  final controller = ref.read(settingsControllerProvider.notifier);
  final BackupPick pick;
  try {
    pick = await controller.pickBackup();
  } catch (_) {
    if (context.mounted) showAppToast(context, SettingsTexts.importFailed);
    return;
  }
  if (!context.mounted) return;
  switch (pick) {
    case BackupPickCancelled():
      return;
    case BackupPickInvalid():
      return showAppToast(context, SettingsTexts.importFailed);
    case BackupPickReady(:final snapshot, :final currentCount):
      final ok = await showConfirmDialog(
        context,
        title: SettingsTexts.importTitle,
        message: SettingsTexts.importMessage(currentCount),
        confirmLabel: SettingsTexts.importConfirm,
      );
      if (!ok) return;
      try {
        await controller.restoreBackup(snapshot);
      } catch (_) {
        if (context.mounted) showAppToast(context, SettingsTexts.restoreFailed);
        return;
      }
      if (context.mounted) showAppToast(context, SettingsTexts.importDone);
  }
}

/// 바뀐 게 없으면 조용히. 바뀌면 저장 뒤 무엇이 달라졌는지 토스트 — 세그먼트만으로는 반응이 약하다는 피드백.
Future<void> _changeWeekStart(BuildContext context, WidgetRef ref, WeekStart current, WeekStart next) async {
  if (current == next) return;
  await ref.read(settingsControllerProvider.notifier).setWeekStart(next);
  if (context.mounted) showAppToast(context, SettingsTexts.weekStartChanged(next));
}

Future<void> _openPrivacy(BuildContext context) async {
  var opened = false;
  try {
    opened = await launchUrl(Uri.parse(SettingsTexts.privacyUrl), mode: LaunchMode.externalApplication);
  } catch (_) {
    opened = false;
  }
  if (!opened && context.mounted) showAppToast(context, SettingsTexts.linkFailed);
}

/// 설정 화면의 순수 UI. 헤더(뒤로 · 제목) → 섹션 여섯 개 (캘린더 · 알림 · 연차 · 수당 · 데이터 · 앱 정보 —
/// 앱 동작 설정 → 값 입력 → 데이터·정보 순, 핸드오프 6 §9).
class SettingsView extends StatelessWidget {
  const SettingsView({
    super.key,
    required this.settings,
    required this.year,
    required this.version,
    required this.callbacks,
    this.notificationPermission = NotificationPermission.notDetermined,
    this.exactAlarmAllowed = true,
    this.rules = const WorkRules(),
  });

  final AppSettings settings;
  /// 올해 — "남은 연차" 행이 보여주고 고치는 해.
  final int year;
  final String version;
  final SettingsCallbacks callbacks;

  /// OS 알림 권한. `denied`면 토글 대신 "설정 열기" 행 — 앱에서는 켤 수 없다.
  final NotificationPermission notificationPermission;

  /// Android "알람 및 리마인더"가 허용돼 있는지. 알림이 켜져 있는데 이게 꺼져 있으면 알림이 오지 않는다 —
  /// 토글 아래에 "허용해야 퇴근 알림이 와요 · 설정 열기" 행이 보인다.
  final bool exactAlarmAllowed;
  final WorkRules rules;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final annual = settings.leaveBalanceOf(year);
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: AppSizes.topInset),
              // 폭을 화면 전체로 — Stack은 배치 안 된 자식(제목) 크기로 줄어들어 뒤로가기가 제목 옆에 붙는다.
              child: SizedBox(
                width: double.infinity,
                height: AppSizes.settingsHeader,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(SettingsTexts.title, style: AppTextStyles.settingsTitle),
                    Positioned(left: AppSizes.settingsBackLeft, child: _BackButton(onTap: callbacks.onBack)),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: AppSizes.settingsBodyPadding.copyWith(bottom: AppSizes.settingsBodyPadding.bottom + bottomInset),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SettingsSection(
                      label: SettingsTexts.sectionCalendar,
                      note: SettingsTexts.weekStartNote,
                      rows: [
                        SettingsRow(
                          label: SettingsTexts.weekStartLabel,
                          padding: AppSizes.settingsSegmentRowPadding,
                          trailing: SegmentToggle<WeekStart>(
                            options: [for (final w in WeekStart.values) (w, SettingsTexts.weekStartOption(w))],
                            value: settings.weekStart,
                            onChanged: callbacks.onWeekStart,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSizes.settingsSectionGap),
                    SettingsSection(
                      label: NotificationTexts.settingsSection,
                      rows: [
                        if (notificationPermission == NotificationPermission.denied)
                          SettingsRow(
                            label: NotificationTexts.settingsLabel,
                            sub: NotificationTexts.osOffSub,
                            subWarning: true,
                            value: NotificationTexts.openSettings,
                            valueSet: true,
                            chevron: true,
                            chevronColor: AppColors.brand,
                            onTap: callbacks.onOpenNotificationSettings,
                          )
                        else
                          SettingsRow(
                            label: NotificationTexts.settingsLabel,
                            sub: settings.clockOutNotificationEnabled
                                ? NotificationTexts.settingsOnSub
                                : NotificationTexts.settingsOffSub,
                            trailing: SoiSwitch(value: settings.clockOutNotificationEnabled),
                            // 행 어디를 눌러도 토글된다.
                            onTap: () => callbacks.onNotificationToggle(!settings.clockOutNotificationEnabled),
                          ),
                        // 켜 뒀지만 알림이 오지 않는 상태 — 정시에 울릴 권한이 없어 예약하지 않는다. 켜는 길을 보인다.
                        if (settings.clockOutNotificationEnabled &&
                            notificationPermission == NotificationPermission.granted &&
                            !exactAlarmAllowed)
                          SettingsRow(
                            label: NotificationTexts.exactRowLabel,
                            sub: NotificationTexts.exactRowSub,
                            subWarning: true,
                            value: NotificationTexts.openSettings,
                            valueSet: true,
                            chevron: true,
                            chevronColor: AppColors.brand,
                            onTap: callbacks.onExactAlarm,
                          ),
                      ],
                    ),
                    SizedBox(height: AppSizes.settingsSectionGap),
                    SettingsSection(
                      label: SettingsTexts.sectionLeave,
                      rows: [
                        SettingsRow(
                          label: SettingsTexts.annualLabel,
                          sub: annual == null ? SettingsTexts.annualSub : SettingsTexts.annualBaseLine(annual.baseDate),
                          value: SettingsTexts.annualValue(annual, rules.dayOffCreditMinutes),
                          valueSet: annual != null,
                          chevron: true,
                          onTap: callbacks.onTapAnnual,
                        ),
                      ],
                    ),
                    SizedBox(height: AppSizes.settingsSectionGap),
                    SettingsSection(
                      label: SettingsTexts.sectionPay,
                      note: SettingsTexts.wageNote(rules),
                      rows: [
                        SettingsRow(
                          label: SettingsTexts.wageLabel,
                          sub: settings.hourlyWage == null ? SettingsTexts.wageSub : null,
                          value: SettingsTexts.wageValue(settings.hourlyWage),
                          valueSet: settings.hourlyWage != null,
                          chevron: true,
                          onTap: callbacks.onTapWage,
                        ),
                      ],
                    ),
                    SizedBox(height: AppSizes.settingsSectionGap),
                    SettingsSection(
                      label: SettingsTexts.sectionData,
                      note: SettingsTexts.lastExportLine(settings.lastExportDate),
                      rows: [
                        SettingsRow(label: SettingsTexts.exportLabel, sub: SettingsTexts.exportSub, chevron: true, onTap: callbacks.onExport),
                        SettingsRow(label: SettingsTexts.importLabel, sub: SettingsTexts.importSub, chevron: true, onTap: callbacks.onImport),
                      ],
                    ),
                    SizedBox(height: AppSizes.settingsSectionGap),
                    SettingsSection(
                      label: SettingsTexts.sectionApp,
                      rows: [
                        SettingsRow(label: SettingsTexts.versionLabel, value: version),
                        SettingsRow(
                          label: SettingsTexts.privacyLabel,
                          trailing: Icon(Icons.open_in_new_rounded, size: AppSizes.externalIcon, color: AppColors.wheelUnselected),
                          onTap: callbacks.onPrivacy,
                        ),
                      ],
                    ),
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

class _BackButton extends StatefulWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: SettingsTexts.back,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppDurations.pressedOpacity,
          width: AppSizes.gearSize,
          height: AppSizes.gearSize,
          alignment: Alignment.center,
          decoration: BoxDecoration(shape: BoxShape.circle, color: _pressed ? AppColors.tabContainer : null),
          child: BackArrowIcon(size: AppSizes.backArrow, color: AppColors.ink, stroke: AppSizes.backArrowStroke),
        ),
      ),
    );
  }
}

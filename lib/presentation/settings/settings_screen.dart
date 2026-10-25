import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/providers/app_info_provider.dart';
import '../../core/providers/clock_provider.dart';
import '../../core/providers/database_providers.dart';
import '../../domain/model/app_settings.dart';
import '../../domain/rules/work_rules.dart';
import '../../ui/app_colors.dart';
import '../../ui/app_sizes.dart';
import '../../ui/app_text_styles.dart';
import '../shared/app_toast.dart';
import '../shared/confirm_dialog.dart';
import '../shared/number_input_sheet.dart';
import '../shared/stroke_icons.dart';
import 'settings_controller.dart';
import 'settings_texts.dart';
import 'widgets/segment_toggle.dart';
import 'widgets/settings_row.dart';
import 'widgets/settings_section.dart';

class SettingsCallbacks {
  const SettingsCallbacks({
    required this.onBack,
    required this.onWeekStart,
    required this.onTapAnnual,
    required this.onTapWage,
    required this.onExport,
    required this.onImport,
    required this.onPrivacy,
  });

  final VoidCallback onBack;
  final ValueChanged<WeekStart> onWeekStart;
  final VoidCallback onTapAnnual;
  final VoidCallback onTapWage;
  final VoidCallback onExport;
  final VoidCallback onImport;
  final VoidCallback onPrivacy;
}

/// 설정 화면. 값은 스트림으로 읽고, 연차·시급은 숫자 시트로 받는다.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider).value ?? const AppSettings();
    final version = ref.watch(appVersionProvider).value ?? '';
    final year = ref.watch(clockProvider)().year;
    final rules = ref.watch(workRulesProvider);
    // autoDispose 컨트롤러를 화면이 떠 있는 동안 붙잡아 둔다 — 내보내기·시트 저장 같은 비동기 작업 중에 사라지면 안 된다.
    ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    return SettingsView(
      settings: settings,
      year: year,
      version: version,
      rules: rules,
      callbacks: SettingsCallbacks(
        onBack: () => context.pop(),
        onWeekStart: controller.setWeekStart,
        onTapAnnual: () => showNumberInputSheet(
          context,
          title: SettingsTexts.annualLabel,
          unit: SettingsTexts.annualUnit,
          note: SettingsTexts.annualNote,
          maxDigits: SettingsTexts.annualMaxDigits,
          initial: settings.annualLeaveDaysOf(year),
          saveLabel: SettingsTexts.save,
          clearLabel: SettingsTexts.clearLink,
          onSave: (v) => controller.setAnnualLeaveDays(year, v),
          onClear: () => controller.setAnnualLeaveDays(year, null),
        ),
        onTapWage: () => showNumberInputSheet(
          context,
          title: SettingsTexts.wageLabel,
          unit: SettingsTexts.wageUnit,
          note: SettingsTexts.wagePrivacyNote,
          lockIcon: true,
          maxDigits: SettingsTexts.wageMaxDigits,
          grouping: true,
          initial: settings.hourlyWage,
          saveLabel: SettingsTexts.save,
          clearLabel: SettingsTexts.clearLink,
          onSave: controller.setHourlyWage,
          onClear: () => controller.setHourlyWage(null),
        ),
        onExport: () => _export(context, ref),
        onImport: () => _import(context, ref),
        onPrivacy: () => launchUrl(Uri.parse(SettingsTexts.privacyUrl), mode: LaunchMode.externalApplication),
      ),
    );
  }
}

Future<void> _export(BuildContext context, WidgetRef ref) async {
  final now = ref.read(clockProvider)();
  final shared = await ref.read(settingsControllerProvider.notifier).exportBackup(now);
  if (shared && context.mounted) showAppToast(context, SettingsTexts.exportDone);
}

Future<void> _import(BuildContext context, WidgetRef ref) async {
  final controller = ref.read(settingsControllerProvider.notifier);
  final pick = await controller.pickBackup();
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
      await controller.restoreBackup(snapshot);
      if (context.mounted) showAppToast(context, SettingsTexts.importDone);
  }
}

/// 설정 화면의 순수 UI. 헤더(뒤로 · 제목) → 섹션 다섯 개.
class SettingsView extends StatelessWidget {
  const SettingsView({
    super.key,
    required this.settings,
    required this.year,
    required this.version,
    required this.callbacks,
    this.rules = const WorkRules(),
  });

  final AppSettings settings;
  /// 올해 — "올해 총 연차"가 보여주고 고치는 해.
  final int year;
  final String version;
  final SettingsCallbacks callbacks;
  final WorkRules rules;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final annual = settings.annualLeaveDaysOf(year);
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: AppSizes.topInset),
              child: SizedBox(
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
                      label: SettingsTexts.sectionLeave,
                      rows: [
                        SettingsRow(
                          label: SettingsTexts.annualLabel,
                          sub: annual == null ? SettingsTexts.annualSub : null,
                          value: SettingsTexts.annualValue(annual),
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
    return Tooltip(
      message: SettingsTexts.back,
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

import 'package:flutter/material.dart';

import '../../../ui/app_colors.dart';
import '../../../ui/app_decorations.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';

/// 섹션 라벨 → 카드(행 사이 1px 구분선) → (선택) 안내 줄.
class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key, required this.label, required this.rows, this.note});

  final String label;
  final List<Widget> rows;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: AppSizes.settingsSectionLabelPadding,
          child: Text(label, style: AppTextStyles.settingsSectionLabel),
        ),
        Container(
          decoration: AppDecorations.card,
          padding: AppSizes.settingsCardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0) Container(height: AppSizes.summaryDivider, color: AppColors.rowDivider),
                rows[i],
              ],
            ],
          ),
        ),
        if (note != null)
          Padding(
            padding: AppSizes.settingsNotePadding.copyWith(top: AppSizes.settingsNoteTop),
            child: Text(note!, style: AppTextStyles.settingsNote),
          ),
      ],
    );
  }
}

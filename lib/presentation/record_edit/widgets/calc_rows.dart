import 'package:flutter/material.dart';

import '../../../ui/app_text_styles.dart';
import '../record_edit_texts.dart';

/// 계산 내역 (근무 / 점심 공제 / 기준 / 기준 대비).
class CalcRows extends StatelessWidget {
  const CalcRows({super.key, required this.lines});

  final List<CalcLine> lines;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final l in lines)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l.label, style: l.kind == CalcKind.note ? AppTextStyles.calcNote : AppTextStyles.calcRow),
              Text(
                l.value,
                style: switch (l.kind) {
                  CalcKind.value => AppTextStyles.calcValue,
                  CalcKind.note => AppTextStyles.calcNote,
                  CalcKind.sum => AppTextStyles.calcSum,
                },
              ),
            ],
          ),
      ],
    );
  }
}

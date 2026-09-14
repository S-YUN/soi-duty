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

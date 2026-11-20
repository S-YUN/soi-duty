import 'package:flutter/material.dart';

import '../../../ui/app_colors.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';
import '../notification_texts.dart';

/// 권한 묻기 다이얼로그 안의 알림 미리보기 — "이런 알림이 와요"를 말로 설명하는 대신 보여준다 (핸드오프 6 §8).
/// 장식이라 접근성에서는 숨긴다(같은 내용을 다이얼로그 설명이 말한다).
class NotificationPreviewCard extends StatelessWidget {
  const NotificationPreviewCard({super.key, required this.time});

  /// 알림이 올 시각 "18:12". 아직 모르면 null — 시각 자리를 비운다.
  final String? time;

  static const _logo = 'assets/images/mark-transparent.png';

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        padding: AppSizes.notifyPreviewPadding,
        decoration: BoxDecoration(
          color: AppColors.chipNeutral,
          borderRadius: BorderRadius.circular(AppSizes.notifyPreviewRadius),
        ),
        child: Row(
          children: [
            Container(
              width: AppSizes.notifyPreviewIcon,
              height: AppSizes.notifyPreviewIcon,
              padding: EdgeInsets.all(AppSizes.notifyPreviewIcon * AppScales.notifyPreviewIconInset),
              decoration: BoxDecoration(
                color: AppColors.brandDeep,
                borderRadius: BorderRadius.circular(AppSizes.notifyPreviewIconRadius),
              ),
              child: Image.asset(_logo, fit: BoxFit.contain),
            ),
            SizedBox(width: AppSizes.notifyPreviewGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(NotificationTexts.appName, style: AppTextStyles.notifyPreviewMeta)),
                      if (time != null) Text(time!, style: AppTextStyles.notifyPreviewMeta),
                    ],
                  ),
                  SizedBox(height: AppSizes.notifyPreviewTitleTop),
                  Text(NotificationTexts.dailyTitle, style: AppTextStyles.notifyPreviewTitle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../ui/app_colors.dart';
import '../../../ui/app_sizes.dart';
import '../../../ui/app_text_styles.dart';
import '../today_texts.dart';

/// 오늘 화면의 출장 칩 (핸드오프 6 §4). 범위가 없으면 점선 "+ 출장", 있으면 출장색 "출장 09:12–12:12".
/// [onTap]이 null이면 보기만 하는 칩(퇴근 완료) — 히트 영역 여백도 없다.
class TripChip extends StatelessWidget {
  const TripChip({super.key, required this.start, required this.end, required this.onTap});

  final DateTime? start;
  final DateTime? end;
  final VoidCallback? onTap;

  bool get _filled => start != null && end != null;

  @override
  Widget build(BuildContext context) {
    final filled = _filled;
    final radius = BorderRadius.circular(AppSizes.tripChipRadius);
    final label = Padding(
      padding: AppSizes.tripChipPadding,
      child: Text(
        filled ? TodayTexts.tripChip(start!, end!) : TodayTexts.tripAdd,
        style: AppTextStyles.tripChip(filled: filled),
        maxLines: 1,
        softWrap: false,
      ),
    );
    final chip = filled
        ? DecoratedBox(
            decoration: BoxDecoration(color: AppColors.tripBackground, borderRadius: radius),
            child: label,
          )
        : CustomPaint(
            painter: _DashedBorderPainter(
              color: AppColors.tripBorder,
              radius: AppSizes.tripChipRadius,
              strokeWidth: AppSizes.tripChipBorder,
              dash: AppSizes.tripChipDash,
            ),
            child: label,
          );
    if (onTap == null) return chip;
    // 칩은 작아도(높이 21쯤) 누르는 자리는 넉넉하게 — 줄 높이 안에서 위아래·좌우로 넓힌다.
    return Semantics(
      button: true,
      label: filled ? TodayTexts.tripEditSemantics : TodayTexts.tripAddSemantics,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: AppSizes.tripChipHitHeight),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.tripChipHitPadding),
            child: Center(widthFactor: 1, heightFactor: 1, child: chip),
          ),
        ),
      ),
    );
  }
}

/// 둥근 사각형 점선 테두리. Flutter 기본 Border에는 점선이 없다.
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
    required this.dash,
  });

  final Color color;
  final double radius;
  final double strokeWidth;
  final double dash;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(strokeWidth / 2);
    final path = Path()..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    for (final PathMetric metric in path.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += dash * 2) {
        canvas.drawPath(metric.extractPath(d, (d + dash).clamp(0, metric.length)), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color || old.radius != radius || old.strokeWidth != strokeWidth || old.dash != dash;
}

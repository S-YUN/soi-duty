import 'package:flutter/material.dart';

import '../../domain/model/work_type.dart';
import '../../ui/app_colors.dart';

/// 유형 색을 입힌 작은 태그. 주간 행·캘린더 셀이 패딩/radius/글꼴만 다르게 쓴다.
class TypeTag extends StatelessWidget {
  const TypeTag({
    super.key,
    required this.type,
    required this.label,
    required this.padding,
    required this.radius,
    required this.style,
  });

  final WorkType type;
  final String label;
  final EdgeInsets padding;
  final double radius;
  final TextStyle Function(Color color) style;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = AppColors.typeColors(type);
    return Container(
      padding: padding,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(radius)),
      child: Text(label, style: style(fg), maxLines: 1),
    );
  }
}

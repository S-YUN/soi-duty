import 'package:flutter/material.dart';

/// 색을 입힌 작은 태그. 주간 행의 유형·시간공제 배지가 쓴다.
class TypeTag extends StatelessWidget {
  const TypeTag({
    super.key,
    required this.background,
    required this.foreground,
    required this.label,
    required this.padding,
    required this.radius,
    required this.style,
  });

  final Color background;
  final Color foreground;
  final String label;
  final EdgeInsets padding;
  final double radius;
  final TextStyle Function(Color color) style;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(radius)),
      child: Text(label, style: style(foreground), maxLines: 1),
    );
  }
}

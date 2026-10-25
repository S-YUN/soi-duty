import 'package:flutter/material.dart';

/// 디자인의 선 아이콘(꺾쇠 · 뒤로 화살표)을 그대로 그린다. 머티리얼 아이콘은 굵기·비율이 달라 쓰지 않는다.
class ChevronIcon extends StatelessWidget {
  const ChevronIcon({super.key, required this.size, required this.color, required this.stroke});

  final Size size;
  final Color color;
  final double stroke;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: size, painter: _StrokePainter(color: color, stroke: stroke, points: const [(0, 0), (1, .5), (0, 1)]));
}

class BackArrowIcon extends StatelessWidget {
  const BackArrowIcon({super.key, required this.size, required this.color, required this.stroke});

  final Size size;
  final Color color;
  final double stroke;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: size, painter: _StrokePainter(color: color, stroke: stroke, points: const [(1, 0), (0, .5), (1, 1)]));
}

class _StrokePainter extends CustomPainter {
  const _StrokePainter({required this.color, required this.stroke, required this.points});

  final Color color;
  final double stroke;
  /// (x, y) 비율 좌표. 선 굵기만큼 안쪽으로 들여 그려 잘리지 않게 한다.
  final List<(double, double)> points;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final inset = stroke / 2;
    final w = size.width - stroke, h = size.height - stroke;
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final (x, y) = points[i];
      final p = Offset(inset + x * w, inset + y * h);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_StrokePainter old) => old.color != color || old.stroke != stroke || old.points != points;
}

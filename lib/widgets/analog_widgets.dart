import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

class MaskingTape extends StatelessWidget {
  final String text;
  final Color color;
  final double width;
  final double height;
  final double rotation;

  const MaskingTape({
    super.key,
    this.text = '',
    this.color = AppTheme.maskingTape,
    this.width = 100,
    this.height = 30,
    this.rotation = -0.05,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color.withOpacity(0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(1, 1),
            ),
          ],
        ),
        child: ClipPath(
          clipper: TapeClipper(),
          child: Container(
            color: color.withOpacity(0.6),
            alignment: Alignment.center,
            child: text.isNotEmpty
                ? Text(
                    text,
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.textPrimary.withOpacity(0.7),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

class TapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height);

    // Bottom jagged edge
    for (var i = 0; i <= 10; i++) {
      path.lineTo(size.width / 10 * i, size.height - (i % 2 == 0 ? 2 : 0));
    }

    path.lineTo(size.width, 0);

    // Top jagged edge
    for (var i = 10; i >= 0; i--) {
      path.lineTo(size.width / 10 * i, (i % 2 == 0 ? 2 : 0));
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class HandDrawnContainer extends StatelessWidget {
  final Widget child;
  final Color color;
  final EdgeInsets padding;
  final double strokeWidth;

  const HandDrawnContainer({
    super.key,
    required this.child,
    this.color = AppTheme.pencilDash,
    this.padding = const EdgeInsets.all(16),
    this.strokeWidth = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: HandDrawnPainter(color: color, strokeWidth: strokeWidth),
      child: Padding(padding: padding, child: child),
    );
  }
}

class HandDrawnPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  HandDrawnPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final random = math.Random(42); // Fixed seed for consistent look

    void drawSkewedLine(Offset start, Offset end) {
      final path = Path();
      path.moveTo(start.dx, start.dy);

      int segments = 5;
      for (int i = 1; i <= segments; i++) {
        double t = i / segments;
        double x = start.dx + (end.dx - start.dx) * t;
        double y = start.dy + (end.dy - start.dy) * t;

        // Add subtle deviation
        x += (random.nextDouble() - 0.5) * 2;
        y += (random.nextDouble() - 0.5) * 2;

        path.lineTo(x, y);
      }
      canvas.drawPath(path, paint);
    }

    drawSkewedLine(Offset.zero, Offset(size.width, 0));
    drawSkewedLine(Offset(size.width, 0), Offset(size.width, size.height));
    drawSkewedLine(Offset(size.width, size.height), Offset(0, size.height));
    drawSkewedLine(Offset(0, size.height), Offset.zero);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

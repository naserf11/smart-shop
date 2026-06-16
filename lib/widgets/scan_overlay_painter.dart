import 'package:flutter/material.dart';

class ScanOverlayPainter extends CustomPainter {
  static const double _cutoutSize = 280.0;
  static const double _cornerLength = 36.0;
  static const double _cornerRadius = 8.0;

  @override
  void paint(Canvas canvas, Size size) {
    final cutoutRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 - 40),
      width: _cutoutSize,
      height: _cutoutSize,
    );

    // Dark dimmed overlay with transparent scan window
    final overlayPaint = Paint()..color = Colors.black.withOpacity(0.6);
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(
        RRect.fromRectAndRadius(
          cutoutRect,
          const Radius.circular(_cornerRadius),
        ),
      );
    canvas.drawPath(
      overlayPath..fillType = PathFillType.evenOdd,
      overlayPaint,
    );

    // White bracket corners
    final cornerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final l = cutoutRect.left;
    final t = cutoutRect.top;
    final r = cutoutRect.right;
    final b = cutoutRect.bottom;
    const cl = _cornerLength;
    const cr = _cornerRadius;

    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(l + cr, t)
        ..lineTo(l + cl, t)
        ..moveTo(l, t + cr)
        ..lineTo(l, t + cl),
      cornerPaint,
    );
    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(r - cl, t)
        ..lineTo(r - cr, t)
        ..moveTo(r, t + cr)
        ..lineTo(r, t + cl),
      cornerPaint,
    );
    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(l, b - cl)
        ..lineTo(l, b - cr)
        ..moveTo(l + cr, b)
        ..lineTo(l + cl, b),
      cornerPaint,
    );
    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(r, b - cl)
        ..lineTo(r, b - cr)
        ..moveTo(r - cl, b)
        ..lineTo(r - cr, b),
      cornerPaint,
    );

    // Instruction text below the scan window
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Align barcode or QR code within the frame',
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 64);

    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        cutoutRect.bottom + 24,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
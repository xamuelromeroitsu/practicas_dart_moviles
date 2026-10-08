import 'package:flutter/material.dart';
import '../game/game_engine.dart';
import '../models/game_config.dart';

class GamePainter extends CustomPainter {
  final GameEngine engine;

  GamePainter({required this.engine});

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / GameConfig.courtWidth;
    final scaleY = size.height / GameConfig.courtHeight;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint..color = const Color(0xFF051010),
    );

    // Center line (dashed)
    final dashPaint = Paint()
      ..color = Colors.tealAccent.withValues(alpha: 0.3)
      ..strokeWidth = 2 * scaleX
      ..style = PaintingStyle.stroke;
    const dashLength = 10.0;
    const dashGap = 10.0;
    double y = 0;
    while (y < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, y),
        Offset(size.width / 2, y + dashLength * scaleY),
        dashPaint,
      );
      y += (dashLength + dashGap) * scaleY;
    }

    // Center circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      30 * scaleX,
      Paint()
        ..color = Colors.tealAccent.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * scaleX,
    );

    // Paddle 1 (Left)
    final p1Rect = Rect.fromLTWH(
      engine.paddle1.x * scaleX,
      engine.paddle1.y * scaleY,
      engine.paddle1.width * scaleX,
      engine.paddle1.height * scaleY,
    );
    paint.shader = const LinearGradient(
      colors: [Color(0xFF00E5FF), Color(0xFF00B8D4)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(p1Rect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(p1Rect, Radius.circular(4 * scaleX)),
      paint,
    );

    // Paddle 2 (Right)
    final p2Rect = Rect.fromLTWH(
      engine.paddle2.x * scaleX,
      engine.paddle2.y * scaleY,
      engine.paddle2.width * scaleX,
      engine.paddle2.height * scaleY,
    );
    paint.shader = const LinearGradient(
      colors: [Color(0xFFFF6EC7), Color(0xFFD81B60)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(p2Rect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(p2Rect, Radius.circular(4 * scaleX)),
      paint,
    );

    // Ball
    final ballRect = Rect.fromLTWH(
      engine.ball.x * scaleX,
      engine.ball.y * scaleY,
      engine.ball.size * scaleX,
      engine.ball.size * scaleY,
    );
    paint.shader = const LinearGradient(
      colors: [Color(0xFF69F0AE), Color(0xFF00C853)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(ballRect);
    canvas.drawOval(ballRect, paint);

    // Ball glow effect
    canvas.drawOval(
      ballRect.inflate(3 * scaleX),
      Paint()
        ..color = const Color(0xFF69F0AE).withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4 * scaleX
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) => true;
}
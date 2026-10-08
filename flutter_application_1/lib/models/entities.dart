import 'game_config.dart';

// Ball entity - represents the ping pong ball
class Ball {
  double x;           // Horizontal position (left edge)
  double y;           // Vertical position (top edge)
  double dx;          // Horizontal velocity (pixels/frame)
  double dy;          // Vertical velocity (pixels/frame)
  final double size;  // Ball diameter (width & height)

  Ball({
    required this.x,
    required this.y,
    required this.dx,
    required this.dy,
    required this.size,
  });

  // Update position based on velocity
  void move() {
    x += dx;
    y += dy;
  }

  // Reverse vertical direction (top/bottom wall bounce)
  void bounceY() => dy = -dy;
  // Reverse horizontal direction (paddle bounce)
  void bounceX() => dx = -dx;

  // Reset ball to center with random angle toward specified side
  void reset(double centerX, double centerY, {required bool serveToLeft}) {
    x = centerX;
    y = centerY;
    final angle = (DateTime.now().microsecondsSinceEpoch % 1000) / 1000 * 0.5 - 0.25;
    final speed = GameConfig.initialBallSpeed;
    dx = (serveToLeft ? -1 : 1) * speed * (1 - angle.abs());
    dy = speed * angle * 4;
  }
}

// Paddle entity - represents a player/AI paddle
class Paddle {
  double y;              // Vertical position (top edge)
  final double x;        // Horizontal position (fixed: left or right edge)
  final double width;    // Paddle thickness
  final double height;   // Paddle height
  final double speed;    // Movement speed per frame

  Paddle({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.speed,
  });

  // Move paddle up (toward top of screen)
  void moveUp(double courtHeight) {
    y = (y - speed).clamp(0, courtHeight - height);
  }

  // Move paddle down (toward bottom of screen)
  void moveDown(double courtHeight) {
    y = (y + speed).clamp(0, courtHeight - height);
  }

  // Set absolute position (used for touch/drag input)
  void setPosition(double newY, double courtHeight) {
    y = newY.clamp(0, courtHeight - height);
  }

  // Center Y coordinate of paddle (used for AI targeting)
  double get center => y + height / 2;

  // Check if ball collides with this paddle
  bool hitsBall(double ballX, double ballY, double ballSize) {
    return ballX <= x + width &&
        ballX + ballSize >= x &&
        ballY + ballSize >= y &&
        ballY <= y + height;
  }
}
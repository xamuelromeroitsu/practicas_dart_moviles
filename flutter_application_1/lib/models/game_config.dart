// Game configuration constants
// All measurements in logical pixels
class GameConfig {
  static const double courtWidth = 400;      // Game court width
  static const double courtHeight = 600;     // Game court height
  static const double paddleWidth = 12;      // Paddle thickness
  static const double paddleHeight = 100;    // Paddle height
  static const double ballSize = 16;         // Ball diameter
  static const double paddleSpeed = 14;      // Pixels per frame movement
  static const double initialBallSpeed = 5;  // Starting ball speed
  static const double maxBallSpeed = 12;     // Maximum ball speed cap
  static const double speedIncrease = 0.3;   // Speed boost per paddle hit
}
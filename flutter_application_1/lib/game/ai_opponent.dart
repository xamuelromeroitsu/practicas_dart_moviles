// AI Opponent - controls the right paddle in single-player mode
import '../models/entities.dart';
import '../models/game_config.dart';
import 'dart:math';

enum AIDifficulty { easy, medium, hard }

class AIOpponent {
  final AIDifficulty difficulty;
  int _frameCounter = 0;
  final Random _random = Random();

  // Paddle speed per difficulty (Hard gets faster paddle)
  double get _paddleSpeed => switch (difficulty) {
    AIDifficulty.easy => 10.0,
    AIDifficulty.medium => 14.0,
    AIDifficulty.hard => 18.0,
  };

  // Reaction rate: frames between AI decisions
  int get _reactionRate => switch (difficulty) {
    AIDifficulty.easy => 5,
    AIDifficulty.medium => 3,
    AIDifficulty.hard => 1,
  };

  // Error margin for imperfect tracking
  double get _errorMargin => switch (difficulty) {
    AIDifficulty.easy => 30.0,
    AIDifficulty.medium => 8.0,
    AIDifficulty.hard => 0.0,
  };

  AIOpponent(this.difficulty);

  // Call when starting new game/point to reset internal state
  void reset() {
    _frameCounter = 0;
  }

  // Called each frame to update AI paddle position
  void update(Paddle paddle, Ball ball) {
    // Only react when ball is moving toward AI (right side)
    if (ball.dx <= 0) return;

    _frameCounter++;
    if (_frameCounter % _reactionRate != 0) return;

    // Predict where ball will hit right wall
    final targetY = _predictBallImpactY(ball);
    
    // Add difficulty-based error
    final error = _errorMargin > 0 
        ? (_random.nextDouble() - 0.5) * _errorMargin * 2
        : 0.0;
    
    final paddleCenter = paddle.center;
    final diff = (targetY + error) - paddleCenter;

    // Move toward target with difficulty-scaled speed
    // Avoid jitter at edges by checking bounds before moving
    if (diff > 2) {
      if (paddle.y + paddle.height < GameConfig.courtHeight) {
        paddle.y = (paddle.y + _paddleSpeed).clamp(0, GameConfig.courtHeight - paddle.height);
      }
    } else if (diff < -2) {
      if (paddle.y > 0) {
        paddle.y = (paddle.y - _paddleSpeed).clamp(0, GameConfig.courtHeight - paddle.height);
      }
    }
  }

  // Predict ball Y position when it reaches right paddle x position
  double _predictBallImpactY(Ball ball) {
    final dx = ball.dx;
    if (dx <= 0) return ball.y + ball.size / 2;

    // Distance to right paddle collision point
    final distanceToPaddle = (GameConfig.courtWidth - GameConfig.paddleWidth) - (ball.x + ball.size);
    final framesToImpact = distanceToPaddle / dx;
    
    // Predict Y position after framesToImpact
    double predictedY = ball.y + ball.dy * framesToImpact;
    const ballRadius = 0.0; // Ball treated as point for prediction
    
    // Simulate bounces off top/bottom walls
    while (predictedY < 0 || predictedY > GameConfig.courtHeight) {
      if (predictedY < 0) {
        predictedY = -predictedY; // Reflect off top
      } else if (predictedY > GameConfig.courtHeight) {
        predictedY = 2 * GameConfig.courtHeight - predictedY; // Reflect off bottom
      }
    }

    return predictedY.clamp(0, GameConfig.courtHeight);
  }
}
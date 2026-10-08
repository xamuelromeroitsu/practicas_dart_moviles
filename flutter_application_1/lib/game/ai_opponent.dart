// AI Opponent - controls the right paddle in single-player mode
import '../models/entities.dart';
import '../models/game_config.dart';
import 'dart:math';

enum AIDifficulty { easy, medium, hard }

class AIOpponent {
  final AIDifficulty difficulty;  // Difficulty level affects reaction speed & accuracy
  int _frameCounter = 0;          // Frame counter for reaction rate limiting
  final Random _random = Random(); // Random for easy mode errors

  AIOpponent(this.difficulty);

  // Called each frame to update AI paddle position
  void update(Paddle paddle, Ball ball) {
    _frameCounter++;
    
    // Reaction rate: how many frames between AI decisions
    // Easy = 5 frames (slow), Medium = 3, Hard = 1 (every frame)
    final reactionRate = switch (difficulty) {
      AIDifficulty.easy => 5,
      AIDifficulty.medium => 3,
      AIDifficulty.hard => 1,
    };
    
    // Skip update if not time to react yet
    if (_frameCounter % reactionRate != 0) return;

    final paddleCenter = paddle.center;           // Current paddle center Y
    final targetY = ball.y + ball.size / 2;       // Ball center Y (target)
    
    // Easy mode: add random error to make AI miss sometimes
    final error = difficulty == AIDifficulty.easy
        ? (_random.nextDouble() - 0.5) * 60  // ±30 pixels error
        : 0.0;
    
    final diff = (targetY + error) - paddleCenter; // Distance to target

    // Move paddle toward ball
    if (diff > 2) {
      paddle.moveDown(GameConfig.courtHeight);
    } else if (diff < -2) {
      paddle.moveUp(GameConfig.courtHeight);
    }
    // If |diff| <= 2, paddle is close enough - don't move (prevents jitter)
  }
}
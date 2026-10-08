// Game Engine - Core game logic, state management, and physics
import '../models/entities.dart';
import '../models/game_config.dart';
import 'ai_opponent.dart';
import 'dart:math';

class GameEngine {
  late Ball ball;              // The ball entity
  late Paddle paddle1;         // Left paddle (player 1)
  late Paddle paddle2;         // Right paddle (player 2 or AI)
  AIOpponent? aiOpponent;      // AI controller for paddle2 (null in PvP)
  bool vsAI = true;            // Game mode: true = vs AI, false = PvP
  AIDifficulty aiDifficulty = AIDifficulty.medium; // AI difficulty setting

  int score1 = 0;              // Player 1 (left) score
  int score2 = 0;              // Player 2 / AI (right) score
  bool isPlaying = true;       // Game state: paused/playing

  // Initialize all game objects
  void initialize() {
    paddle1 = Paddle(
      x: 0,
      y: (GameConfig.courtHeight - GameConfig.paddleHeight) / 2,
      width: GameConfig.paddleWidth,
      height: GameConfig.paddleHeight,
      speed: GameConfig.paddleSpeed,
    );
    paddle2 = Paddle(
      x: GameConfig.courtWidth - GameConfig.paddleWidth,
      y: (GameConfig.courtHeight - GameConfig.paddleHeight) / 2,
      width: GameConfig.paddleWidth,
      height: GameConfig.paddleHeight,
      speed: GameConfig.paddleSpeed,
    );
    _resetGame();
  }

  // Full game reset: scores, positions, ball
  void _resetGame() {
    score1 = 0;
    score2 = 0;
    _resetBall(serveToLeft: true);
    paddle1.y = (GameConfig.courtHeight - GameConfig.paddleHeight) / 2;
    paddle2.y = (GameConfig.courtHeight - GameConfig.paddleHeight) / 2;

    if (vsAI) {
      aiOpponent = AIOpponent(aiDifficulty);
    }
    aiOpponent?.reset();
  }

  // Reset ball to center with random angle toward serving side
  void _resetBall({required bool serveToLeft}) {
    ball = Ball(
      x: GameConfig.courtWidth / 2,
      y: GameConfig.courtHeight / 2,
      dx: 0,
      dy: 0,
      size: GameConfig.ballSize,
    );
    final angle = (Random().nextDouble() - 0.5) * pi / 4; // ±22.5 degrees
    final speed = GameConfig.initialBallSpeed;
    ball.dx = (serveToLeft ? -1 : 1) * speed * cos(angle);
    ball.dy = speed * sin(angle);
  }

  // Main game update - called every frame (~60 FPS)
  void update() {
    if (!isPlaying) return;

    ball.move();

    // Top/bottom wall collision
    if (ball.y <= 0) {
      ball.y = 0;
      ball.bounceY();
    } else if (ball.y + ball.size >= GameConfig.courtHeight) {
      ball.y = GameConfig.courtHeight - ball.size;
      ball.bounceY();
    }

    // Left paddle collision (player 1)
    if (paddle1.hitsBall(ball.x, ball.y, ball.size)) {
      ball.x = paddle1.x + paddle1.width;  // Push ball out of paddle
      ball.bounceX();                       // Reverse horizontal direction
      _increaseSpeed();                     // Speed up slightly
      _addSpin(paddle1);                    // Add spin based on hit position
    }

    // Right paddle collision (player 2 or AI)
    if (paddle2.hitsBall(ball.x, ball.y, ball.size)) {
      ball.x = paddle2.x - ball.size;       // Push ball out of paddle
      ball.bounceX();                       // Reverse horizontal direction
      _increaseSpeed();                     // Speed up slightly
      _addSpin(paddle2);                    // Add spin based on hit position
    }

    // Scoring: ball passed left edge
    if (ball.x < 0) {
      score2++;
      _resetBall(serveToLeft: false);       // Serve toward player 1
      aiOpponent?.reset();
    } 
    // Scoring: ball passed right edge
    else if (ball.x > GameConfig.courtWidth) {
      score1++;
      _resetBall(serveToLeft: true);        // Serve toward player 2/AI
      aiOpponent?.reset();
    }

    // Update AI if in single-player mode
    if (vsAI && aiOpponent != null) {
      aiOpponent!.update(paddle2, ball);
    }
  }

  // Increase ball speed up to maximum
  void _increaseSpeed() {
    final speed = sqrt(ball.dx * ball.dx + ball.dy * ball.dy);
    if (speed < GameConfig.maxBallSpeed) {
      final factor = (speed + GameConfig.speedIncrease) / speed;
      ball.dx *= factor;
      ball.dy *= factor;
    }
  }

  // Add vertical spin based on where ball hits paddle
  // Hit top of paddle -> upward spin, bottom -> downward spin
  void _addSpin(Paddle paddle) {
    final hitPos = (ball.y + ball.size / 2) - paddle.center;
    final normalizedHit = (hitPos / (paddle.height / 2)).clamp(-1.0, 1.0);
    ball.dy += normalizedHit * 3;
  }

  // Input handlers for keyboard/touch
  void movePaddle1Up() => paddle1.moveUp(GameConfig.courtHeight);
  void movePaddle1Down() => paddle1.moveDown(GameConfig.courtHeight);
  void movePaddle2Up() => paddle2.moveUp(GameConfig.courtHeight);
  void movePaddle2Down() => paddle2.moveDown(GameConfig.courtHeight);

  // Direct position setting (for drag/touch input)
  void setPaddle1Position(double y) => paddle1.setPosition(y, GameConfig.courtHeight);
  void setPaddle2Position(double y) => paddle2.setPosition(y, GameConfig.courtHeight);

  void togglePause() => isPlaying = !isPlaying;
  void reset() => _resetGame();

  // Change game mode (vs AI / PvP) and difficulty
  void setMode({required bool vsAI, AIDifficulty? difficulty}) {
    this.vsAI = vsAI;
    if (difficulty != null) aiDifficulty = difficulty;
    _resetGame();
    aiOpponent?.reset();
  }
}
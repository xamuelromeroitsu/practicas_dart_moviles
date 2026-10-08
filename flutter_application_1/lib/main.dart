import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/game_config.dart';
import 'game/game_engine.dart';
import 'game/ai_opponent.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const PingPongApp());
}

class PingPongApp extends StatelessWidget {
  const PingPongApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ping Pong Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0D1B1B),
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  final GameEngine _engine = GameEngine();
  late final AnimationController _ticker;
  OverlayEntry? _menuOverlay;
  AIDifficulty _selectedDifficulty = AIDifficulty.medium;
  bool _showMenu = true;

  // Input state
  final Set<LogicalKeyboardKey> _pressedKeys = {};

  @override
  void initState() {
    super.initState();
    _engine.initialize();
    _ticker = AnimationController(vsync: this, duration: const Duration(milliseconds: 16))
      ..addListener(_gameLoop)
      ..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _showMainMenu();
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _menuOverlay?.remove();
    super.dispose();
  }

  void _gameLoop() {
    setState(() {
      _engine.update();
    });
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      _pressedKeys.add(event.logicalKey);
    } else if (event is KeyUpEvent) {
      _pressedKeys.remove(event.logicalKey);
    }
    _processInput();
  }

  void _processInput() {
    if (_showMenu) return;

    // Player 1 (left) - W/S
    if (_pressedKeys.contains(LogicalKeyboardKey.keyW)) {
      _engine.movePaddle1Up();
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.keyS)) {
      _engine.movePaddle1Down();
    }

    // Player 2 (right) - Arrow Up/Down (only in PvP)
    if (!_engine.vsAI) {
      if (_pressedKeys.contains(LogicalKeyboardKey.arrowUp)) {
        _engine.movePaddle2Up();
      }
      if (_pressedKeys.contains(LogicalKeyboardKey.arrowDown)) {
        _engine.movePaddle2Down();
      }
    }

    // Pause - Space
    if (_pressedKeys.contains(LogicalKeyboardKey.space)) {
      _engine.togglePause();
    }
  }

  void _showMainMenu() {
    _menuOverlay?.remove();
    _showMenu = true;
    _menuOverlay = OverlayEntry(
      builder: (context) => _MenuOverlay(
        onModeSelected: (mode) {
          setState(() {
            if (mode == GameMode.pve) {
              _showDifficultyMenu();
            } else {
              _startGame(mode);
            }
          });
        },
      ),
    );
    Overlay.of(context).insert(_menuOverlay!);
  }

  void _showDifficultyMenu() {
    _menuOverlay?.remove();
    _menuOverlay = OverlayEntry(
      builder: (context) => _DifficultyOverlay(
        selectedDifficulty: _selectedDifficulty,
        onDifficultyChanged: (d) => setState(() => _selectedDifficulty = d),
        onStart: () => _startGame(GameMode.pve),
        onBack: _showMainMenu,
      ),
    );
    Overlay.of(context).insert(_menuOverlay!);
  }

  void _startGame(GameMode mode) {
    _menuOverlay?.remove();
    _menuOverlay = null;
    _showMenu = false;
    _pressedKeys.clear();
    _engine.setMode(
      vsAI: mode == GameMode.pve,
      difficulty: mode == GameMode.pve ? _selectedDifficulty : null,
    );
  }

  void _handlePanUpdate(DragUpdateDetails details, bool isLeftPaddle) {
    if (_showMenu) return;
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final local = renderBox.globalToLocal(details.globalPosition);
    final courtWidth = MediaQuery.of(context).size.width * 0.9;
    final scale = courtWidth / GameConfig.courtWidth;
    final courtTop = (MediaQuery.of(context).size.height - GameConfig.courtHeight * scale) / 2;
    final y = (local.dy - courtTop) / scale;
    if (isLeftPaddle) {
      _engine.setPaddle1Position(y);
    } else if (!_engine.vsAI) {
      _engine.setPaddle2Position(y);
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        body: GestureDetector(
          onPanUpdate: (d) => _handlePanUpdate(d, true),
          onPanEnd: (_) {},
          child: Stack(
            children: [
              Center(
                child: AspectRatio(
                  aspectRatio: GameConfig.courtWidth / GameConfig.courtHeight,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.tealAccent.withValues(alpha: 0.3), width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: CustomPaint(
                        painter: _GamePainter(engine: _engine),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                ),
              ),
              if (!_showMenu)
                Positioned(
                  top: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_engine.score1}  -  ${_engine.score2}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          color: Colors.tealAccent,
                          letterSpacing: 8,
                        ),
                      ),
                    ),
                  ),
                ),
              if (!_showMenu)
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      _engine.vsAI ? 'W/S para mover  •  ESPACIO: Pausa' : 'W/S (Izq)  •  ↑/↓ (Der)  •  ESPACIO: Pausa',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.tealAccent.withValues(alpha: 0.6),
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

enum GameMode { menu, pvp, pve }

class _MenuOverlay extends StatelessWidget {
  final ValueChanged<GameMode> onModeSelected;
  const _MenuOverlay({required this.onModeSelected});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1B1B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.tealAccent.withValues(alpha: 0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.tealAccent.withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'PING PONG PRO',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.tealAccent,
                  letterSpacing: 4,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 32),
              _MenuButton(
                label: 'MULTIJUGADOR (PvP)',
                icon: Icons.sports_tennis,
                onTap: () => onModeSelected(GameMode.pvp),
              ),
              const SizedBox(height: 16),
              _MenuButton(
                label: 'CONTRA LA IA (PvE)',
                icon: Icons.smart_toy,
                onTap: () => onModeSelected(GameMode.pve),
              ),
              const SizedBox(height: 16),
              _MenuButton(
                label: 'SALIR',
                icon: Icons.exit_to_app,
                isDestructive: true,
                onTap: () => SystemNavigator.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyOverlay extends StatelessWidget {
  final AIDifficulty selectedDifficulty;
  final ValueChanged<AIDifficulty> onDifficultyChanged;
  final VoidCallback onStart;
  final VoidCallback onBack;
  const _DifficultyOverlay({
    required this.selectedDifficulty,
    required this.onDifficultyChanged,
    required this.onStart,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1B1B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.tealAccent.withValues(alpha: 0.5), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'SELECCIONA DIFICULTAD',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.tealAccent,
                  letterSpacing: 2,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 24),
              ...AIDifficulty.values.map((d) => _DifficultyTile(
                    difficulty: d,
                    isSelected: d == selectedDifficulty,
                    onTap: () => onDifficultyChanged(d),
                  )),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _MenuButton(
                      label: 'VOLVER',
                      icon: Icons.arrow_back,
                      onTap: onBack,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _MenuButton(
                      label: 'JUGAR',
                      icon: Icons.play_arrow,
                      onTap: onStart,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyTile extends StatelessWidget {
  final AIDifficulty difficulty;
  final bool isSelected;
  final VoidCallback onTap;
  const _DifficultyTile({
    required this.difficulty,
    required this.isSelected,
    required this.onTap,
  });

  String get _label => switch (difficulty) {
    AIDifficulty.easy => 'FÁCIL',
    AIDifficulty.medium => 'MEDIO',
    AIDifficulty.hard => 'DIFÍCIL',
  };

  String get _desc => switch (difficulty) {
    AIDifficulty.easy => 'Reacción lenta, comete errores',
    AIDifficulty.medium => 'Reacción equilibrada',
    AIDifficulty.hard => 'Reacción instantánea, precisión perfecta',
  };

  Color get _color => switch (difficulty) {
    AIDifficulty.easy => Colors.greenAccent,
    AIDifficulty.medium => Colors.orangeAccent,
    AIDifficulty.hard => Colors.redAccent,
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? _color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _color : Colors.tealAccent.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? _color : Colors.transparent,
                border: Border.all(
                  color: isSelected ? _color : Colors.tealAccent.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.black)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _label,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? _color : Colors.white,
                      fontFamily: 'monospace',
                    ),
                  ),
                  Text(
                    _desc,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.tealAccent.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;
  const _MenuButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, color: isDestructive ? Colors.redAccent : Colors.tealAccent),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDestructive ? Colors.redAccent : Colors.white,
            fontFamily: 'monospace',
            letterSpacing: 1,
          ),
        ),
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDestructive
              ? Colors.redAccent.withValues(alpha: 0.1)
              : Colors.tealAccent.withValues(alpha: 0.1),
          foregroundColor: isDestructive ? Colors.redAccent : Colors.tealAccent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isDestructive ? Colors.redAccent : Colors.tealAccent.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

class _GamePainter extends CustomPainter {
  final GameEngine engine;
  _GamePainter({required this.engine});

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / GameConfig.courtWidth;
    final scaleY = size.height / GameConfig.courtHeight;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint..color = const Color(0xFF051010));

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
  bool shouldRepaint(covariant _GamePainter oldDelegate) => true;
}
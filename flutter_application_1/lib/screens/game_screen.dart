import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/game_painter.dart';
import '../widgets/menu_overlay.dart';
import '../widgets/back_to_menu_button.dart';
import '../game/game_engine.dart';
import '../game/ai_opponent.dart';
import '../models/game_config.dart';

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
      builder: (context) => MenuOverlay(
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
      builder: (context) => DifficultyOverlay(
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

  void _returnToMainMenu() {
    _ticker.stop();
    _menuOverlay?.remove();
    _menuOverlay = null;
    _showMenu = true;
    _pressedKeys.clear();
    _engine.reset();
    _showMainMenu();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        body: Stack(
          children: [
            // Game canvas
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
                      painter: GamePainter(engine: _engine),
                      size: Size.infinite,
                    ),
                  ),
                ),
              ),
            ),

            // Touch zones (mobile) - overlay on top of canvas
            if (isMobile && !_showMenu)
              LayoutBuilder(
                builder: (context, constraints) {
                  final courtWidth = constraints.maxWidth;
                  final courtHeight = constraints.maxHeight;
                  return Stack(
                    children: [
                      // Left zone (Player 1) - always active
                      Positioned(
                        left: 0,
                        top: 0,
                        width: courtWidth / 2,
                        height: courtHeight,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onPanUpdate: (d) => _handlePanUpdate(d, true),
                          onPanEnd: (_) {},
                        ),
                      ),
                      // Right zone (Player 2) - only in PvP
                      if (!_engine.vsAI)
                        Positioned(
                          right: 0,
                          top: 0,
                          width: courtWidth / 2,
                          height: courtHeight,
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onPanUpdate: (d) => _handlePanUpdate(d, false),
                            onPanEnd: (_) {},
                          ),
                        ),
                      // Visual divider for PvP mobile
                      if (!_engine.vsAI)
                        Center(
                          child: Container(
                            width: 1,
                            height: courtHeight,
                            color: Colors.tealAccent.withValues(alpha: 0.15),
                          ),
                        ),
                    ],
                  );
                },
              ),

            // Back to menu button (top-left) - only during gameplay
            if (!_showMenu)
              Positioned(
                top: 20,
                left: 20,
                child: BackToMenuButton(
                  onPressed: _returnToMainMenu,
                  color: Colors.tealAccent,
                  size: 48,
                ),
              ),

            // Score
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

            // Controls hint
            if (!_showMenu)
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    _engine.vsAI
                        ? (isMobile ? 'Arrastrar zona izquierda  •  ESPACIO: Pausa' : 'W/S para mover  •  ESPACIO: Pausa')
                        : (isMobile ? 'Arrastrar en cada zona  •  ESPACIO: Pausa' : 'W/S (Izq)  •  ↑/↓ (Der)  •  ESPACIO: Pausa'),
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
    );
  }
}
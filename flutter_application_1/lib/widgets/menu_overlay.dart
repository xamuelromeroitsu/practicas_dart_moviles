import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../game/ai_opponent.dart';

enum GameMode { pvp, pve }

class MenuOverlay extends StatelessWidget {
  final ValueChanged<GameMode> onModeSelected;
  const MenuOverlay({super.key, required this.onModeSelected});

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
              MenuButton(
                label: 'MULTIJUGADOR (PvP)',
                icon: Icons.sports_tennis,
                onTap: () => onModeSelected(GameMode.pvp),
              ),
              const SizedBox(height: 16),
              MenuButton(
                label: 'CONTRA LA IA (PvE)',
                icon: Icons.smart_toy,
                onTap: () => onModeSelected(GameMode.pve),
              ),
              const SizedBox(height: 16),
              MenuButton(
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

class DifficultyOverlay extends StatelessWidget {
  final AIDifficulty selectedDifficulty;
  final ValueChanged<AIDifficulty> onDifficultyChanged;
  final VoidCallback onStart;
  final VoidCallback onBack;
  const DifficultyOverlay({
    super.key,
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
              ...AIDifficulty.values.map((d) => DifficultyTile(
                    difficulty: d,
                    isSelected: d == selectedDifficulty,
                    onTap: () => onDifficultyChanged(d),
                  )),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: MenuButton(
                      label: 'VOLVER',
                      icon: Icons.arrow_back,
                      onTap: onBack,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: MenuButton(
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

class DifficultyTile extends StatelessWidget {
  final AIDifficulty difficulty;
  final bool isSelected;
  final VoidCallback onTap;
  const DifficultyTile({
    super.key,
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

class MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;
  const MenuButton({
    super.key,
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
// ai.dart
import 'package:ping_pong_game/dificultad.dart';
import 'package:ping_pong_game/entities.dart';
import 'package:ping_pong_game/game_config.dart';
import 'dart:math';


class IAPingPong {
  final Dificultad dificultad;
  int _contadorFrames = 0;
  final Random _random = Random();

  IAPingPong(this.dificultad);

  void moverPaleta(Paleta paleta, Pelota pelota) {
    _contadorFrames++;

    // Control de velocidad de reacción (frecuencia de muestreo)
    int tasaReaccion = switch (dificultad) {
      Dificultad.facil => 5,   // Toma decisiones cada 5 frames (reacción lenta)
      Dificultad.medio => 3,   // Reacción moderada
      Dificultad.dificil => 1, // Reacción inmediata en cada frame
    };

    if (_contadorFrames % tasaReaccion != 0) return;

    // Calcular la posición objetivo de la pelota
    int objetivoY = pelota.y;

    // En nivel fácil, agregamos un error aleatorio para que falle ocasionalmente
    if (dificultad == Dificultad.facil && _random.nextDouble() < 0.4) {
      objetivoY += _random.nextInt(7) - 3; // Desvío de hasta +/- 3 casillas
    }

    // Calcular el centro actual de la paleta de la IA
    int centroPaleta = paleta.y + (paleta.alto ~/ 2);

    // Perseguir la posición de la pelota
    if (centroPaleta < objetivoY) {
      paleta.moverAbajo(GameConfig.alto);
    } else if (centroPaleta > objetivoY) {
      paleta.moverArriba();
    }
  }
}
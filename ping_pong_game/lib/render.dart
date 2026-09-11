import 'dart:io';
import 'entities.dart';
import 'game_config.dart';

class Renderer {
  static void limpiarPantalla() {
    stdout.write('\x1B[2J\x1B[H');
  }

  static void dibujarMenuPrincipal(int seleccion) {
    limpiarPantalla();
    print('\x1B[36m========================================\x1B[0m');
    print('\x1B[32m             PING PONG PRO              \x1B[0m');
    print('\x1B[36m========================================\n\x1B[0m');
    print(seleccion == 0 ? '  \x1B[33m> 1. Multijugador (PvP)\x1B[0m' : '    1. Multijugador (PvP)');
    print(seleccion == 1 ? '  \x1B[33m> 2. Contra la IA (PvE)\x1B[0m' : '    2. Contra la IA (PvE)');
    print(seleccion == 2 ? '  \x1B[33m> 3. Salir\x1B[0m' : '    3. Salir');
    print('\n\x1B[90mUsa W/S para mover, ENTER para elegir.\x1B[0m');
  }

  static void dibujarMenuDificultad(int seleccion) {
    limpiarPantalla();
    print('\x1B[36m========================================\x1B[0m');
    print('\x1B[32m         SELECCIONA DIFICULTAD          \x1B[0m');
    print('\x1B[36m========================================\n\x1B[0m');
    print(seleccion == 0 ? '  \x1B[33m> 1. Fácil\x1B[0m' : '    1. Fácil');
    print(seleccion == 1 ? '  \x1B[33m> 2. Medio\x1B[0m' : '    2. Medio');
    print(seleccion == 2 ? '  \x1B[33m> 3. Difícil\x1B[0m' : '    3. Difícil');
    print('\n\x1B[90mUsa W/S para mover, ENTER para elegir.\x1B[0m');
  }

  static void dibujar(Pelota pelota, Paleta j1, Paleta j2, int p1, int p2) {
    final buffer = StringBuffer();
    buffer.write('\x1B[H'); // Mover cursor al origen sin borrar

    // Colores ANSI avanzados
    const reset = '\x1B[0m';
    const colorBorde = '\x1B[38;5;33m'; // Azul cian neón
    const colorRed = '\x1B[38;5;201m'; // Magenta brillante
    const colorPelota = '\x1B[38;5;82m'; // Verde neón
    const colorJ1 = '\x1B[38;5;51m'; // Cian neón
    const colorJ2 = '\x1B[38;5;165m'; // Púrpura/magenta
    const colorMarcador = '\x1B[38;5;220m'; // Amarillo neón

    // Marcador estilizado
    buffer.writeln('$colorMarcador╔${'═' * (GameConfig.ancho - 2)}╗$reset');
    buffer.writeln('$colorMarcador║$colorJ1 P1 (HUMAN): $p1$reset  ${' ' * (GameConfig.ancho - 42)}$reset${colorJ2}P2 (AI): $p2 ║$reset');
    buffer.writeln('$colorMarcador╚${'═' * (GameConfig.ancho - 2)}╝$reset');
    buffer.writeln('');

    // Marco superior reforzado
    buffer.writeln('$colorBorde╔${'═' * (GameConfig.ancho - 2)}╗$reset');

    for (int y = 0; y < GameConfig.alto; y++) {
      buffer.write('$colorBorde║$reset'); // Borde izquierdo reforzado

      for (int x = 1; x < GameConfig.ancho - 1; x++) {
        if (x == pelota.x && y == pelota.y) {
          buffer.write('${colorPelota}O$reset'); // Pelota (requiere llaves porque la 'O' es una letra)
        } else if (x == j1.x && y >= j1.y && y < j1.y + j1.alto) {
          buffer.write('$colorJ1█$reset'); // Paleta J1
        } else if (x == j2.x && y >= j2.y && y < j2.y + j2.alto) {
          buffer.write('$colorJ2█$reset'); // Paleta J2
        } else if (x == GameConfig.ancho ~/ 2) {
          buffer.write('$colorRed┆$reset'); // Red central
        } else {
          buffer.write(' ');
        }
      }
      buffer.writeln('$colorBorde║$reset'); // Borde derecho reforzado
    }

    // Marco inferior reforzado
    buffer.writeln('$colorBorde╚${'═' * (GameConfig.ancho - 2)}╝$reset');
    stdout.write(buffer.toString());
  }
}
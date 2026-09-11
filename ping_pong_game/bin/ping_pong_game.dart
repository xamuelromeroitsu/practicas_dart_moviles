import 'dart:async';
import 'dart:io';

import 'package:ping_pong_game/dificultad.dart';
import 'package:ping_pong_game/entities.dart';
import 'package:ping_pong_game/game_config.dart';
import 'package:ping_pong_game/iapingpong.dart';
import 'package:ping_pong_game/input.dart';
import 'package:ping_pong_game/render.dart';

enum EstadoJuego { menuPrincipal, menuDificultad, jugando }

void main() {
  // Ocultar cursor en la terminal
  stdout.write('\x1B[?25l');

  EstadoJuego estado = EstadoJuego.menuPrincipal;
  int opcionMenuPrincipal = 0;
  int opcionDificultad = 0;

  bool esVsIA = false;
  IAPingPong? ia;
  Timer? loopJuego;

  late Pelota pelota;
  late Paleta j1;
  late Paleta j2;
  int puntajeJ1 = 0;
  int puntajeJ2 = 0;

  // Inicialización y arranque del bucle de juego
  void iniciarPartida() {
    pelota = Pelota(x: GameConfig.ancho ~/ 2, y: GameConfig.alto ~/ 2);
    j1 = Paleta(x: 2, y: 8, alto: GameConfig.tamanoPaleta);
    j2 = Paleta(x: GameConfig.ancho - 3, y: 8, alto: GameConfig.tamanoPaleta);
    puntajeJ1 = 0;
    puntajeJ2 = 0;

    estado = EstadoJuego.jugando;

    loopJuego?.cancel();
    loopJuego = Timer.periodic(GameConfig.frameRate, (timer) {
      pelota.mover();

      if (esVsIA && ia != null) {
        ia!.moverPaleta(j2, pelota);
      }

      if (pelota.y <= 0 || pelota.y >= GameConfig.alto - 1) {
        pelota.rebotarY();
      }

      if (pelota.x == j1.x + 1 && (pelota.y >= j1.y && pelota.y < j1.y + j1.alto)) {
        pelota.rebotarX();
      }

      if (pelota.x == j2.x - 1 && (pelota.y >= j2.y && pelota.y < j2.y + j2.alto)) {
        pelota.rebotarX();
      }

      if (pelota.x <= 0) {
        puntajeJ2++;
        pelota.reiniciar(GameConfig.ancho ~/ 2, GameConfig.alto ~/ 2);
      } else if (pelota.x >= GameConfig.ancho - 1) {
        puntajeJ1++;
        pelota.reiniciar(GameConfig.ancho ~/ 2, GameConfig.alto ~/ 2);
      }

      Renderer.dibujar(pelota, j1, j2, puntajeJ1, puntajeJ2);
    });
  }

  // Dibujar pantalla inicial
  Renderer.dibujarMenuPrincipal(opcionMenuPrincipal);

  // Gestor de entradas por teclado
  configurarTeclado((tecla) {
    if (tecla == 'q') {
      loopJuego?.cancel();
      restaurarTerminal();
      exit(0);
    }

    if (estado == EstadoJuego.menuPrincipal) {
      if (tecla == 'w') {
        opcionMenuPrincipal = (opcionMenuPrincipal - 1) % 3;
        if (opcionMenuPrincipal < 0) opcionMenuPrincipal = 2;
        Renderer.dibujarMenuPrincipal(opcionMenuPrincipal);
      } else if (tecla == 's') {
        opcionMenuPrincipal = (opcionMenuPrincipal + 1) % 3;
        Renderer.dibujarMenuPrincipal(opcionMenuPrincipal);
      } else if (tecla == '\r' || tecla == '\n' || tecla == ' ') {
        if (opcionMenuPrincipal == 0) {
          esVsIA = false;
          iniciarPartida();
        } else if (opcionMenuPrincipal == 1) {
          estado = EstadoJuego.menuDificultad;
          opcionDificultad = 0;
          Renderer.dibujarMenuDificultad(opcionDificultad);
        } else if (opcionMenuPrincipal == 2) {
          restaurarTerminal();
          exit(0);
        }
      }
    } else if (estado == EstadoJuego.menuDificultad) {
      if (tecla == 'w') {
        opcionDificultad = (opcionDificultad - 1) % 3;
        if (opcionDificultad < 0) opcionDificultad = 2;
        Renderer.dibujarMenuDificultad(opcionDificultad);
      } else if (tecla == 's') {
        opcionDificultad = (opcionDificultad + 1) % 3;
        Renderer.dibujarMenuDificultad(opcionDificultad);
      } else if (tecla == '\r' || tecla == '\n' || tecla == ' ') {
        esVsIA = true;
        Dificultad diff = Dificultad.facil;
        if (opcionDificultad == 1) diff = Dificultad.medio;
        if (opcionDificultad == 2) diff = Dificultad.dificil;
        ia = IAPingPong(diff);
        iniciarPartida();
      }
    } else if (estado == EstadoJuego.jugando) {
      // Controles del Jugador 1
      if (tecla == 'w') j1.moverArriba();
      if (tecla == 's') j1.moverAbajo(GameConfig.alto);

      // Controles del Jugador 2 (sólo si no es vs IA)
      if (!esVsIA) {
        if (tecla == 'i') j2.moverArriba();
        if (tecla == 'k') j2.moverAbajo(GameConfig.alto);
      }

      // Regresar al menú con 'm'
      if (tecla == 'm') {
        loopJuego?.cancel();
        estado = EstadoJuego.menuPrincipal;
        Renderer.dibujarMenuPrincipal(opcionMenuPrincipal);
      }
    }
  });
}

void restaurarTerminal() {
  stdout.write('\x1B[?25h'); // Restaurar la visibilidad del cursor
  if (stdin.hasTerminal) {
    try {
  
  stdin.lineMode = true;
  stdin.echoMode = true;
    } catch (_) {}
    print('\n¡Gracias por jugar!');
  }
}
class Pelota {
  int x;
  int y;
  int dx; // Dirección horizontal: 1 (derecha) o -1 (izquierda)
  int dy; // Dirección vertical: 1 (abajo) o -1 (arriba)

  Pelota({required this.x, required this.y, this.dx = 1, this.dy = 1});

  void mover() {
    x += dx;
    y += dy;
  }

  void rebotarY() => dy = -dy;
  void rebotarX() => dx = -dx;

  void reiniciar(int centroX, int centroY) {
    x = centroX;
    y = centroY;
    dx = -dx; // Cambia de lado hacia quien anotó
  }
}

class Paleta {
  int y;
  final int x;
  final int alto;
  final int velocidad; // Cantidad de casillas por pulsación

  Paleta({
    required this.x,
    required this.y,
    required this.alto,
    this.velocidad = 3, // 2 casillas por tecla hace el control reactivo
  });

  void moverArriba() {
    // Evita subir más allá del borde superior (fila 1)
    y = (y - velocidad < 1) ? 1 : y - velocidad;
  }

  void moverAbajo(int limiteInferior) {
    // Evita bajar más allá del marco inferior
    final int limiteMaximo = limiteInferior - alto - 1;
    y = (y + velocidad > limiteMaximo) ? limiteMaximo : y + velocidad;
  }
}
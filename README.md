# Prácticas de Desarrollo de Aplicaciones Móviles 📱

Este repositorio contiene los ejercicios y proyectos desarrollados en el lenguaje **Dart** como parte de las actividades prácticas de la materia de Desarrollo de Aplicaciones Móviles. El repositorio está estructurado para escalar e incluir futuras prácticas a lo largo del curso.

## Proyectos Actuales 🚀

### 1. 🧮 Calculadora Terminal Pro (`calculadora_dart`)
Una calculadora interactiva de línea de comandos (CLI) con una interfaz de usuario mejorada.
* **Características:**
  * Resolución de expresiones matemáticas complejas respetando la precedencia de operadores (ej. `4 + 5 * (3 / 2)`).
  * Manejo seguro de errores de sintaxis y división por cero.
  * Sistema de perfiles de usuario e historial de las últimas operaciones.

### 2. 🏓 Ping Pong Pro (`ping_pong_game`)
Una recreación del clásico juego retro adaptado a la terminal con un estilo visual futurista neón.
* **Características:**
  * **Modo Multijugador (PvP):** Dos jugadores en el mismo teclado (Controles: `W/S` y `I/K`).
  * **Modo vs IA (PvE):** Juega contra la computadora con 3 niveles de dificultad adaptativos.
  * Menús interactivos, renderizado fluido a 33 FPS y sistema de puntuación.

## Requisitos y Ejecución ⚙️

Para ejecutar cualquiera de estos proyectos en tu entorno local, necesitas tener instalado el [Dart SDK](https://dart.dev/get-dart).

1. Clona este repositorio.
2. Navega al directorio del proyecto que deseas probar.
3. Descarga las dependencias (si aplica): `dart pub get`
4. Ejecuta el script principal directamente para evitar problemas con la terminal:
   * Calculadora: `dart bin/calculadora_dart.dart`
   * Ping Pong: `dart bin/ping_pong_game.dart`
import 'dart:io';

void configurarTeclado(Function(String) onTecla) {
  // Verificamos si estamos en una terminal real antes de cambiar los modos
  if (stdin.hasTerminal) {
    try {
      stdin.lineMode = false;
      stdin.echoMode = false;
    } catch (e) {
      // Si el entorno rechaza el cambio, lo ignoramos para que no colapse
    }
  }

  stdin.listen((List<int> codigos) {
    for (var code in codigos) {
      final char = String.fromCharCode(code).toLowerCase();
      onTecla(char);
    }
  });
}
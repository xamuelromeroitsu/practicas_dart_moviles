import 'dart:io';
import 'package:calculadora_dart/calculadora_dart.dart' as mate;

void limpiarConsola() {
  stdout.write('\x1B[2J\x1B[0;0H');
}

void dibujarCalculadora(String usuario, String pantalla, List<String> historial) {
  limpiarConsola();
  
  String display = pantalla.length > 18 
      ? pantalla.substring(pantalla.length - 18) 
      : pantalla.padLeft(18);

  // Paleta de colores
  const reset = '\x1B[0m';
  const cBorde = '\x1B[38;5;51m'; // Cyan neón
  const cDisplay = '\x1B[38;5;48m'; // Verde brillante
  const cBoton = '\x1B[38;5;253m'; // Blanco ceniza
  const cEspecial = '\x1B[38;5;214m'; // Naranja
  const cTexto = '\x1B[38;5;111m'; // Azul claro

  print('$cBorde╭─────────────────────────────────────────╮$reset');
  print('$cBorde│$reset       $cTexto CALCULADORA TERMINAL PRO $reset        $cBorde│$reset');
  print('$cBorde╰─────────────────────────────────────────╯$reset');
  print('  Perfil activo: $cEspecial$usuario$reset\n');

  // Diseño de calculadora
  print('''    $cBorde╭────────────────────────╮$reset
    $cBorde│$reset  $cDisplay$display$reset  $cBorde  │$reset
    $cBorde├────────────────────────┤$reset
    $cBorde│$reset $cEspecial [C]  [(]  [)]   [/] $reset $cBorde │$reset
    $cBorde│$reset $cBoton [7]  [8]  [9] $reset $cEspecial [*] $reset $cBorde │$reset
    $cBorde│$reset $cBoton [4]  [5]  [6] $reset $cEspecial [-] $reset $cBorde │$reset
    $cBorde│$reset $cBoton [1]  [2]  [3] $reset $cEspecial [+] $reset $cBorde │$reset
    $cBorde│$reset $cBoton [0]  [.]  [=] $reset      $cBorde  │$reset
    $cBorde╰────────────────────────╯$reset''');

  if (historial.isNotEmpty) {
    print('\n  $cTexto• Historial de operaciones •$reset');
    for (var item in historial.reversed.take(3)) {
      print('    $cEspecial>$reset $item');
    }
    print('');
  }
}

void main() {
  limpiarConsola();
  print('Iniciando Calculadora Terminal Pro...\n');

  while (true) {
    stdout.write('Introduce tu nombre de perfil (o escribe "salir"): ');
    String? inputNombre = stdin.readLineSync()?.trim();

    if (inputNombre == null || inputNombre.toLowerCase() == 'salir') {
      print('\nApagando el sistema. ¡Adiós!');
      break;
    }

    String perfil = inputNombre.isEmpty ? 'Invitado' : inputNombre;
    List<String> historialOperaciones = [];
    bool enMenu = true;

    while (enMenu) {
      dibujarCalculadora(
        perfil, 
        historialOperaciones.isEmpty ? '0' : historialOperaciones.last.split('=').last.trim(), 
        historialOperaciones
      );

      print('Acciones disponibles:');
      print(' 1. Ingresar nueva expresión matemática (ej: 4 * 2 + 8)');
      print(' 2. Cambiar de perfil');
      print(' 3. Salir');
      stdout.write('\nElige una opción: ');

      String? opcion = stdin.readLineSync()?.trim();

      switch (opcion) {
        case '3':
          limpiarConsola();
          print('¡Nos vemos, $perfil!\n');
          return; // Finalizacion del script
        case '2':
          enMenu = false; // Rompe el bucle y pide el nombre de nuevo
          limpiarConsola();
          break;
        case '1':
          stdout.write('\nEscribe tu operación: ');
          String operacion = stdin.readLineSync()?.trim() ?? '';

          if (operacion.isNotEmpty) {
            try {
              final resultado = mate.procesarFormula(operacion);
              historialOperaciones.add('$operacion = $resultado');
            } catch (error) {
              dibujarCalculadora(perfil, 'ERROR SINTAXIS', historialOperaciones);
              
              String mensajeError = error.toString().replaceAll('Invalid argument(s): ', '');
              print('\x1B[31m[Error]\x1B[0m $mensajeError');
              stdout.write('\nPresiona ENTER para continuar...');
              stdin.readLineSync();
            }
          }
          break;
        default:
          // Si el usuario ingresa algo inválido, el bucle vuelve a dibujar la interfaz
          break;
      }
    }
  }
}
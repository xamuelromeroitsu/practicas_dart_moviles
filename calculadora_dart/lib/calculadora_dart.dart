import 'package:expressions/expressions.dart';

// Funciones aritméticas base
double adicion(double a, double b) => a + b;
double sustraccion(double a, double b) => a - b;
double producto(double a, double b) => a * b;

double cociente(double a, double b) {
  if (b == 0) {
    throw ArgumentError('Operación inválida: División por cero.');
  }
  return a / b;
}

/// Analiza y resuelve una ecuación matemática en formato string
num procesarFormula(String operacion) {
  try {
    // Convertimos el texto en una expresión evaluable
    final expresionParseada = Expression.parse(operacion);
    const evaluador = ExpressionEvaluator();
    
    // Evaluamos la expresión
    final resultado = evaluador.eval(expresionParseada, {});
    
    if (resultado is num) {
      // Validamos que el resultado no sea infinito (ej. dividir 5/0 en algunos contextos)
      if (resultado.isInfinite || resultado.isNaN) {
        throw ArgumentError('Resultado no definido (posible división por cero).');
      }
      return resultado;
    }
    
    throw ArgumentError('El cálculo no devolvió un valor numérico.');
  } catch (e) {
    // Si la librería falla al leer el string (ej. "4 + * 5"), atrapamos el error aquí
    throw ArgumentError('Error de sintaxis en la ecuación.');
  }
}
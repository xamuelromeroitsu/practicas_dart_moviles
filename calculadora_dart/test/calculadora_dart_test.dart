import 'package:calculadora_dart/calculadora_dart.dart';
import 'package:test/test.dart';

void main() {
  test('Prueba de evaluación matemática básica', () {
    expect(procesarFormula('2 + 2 * 3'), 8);
    expect(procesarFormula('10 / 2'), 5);
  });
}
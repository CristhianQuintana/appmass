import 'package:intl/intl.dart';

/// Soles peruanos en céntimos. Evita el error de los números binarios.
class Money {
  const Money(this.cents);

  final int cents;

  static final NumberFormat _format = NumberFormat.currency(
    locale: 'es_PE',
    name: 'PEN',
    symbol: 'S/',
    decimalDigits: 2,
  );

  int lineTotal(int quantity) {
    if (quantity < 1 || quantity > 99) {
      throw ArgumentError('Cantidad fuera de rango.');
    }
    if (cents < 0) {
      throw ArgumentError('El precio no puede ser negativo.');
    }
    return cents * quantity;
  }

  String get label => _format.format(cents / 100);
}

/// Convierte un importe escrito en soles a céntimos, sin usar binarios.
int? parseSolesToCents(String raw) {
  final cleaned = raw.trim().replaceAll(',', '.');
  if (!RegExp(r'^\d{1,7}(\.\d{1,2})?$').hasMatch(cleaned)) return null;
  final parts = cleaned.split('.');
  final soles = int.parse(parts[0]);
  final fraction = parts.length == 1 ? 0 : int.parse(parts[1].padRight(2, '0'));
  return soles * 100 + fraction;
}

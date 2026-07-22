/// Formatea un valor double como pesos colombianos con puntos de miles.
/// Ejemplo: 150000.0 -> "$150.000"
String formatearMoneda(double valor) {
  final int entero = valor.round();
  final String signo = entero < 0 ? '-' : '';
  final String digitos = entero.abs().toString();

  final StringBuffer buffer = StringBuffer();
  for (int i = 0; i < digitos.length; i++) {
    final int posicionDesdeDerecha = digitos.length - i;
    buffer.write(digitos[i]);
    final bool esMultiploDeTres =
        posicionDesdeDerecha > 1 && (posicionDesdeDerecha - 1) % 3 == 0;
    if (esMultiploDeTres) {
      buffer.write('.');
    }
  }
  return '$signo\$${buffer.toString()}';
}

/// Formatea una fecha como dd/mm/aaaa.
String formatearFecha(DateTime fecha) {
  final String dia = fecha.day.toString().padLeft(2, '0');
  final String mes = fecha.month.toString().padLeft(2, '0');
  final String anio = fecha.year.toString();
  return '$dia/$mes/$anio';
}

/// Verifica si dos fechas corresponden al mismo día (ignora la hora).
bool esMismoDia(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

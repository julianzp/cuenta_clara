// Funciones pequeñas que no dependen de paquetes externos.
String formatearFecha(DateTime fecha) {
  final dia = fecha.day.toString().padLeft(2, '0');
  final mes = fecha.month.toString().padLeft(2, '0');
  return '$dia/$mes/${fecha.year}';
}

// Ejemplo: 1250000 -> $1.250.000
String formatearPesos(int valor) {
  final negativo = valor < 0;
  final digitos = valor.abs().toString();
  final resultado = StringBuffer();
  for (var i = 0; i < digitos.length; i++) {
    if (i > 0 && (digitos.length - i) % 3 == 0) {
      resultado.write('.');
    }
    resultado.write(digitos[i]);
  }
  return '${negativo ? '-' : ''}\$${resultado.toString()}';
}

// Comparar fechas sin la hora (medianoche de cada día).
DateTime soloFecha(DateTime fecha) =>
    DateTime(fecha.year, fecha.month, fecha.day);

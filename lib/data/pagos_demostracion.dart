import '../models/pago.dart';

// Datos ficticios para que la pantalla no inicie vacía.
// En próximas sesiones serán reemplazados por almacenamiento persistente.
List<Pago> crearPagosDemostracion() {
  final hoy = DateTime.now();
  DateTime relativo(int dias) => DateTime(hoy.year, hoy.month, hoy.day + dias);
  return [
    Pago(
      id: 'demo-1',
      concepto: 'Internet del hogar',
      categoria: CategoriaPago.servicios,
      monto: 110000,
      fechaVencimiento: relativo(3),
      pagado: false,
      nota: 'Factura mensual',
    ),
    Pago(
      id: 'demo-2',
      concepto: 'Arriendo',
      categoria: CategoriaPago.vivienda,
      monto: 950000,
      fechaVencimiento: relativo(-2),
      pagado: false,
      nota: 'Revisar antes de pagar',
    ),
    Pago(
      id: 'demo-3',
      concepto: 'Transporte',
      categoria: CategoriaPago.transporte,
      monto: 85000,
      fechaVencimiento: relativo(-1),
      pagado: true,
      nota: '',
    ),
  ];
}

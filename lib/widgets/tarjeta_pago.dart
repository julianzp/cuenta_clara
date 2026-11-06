import 'package:flutter/material.dart';

import '../models/pago.dart';
import '../utils/formato.dart';

// Enum = opciones cerradas del menú de acciones
enum AccionPago { editar, cambiarEstado, eliminar }

class TarjetaPago extends StatelessWidget {
  final Pago pago;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;
  final VoidCallback onCambiarEstado;

  const TarjetaPago({
    super.key,
    required this.pago,
    required this.onEditar,
    required this.onEliminar,
    required this.onCambiarEstado,
  });

  String get _estado {
    if (pago.pagado) return 'Pagado';
    final hoy = soloFecha(DateTime.now());
    final vencimiento = soloFecha(pago.fechaVencimiento);
    if (vencimiento.isBefore(hoy)) return 'Vencido';
    if (vencimiento.isAtSameMomentAs(hoy)) return 'Vence hoy';
    return 'Pendiente';
  }

  @override
  Widget build(BuildContext context) {
    final color = pago.pagado
        ? Colors.green.shade700
        : _estado == 'Vencido'
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          child: Icon(pago.pagado ? Icons.check : Icons.receipt_long),
        ),
        title: Text(
          pago.concepto,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${pago.categoria.etiqueta} - ${formatearFecha(pago.fechaVencimiento)}',
            ),
            const SizedBox(height: 4),
            Text(
              formatearPesos(pago.monto),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              _estado,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
            if (pago.nota.trim().isNotEmpty) Text('Nota: ${pago.nota}'),
          ],
        ),
        // Pulsar la tarjeta también permite editar
        onTap: onEditar,
        trailing: PopupMenuButton<AccionPago>(
          tooltip: 'Acciones del pago',
          onSelected: (accion) {
            switch (accion) {
              case AccionPago.editar:
                onEditar();
              case AccionPago.cambiarEstado:
                onCambiarEstado();
              case AccionPago.eliminar:
                onEliminar();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: AccionPago.editar,
              child: Text('Editar'),
            ),
            PopupMenuItem(
              value: AccionPago.cambiarEstado,
              child: Text(
                pago.pagado ? 'Marcar como pendiente' : 'Marcar como pagado',
              ),
            ),
            const PopupMenuItem(
              value: AccionPago.eliminar,
              child: Text('Eliminar'),
            ),
          ],
        ),
      ),
    );
  }
}

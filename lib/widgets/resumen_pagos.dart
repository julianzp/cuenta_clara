import 'package:flutter/material.dart';

import '../utils/formato.dart';

// Widget reutilizable: solo recibe datos y dibuja tarjetas de resumen.
class ResumenPagos extends StatelessWidget {
  final int totalPendiente;
  final int totalPagado;
  final int cantidadVencidos;

  const ResumenPagos({
    super.key,
    required this.totalPendiente,
    required this.totalPagado,
    required this.cantidadVencidos,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _indicador(
            context,
            'Por pagar',
            formatearPesos(totalPendiente),
            Icons.schedule_outlined,
          ),
          _indicador(
            context,
            'Pagado',
            formatearPesos(totalPagado),
            Icons.check_circle_outline,
          ),
          _indicador(
            context,
            'Vencidos',
            '$cantidadVencidos',
            Icons.warning_amber_outlined,
          ),
        ],
      ),
    );
  }

  Widget _indicador(
    BuildContext context,
    String titulo,
    String valor,
    IconData icono,
  ) {
    final esquema = Theme.of(context).colorScheme;
    return SizedBox(
      width: 165,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icono, color: esquema.primary),
              const SizedBox(height: 6),
              Text(titulo, style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 3),
              Text(
                valor,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

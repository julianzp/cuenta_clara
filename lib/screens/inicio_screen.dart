import 'package:flutter/material.dart';

import '../data/pagos_demostracion.dart';
import '../models/pago.dart';
import '../utils/formato.dart';
import '../widgets/resumen_pagos.dart';
import '../widgets/tarjeta_pago.dart';
import 'formulario_pago_screen.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  // Fuente de verdad temporal: una sola lista en la pantalla principal.
  // En la sesión de persistencia se reemplazará por un repositorio.
  final List<Pago> _pagos = crearPagosDemostracion();

  Future<void> _abrirFormulario([Pago? pagoActual]) async {
    // Navegamos a otra pantalla y esperamos un Pago, o null si cancela.
    final resultado = await Navigator.push<Pago>(
      context,
      MaterialPageRoute(
        builder: (context) => FormularioPagoScreen(pagoExistente: pagoActual),
      ),
    );
    if (!mounted || resultado == null) return;

    setState(() {
      if (pagoActual == null) {
        _pagos.add(resultado); // CREATE: agregar al listado.
      } else {
        final indice = _pagos.indexWhere((p) => p.id == pagoActual.id);
        if (indice != -1) _pagos[indice] = resultado; // UPDATE: editar.
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          pagoActual == null ? 'Pago registrado' : 'Pago actualizado',
        ),
      ),
    );
  }

  void _cambiarEstado(Pago pago) {
    setState(() {
      final indice = _pagos.indexWhere((p) => p.id == pago.id);
      if (indice != -1) {
        _pagos[indice] = pago.copyWith(pagado: !pago.pagado);
      }
    });
  }

  Future<void> _eliminar(Pago pago) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar pago'),
        content: Text('¿Desea eliminar "${pago.concepto}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (!mounted || confirmar != true) return;

    setState(() => _pagos.removeWhere((elemento) => elemento.id == pago.id));

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Pago eliminado')));
  }

  Widget _lista(List<Pago> datos) {
    if (datos.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('No hay pagos en esta sección.'),
        ),
      );
    }

    // READ: ListView.builder crea las tarjetas de manera dinámica.
    return ListView.builder(
      itemCount: datos.length,
      itemBuilder: (context, indice) {
        final pago = datos[indice];
        return TarjetaPago(
          key: ValueKey(pago.id),
          pago: pago,
          onEditar: () => _abrirFormulario(pago),
          onCambiarEstado: () => _cambiarEstado(pago),
          onEliminar: () => _eliminar(pago),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendientes = _pagos.where((p) => !p.pagado).toList();
    final pagados = _pagos.where((p) => p.pagado).toList();
    final hoy = soloFecha(DateTime.now());

    final totalPendiente = pendientes.fold<int>(
      0,
      (total, p) => total + p.monto,
    );
    final totalPagado = pagados.fold<int>(0, (total, p) => total + p.monto);
    final vencidos = pendientes
        .where((p) => soloFecha(p.fechaVencimiento).isBefore(hoy))
        .length;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('CuentaClara'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Todos'),
              Tab(text: 'Pendientes'),
              Tab(text: 'Pagados'),
            ],
          ),
        ),
        body: Column(
          children: [
            ResumenPagos(
              totalPendiente: totalPendiente,
              totalPagado: totalPagado,
              cantidadVencidos: vencidos,
            ),
            // Expanded ocupa el espacio disponible debajo del resumen.
            Expanded(
              child: TabBarView(
                children: [_lista(_pagos), _lista(pendientes), _lista(pagados)],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _abrirFormulario(),
          icon: const Icon(Icons.add),
          label: const Text('Nuevo pago'),
        ),
      ),
    );
  }
}

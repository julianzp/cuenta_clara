import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/pago.dart';
import '../utils/formato.dart';

class FormularioPagoScreen extends StatefulWidget {
  final Pago? pagoExistente; // null = creación; con valor = edición

  const FormularioPagoScreen({super.key, this.pagoExistente});

  @override
  State<FormularioPagoScreen> createState() => _FormularioPagoScreenState();
}

class _FormularioPagoScreenState extends State<FormularioPagoScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _conceptoController;
  late final TextEditingController _montoController;
  late final TextEditingController _notaController;

  late CategoriaPago _categoria;
  late DateTime _fechaVencimiento;
  late bool _pagado;

  bool get _editando => widget.pagoExistente != null;

  @override
  void initState() {
    super.initState();
    final pago = widget.pagoExistente;
    _conceptoController = TextEditingController(text: pago?.concepto ?? '');
    _montoController = TextEditingController(
      text: pago?.monto.toString() ?? '',
    );
    _notaController = TextEditingController(text: pago?.nota ?? '');
    _categoria = pago?.categoria ?? CategoriaPago.servicios;
    _fechaVencimiento = pago?.fechaVencimiento ?? DateTime.now();
    _pagado = pago?.pagado ?? false;
  }

  @override
  void dispose() {
    _conceptoController.dispose();
    _montoController.dispose();
    _notaController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final hoy = DateTime.now();
    final primera = DateTime(hoy.year - 5);
    final ultima = DateTime(hoy.year + 10, 12, 31);
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fechaVencimiento,
      // El rango se amplía para que un pago con fecha fuera de él se pueda
      // editar: showDatePicker falla si initialDate queda fuera del rango.
      firstDate: _fechaVencimiento.isBefore(primera)
          ? _fechaVencimiento
          : primera,
      lastDate: _fechaVencimiento.isAfter(ultima) ? _fechaVencimiento : ultima,
      helpText: 'Selecciona la fecha de vencimiento',
    );
    if (!mounted || elegida == null) return;
    setState(() => _fechaVencimiento = elegida);
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;

    final anterior = widget.pagoExistente;
    final concepto = _conceptoController.text.trim();
    final monto = int.parse(_montoController.text.trim());
    final nota = _notaController.text.trim();

    final resultado = anterior == null
        ? Pago(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            concepto: concepto,
            categoria: _categoria,
            monto: monto,
            fechaVencimiento: _fechaVencimiento,
            pagado: _pagado,
            nota: nota,
          )
        : anterior.copyWith(
            concepto: concepto,
            categoria: _categoria,
            monto: monto,
            fechaVencimiento: _fechaVencimiento,
            pagado: _pagado,
            nota: nota,
          );

    Navigator.pop(context, resultado);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_editando ? 'Editar pago' : 'Nuevo pago')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _conceptoController,
              maxLength: 60,
              decoration: const InputDecoration(
                labelText: 'Concepto',
                hintText: 'Ej. Luz, Agua, Gas, Internet...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description_outlined),
              ),
              validator: (valor) {
                if (valor == null || valor.trim().isEmpty) {
                  return 'El concepto es obligatorio';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _montoController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Monto en COP',
                hintText: 'Ej. 120000 (sin puntos)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              validator: (valor) {
                final monto = int.tryParse(valor?.trim() ?? '');
                if (monto == null || monto <= 0) {
                  return 'El monto debe ser mayor a cero';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<CategoriaPago>(
              initialValue: _categoria,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: CategoriaPago.values.map((categoria) {
                return DropdownMenuItem(
                  value: categoria,
                  child: Text(categoria.etiqueta),
                );
              }).toList(),
              onChanged: (valor) {
                if (valor != null) setState(() => _categoria = valor);
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _seleccionarFecha,
              icon: const Icon(Icons.calendar_month_outlined),
              label: Text('Vence el ${formatearFecha(_fechaVencimiento)}'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notaController,
              maxLength: 120,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Nota (opcional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note_alt_outlined),
              ),
            ),
            SwitchListTile(
              title: const Text('¿Ya está pagado?'),
              value: _pagado,
              onChanged: (valor) => setState(() => _pagado = valor),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _guardar,
              icon: const Icon(Icons.save_alt_outlined),
              label: Text(_editando ? 'Guardar cambios' : 'Registrar pago'),
            ),
          ],
        ),
      ),
    );
  }
}

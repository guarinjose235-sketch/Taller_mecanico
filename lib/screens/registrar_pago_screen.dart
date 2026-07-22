import 'package:flutter/material.dart';
import '../db/pagos_helper.dart';
import '../models/pago_trabajador.dart';
import '../utils/formato.dart';

class RegistrarPagoScreen extends StatefulWidget {
  const RegistrarPagoScreen({super.key});

  @override
  State<RegistrarPagoScreen> createState() => _RegistrarPagoScreenState();
}

class _RegistrarPagoScreenState extends State<RegistrarPagoScreen> {
  final _formKey = GlobalKey<FormState>();

  final _trabajadorCtrl = TextEditingController();
  final _conceptoCtrl = TextEditingController();
  final _montoCtrl = TextEditingController();

  DateTime _fecha = DateTime.now();
  bool _guardando = false;

  @override
  void dispose() {
    _trabajadorCtrl.dispose();
    _conceptoCtrl.dispose();
    _montoCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? seleccionada = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2015),
      lastDate: DateTime(2100),
    );
    if (seleccionada != null) {
      setState(() => _fecha = seleccionada);
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    final pago = PagoTrabajador(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      trabajador: _trabajadorCtrl.text.trim(),
      concepto: _conceptoCtrl.text.trim(),
      monto: double.tryParse(_montoCtrl.text.trim()) ?? 0.0,
      fecha: _fecha,
    );

    try {
      await PagosHelper.instancia.insertarPago(pago);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar pago')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _trabajadorCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre del trabajador',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _conceptoCtrl,
              decoration: const InputDecoration(
                labelText: 'Concepto (ej. quincena, trabajo, adelanto)',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _montoCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Monto (COP)',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Campo obligatorio';
                if (double.tryParse(v.trim()) == null) return 'Monto inválido';
                return null;
              },
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _seleccionarFecha,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Fecha del pago',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(formatearFecha(_fecha)),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _guardando ? null : _guardar,
                icon: _guardando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: const Text('Registrar pago'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

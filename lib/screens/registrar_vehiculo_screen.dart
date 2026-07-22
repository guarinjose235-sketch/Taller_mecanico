import 'package:flutter/material.dart';
import '../models/vehiculo.dart';
import '../utils/formato.dart';

class RegistrarVehiculoScreen extends StatefulWidget {
  final Future<void> Function(Vehiculo vehiculo, {required bool esNuevo})
      onGuardar;
  final Vehiculo? vehiculoExistente;

  const RegistrarVehiculoScreen({
    super.key,
    required this.onGuardar,
    this.vehiculoExistente,
  });

  @override
  State<RegistrarVehiculoScreen> createState() =>
      _RegistrarVehiculoScreenState();
}

class _RegistrarVehiculoScreenState extends State<RegistrarVehiculoScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _clienteNombreCtrl;
  late TextEditingController _clienteTelefonoCtrl;
  late TextEditingController _marcaCtrl;
  late TextEditingController _modeloCtrl;
  late TextEditingController _colorCtrl;
  late TextEditingController _placaCtrl;
  late TextEditingController _kilometrajeCtrl;
  late TextEditingController _precioCtrl;
  late TextEditingController _otroTrabajoCtrl;

  late TipoVehiculo _tipo;
  late Set<String> _trabajosSeleccionados;
  late EstadoVehiculo _estado;
  late DateTime _fechaIngreso;
  DateTime? _fechaEntrega;

  bool _guardando = false;

  bool get _esEdicion => widget.vehiculoExistente != null;

  @override
  void initState() {
    super.initState();
    final v = widget.vehiculoExistente;

    _clienteNombreCtrl = TextEditingController(text: v?.clienteNombre ?? '');
    _clienteTelefonoCtrl =
        TextEditingController(text: v?.clienteTelefono ?? '');
    _marcaCtrl = TextEditingController(text: v?.marca ?? '');
    _modeloCtrl = TextEditingController(text: v?.modelo ?? '');
    _colorCtrl = TextEditingController(text: v?.color ?? '');
    _placaCtrl = TextEditingController(text: v?.placa ?? '');
    _kilometrajeCtrl = TextEditingController(text: v?.kilometraje ?? '');
    _precioCtrl = TextEditingController(
      text: v != null ? v.precio.toStringAsFixed(0) : '',
    );
    _otroTrabajoCtrl = TextEditingController(text: v?.otroTrabajo ?? '');

    _tipo = v?.tipo ?? TipoVehiculo.carro;
    _trabajosSeleccionados = (v?.trabajos ?? <String>[]).toSet();
    _estado = v?.estado ?? EstadoVehiculo.pendiente;
    _fechaIngreso = v?.fechaIngreso ?? DateTime.now();
    _fechaEntrega = v?.fechaEntrega;
  }

  @override
  void dispose() {
    _clienteNombreCtrl.dispose();
    _clienteTelefonoCtrl.dispose();
    _marcaCtrl.dispose();
    _modeloCtrl.dispose();
    _colorCtrl.dispose();
    _placaCtrl.dispose();
    _kilometrajeCtrl.dispose();
    _precioCtrl.dispose();
    _otroTrabajoCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha({required bool esIngreso}) async {
    final DateTime inicial =
        esIngreso ? _fechaIngreso : (_fechaEntrega ?? DateTime.now());
    final DateTime? seleccionada = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: DateTime(2015),
      lastDate: DateTime(2100),
    );
    if (seleccionada != null) {
      setState(() {
        if (esIngreso) {
          _fechaIngreso = seleccionada;
        } else {
          _fechaEntrega = seleccionada;
        }
      });
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_trabajosSeleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos un trabajo')),
      );
      return;
    }

    setState(() => _guardando = true);

    final String id = widget.vehiculoExistente?.id ??
        DateTime.now().microsecondsSinceEpoch.toString();

    final Vehiculo vehiculo = Vehiculo(
      id: id,
      clienteNombre: _clienteNombreCtrl.text.trim(),
      clienteTelefono: _clienteTelefonoCtrl.text.trim(),
      tipo: _tipo,
      marca: _marcaCtrl.text.trim(),
      modelo: _modeloCtrl.text.trim(),
      color: _colorCtrl.text.trim(),
      placa: _placaCtrl.text.trim().toUpperCase(),
      kilometraje: _kilometrajeCtrl.text.trim().isEmpty
          ? null
          : _kilometrajeCtrl.text.trim(),
      trabajos: _trabajosSeleccionados.toList(),
      otroTrabajo: _otroTrabajoCtrl.text.trim(),
      precio: double.tryParse(_precioCtrl.text.trim()) ?? 0.0,
      estado: _estado,
      fechaIngreso: _fechaIngreso,
      fechaEntrega: _fechaEntrega,
    );

    try {
      await widget.onGuardar(vehiculo, esNuevo: !_esEdicion);
      if (!mounted) return;
      // Solo un pop, sin importar desde dónde se abrió esta pantalla.
      Navigator.pop(context);
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
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar vehículo' : 'Registrar vehículo'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _seccionTitulo('Datos del cliente'),
            TextFormField(
              controller: _clienteNombreCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre del cliente',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _clienteTelefonoCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Teléfono del cliente',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
            ),
            const SizedBox(height: 20),
            _seccionTitulo('Tipo de vehículo'),
            Wrap(
              spacing: 10,
              children: TipoVehiculo.values.map((t) {
                final seleccionado = _tipo == t;
                return ChoiceChip(
                  label: Text(t.etiqueta),
                  avatar: Icon(t.icono, size: 18),
                  selected: seleccionado,
                  onSelected: (_) => setState(() => _tipo = t),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            _seccionTitulo('Datos del vehículo'),
            TextFormField(
              controller: _marcaCtrl,
              decoration: const InputDecoration(
                labelText: 'Marca',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _modeloCtrl,
              decoration: const InputDecoration(
                labelText: 'Modelo',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _colorCtrl,
              decoration: const InputDecoration(
                labelText: 'Color',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _placaCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Placa',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _kilometrajeCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Kilometraje (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            _seccionTitulo('Trabajos solicitados'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tiposDeTrabajo.map((trabajo) {
                final seleccionado = _trabajosSeleccionados.contains(trabajo);
                return FilterChip(
                  label: Text(trabajo),
                  selected: seleccionado,
                  onSelected: (marcado) {
                    setState(() {
                      if (marcado) {
                        _trabajosSeleccionados.add(trabajo);
                      } else {
                        _trabajosSeleccionados.remove(trabajo);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            if (_trabajosSeleccionados.contains('Otro')) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _otroTrabajoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Especifique el otro trabajo',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (_trabajosSeleccionados.contains('Otro') &&
                      (v == null || v.trim().isEmpty)) {
                    return 'Describe el trabajo';
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 20),
            _seccionTitulo('Precio y estado'),
            TextFormField(
              controller: _precioCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Precio (COP)',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Campo obligatorio';
                if (double.tryParse(v.trim()) == null) return 'Precio inválido';
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<EstadoVehiculo>(
              value: _estado,
              decoration: const InputDecoration(
                labelText: 'Estado',
                border: OutlineInputBorder(),
              ),
              items: EstadoVehiculo.values.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(e.icono, size: 18, color: e.color),
                      const SizedBox(width: 8),
                      Text(e.etiqueta),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (nuevoEstado) {
                if (nuevoEstado == null) return;
                setState(() {
                  _estado = nuevoEstado;
                  if (nuevoEstado == EstadoVehiculo.entregado &&
                      _fechaEntrega == null) {
                    _fechaEntrega = DateTime.now();
                  }
                });
              },
            ),
            const SizedBox(height: 20),
            _seccionTitulo('Fechas'),
            _selectorFecha(
              etiqueta: 'Fecha de ingreso',
              fecha: _fechaIngreso,
              onTap: () => _seleccionarFecha(esIngreso: true),
            ),
            const SizedBox(height: 12),
            _selectorFecha(
              etiqueta: 'Fecha de entrega (opcional)',
              fecha: _fechaEntrega,
              onTap: () => _seleccionarFecha(esIngreso: false),
              onLimpiar: _fechaEntrega != null
                  ? () => setState(() => _fechaEntrega = null)
                  : null,
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
                label:
                    Text(_esEdicion ? 'Guardar cambios' : 'Registrar vehículo'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _seccionTitulo(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        texto,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _selectorFecha({
    required String etiqueta,
    required DateTime? fecha,
    required VoidCallback onTap,
    VoidCallback? onLimpiar,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: etiqueta,
          border: const OutlineInputBorder(),
          suffixIcon: onLimpiar != null
              ? IconButton(icon: const Icon(Icons.clear), onPressed: onLimpiar)
              : const Icon(Icons.calendar_today),
        ),
        child: Text(fecha != null ? formatearFecha(fecha) : 'Sin definir'),
      ),
    );
  }
}

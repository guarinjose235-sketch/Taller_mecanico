import 'package:flutter/material.dart';
import '../models/vehiculo.dart';
import '../utils/formato.dart';
import 'registrar_vehiculo_screen.dart';

class DetalleVehiculoScreen extends StatefulWidget {
  final Vehiculo vehiculo;
  final Future<void> Function(Vehiculo vehiculo, {required bool esNuevo})
      onGuardar;
  final Future<void> Function(String id) onEliminar;

  const DetalleVehiculoScreen({
    super.key,
    required this.vehiculo,
    required this.onGuardar,
    required this.onEliminar,
  });

  @override
  State<DetalleVehiculoScreen> createState() => _DetalleVehiculoScreenState();
}

class _DetalleVehiculoScreenState extends State<DetalleVehiculoScreen> {
  late Vehiculo _vehiculo;
  bool _procesando = false;

  @override
  void initState() {
    super.initState();
    _vehiculo = widget.vehiculo;
  }

  Future<void> _irAEditar() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegistrarVehiculoScreen(
          onGuardar: widget.onGuardar,
          vehiculoExistente: _vehiculo,
        ),
      ),
    );
    // La pantalla de registro ya hizo su propio pop al guardar.
    // Aquí solo refrescamos la vista de detalle con los datos actuales
    // (el estado real vive en la base de datos; como no releemos aquí,
    // simplemente cerramos el detalle para que la lista se refresque).
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _marcarComoTerminado() async {
    setState(() => _procesando = true);
    final actualizado = _vehiculo.copyWith(estado: EstadoVehiculo.terminado);
    try {
      await widget.onGuardar(actualizado, esNuevo: false);
      if (!mounted) return;
      setState(() {
        _vehiculo = actualizado;
        _procesando = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehículo marcado como terminado')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _procesando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo actualizar: $e')),
      );
    }
  }

  Future<void> _marcarComoEntregado() async {
    setState(() => _procesando = true);
    final actualizado = _vehiculo.copyWith(
      estado: EstadoVehiculo.entregado,
      fechaEntrega: DateTime.now(),
    );
    try {
      await widget.onGuardar(actualizado, esNuevo: false);
      if (!mounted) return;
      setState(() {
        _vehiculo = actualizado;
        _procesando = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehículo marcado como entregado')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _procesando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo actualizar: $e')),
      );
    }
  }

  Future<void> _confirmarEliminar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar vehículo'),
        content: Text(
          '¿Seguro que deseas eliminar el vehículo con placa ${_vehiculo.placa}? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _procesando = true);
    try {
      await widget.onEliminar(_vehiculo.id);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _procesando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = _vehiculo;
    return Scaffold(
      appBar: AppBar(title: Text('${v.placa} · ${v.marca} ${v.modelo}')),
      body: AbsorbPointer(
        absorbing: _procesando,
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(v.tipo.icono,
                            size: 40, color: const Color(0xFF1565C0)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${v.marca} ${v.modelo}',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text('${v.tipo.etiqueta} · ${v.color}'),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: v.estado.color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            v.estado.etiqueta,
                            style: TextStyle(
                              color: v.estado.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _seccion('Datos del cliente', [
                  _fila('Nombre', v.clienteNombre),
                  _fila('Teléfono', v.clienteTelefono),
                ]),
                _seccion('Datos del vehículo', [
                  _fila('Placa', v.placa),
                  _fila('Marca', v.marca),
                  _fila('Modelo', v.modelo),
                  _fila('Color', v.color),
                  if (v.kilometraje != null && v.kilometraje!.isNotEmpty)
                    _fila('Kilometraje', '${v.kilometraje} km'),
                ]),
                _seccion('Trabajos solicitados', [
                  _fila('Detalle', v.resumenTrabajos()),
                ]),
                _seccion('Precio y fechas', [
                  _fila('Precio', formatearMoneda(v.precio)),
                  _fila('Fecha de ingreso', formatearFecha(v.fechaIngreso)),
                  _fila(
                    'Fecha de entrega',
                    v.fechaEntrega != null
                        ? formatearFecha(v.fechaEntrega!)
                        : 'Aún no entregado',
                  ),
                ]),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _irAEditar,
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar'),
                    ),
                    if (v.estado != EstadoVehiculo.terminado &&
                        v.estado != EstadoVehiculo.entregado)
                      ElevatedButton.icon(
                        onPressed: _marcarComoTerminado,
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Marcar terminado'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    if (v.estado != EstadoVehiculo.entregado)
                      ElevatedButton.icon(
                        onPressed: _marcarComoEntregado,
                        icon: const Icon(Icons.done_all),
                        label: const Text('Marcar entregado'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[700],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ElevatedButton.icon(
                      onPressed: _confirmarEliminar,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Eliminar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
            if (_procesando)
              const Positioned.fill(
                child: ColoredBox(
                  color: Colors.black26,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _seccion(String titulo, List<Widget> filas) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            ...filas,
          ],
        ),
      ),
    );
  }

  Widget _fila(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(etiqueta, style: TextStyle(color: Colors.grey[600])),
          ),
          Expanded(child: Text(valor)),
        ],
      ),
    );
  }
}

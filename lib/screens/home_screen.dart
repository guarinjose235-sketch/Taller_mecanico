import 'package:flutter/material.dart';
import '../models/vehiculo.dart';
import 'registrar_vehiculo_screen.dart';
import 'lista_vehiculos_screen.dart';
import 'resumen_screen.dart';
import 'pagos_trabajadores_screen.dart';

class HomeScreen extends StatelessWidget {
  final List<Vehiculo> vehiculos;
  final Future<void> Function() onRecargar;
  final Future<void> Function(Vehiculo vehiculo, {required bool esNuevo})
      onGuardar;
  final Future<void> Function(String id) onEliminar;

  const HomeScreen({
    super.key,
    required this.vehiculos,
    required this.onRecargar,
    required this.onGuardar,
    required this.onEliminar,
  });

  Future<void> _irARegistrar(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegistrarVehiculoScreen(
          onGuardar: onGuardar,
        ),
      ),
    );
    await onRecargar();
  }

  Future<void> _irALista(BuildContext context,
      {required bool soloEntregados}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ListaVehiculosScreen(
          vehiculos: vehiculos,
          soloEntregados: soloEntregados,
          onGuardar: onGuardar,
          onEliminar: onEliminar,
          onRecargar: onRecargar,
        ),
      ),
    );
    await onRecargar();
  }

  Future<void> _irAResumen(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResumenScreen(vehiculos: vehiculos),
      ),
    );
    await onRecargar();
  }

  Future<void> _irAPagosTrabajadores(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PagosTrabajadoresScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Taller de Pintura')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              const Icon(Icons.format_paint, size: 72, color: Color(0xFF1565C0)),
              const SizedBox(height: 12),
              const Text(
                'Bienvenido',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Gestiona los vehículos que ingresan a pintura',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              _botonMenu(
                context,
                icono: Icons.add_circle_outline,
                texto: 'Registrar vehículo',
                onPressed: () => _irARegistrar(context),
              ),
              const SizedBox(height: 14),
              _botonMenu(
                context,
                icono: Icons.build_circle_outlined,
                texto: 'Vehículos en el taller',
                onPressed: () => _irALista(context, soloEntregados: false),
              ),
              const SizedBox(height: 14),
              _botonMenu(
                context,
                icono: Icons.check_circle_outline,
                texto: 'Vehículos entregados',
                onPressed: () => _irALista(context, soloEntregados: true),
              ),
              const SizedBox(height: 14),
              _botonMenu(
                context,
                icono: Icons.bar_chart,
                texto: 'Resumen',
                onPressed: () => _irAResumen(context),
              ),
              const SizedBox(height: 14),
              _botonMenu(
                context,
                icono: Icons.payments_outlined,
                texto: 'Pagos de trabajadores',
                onPressed: () => _irAPagosTrabajadores(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _botonMenu(
    BuildContext context, {
    required IconData icono,
    required String texto,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icono),
      label: Text(texto),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/vehiculo.dart';
import '../utils/formato.dart';

class ResumenScreen extends StatelessWidget {
  final List<Vehiculo> vehiculos;

  const ResumenScreen({super.key, required this.vehiculos});

  @override
  Widget build(BuildContext context) {
    final enTaller =
        vehiculos.where((v) => v.estado != EstadoVehiculo.entregado).length;
    final pendientes =
        vehiculos.where((v) => v.estado == EstadoVehiculo.pendiente).length;
    final enProceso =
        vehiculos.where((v) => v.estado == EstadoVehiculo.enProceso).length;
    final terminados =
        vehiculos.where((v) => v.estado == EstadoVehiculo.terminado).length;

    final hoy = DateTime.now();
    final totalFacturadoHoy = vehiculos
        .where((v) =>
            v.estado == EstadoVehiculo.entregado &&
            v.fechaEntrega != null &&
            esMismoDia(v.fechaEntrega!, hoy))
        .fold<double>(0.0, (suma, v) => suma + v.precio);

    return Scaffold(
      appBar: AppBar(title: const Text('Resumen')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              _tarjetaConteo(
                'En el taller',
                enTaller,
                Icons.build_circle_outlined,
                const Color(0xFF1565C0),
              ),
              _tarjetaConteo(
                'Pendientes',
                pendientes,
                Icons.hourglass_empty,
                Colors.orange,
              ),
              _tarjetaConteo(
                'En proceso',
                enProceso,
                Icons.build,
                Colors.blue,
              ),
              _tarjetaConteo(
                'Terminados',
                terminados,
                Icons.check_circle,
                Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            color: const Color(0xFF1565C0),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total facturado hoy',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatearMoneda(totalFacturadoHoy),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Suma de vehículos entregados con fecha de hoy (${formatearFecha(hoy)})',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tarjetaConteo(String titulo, int valor, IconData icono, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icono, color: color, size: 28),
            const Spacer(),
            Text(
              '$valor',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              titulo,
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

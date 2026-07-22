import 'package:flutter/material.dart';
import '../db/pagos_helper.dart';
import '../models/pago_trabajador.dart';
import '../utils/formato.dart';
import 'registrar_pago_screen.dart';

class PagosTrabajadoresScreen extends StatefulWidget {
  const PagosTrabajadoresScreen({super.key});

  @override
  State<PagosTrabajadoresScreen> createState() =>
      _PagosTrabajadoresScreenState();
}

class _PagosTrabajadoresScreenState extends State<PagosTrabajadoresScreen> {
  List<PagoTrabajador> _pagos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarPagos();
  }

  Future<void> _cargarPagos() async {
    setState(() => _cargando = true);
    final datos = await PagosHelper.instancia.obtenerPagos();
    datos.sort((a, b) => b.fecha.compareTo(a.fecha));
    if (!mounted) return;
    setState(() {
      _pagos = datos;
      _cargando = false;
    });
  }

  Future<void> _irARegistrarPago() async {
    final guardado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const RegistrarPagoScreen()),
    );
    if (guardado == true) {
      await _cargarPagos();
    }
  }

  Future<void> _confirmarEliminar(PagoTrabajador pago) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar pago'),
        content: Text(
          '¿Eliminar el pago de ${formatearMoneda(pago.monto)} a ${pago.trabajador}?',
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
    if (confirmar == true) {
      await PagosHelper.instancia.eliminarPago(pago.id);
      await _cargarPagos();
    }
  }

  Map<String, double> get _totalesPorTrabajador {
    final Map<String, double> totales = {};
    for (final p in _pagos) {
      totales[p.trabajador] = (totales[p.trabajador] ?? 0) + p.monto;
    }
    return totales;
  }

  double get _totalGeneral =>
      _pagos.fold<double>(0.0, (suma, p) => suma + p.monto);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pagos de trabajadores')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _irARegistrarPago,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo pago'),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargarPagos,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    color: const Color(0xFF1565C0),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total pagado',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            formatearMoneda(_totalGeneral),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_totalesPorTrabajador.isNotEmpty) ...[
                    const Text(
                      'Total por trabajador',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ..._totalesPorTrabajador.entries.map(
                      (e) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.person_outline),
                          title: Text(e.key),
                          trailing: Text(
                            formatearMoneda(e.value),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  const Text(
                    'Historial de pagos',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (_pagos.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'No hay pagos registrados',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    )
                  else
                    ..._pagos.map(
                      (p) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.payments_outlined),
                          ),
                          title: Text(p.trabajador),
                          subtitle: Text(
                            '${p.concepto}\n${formatearFecha(p.fecha)}',
                          ),
                          isThreeLine: true,
                          trailing: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                formatearMoneda(p.monto),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.red, size: 20),
                                onPressed: () => _confirmarEliminar(p),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }
}

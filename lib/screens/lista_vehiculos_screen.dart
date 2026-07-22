import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../models/vehiculo.dart';
import '../widgets/tarjeta_vehiculo.dart';
import 'detalle_vehiculo_screen.dart';

class ListaVehiculosScreen extends StatefulWidget {
  final List<Vehiculo> vehiculos;
  final bool soloEntregados;
  final Future<void> Function(Vehiculo vehiculo, {required bool esNuevo})
      onGuardar;
  final Future<void> Function(String id) onEliminar;
  final Future<void> Function() onRecargar;

  const ListaVehiculosScreen({
    super.key,
    required this.vehiculos,
    required this.soloEntregados,
    required this.onGuardar,
    required this.onEliminar,
    required this.onRecargar,
  });

  @override
  State<ListaVehiculosScreen> createState() => _ListaVehiculosScreenState();
}

class _ListaVehiculosScreenState extends State<ListaVehiculosScreen> {
  late List<Vehiculo> _vehiculos;
  String _busqueda = '';
  TipoVehiculo? _filtroTipo; // null = todos

  @override
  void initState() {
    super.initState();
    _vehiculos = List<Vehiculo>.from(widget.vehiculos);
  }

  Future<void> _refrescarLocal() async {
    try {
      final datos = await DBHelper.instancia.obtenerVehiculos();
      if (!mounted) return;
      setState(() => _vehiculos = datos);
    } catch (_) {
      // Si falla, se conserva la lista local previa.
    }
    await widget.onRecargar();
  }

  Future<void> _abrirDetalle(Vehiculo vehiculo) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetalleVehiculoScreen(
          vehiculo: vehiculo,
          onGuardar: widget.onGuardar,
          onEliminar: widget.onEliminar,
        ),
      ),
    );
    await _refrescarLocal();
  }

  List<Vehiculo> get _vehiculosFiltrados {
    return _vehiculos.where((v) {
      final coincideEntrega = widget.soloEntregados
          ? v.estado == EstadoVehiculo.entregado
          : v.estado != EstadoVehiculo.entregado;

      if (!coincideEntrega) return false;

      if (_filtroTipo != null && v.tipo != _filtroTipo) return false;

      if (_busqueda.trim().isNotEmpty) {
        final texto = _busqueda.trim().toLowerCase();
        final coincideBusqueda = v.placa.toLowerCase().contains(texto) ||
            v.clienteNombre.toLowerCase().contains(texto);
        if (!coincideBusqueda) return false;
      }

      return true;
    }).toList()
      ..sort((a, b) => b.fechaIngreso.compareTo(a.fechaIngreso));
  }

  @override
  Widget build(BuildContext context) {
    final lista = _vehiculosFiltrados;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.soloEntregados
              ? 'Vehículos entregados'
              : 'Vehículos en el taller',
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por placa o nombre del cliente',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                isDense: true,
              ),
              onChanged: (valor) => setState(() => _busqueda = valor),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _chipFiltro('Todos', null),
                const SizedBox(width: 8),
                _chipFiltro('Carro', TipoVehiculo.carro),
                const SizedBox(width: 8),
                _chipFiltro('Moto', TipoVehiculo.moto),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: lista.isEmpty
                ? Center(
                    child: Text(
                      'No hay vehículos para mostrar',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _refrescarLocal,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16, top: 4),
                      itemCount: lista.length,
                      itemBuilder: (context, index) {
                        final vehiculo = lista[index];
                        return TarjetaVehiculo(
                          vehiculo: vehiculo,
                          onTap: () => _abrirDetalle(vehiculo),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _chipFiltro(String etiqueta, TipoVehiculo? tipo) {
    final seleccionado = _filtroTipo == tipo;
    return ChoiceChip(
      label: Text(etiqueta),
      selected: seleccionado,
      onSelected: (_) => setState(() => _filtroTipo = tipo),
    );
  }
}

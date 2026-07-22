import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pago_trabajador.dart';

/// Maneja la persistencia de los pagos a trabajadores usando
/// shared_preferences, igual que db_helper.dart pero con su propia
/// clave para no mezclarse con los datos de los vehículos.
class PagosHelper {
  PagosHelper._interno();
  static final PagosHelper instancia = PagosHelper._interno();

  static const String _clave = 'pagos_trabajadores_data';

  Future<List<PagoTrabajador>> obtenerPagos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_clave);
    if (data == null || data.isEmpty) {
      return <PagoTrabajador>[];
    }
    try {
      final List<dynamic> listaJson = jsonDecode(data) as List<dynamic>;
      return listaJson
          .map((item) => PagoTrabajador.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return <PagoTrabajador>[];
    }
  }

  Future<void> _guardarTodos(List<PagoTrabajador> pagos) async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(pagos.map((p) => p.toMap()).toList());
    await prefs.setString(_clave, data);
  }

  Future<void> insertarPago(PagoTrabajador pago) async {
    final List<PagoTrabajador> actuales = await obtenerPagos();
    actuales.add(pago);
    await _guardarTodos(actuales);
  }

  Future<void> eliminarPago(String id) async {
    final List<PagoTrabajador> actuales = await obtenerPagos();
    actuales.removeWhere((p) => p.id == id);
    await _guardarTodos(actuales);
  }
}

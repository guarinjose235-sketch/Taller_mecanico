import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pago_trabajador.dart';

/// Maneja la persistencia de los pagos a trabajadores usando la
/// Realtime Database de Firebase (API REST), igual que db_helper.dart
/// pero con su propio nodo para no mezclarse con los vehículos.
class PagosHelper {
  PagosHelper._interno();
  static final PagosHelper instancia = PagosHelper._interno();

  // TODO: usa la MISMA URL que pusiste en db_helper.dart.
  static const String _baseUrl =
      'https://taller-pintura-default-rtdb.firebaseio.com';
  static const String _nodo = 'pagos_trabajadores';

  Uri _uri([String extra = '']) => Uri.parse('$_baseUrl/$_nodo$extra.json');

  Future<List<PagoTrabajador>> obtenerPagos() async {
    try {
      final response = await http.get(_uri());
      if (response.statusCode != 200 ||
          response.body.isEmpty ||
          response.body == 'null') {
        return <PagoTrabajador>[];
      }
      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;
      return data.entries
          .map((e) => PagoTrabajador.fromMap(
              Map<String, dynamic>.from(e.value as Map)))
          .toList();
    } catch (e) {
      return <PagoTrabajador>[];
    }
  }

  Future<void> insertarPago(PagoTrabajador pago) async {
    await http.put(
      _uri('/${pago.id}'),
      body: jsonEncode(pago.toMap()),
    );
  }

  Future<void> eliminarPago(String id) async {
    await http.delete(_uri('/$id'));
  }
}

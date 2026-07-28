import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vehiculo.dart';

/// Maneja la persistencia de los vehículos usando la Realtime Database
/// de Firebase a través de su API REST (sin SDK nativo de Firebase).
/// Esto hace que Android y Web lean y escriban en el MISMO lugar
/// (la nube), a diferencia de shared_preferences que guarda cada
/// plataforma por separado. Se usa el paquete http (puro Dart) para
/// evitar plugins nativos que puedan fallar al compilar en FlutLab.
class DBHelper {
  DBHelper._interno();
  static final DBHelper instancia = DBHelper._interno();

  // TODO: reemplaza esta URL por la de tu Realtime Database.
  // Firebase Console > Realtime Database > (copia la URL que aparece
  // arriba, ej: https://tu-proyecto-default-rtdb.firebaseio.com)
  static const String _baseUrl =
      'https://taller-pintura-default-rtdb.firebaseio.com';
  static const String _nodo = 'vehiculos';

  Uri _uri([String extra = '']) => Uri.parse('$_baseUrl/$_nodo$extra.json');

  Future<List<Vehiculo>> obtenerVehiculos() async {
    try {
      final response = await http.get(_uri());
      if (response.statusCode != 200 ||
          response.body.isEmpty ||
          response.body == 'null') {
        return <Vehiculo>[];
      }
      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;
      return data.entries
          .map((e) =>
              Vehiculo.fromMap(Map<String, dynamic>.from(e.value as Map)))
          .toList();
    } catch (e) {
      // Si falla la conexión o los datos están corruptos, se retorna
      // lista vacía en vez de romper la app.
      return <Vehiculo>[];
    }
  }

  Future<void> insertarVehiculo(Vehiculo vehiculo) async {
    await http.put(
      _uri('/${vehiculo.id}'),
      body: jsonEncode(vehiculo.toMap()),
    );
  }

  Future<void> actualizarVehiculo(Vehiculo vehiculo) async {
    await http.put(
      _uri('/${vehiculo.id}'),
      body: jsonEncode(vehiculo.toMap()),
    );
  }

  Future<void> eliminarVehiculo(String id) async {
    await http.delete(_uri('/$id'));
  }
}

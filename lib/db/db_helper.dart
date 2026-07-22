import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vehiculo.dart';

/// Maneja la persistencia de los vehículos usando shared_preferences.
/// Se guarda una única clave con la lista completa serializada como JSON.
/// Esto funciona igual en Android y Web sin configuración extra por
/// plataforma, a diferencia de SQLite (por eso NO se usa sqflite aquí,
/// ya que ese paquete puede fallar al compilar en FlutLab).
class DBHelper {
  DBHelper._interno();
  static final DBHelper instancia = DBHelper._interno();

  static const String _clave = 'vehiculos_data';

  Future<List<Vehiculo>> obtenerVehiculos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_clave);
    if (data == null || data.isEmpty) {
      return <Vehiculo>[];
    }
    try {
      final List<dynamic> listaJson = jsonDecode(data) as List<dynamic>;
      return listaJson
          .map((item) => Vehiculo.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Si los datos guardados están corruptos, se retorna lista vacía
      // en vez de romper la app.
      return <Vehiculo>[];
    }
  }

  Future<void> _guardarTodos(List<Vehiculo> vehiculos) async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(vehiculos.map((v) => v.toMap()).toList());
    await prefs.setString(_clave, data);
  }

  Future<void> insertarVehiculo(Vehiculo vehiculo) async {
    final List<Vehiculo> actuales = await obtenerVehiculos();
    actuales.add(vehiculo);
    await _guardarTodos(actuales);
  }

  Future<void> actualizarVehiculo(Vehiculo vehiculo) async {
    final List<Vehiculo> actuales = await obtenerVehiculos();
    final int indice = actuales.indexWhere((v) => v.id == vehiculo.id);
    if (indice != -1) {
      actuales[indice] = vehiculo;
    } else {
      actuales.add(vehiculo);
    }
    await _guardarTodos(actuales);
  }

  Future<void> eliminarVehiculo(String id) async {
    final List<Vehiculo> actuales = await obtenerVehiculos();
    actuales.removeWhere((v) => v.id == id);
    await _guardarTodos(actuales);
  }
}

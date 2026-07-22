import 'package:flutter/material.dart';
import 'db/db_helper.dart';
import 'models/vehiculo.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const TallerVehiculosApp());
}

class TallerVehiculosApp extends StatefulWidget {
  const TallerVehiculosApp({super.key});

  @override
  State<TallerVehiculosApp> createState() => _TallerVehiculosAppState();
}

class _TallerVehiculosAppState extends State<TallerVehiculosApp> {
  List<Vehiculo> _vehiculos = [];
  bool _cargando = true;
  String? _errorCarga;

  @override
  void initState() {
    super.initState();
    _cargarVehiculos();
  }

  Future<void> _cargarVehiculos() async {
    setState(() {
      _cargando = true;
      _errorCarga = null;
    });
    try {
      final datos = await DBHelper.instancia.obtenerVehiculos();
      setState(() {
        _vehiculos = datos;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _errorCarga = 'No se pudieron cargar los datos.\n$e';
        _cargando = false;
      });
    }
  }

  /// Guarda (inserta o actualiza) un vehículo y recarga la lista.
  Future<void> _guardarVehiculo(Vehiculo vehiculo,
      {required bool esNuevo}) async {
    if (esNuevo) {
      await DBHelper.instancia.insertarVehiculo(vehiculo);
    } else {
      await DBHelper.instancia.actualizarVehiculo(vehiculo);
    }
    await _cargarVehiculos();
  }

  Future<void> _eliminarVehiculo(String id) async {
    await DBHelper.instancia.eliminarVehiculo(id);
    await _cargarVehiculos();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taller de Vehículos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1565C0),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: _construirPantallaInicial(),
    );
  }

  Widget _construirPantallaInicial() {
    if (_cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorCarga != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Taller de Vehículos')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  _errorCarga!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _cargarVehiculos();
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return HomeScreen(
      vehiculos: _vehiculos,
      onRecargar: _cargarVehiculos,
      onGuardar: _guardarVehiculo,
      onEliminar: _eliminarVehiculo,
    );
  }
}

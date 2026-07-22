import 'package:flutter/material.dart';

enum TipoVehiculo { carro, moto }

enum EstadoVehiculo { pendiente, enProceso, terminado, entregado }

extension TipoVehiculoExtension on TipoVehiculo {
  String get etiqueta {
    switch (this) {
      case TipoVehiculo.carro:
        return 'Carro';
      case TipoVehiculo.moto:
        return 'Moto';
    }
  }

  IconData get icono {
    switch (this) {
      case TipoVehiculo.carro:
        return Icons.directions_car;
      case TipoVehiculo.moto:
        return Icons.two_wheeler;
    }
  }
}

extension EstadoVehiculoExtension on EstadoVehiculo {
  String get etiqueta {
    switch (this) {
      case EstadoVehiculo.pendiente:
        return 'Pendiente';
      case EstadoVehiculo.enProceso:
        return 'En proceso';
      case EstadoVehiculo.terminado:
        return 'Terminado';
      case EstadoVehiculo.entregado:
        return 'Entregado';
    }
  }

  Color get color {
    switch (this) {
      case EstadoVehiculo.pendiente:
        return Colors.orange;
      case EstadoVehiculo.enProceso:
        return Colors.blue;
      case EstadoVehiculo.terminado:
        return Colors.green;
      case EstadoVehiculo.entregado:
        return Colors.grey;
    }
  }

  IconData get icono {
    switch (this) {
      case EstadoVehiculo.pendiente:
        return Icons.hourglass_empty;
      case EstadoVehiculo.enProceso:
        return Icons.build;
      case EstadoVehiculo.terminado:
        return Icons.check_circle;
      case EstadoVehiculo.entregado:
        return Icons.done_all;
    }
  }
}

/// Lista fija de trabajos de pintura que se pueden seleccionar en el checklist.
const List<String> tiposDeTrabajo = [
  'Pintura completa',
  'Retoque de pintura',
  'Cambio de color',
  'Latonería y pintura',
  'Pulida y brillado',
  'Desabolladura',
  'Antichoque / laca',
  'Otro',
];

class Vehiculo {
  String id;
  String clienteNombre;
  String clienteTelefono;
  TipoVehiculo tipo;
  String marca;
  String modelo;
  String color;
  String placa;
  String? kilometraje;
  List<String> trabajos;
  String otroTrabajo;
  double precio;
  EstadoVehiculo estado;
  DateTime fechaIngreso;
  DateTime? fechaEntrega;

  Vehiculo({
    required this.id,
    required this.clienteNombre,
    required this.clienteTelefono,
    required this.tipo,
    required this.marca,
    required this.modelo,
    required this.color,
    required this.placa,
    this.kilometraje,
    required this.trabajos,
    this.otroTrabajo = '',
    required this.precio,
    required this.estado,
    required this.fechaIngreso,
    this.fechaEntrega,
  });

  /// Convierte el objeto a un Map serializable a JSON.
  /// Los trabajos se guardan como un solo string separado por '|'.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clienteNombre': clienteNombre,
      'clienteTelefono': clienteTelefono,
      'tipo': tipo.name,
      'marca': marca,
      'modelo': modelo,
      'color': color,
      'placa': placa,
      'kilometraje': kilometraje,
      'trabajos': trabajos.join('|'),
      'otroTrabajo': otroTrabajo,
      'precio': precio,
      'estado': estado.name,
      'fechaIngreso': fechaIngreso.toIso8601String(),
      'fechaEntrega': fechaEntrega?.toIso8601String(),
    };
  }

  factory Vehiculo.fromMap(Map<String, dynamic> map) {
    final String trabajosRaw = (map['trabajos'] as String?) ?? '';
    final List<String> trabajosList = trabajosRaw.isEmpty
        ? <String>[]
        : trabajosRaw.split('|').where((t) => t.isNotEmpty).toList();

    return Vehiculo(
      id: map['id'] as String,
      clienteNombre: map['clienteNombre'] as String? ?? '',
      clienteTelefono: map['clienteTelefono'] as String? ?? '',
      tipo: TipoVehiculo.values.firstWhere(
        (t) => t.name == map['tipo'],
        orElse: () => TipoVehiculo.carro,
      ),
      marca: map['marca'] as String? ?? '',
      modelo: map['modelo'] as String? ?? '',
      color: map['color'] as String? ?? '',
      placa: map['placa'] as String? ?? '',
      kilometraje: map['kilometraje'] as String?,
      trabajos: trabajosList,
      otroTrabajo: map['otroTrabajo'] as String? ?? '',
      precio: (map['precio'] as num?)?.toDouble() ?? 0.0,
      estado: EstadoVehiculo.values.firstWhere(
        (e) => e.name == map['estado'],
        orElse: () => EstadoVehiculo.pendiente,
      ),
      fechaIngreso: map['fechaIngreso'] != null
          ? DateTime.parse(map['fechaIngreso'] as String)
          : DateTime.now(),
      fechaEntrega: map['fechaEntrega'] != null
          ? DateTime.parse(map['fechaEntrega'] as String)
          : null,
    );
  }

  Vehiculo copyWith({
    String? clienteNombre,
    String? clienteTelefono,
    TipoVehiculo? tipo,
    String? marca,
    String? modelo,
    String? color,
    String? placa,
    String? kilometraje,
    List<String>? trabajos,
    String? otroTrabajo,
    double? precio,
    EstadoVehiculo? estado,
    DateTime? fechaIngreso,
    DateTime? fechaEntrega,
  }) {
    return Vehiculo(
      id: id,
      clienteNombre: clienteNombre ?? this.clienteNombre,
      clienteTelefono: clienteTelefono ?? this.clienteTelefono,
      tipo: tipo ?? this.tipo,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      color: color ?? this.color,
      placa: placa ?? this.placa,
      kilometraje: kilometraje ?? this.kilometraje,
      trabajos: trabajos ?? this.trabajos,
      otroTrabajo: otroTrabajo ?? this.otroTrabajo,
      precio: precio ?? this.precio,
      estado: estado ?? this.estado,
      fechaIngreso: fechaIngreso ?? this.fechaIngreso,
      fechaEntrega: fechaEntrega ?? this.fechaEntrega,
    );
  }

  /// Resumen corto de los trabajos solicitados, útil para las tarjetas.
  String resumenTrabajos() {
    final List<String> lista = List<String>.from(trabajos);
    if (lista.contains('Otro') && otroTrabajo.trim().isNotEmpty) {
      lista.remove('Otro');
      lista.add(otroTrabajo.trim());
    }
    if (lista.isEmpty) return 'Sin trabajos registrados';
    return lista.join(', ');
  }
}

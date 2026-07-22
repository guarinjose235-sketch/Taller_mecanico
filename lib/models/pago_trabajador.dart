/// Modelo que representa el pago realizado a un trabajador del taller.
class PagoTrabajador {
  String id;
  String trabajador;
  String concepto;
  double monto;
  DateTime fecha;

  PagoTrabajador({
    required this.id,
    required this.trabajador,
    required this.concepto,
    required this.monto,
    required this.fecha,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trabajador': trabajador,
      'concepto': concepto,
      'monto': monto,
      'fecha': fecha.toIso8601String(),
    };
  }

  factory PagoTrabajador.fromMap(Map<String, dynamic> map) {
    return PagoTrabajador(
      id: map['id'] as String,
      trabajador: map['trabajador'] as String? ?? '',
      concepto: map['concepto'] as String? ?? '',
      monto: (map['monto'] as num?)?.toDouble() ?? 0.0,
      fecha: map['fecha'] != null
          ? DateTime.parse(map['fecha'] as String)
          : DateTime.now(),
    );
  }
}

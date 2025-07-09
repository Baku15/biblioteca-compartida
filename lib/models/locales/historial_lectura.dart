class HistorialLectura {
  final int? id;
  final int libroId;
  final int ultimaPagina;
  final DateTime fechaActualizacion;

  HistorialLectura({
    this.id,
    required this.libroId,
    required this.ultimaPagina,
    required this.fechaActualizacion,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'libro_id': libroId,
        'ultima_pagina': ultimaPagina,
        'fecha_actualizacion': fechaActualizacion.toIso8601String(),
      };

  factory HistorialLectura.fromMap(Map<String, dynamic> map) =>
      HistorialLectura(
        id: map['id'],
        libroId: map['libro_id'],
        ultimaPagina: map['ultima_pagina'],
        fechaActualizacion: DateTime.parse(map['fecha_actualizacion']),
      );
}

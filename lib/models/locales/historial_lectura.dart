class HistorialLectura {
  final int id;
  final int libroId;
  final int paginaLeida;
  final DateTime fecha;

  HistorialLectura({
    required this.id,
    required this.libroId,
    required this.paginaLeida,
    required this.fecha,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'libroId': libroId,
        'paginaLeida': paginaLeida,
        'fecha': fecha.toIso8601String(),
      };

  factory HistorialLectura.fromMap(Map<String, dynamic> map) =>
      HistorialLectura(
        id: map['id'],
        libroId: map['libroId'],
        paginaLeida: map['paginaLeida'],
        fecha: DateTime.parse(map['fecha']),
      );
}

// models/locales/nota_lectura_local.dart
class NotaLectura {
  final int? id;
  final int libroId;
  final int pagina;
  final String contenido;
  final DateTime fecha;

  // Opcional: enlace con Firestore (para sincronización)
  final String? remoteId;

  NotaLectura({
    this.id,
    required this.libroId,
    required this.pagina,
    required this.contenido,
    required this.fecha,
    this.remoteId,
  });

  factory NotaLectura.fromMap(Map<String, dynamic> map) => NotaLectura(
        id: map['id'],
        libroId: map['libro_id'],
        pagina: map['pagina'],
        contenido: map['contenido'],
        fecha: DateTime.parse(map['fecha']),
        remoteId: map['remote_id'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'libro_id': libroId,
        'pagina': pagina,
        'contenido': contenido,
        'fecha': fecha.toIso8601String(),
        'remote_id': remoteId,
      };
}

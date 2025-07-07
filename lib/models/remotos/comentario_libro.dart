class ComentarioLibro {
  final String id;
  final String libroId;
  final String usuarioId;
  final String comentario;
  final DateTime fecha;

  ComentarioLibro({
    required this.id,
    required this.libroId,
    required this.usuarioId,
    required this.comentario,
    required this.fecha,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'libroId': libroId,
        'usuarioId': usuarioId,
        'comentario': comentario,
        'fecha': fecha.toIso8601String(),
      };

  factory ComentarioLibro.fromJson(Map<String, dynamic> json) =>
      ComentarioLibro(
        id: json['id'],
        libroId: json['libroId'],
        usuarioId: json['usuarioId'],
        comentario: json['comentario'],
        fecha: DateTime.parse(json['fecha']),
      );
}

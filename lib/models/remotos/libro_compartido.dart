class LibroCompartido {
  final String id;
  final String titulo;
  final String autor;
  final String categoria;
  final String resumen;
  final String usuarioId;
  final DateTime fechaPublicacion;

  LibroCompartido({
    required this.id,
    required this.titulo,
    required this.autor,
    required this.categoria,
    required this.resumen,
    required this.usuarioId,
    required this.fechaPublicacion,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'autor': autor,
        'categoria': categoria,
        'resumen': resumen,
        'usuarioId': usuarioId,
        'fechaPublicacion': fechaPublicacion.toIso8601String(),
      };

  factory LibroCompartido.fromJson(Map<String, dynamic> json) =>
      LibroCompartido(
        id: json['id'],
        titulo: json['titulo'],
        autor: json['autor'],
        categoria: json['categoria'],
        resumen: json['resumen'],
        usuarioId: json['usuarioId'],
        fechaPublicacion: DateTime.parse(json['fechaPublicacion']),
      );
}

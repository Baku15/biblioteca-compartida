class LibroCompartido {
  final String id;
  final String titulo;
  final String autor;
  final String resumen;
  final String? imagenUrl;
  final String categoria;
  final String usuarioId;
  final String estadoLectura;
  final int? calificacion;
  final String? resena;

  LibroCompartido({
    required this.id,
    required this.titulo,
    required this.autor,
    required this.resumen,
    required this.categoria,
    required this.usuarioId,
    required this.estadoLectura,
    this.imagenUrl,
    this.calificacion,
    this.resena,
  });

  factory LibroCompartido.fromMap(String id, Map<String, dynamic> map) {
    return LibroCompartido(
      id: id,
      titulo: map['titulo'],
      autor: map['autor'],
      resumen: map['resumen'],
      categoria: map['categoria'],
      usuarioId: map['usuarioId'],
      estadoLectura: map['estadoLectura'],
      imagenUrl: map['imagenUrl'],
      calificacion: map['calificacion'],
      resena: map['resena'],
    );
  }

  Map<String, dynamic> toMap() => {
        'titulo': titulo,
        'autor': autor,
        'resumen': resumen,
        'categoria': categoria,
        'usuarioId': usuarioId,
        'estadoLectura': estadoLectura,
        'imagenUrl': imagenUrl,
        'calificacion': calificacion,
        'resena': resena,
      };
}

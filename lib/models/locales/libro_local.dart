class LibroLocal {
  final int id;
  final String titulo;
  final String autor;
  final String categoria;
  final String resumen;
  final DateTime fechaCreacion;
  final String? imagenPath;
  final String? estadoLectura;
  final int? calificacion;
  final String? resena;
  final String? remoteId;
  final String usuarioId;

  LibroLocal({
    required this.id,
    required this.titulo,
    required this.autor,
    required this.categoria,
    required this.resumen,
    required this.fechaCreacion,
    this.imagenPath,
    required this.estadoLectura,
    this.calificacion,
    this.resena,
    this.remoteId,
    required this.usuarioId,
  });
  Map<String, dynamic> toMap() => {
        'id': id,
        'titulo': titulo,
        'autor': autor,
        'categoria': categoria,
        'resumen': resumen,
        'fechaCreacion': fechaCreacion.toIso8601String(),
        'imagenPath': imagenPath,
        'estadoLectura': estadoLectura,
        'calificacion': calificacion,
        'resena': resena,
        'remote_id': remoteId,
        'usuarioId': usuarioId,
      };

  factory LibroLocal.fromMap(Map<String, dynamic> map) => LibroLocal(
        id: map['id'],
        titulo: map['titulo'],
        autor: map['autor'],
        categoria: map['categoria'],
        resumen: map['resumen'],
        fechaCreacion: DateTime.parse(map['fechaCreacion']),
        imagenPath: map['imagenPath'],
        estadoLectura: map['estadoLectura'] ?? 'Quiero leer',
        calificacion: map['calificacion'],
        resena: map['resena'],
        remoteId: map['remote_id'],
        usuarioId: map['usuarioId'],
      );

  LibroLocal copyWith({
    int? id,
    String? titulo,
    String? autor,
    String? categoria,
    String? resumen,
    DateTime? fechaCreacion,
    String? imagenPath,
    String? estadoLectura,
    int? calificacion,
    String? resena,
    String? remoteId,
    String? usuarioId,
  }) {
    return LibroLocal(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      autor: autor ?? this.autor,
      categoria: categoria ?? this.categoria,
      resumen: resumen ?? this.resumen,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      imagenPath: imagenPath ?? this.imagenPath,
      estadoLectura: estadoLectura ?? this.estadoLectura,
      calificacion: calificacion ?? this.calificacion,
      resena: resena ?? this.resena,
      remoteId: remoteId ?? this.remoteId,
      usuarioId: usuarioId ?? this.usuarioId,
    );
  }
}

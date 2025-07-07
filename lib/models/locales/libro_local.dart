class LibroLocal {
  final int id;
  final String titulo;
  final String autor;
  final String categoria;
  final String resumen;
  final DateTime fechaCreacion;

  LibroLocal({
    required this.id,
    required this.titulo,
    required this.autor,
    required this.categoria,
    required this.resumen,
    required this.fechaCreacion,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'titulo': titulo,
        'autor': autor,
        'categoria': categoria,
        'resumen': resumen,
        'fechaCreacion': fechaCreacion.toIso8601String(),
      };

  factory LibroLocal.fromMap(Map<String, dynamic> map) => LibroLocal(
        id: map['id'],
        titulo: map['titulo'],
        autor: map['autor'],
        categoria: map['categoria'],
        resumen: map['resumen'],
        fechaCreacion: DateTime.parse(map['fechaCreacion']),
      );
}

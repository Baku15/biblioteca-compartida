class Libro {
  final String id;
  final String titulo;
  final String autor;

  Libro({required this.id, required this.titulo, required this.autor});

  factory Libro.fromJson(Map<String, dynamic> json) => Libro(
        id: json['id'],
        titulo: json['titulo'],
        autor: json['autor'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'autor': autor,
      };
}

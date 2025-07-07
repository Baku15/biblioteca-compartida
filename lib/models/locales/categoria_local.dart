class CategoriaLocal {
  final int id;
  final String nombre;

  CategoriaLocal({
    required this.id,
    required this.nombre,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
      };

  factory CategoriaLocal.fromMap(Map<String, dynamic> map) => CategoriaLocal(
        id: map['id'],
        nombre: map['nombre'],
      );
}

class CategoriaGlobal {
  final String id;
  final String nombre;

  CategoriaGlobal({
    required this.id,
    required this.nombre,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
      };

  factory CategoriaGlobal.fromJson(Map<String, dynamic> json) =>
      CategoriaGlobal(
        id: json['id'],
        nombre: json['nombre'],
      );
}

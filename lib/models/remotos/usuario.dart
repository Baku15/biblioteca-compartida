class Usuario {
  final String id;
  final String email;
  final String nombre;

  Usuario({
    required this.id,
    required this.email,
    required this.nombre,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'nombre': nombre,
      };

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        id: json['id'],
        email: json['email'],
        nombre: json['nombre'],
      );
}

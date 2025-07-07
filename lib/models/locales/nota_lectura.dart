class NotaLectura {
  final int id;
  final int libroId;
  final int pagina;
  final String nota;

  NotaLectura({
    required this.id,
    required this.libroId,
    required this.pagina,
    required this.nota,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'libroId': libroId,
        'pagina': pagina,
        'nota': nota,
      };

  factory NotaLectura.fromMap(Map<String, dynamic> map) => NotaLectura(
        id: map['id'],
        libroId: map['libroId'],
        pagina: map['pagina'],
        nota: map['nota'],
      );
}

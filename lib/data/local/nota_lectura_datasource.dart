// data/local/nota_lectura_datasource.dart
import 'package:flutter_libros/data/local/libro_local_datasource.dart';
import 'package:flutter_libros/models/locales/nota_lectura.dart';
import 'package:sqflite/sqflite.dart';

class NotaLecturaDataSource {
  final _dbFuture = LibroLocalDataSource().database;

  /// Inserta una nueva nota en la base de datos local
  Future<void> insertarNota(NotaLectura nota) async {
    final db = await _dbFuture;
    await db.insert('notas_lectura', nota.toMap());
  }

  /// Obtiene todas las notas asociadas a un libro local, ordenadas por página
  Future<List<NotaLectura>> obtenerNotasPorLibro(int libroId) async {
    final db = await _dbFuture;
    final res = await db.query(
      'notas_lectura',
      where: 'libro_id = ?',
      whereArgs: [libroId],
      orderBy: 'pagina ASC',
    );
    return res.map((e) => NotaLectura.fromMap(e)).toList();
  }

  /// Método existente vacío (por ahora lo dejamos para compatibilidad)
  Future getNotasPorLibro(int id) async {
    return obtenerNotasPorLibro(id);
  }

  /// Elimina una nota por su ID
  Future<void> eliminarNota(int notaId) async {
    final db = await _dbFuture;
    await db.delete('notas_lectura', where: 'id = ?', whereArgs: [notaId]);
  }

  /// Actualiza el remote_id de una nota luego de ser subida a Firestore
  Future<void> actualizarRemoteId(int notaId, String remoteId) async {
    final db = await _dbFuture;
    await db.update(
      'notas_lectura',
      {'remote_id': remoteId},
      where: 'id = ?',
      whereArgs: [notaId],
    );
  }

  /// Obtiene todas las notas locales que aún no se han sincronizado (sin remote_id)
  Future<List<NotaLectura>> obtenerNotasSinSincronizar() async {
    final db = await _dbFuture;
    final result = await db.query(
      'notas_lectura',
      where: 'remote_id IS NULL',
    );
    return result.map((e) => NotaLectura.fromMap(e)).toList();
  }
}

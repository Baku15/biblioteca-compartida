import 'package:sqflite/sqflite.dart';
import '../../models/locales/historial_lectura.dart';
import 'libro_local_datasource.dart';

class HistorialLecturaDataSource {
  Future<void> guardarHistorial(HistorialLectura historial) async {
    final db = await LibroLocalDataSource().database;
    await db.insert(
      'historial_lectura',
      historial.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<HistorialLectura?> obtenerHistorialPorLibro(int libroId) async {
    final db = await LibroLocalDataSource().database;
    final res = await db.query(
      'historial_lectura',
      where: 'libro_id = ?',
      whereArgs: [libroId],
    );
    if (res.isNotEmpty) {
      return HistorialLectura.fromMap(res.first);
    }
    return null;
  }
}

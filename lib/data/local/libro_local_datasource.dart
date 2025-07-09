import 'package:flutter_libros/models/locales/libro_local.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../../models/libro.dart';

class LibroLocalDataSource {
  static final LibroLocalDataSource _instance =
      LibroLocalDataSource._internal();
  factory LibroLocalDataSource() => _instance;

  LibroLocalDataSource._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'libros.db');

    return openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
    );
  }

  Future<void> updateLibro(LibroLocal libro) async {
    final db = await database;
    await db.update(
      'libros_locales',
      {
        'id': libro.id,
        'titulo': libro.titulo,
        'autor': libro.autor,
        'categoria': libro.categoria,
        'resumen': libro.resumen,
        'fechaCreacion': libro.fechaCreacion.toIso8601String(),
        'imagenPath': libro.imagenPath,
        'estadoLectura': libro.estadoLectura,
        'calificacion': libro.calificacion,
        'resena': libro.resena,
      },
      where: 'id = ?',
      whereArgs: [libro.id],
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
         CREATE TABLE libros_locales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT,
        autor TEXT,
        categoria TEXT,
        resumen TEXT,
        fechaCreacion TEXT,
        imagenPath TEXT,
        estadoLectura TEXT,
        calificacion INTEGER,
        resena TEXT,
        remote_id TEXT


)
    ''');
  }

  Future<int> insertLibro(LibroLocal libro) async {
    final db = await database;
    return await db.insert(
      'libros_locales',
      {
        'titulo': libro.titulo,
        'autor': libro.autor,
        'categoria': libro.categoria,
        'resumen': libro.resumen,
        'fechaCreacion': libro.fechaCreacion.toIso8601String(),
        'imagenPath': libro.imagenPath,
        'estadoLectura': libro.estadoLectura,
        'calificacion': libro.calificacion,
        'resena': libro.resena,
        'remote_id': libro.remoteId, // ✅ ESTA LÍNEA ESCLAVE
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<LibroLocal>> getLibros() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('libros_locales');

    return List.generate(
      maps.length,
      (i) => LibroLocal.fromMap(maps[i]),
    );
  }

  Future<void> deleteLibro(int id) async {
    final db = await database;
    await db.delete('libros_locales', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('libros_locales');
  }

  Future<void> actualizarRemoteId(int libroId, String remoteId) async {
    final db = await database;
    await db.update(
      'libros_locales',
      {'remote_id': remoteId},
      where: 'id = ?',
      whereArgs: [libroId],
    );
  }
}

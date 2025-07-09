import 'package:flutter_libros/models/locales/libro_local.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          // Migración: agregamos columna usuarioId si no existía
          await db.execute(
            'ALTER TABLE libros_locales ADD COLUMN usuarioId TEXT NOT NULL DEFAULT ""',
          );
        }
      },
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
        remote_id TEXT,
        usuarioId TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE notas_lectura (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        libro_id INTEGER,
        pagina INTEGER,
        contenido TEXT,
        fecha TEXT,
        remote_id TEXT,
        FOREIGN KEY(libro_id) REFERENCES libros_locales(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE historial_lectura (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        libro_id INTEGER,
        ultima_pagina INTEGER,
        fecha_actualizacion TEXT,
        FOREIGN KEY(libro_id) REFERENCES libros_locales(id)
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
        'remote_id': libro.remoteId,
        'usuarioId': libro.usuarioId,
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

  Future<void> updateLibro(LibroLocal libro) async {
    final db = await database;
    await db.update(
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
        'remote_id': libro.remoteId,
        'usuarioId': libro.usuarioId,
      },
      where: 'id = ?',
      whereArgs: [libro.id],
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

  Future<List<LibroLocal>> getLibrosPorUsuario(String usuarioId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'libros_locales',
      where: 'usuarioId = ?',
      whereArgs: [usuarioId],
    );

    return List.generate(
      maps.length,
      (i) => LibroLocal.fromMap(maps[i]),
    );
  }
}

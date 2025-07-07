import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../../models/libro.dart';

class LibroLocalDatasource {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final path = join(await getDatabasesPath(), 'libros.db');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE libros (
            id TEXT PRIMARY KEY,
            titulo TEXT,
            autor TEXT
          )
        ''');
      },
    );
    return _database!;
  }

  Future<void> guardarLibro(Libro libro) async {
    final db = await database;
    await db.insert('libros', libro.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Libro>> obtenerLibros() async {
    final db = await database;
    final result = await db.query('libros');
    return result.map((e) => Libro.fromJson(e)).toList();
  }

  Future<void> eliminarLibro(String id) async {
    final db = await database;
    await db.delete('libros', where: 'id = ?', whereArgs: [id]);
  }
}

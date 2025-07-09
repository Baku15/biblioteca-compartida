import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_libros/models/locales/libro_local.dart';
import 'package:flutter_libros/data/local/libro_local_datasource.dart';

class SincronizadorLibros {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final LibroLocalDataSource localDataSource = LibroLocalDataSource();

  /// Sube un libro local a Firestore (colección libros_compartidos)
  Future<void> compartirLibro(LibroLocal libro) async {
    try {
      // Si ya fue compartido antes, actualizamos
      if (libro.remoteId != null) {
        await firestore
            .collection('libros_compartidos')
            .doc(libro.remoteId)
            .update({
          'titulo': libro.titulo,
          'autor': libro.autor,
          'categoria': libro.categoria,
          'resumen': libro.resumen,
          'estadoLectura': libro.estadoLectura,
          'imagenUrl': libro
              .imagenPath, // Si luego subes imágenes a Firebase Storage, cambia esto por la URL
          'calificacion': libro.calificacion,
          'resena': libro.resena,
          'fechaCreacion': libro.fechaCreacion.toIso8601String(),
        });
        return;
      }

      // Sino, lo subimos como nuevo
      final docRef = await firestore.collection('libros_compartidos').add({
        'titulo': libro.titulo,
        'autor': libro.autor,
        'categoria': libro.categoria,
        'resumen': libro.resumen,
        'estadoLectura': libro.estadoLectura,
        'imagenUrl': libro
            .imagenPath, // Si luego subes imágenes a Firebase Storage, cambia esto por la URL
        'calificacion': libro.calificacion,
        'resena': libro.resena,
        'fechaCreacion': libro.fechaCreacion.toIso8601String(),

        // Puedes agregar userId si estás logueado
      });

      // Actualizamos el remoteId local
      await localDataSource.actualizarRemoteId(libro.id, docRef.id);
    } catch (e) {
      print('❌ Error al sincronizar libro: $e');
      rethrow;
    }
  }
}

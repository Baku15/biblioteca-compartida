import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_libros/models/locales/libro_local.dart';
import 'package:flutter_libros/data/local/libro_local_datasource.dart';

class SincronizadorLibros {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final LibroLocalDataSource localDataSource = LibroLocalDataSource();

  /// Sube un libro local a Firestore (colección libros_compartidos)
  Future<void> compartirLibro(LibroLocal libro) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception("Usuario no autenticado");
      }

      final uid = currentUser.uid;

      final libroData = {
        'titulo': libro.titulo,
        'autor': libro.autor,
        'categoria': libro.categoria,
        'resumen': libro.resumen,
        'estadoLectura': libro.estadoLectura,
        'imagenUrl': libro.imagenPath,
        'calificacion': libro.calificacion,
        'resena': libro.resena,
        'fechaCreacion': libro.fechaCreacion.toIso8601String(),
        'usuarioId': uid, // 👈 NECESARIO PARA PASAR LAS REGLAS
      };

      // Si ya fue compartido antes, actualizamos
      if (libro.remoteId != null) {
        await firestore
            .collection('libros_compartidos')
            .doc(libro.remoteId)
            .update(libroData);
        return;
      }

      // Sino, lo subimos como nuevo
      final docRef =
          await firestore.collection('libros_compartidos').add(libroData);

      // Actualizamos el remoteId local
      await localDataSource.actualizarRemoteId(libro.id, docRef.id);
    } catch (e) {
      print('❌ Error al sincronizar libro: $e');
      rethrow;
    }
  }
}

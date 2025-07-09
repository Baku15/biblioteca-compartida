// data/sincronizacion/sincronizacion_notas.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_libros/models/locales/nota_lectura.dart';
import 'package:flutter_libros/data/local/nota_lectura_datasource.dart';

class SincronizadorNotas {
  final _firestore = FirebaseFirestore.instance;
  final _notaDataSource = NotaLecturaDataSource();

  /// Sube una sola nota al libro compartido correspondiente (por `remoteLibroId`)
  Future<void> compartirNota({
    required NotaLectura nota,
    required String remoteLibroId,
  }) async {
    try {
      // Si ya tiene remote_id: no hacemos nada
      if (nota.remoteId != null) return;

      final docRef = await _firestore
          .collection('libros_compartidos')
          .doc(remoteLibroId)
          .collection('notas')
          .add({
        'pagina': nota.pagina,
        'contenido': nota.contenido,
        'fecha': nota.fecha.toIso8601String(),
        // Aquí puedes añadir userId si lo deseas
      });

      await _notaDataSource.actualizarRemoteId(nota.id!, docRef.id);
    } catch (e) {
      print('❌ Error al compartir nota: $e');
      rethrow;
    }
  }

  /// Sube todas las notas locales sin sincronizar
  Future<void> sincronizarTodas(String remoteLibroId, int libroLocalId) async {
    final notas = await _notaDataSource.obtenerNotasSinSincronizar();
    for (final nota in notas.where((n) => n.libroId == libroLocalId)) {
      await compartirNota(nota: nota, remoteLibroId: remoteLibroId);
    }
  }
}

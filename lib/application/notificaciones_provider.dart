import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final notificacionesNoLeidasProvider =
    StreamProvider.autoDispose.family<int, String>((ref, usuarioId) {
  final query = FirebaseFirestore.instance
      .collection('notificaciones')
      .where('usuarioId', isEqualTo: usuarioId)
      .where('leido', isEqualTo: false);

  return query.snapshots().map((snapshot) => snapshot.docs.length);
});

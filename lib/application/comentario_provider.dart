import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final comentarioProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, libroId) {
  return FirebaseFirestore.instance
      .collection('libros_compartidos')
      .doc(libroId)
      .collection('comentarios')
      .orderBy('fecha', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList());
});

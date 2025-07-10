import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Estado que guarda el filtro actual del buscador
final filtroLibrosCompartidosProvider = StateProvider<String>((ref) => '');

// Stream que escucha libros compartidos y filtra según el texto buscado
final librosCompartidosStreamProvider =
    StreamProvider.autoDispose<List<DocumentSnapshot>>((ref) {
  final filtro = ref.watch(filtroLibrosCompartidosProvider).toLowerCase();

  final stream =
      FirebaseFirestore.instance.collection('libros_compartidos').snapshots();

  return stream.map((snapshot) {
    return snapshot.docs.where((doc) {
      final titulo = (doc['titulo'] ?? '').toString().toLowerCase();
      final autor = (doc['autor'] ?? '').toString().toLowerCase();
      return titulo.contains(filtro) || autor.contains(filtro);
    }).toList();
  });
});

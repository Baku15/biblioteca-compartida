import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/remotos/libro_compartido.dart';

class LibroRemoteDataSource {
  final _firestore = FirebaseFirestore.instance;

  Future<List<LibroCompartido>> obtenerLibrosCompartidos() async {
    final snapshot = await _firestore.collection('libros_compartidos').get();

    return snapshot.docs.map((doc) {
      return LibroCompartido.fromMap(doc.id, doc.data());
    }).toList();
  }
}

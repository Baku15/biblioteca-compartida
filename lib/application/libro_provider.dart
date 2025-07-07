import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/libro_local_datasource.dart';
import '../models/libro.dart';

// Provider del datasource
final libroDatasourceProvider = Provider<LibroLocalDatasource>((ref) {
  return LibroLocalDatasource();
});

// Provider del notifier (estado)
final libroProvider = StateNotifierProvider<LibroNotifier, List<Libro>>((ref) {
  final datasource = ref.read(libroDatasourceProvider);
  return LibroNotifier(datasource);
});

class LibroNotifier extends StateNotifier<List<Libro>> {
  final LibroLocalDatasource datasource;

  LibroNotifier(this.datasource) : super([]) {
    cargarLibros();
  }

  Future<void> cargarLibros() async {
    final libros = await datasource.obtenerLibros();
    state = libros;
  }

  Future<void> agregarLibro(Libro libro) async {
    await datasource.guardarLibro(libro);
    state = [...state, libro];
  }

  Future<void> eliminarLibro(String id) async {
    await datasource.eliminarLibro(id);
    state = state.where((l) => l.id != id).toList();
  }
}

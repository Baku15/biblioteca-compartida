import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/libro_local_datasource.dart';
import '../models/locales/libro_local.dart';

// Provider del datasource
final libroDatasourceProvider = Provider<LibroLocalDataSource>((ref) {
  return LibroLocalDataSource();
});

// Provider del StateNotifier que maneja la lista de libros
final libroProvider =
    StateNotifierProvider<LibroNotifier, List<LibroLocal>>((ref) {
  final datasource = ref.read(libroDatasourceProvider);
  return LibroNotifier(datasource);
});

class LibroNotifier extends StateNotifier<List<LibroLocal>> {
  final LibroLocalDataSource datasource;

  LibroNotifier(this.datasource) : super([]) {
    cargarLibros();
  }

  Future<void> cargarLibros() async {
    final libros = await datasource.getLibros();
    state = libros;
  }

  Future<void> agregarLibro(LibroLocal libro) async {
    await datasource.insertLibro(libro);
    state = [...state, libro];
  }

  Future<void> eliminarLibro(int id) async {
    await datasource.deleteLibro(id);
    state = state.where((l) => l.id != id).toList();
  }
}

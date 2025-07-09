import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/nota_lectura_datasource.dart';
import '../../models/locales/nota_lectura.dart';

final notaDatasourceProvider = Provider<NotaLecturaDataSource>((ref) {
  return NotaLecturaDataSource();
});

final notaProvider =
    StateNotifierProvider<NotaNotifier, List<NotaLectura>>((ref) {
  final datasource = ref.read(notaDatasourceProvider);
  return NotaNotifier(datasource);
});

class NotaNotifier extends StateNotifier<List<NotaLectura>> {
  final NotaLecturaDataSource datasource;

  NotaNotifier(this.datasource) : super([]);

  Future<void> cargarNotas(int libroId) async {
    final notas = await datasource.obtenerNotasPorLibro(libroId);
    state = notas;
  }

  Future<void> agregarNota(NotaLectura nota) async {
    await datasource.insertarNota(nota);
    state = [...state, nota];
  }

  Future<void> eliminarNota(int id) async {
    await datasource.eliminarNota(id);
    state = state.where((n) => n.id != id).toList();
  }

  Future<void> editarNota(NotaLectura nota) async {
    await datasource.actualizarNota(nota);
    state = [
      for (final n in state)
        if (n.id == nota.id) nota else n
    ];
  }
}

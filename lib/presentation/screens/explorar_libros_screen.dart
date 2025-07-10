import 'package:flutter/material.dart';
import 'package:flutter_libros/application/libros_compartidos_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExplorarLibrosScreen extends ConsumerWidget {
  const ExplorarLibrosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtro = ref.watch(filtroLibrosCompartidosProvider);
    final librosAsync = ref.watch(librosCompartidosStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Explorar Biblioteca"),
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Buscar libros...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // Actualiza el filtro sin usar setState
                ref.read(filtroLibrosCompartidosProvider.notifier).state =
                    value;
              },
            ),
          ),
          Expanded(
            child: librosAsync.when(
              data: (librosFiltrados) {
                if (librosFiltrados.isEmpty) {
                  return const Center(child: Text("No se encontraron libros."));
                }
                return ListView.builder(
                  itemCount: librosFiltrados.length,
                  itemBuilder: (context, index) {
                    final libro = librosFiltrados[index];
                    return ListTile(
                      leading: const Icon(Icons.book, color: Colors.blueAccent),
                      title: Text(libro['titulo']),
                      subtitle: Text(libro['autor']),
                      trailing: const Icon(Icons.comment),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/detalle_libro_compartido',
                          arguments: libro,
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text("Error: $error")),
            ),
          ),
        ],
      ),
    );
  }
}

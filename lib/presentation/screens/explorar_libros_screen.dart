import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ExplorarLibrosScreen extends StatefulWidget {
  const ExplorarLibrosScreen({super.key});

  @override
  State<ExplorarLibrosScreen> createState() => _ExplorarLibrosScreenState();
}

class _ExplorarLibrosScreenState extends State<ExplorarLibrosScreen> {
  String _filtro = '';

  @override
  Widget build(BuildContext context) {
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
                setState(() {
                  _filtro = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('libros_compartidos')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Error al cargar libros"));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                // Filtrar localmente por título o autor
                final librosFiltrados = docs.where((doc) {
                  final titulo = (doc['titulo'] ?? '').toString().toLowerCase();
                  final autor = (doc['autor'] ?? '').toString().toLowerCase();
                  return titulo.contains(_filtro) || autor.contains(_filtro);
                }).toList();

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
            ),
          ),
        ],
      ),
    );
  }
}

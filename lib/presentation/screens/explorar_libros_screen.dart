import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ExplorarLibrosScreen extends StatelessWidget {
  const ExplorarLibrosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Explorar Biblioteca"),
        backgroundColor: Colors.indigo,
      ),
      body: StreamBuilder<QuerySnapshot>(
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

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final libro = docs[index];
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
    );
  }
}

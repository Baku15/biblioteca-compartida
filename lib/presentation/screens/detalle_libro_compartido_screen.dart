import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DetalleLibroCompartidoScreen extends StatelessWidget {
  final DocumentSnapshot libro;

  const DetalleLibroCompartidoScreen({super.key, required this.libro});

  @override
  Widget build(BuildContext context) {
    final libroId = libro.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(libro['titulo']),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (libro['imagenUrl'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  libro['imagenUrl'],
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 20),

            /// Título
            Text(
              libro['titulo'],
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            /// Autor
            Text(
              'Autor: ${libro['autor']}',
              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 12),

            /// Estado de lectura
            Text(
              '📖 Estado: ${libro['estadoLectura']}',
              style: const TextStyle(fontSize: 15, color: Colors.blueGrey),
            ),
            const SizedBox(height: 12),

            /// Calificación
            if (libro['calificacion'] != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return Icon(
                    i < libro['calificacion'] ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 28,
                  );
                }),
              ),

            /// Reseña
            if (libro['resena'] != null &&
                libro['resena'].toString().trim().isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  libro['resena'],
                  style: const TextStyle(fontSize: 15),
                  textAlign: TextAlign.justify,
                ),
              ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 10),

            /// Comentarios
            const Text("💬 Comentarios", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),

            SizedBox(
              height: 300, // Altura fija para permitir scroll de comentarios
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('libros_compartidos')
                    .doc(libroId)
                    .collection('comentarios')
                    .orderBy('fecha', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const CircularProgressIndicator();
                  final comentarios = snapshot.data!.docs;
                  if (comentarios.isEmpty) {
                    return const Center(child: Text("Sin comentarios aún."));
                  }
                  return ListView.builder(
                    itemCount: comentarios.length,
                    itemBuilder: (context, index) {
                      final com = comentarios[index];
                      return ListTile(
                        title: Text(com['contenido']),
                        subtitle: Text("👤 ${com['usuario']}"),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 12),
            ComentarioInput(libroId: libroId),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class ComentarioInput extends StatefulWidget {
  final String libroId;
  const ComentarioInput({super.key, required this.libroId});

  @override
  State<ComentarioInput> createState() => _ComentarioInputState();
}

class _ComentarioInputState extends State<ComentarioInput> {
  final _controller = TextEditingController();

  Future<void> _enviarComentario() async {
    if (_controller.text.trim().isEmpty) return;

    await FirebaseFirestore.instance
        .collection('libros_compartidos')
        .doc(widget.libroId)
        .collection('comentarios')
        .add({
      'contenido': _controller.text.trim(),
      'usuario': 'Anónimo', // ⚠️ Aquí debes usar FirebaseAuth para nombre real
      'fecha': DateTime.now(),
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: "Escribe un comentario...",
              border: OutlineInputBorder(),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: _enviarComentario,
        ),
      ],
    );
  }
}

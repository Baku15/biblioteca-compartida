import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_libros/presentation/widgets/comentarios_widget.dart';

class DetalleLibroCompartidoScreen extends StatelessWidget {
  final DocumentSnapshot libro;

  const DetalleLibroCompartidoScreen({super.key, required this.libro});

  Widget _buildImagen() {
    final imagenUrl = libro['imagenUrl'] as String?;

    if (imagenUrl == null || imagenUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    if (imagenUrl.startsWith('http')) {
      // URL válida, carga con Image.network
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imagenUrl,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    } else if (File(imagenUrl).existsSync()) {
      // Ruta local válida, carga con Image.file
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(imagenUrl),
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    } else {
      // No es ruta ni URL válida → no muestra nada
      return const SizedBox.shrink();
    }
  }

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
            _buildImagen(), // Aquí se muestra la imagen correctamente
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

            ComentariosWidget(libroId: libroId),
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
    final contenido = _controller.text.trim();
    if (contenido.isEmpty) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      // Guardar comentario
      await FirebaseFirestore.instance
          .collection('libros_compartidos')
          .doc(widget.libroId)
          .collection('comentarios')
          .add({
        'contenido': contenido,
        'usuario': currentUser.email ?? 'Anónimo',
        'usuarioId': currentUser.uid,
        'fecha': DateTime.now(),
      });

      // Obtener el libro para saber quién es el creador
      final libroSnap = await FirebaseFirestore.instance
          .collection('libros_compartidos')
          .doc(widget.libroId)
          .get();

      final creadorId = libroSnap['usuarioId'];

      // Enviar notificación si el comentarista NO es el creador
      if (creadorId != currentUser.uid) {
        await FirebaseFirestore.instance.collection('notificaciones').add({
          'usuarioId': creadorId, // destinatario
          'mensaje':
              '${currentUser.email} comentó tu libro "${libroSnap['titulo']}"',
          'libroId': widget.libroId, // 👈 ESTA LÍNEA ES LA CLAVE
          'leido': false,
          'fecha': DateTime.now(),
        });
      }

      _controller.clear();
    } catch (e) {
      print('Error al enviar comentario o notificación: $e');
    }
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

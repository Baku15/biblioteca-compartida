// presentation/widgets/comentarios_widget.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ComentariosWidget extends ConsumerStatefulWidget {
  final String libroId;
  const ComentariosWidget({super.key, required this.libroId});

  @override
  ConsumerState<ComentariosWidget> createState() => _ComentariosWidgetState();
}

final comentariosStreamProvider = StreamProvider.family<
    List<QueryDocumentSnapshot<Map<String, dynamic>>>, String>(
  (ref, libroId) {
    return FirebaseFirestore.instance
        .collection('libros_compartidos')
        .doc(libroId)
        .collection('comentarios')
        .orderBy('fecha')
        .snapshots()
        .map((snapshot) => snapshot.docs);
  },
);

class _ComentariosWidgetState extends ConsumerState<ComentariosWidget> {
  final TextEditingController _controller = TextEditingController();
  String? respuestaAId;
  String? respuestaAUsuario;

  Future<void> _enviarComentario() async {
    final contenido = _controller.text.trim();
    if (contenido.isEmpty) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      final comentarioData = {
        'contenido': contenido,
        'usuario': currentUser.email ?? 'Anónimo',
        'usuarioId': currentUser.uid,
        'fecha': DateTime.now(),
        if (respuestaAId != null) 'respuestaA': respuestaAId,
      };

      await FirebaseFirestore.instance
          .collection('libros_compartidos')
          .doc(widget.libroId)
          .collection('comentarios')
          .add(comentarioData);

      if (respuestaAId != null) {
        final comentarioOriginalSnap = await FirebaseFirestore.instance
            .collection('libros_compartidos')
            .doc(widget.libroId)
            .collection('comentarios')
            .doc(respuestaAId)
            .get();

        final autorOriginalId = comentarioOriginalSnap['usuarioId'];
        final autorOriginalEmail = comentarioOriginalSnap['usuario'];

        if (autorOriginalId != currentUser.uid) {
          await FirebaseFirestore.instance.collection('notificaciones').add({
            'usuarioId': autorOriginalId,
            'mensaje':
                '${currentUser.email} respondió a tu comentario: "$contenido"',
            'libroId': widget.libroId,
            'leido': false,
            'fecha': DateTime.now(),
          });
        }
      } else {
        final libroSnap = await FirebaseFirestore.instance
            .collection('libros_compartidos')
            .doc(widget.libroId)
            .get();

        final creadorId = libroSnap['usuarioId'];
        if (creadorId != currentUser.uid) {
          await FirebaseFirestore.instance.collection('notificaciones').add({
            'usuarioId': creadorId,
            'mensaje':
                '${currentUser.email} comentó tu libro "${libroSnap['titulo']}"',
            'libroId': widget.libroId,
            'leido': false,
            'fecha': DateTime.now(),
          });
        }
      }

      _controller.clear();
      setState(() {
        respuestaAId = null;
        respuestaAUsuario = null;
      });
    } catch (e) {
      print('Error al enviar comentario o notificación: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final comentariosAsync =
        ref.watch(comentariosStreamProvider(widget.libroId));

    return Column(
      children: [
        comentariosAsync.when(
          data: (comentarios) {
            final principales = comentarios.where((doc) {
              final data = doc.data();
              return !data.containsKey('respuestaA');
            }).toList();

            final respuestas = comentarios.where((doc) {
              final data = doc.data();
              return data.containsKey('respuestaA');
            }).toList();

            return SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: principales.length,
                itemBuilder: (context, index) {
                  final comentario = principales[index];
                  final data = comentario.data();

                  final subrespuestas = respuestas.where((r) {
                    return r.data()['respuestaA'] == comentario.id;
                  }).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(data['contenido']),
                        subtitle: Text("👤 ${data['usuario']}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.reply, size: 20),
                          onPressed: () {
                            setState(() {
                              respuestaAId = comentario.id;
                              respuestaAUsuario = data['usuario'];
                            });
                          },
                        ),
                      ),
                      ...subrespuestas.map((r) {
                        final rData = r.data();
                        return Padding(
                          padding: const EdgeInsets.only(left: 32),
                          child: ListTile(
                            title: Text(rData['contenido']),
                            subtitle: Text("↪️ ${rData['usuario']}"),
                            tileColor: Colors.grey[200],
                          ),
                        );
                      }),
                      const Divider(),
                    ],
                  );
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Text("Error: $err"),
        ),
        if (respuestaAUsuario != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Respondiendo a: $respuestaAUsuario",
                    style: const TextStyle(color: Colors.indigo),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      respuestaAId = null;
                      respuestaAUsuario = null;
                    });
                  },
                )
              ],
            ),
          ),
        Row(
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
        ),
      ],
    );
  }
}

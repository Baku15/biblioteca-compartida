import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificacionesScreen extends StatefulWidget {
  final String usuarioId;

  const NotificacionesScreen({super.key, required this.usuarioId});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  Future<void> marcarComoLeidas() async {
    print('marcarComoLeidas llamado');
    final snapshot = await FirebaseFirestore.instance
        .collection('notificaciones')
        .where('usuarioId', isEqualTo: widget.usuarioId)
        .where('leido', isEqualTo: false)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.update({'leido': true});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notificaciones"),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Marcar todo como leído',
            onPressed: () async {
              await marcarComoLeidas();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("✅ Notificaciones marcadas como leídas")),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notificaciones')
            .where('usuarioId', isEqualTo: widget.usuarioId)
            .orderBy('fecha', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final notificaciones = snapshot.data!.docs;

          // Aquí agregas el print para depurar
          print('Notificaciones recibidas: ${notificaciones.length}');
          for (var notif in notificaciones) {
            final data = notif.data() as Map<String, dynamic>;
            print(
                'Notif mensaje: ${data['mensaje']} para usuarioId: ${data['usuarioId']}');
          }

          if (notificaciones.isEmpty) {
            return const Center(child: Text("No tienes notificaciones."));
          }
          return ListView.builder(
            itemCount: notificaciones.length,
            itemBuilder: (context, index) {
              final notif = notificaciones[index];
              final leido = notif['leido'] == true;

              return ListTile(
                leading: Icon(
                  leido ? Icons.notifications_none : Icons.notifications_active,
                  color: leido ? Colors.grey : Colors.redAccent,
                ),
                title: Text(
                  notif['mensaje'] ?? '',
                  style: TextStyle(
                    fontWeight: leido ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  (notif['fecha'] as Timestamp)
                      .toDate()
                      .toString()
                      .substring(0, 16),
                ),
                onTap: () async {
                  // ✅ Validación segura para campo opcional
                  final data = notif.data() as Map<String, dynamic>;
                  final libroId =
                      data.containsKey('libroId') ? data['libroId'] : null;

                  if (libroId != null && libroId.toString().isNotEmpty) {
                    final doc = await FirebaseFirestore.instance
                        .collection('libros_compartidos')
                        .doc(libroId)
                        .get();

                    if (doc.exists) {
                      Navigator.pushNamed(
                        context,
                        '/detalle_libro_compartido',
                        arguments: doc,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('⚠️ Libro no encontrado')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              '❗ Esta notificación no tiene un libro asociado')),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

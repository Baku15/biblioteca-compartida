import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_libros/application/notificaciones_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificacionesScreen extends ConsumerStatefulWidget {
  final String usuarioId;

  const NotificacionesScreen({super.key, required this.usuarioId});

  @override
  ConsumerState<NotificacionesScreen> createState() =>
      _NotificacionesScreenState();
}

class _NotificacionesScreenState extends ConsumerState<NotificacionesScreen> {
  Future<void> marcarComoLeidas() async {
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

              // Aquí usas ref para invalidar el provider y refrescar la UI
              ref.invalidate(notificacionesNoLeidasProvider(widget.usuarioId));

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("✅ Notificaciones marcadas como leídas"),
                  ),
                );
              }
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
              );
            },
          );
        },
      ),
    );
  }
}

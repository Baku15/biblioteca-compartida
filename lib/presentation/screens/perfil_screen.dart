import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  String? nickname;
  String? bio;
  String? fotoUrl;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      // Usuario no autenticado, manejar esto (mostrar mensaje, salir, etc)
      print('No hay usuario autenticado.');
      return;
    }

    final uid = currentUser.uid;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .get();
      final data = doc.data();

      if (data != null) {
        setState(() {
          nickname = data['nickname'];
          bio = data['bio'];
          fotoUrl = data['fotoUrl'];
        });
      }
    } catch (e) {
      print('Error al cargar perfil: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final letraInicial =
        nickname?.isNotEmpty == true ? nickname![0].toUpperCase() : '?';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // FOTO o INICIAL
                CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      fotoUrl != null ? NetworkImage(fotoUrl!) : null,
                  backgroundColor: Colors.grey[300],
                  child: fotoUrl == null
                      ? Text(
                          letraInicial,
                          style: const TextStyle(
                              fontSize: 40, color: Colors.white),
                        )
                      : null,
                ),
                const SizedBox(height: 16),

                // NICKNAME
                Text(
                  nickname ?? 'Usuario',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                // BIO
                if (bio != null && bio!.isNotEmpty)
                  Text(
                    bio!,
                    style: const TextStyle(
                        fontSize: 16, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  )
                else
                  const Text(
                    'Sin biografía aún',
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  ),

                const SizedBox(height: 20),
                const Divider(thickness: 1.5),
                const SizedBox(height: 20),

                // BOTÓN EDITAR PERFIL
                ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.pushNamed(context, '/editar_perfil');
                    _cargarPerfil(); // Recarga tras editar
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar Perfil'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                // ... debajo del email
                const SizedBox(height: 20),

                ElevatedButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (!context.mounted) return;
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        '/login', (Route<dynamic> route) => false);
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text("Cerrar sesión"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
                Text(
                  FirebaseAuth.instance.currentUser!.email ?? '',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

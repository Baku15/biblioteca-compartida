import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Para Firestore
import '../../application/auth_provider.dart';
import 'explorar_libros_screen.dart';
import 'mis_libros_screen.dart';
import 'perfil_screen.dart';
import 'notificaciones_screen.dart'; // Importa tu pantalla de notificaciones

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final String usuarioId =
        ref.read(authServiceProvider).currentUser?.uid ?? '';

    final List<Widget> screens = [
      MisLibrosScreen(usuarioId: usuarioId),
      const ExplorarLibrosScreen(),
      NotificacionesScreen(usuarioId: usuarioId), // Nueva pantalla
      const PerfilScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblioteca'),
        backgroundColor: Colors.indigo,
        // Ya no hay campanita aquí
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notificaciones')
            .where('usuarioId', isEqualTo: usuarioId)
            .where('leido', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          final count = snapshot.data?.docs.length ?? 0;
          return BottomNavigationBar(
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.blueAccent,
            unselectedItemColor: Colors.grey,
            onTap: (index) => setState(() => _selectedIndex = index),
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.book),
                label: 'Mis Libros',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.public),
                label: 'Explorar',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    const Icon(Icons.notifications),
                    if (count > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: CircleAvatar(
                          radius: 8,
                          backgroundColor: Colors.red,
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                label: 'Notificaciones',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
          );
        },
      ),
    );
  }
}

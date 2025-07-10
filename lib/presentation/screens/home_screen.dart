import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../application/auth_provider.dart';
import '../screens/explorar_libros_screen.dart';
import '../screens/mis_libros_screen.dart';
import '../screens/perfil_screen.dart';
import '../screens/notificaciones_screen.dart';
import '../../application/notificaciones_provider.dart'; // nuevo provider

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authServiceProvider);
    final usuarioId = authService.currentUser?.uid;

    if (usuarioId == null || usuarioId.isEmpty) {
      // Mostrar pantalla de carga si aún no se ha obtenido el UID
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final List<Widget> screens = [
      MisLibrosScreen(usuarioId: usuarioId),
      const ExplorarLibrosScreen(),
      NotificacionesScreen(usuarioId: usuarioId),
      const PerfilScreen(),
    ];

    final notificacionesAsync =
        ref.watch(notificacionesNoLeidasProvider(usuarioId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblioteca'),
        backgroundColor: Colors.indigo,
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
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
                notificacionesAsync.when(
                  data: (count) => count > 0
                      ? Positioned(
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
                        )
                      : const SizedBox.shrink(),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
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
      ),
    );
  }
}

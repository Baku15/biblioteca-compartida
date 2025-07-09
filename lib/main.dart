import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter_libros/models/locales/libro_local.dart';
import 'package:flutter_libros/models/locales/nota_lectura.dart';

import 'application/auth_provider.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/agregar_libro_screen.dart';
import 'presentation/screens/agregar_nota_screen.dart';
import 'presentation/screens/editar_libro_screen.dart';
import 'presentation/screens/editar_nota_screen.dart';
import 'presentation/screens/editar_perfil_screen.dart';
import 'presentation/screens/explorar_libros_screen.dart';
import 'presentation/screens/detalle_libro_compartido_screen.dart';
import 'presentation/screens/notificaciones_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Biblioteca Compartida',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),

      /// 👇 Manejo de rutas dinámicas (con argumentos)
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/notificaciones':
            final usuarioId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => NotificacionesScreen(usuarioId: usuarioId),
            );

          case '/editar_nota':
            final nota = settings.arguments as NotaLectura;
            return MaterialPageRoute(
              builder: (_) => EditarNotaScreen(nota: nota),
            );

          case '/agregar_nota':
            final libroId = settings.arguments as int;
            return MaterialPageRoute(
              builder: (_) => AgregarNotaScreen(libroId: libroId),
            );

          case '/detalle_libro_compartido':
            final libro = settings.arguments as DocumentSnapshot;
            return MaterialPageRoute(
              builder: (_) => DetalleLibroCompartidoScreen(libro: libro),
            );

          case '/agregar_libro':
            final usuarioId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => AgregarLibroScreen(usuarioId: usuarioId),
            );

          case '/editar_libro':
            final libro = settings.arguments as LibroLocal;
            return MaterialPageRoute(
              builder: (_) => EditarLibroScreen(libro: libro),
            );
        }

        return null; // Ruta desconocida
      },

      /// 👇 Rutas estáticas (sin argumentos)
      routes: {
        '/login': (context) => const LoginScreen(),
        '/editar_perfil': (context) => const EditarPerfilScreen(),
        '/explorar': (context) => const ExplorarLibrosScreen(),
        '/explorar_libros': (context) => const ExplorarLibrosScreen(),
      },

      /// 👇 Inicio según el estado de autenticación
      home: authState.when(
        data: (user) => user != null ? const HomeScreen() : const LoginScreen(),
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (_, __) => const Scaffold(
          body: Center(child: Text('Error de autenticación')),
        ),
      ),
    );
  }
}

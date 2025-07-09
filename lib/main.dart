import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_libros/models/locales/libro_local.dart';
import 'package:flutter_libros/models/locales/nota_lectura.dart';
import 'package:flutter_libros/presentation/screens/agregar_libro_screen.dart';
import 'package:flutter_libros/presentation/screens/agregar_nota_screen.dart';
import 'package:flutter_libros/presentation/screens/detalle_libro_compartido_screen.dart';
import 'package:flutter_libros/presentation/screens/editar_libro_screen.dart';
import 'package:flutter_libros/presentation/screens/editar_nota_screen.dart';
import 'package:flutter_libros/presentation/screens/explorar_libros_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'application/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ProviderScope(child: MyApp()));
}

//void main() async {
//  WidgetsFlutterBinding.ensureInitialized();
//  final dbPath = await getDatabasesPath();
//  final path = join(dbPath, 'libros.db');
//  await deleteDatabase(path); // 🔥 Esto borra la BD
//  runApp(ProviderScope(child: MyApp()));
//}

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
      // 👇 RUTAS REGISTRADAS AQUÍ
      routes: {
        '/editar_nota': (context) {
          final nota =
              ModalRoute.of(context)!.settings.arguments as NotaLectura;
          return EditarNotaScreen(nota: nota);
        },
        '/agregar_nota': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as int;
          return AgregarNotaScreen(libroId: args);
        },
        '/explorar': (context) => const ExplorarLibrosScreen(),
        '/detalle_libro_compartido': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments as DocumentSnapshot;
          return DetalleLibroCompartidoScreen(libro: args);
        },
        '/explorar_libros': (context) => const ExplorarLibrosScreen(),
        '/agregar_libro': (context) => const AgregarLibroScreen(),
        '/editar_libro': (context) {
          final libro =
              ModalRoute.of(context)!.settings.arguments as LibroLocal;
          return EditarLibroScreen(libro: libro);
        },
      },
      home: authState.when(
        data: (user) => user != null ? const HomeScreen() : const LoginScreen(),
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (_, __) =>
            const Scaffold(body: Center(child: Text('Error de autenticación'))),
      ),
    );
  }
}

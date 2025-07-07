import 'package:flutter/material.dart';
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

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      home: authState.when(
        data: (user) => user != null ? HomeScreen() : LoginScreen(),
        loading: () =>
            Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (_, __) =>
            Scaffold(body: Center(child: Text('Error de autenticación'))),
      ),
    );
  }
}

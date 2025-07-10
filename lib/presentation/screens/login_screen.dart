import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/auth_provider.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import '../widgets/custom_snackbar.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authServiceProvider); // en lugar de .read

    return Scaffold(
      body: Stack(
        children: [
          // Imagen de fondo
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    "assets/fondo_libro.jpeg"), // Asegúrate que esté en pubspec.yaml
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Capa de oscurecimiento
          Container(
            color: Colors.black.withOpacity(0.5),
          ),

          // Contenido del formulario
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Iniciar Sesión',
                        style: TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildTextField("Correo electrónico", _emailController,
                          TextInputType.emailAddress),
                      const SizedBox(height: 16),
                      _buildTextField(
                          "Contraseña", _passwordController, TextInputType.text,
                          obscure: true),
                      const SizedBox(height: 32),
                      _loading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.white.withOpacity(0.95),
                                  foregroundColor: Colors.black,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 11),
                                  textStyle: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 4,
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() => _loading = true);
                                    try {
                                      await auth.login(
                                        _emailController.text.trim(),
                                        _passwordController.text.trim(),
                                      );
                                      if (!mounted)
                                        return; // <-- Verificamos aquí también
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => const HomeScreen()),
                                      );
                                    } catch (e) {
                                      if (!mounted) return;
                                      showCustomSnackbar(
                                          context, 'Error: ${e.toString()}',
                                          isError: true);
                                    } finally {
                                      if (!mounted) return;
                                      setState(() => _loading = false);
                                    }
                                  }
                                },
                                child: const Text('INGRESAR'),
                              ),
                            ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RegisterScreen()),
                        ),
                        child: const Text(
                          '¿No tienes cuenta? Regístrate',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    TextInputType type, {
    bool obscure = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: type,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black54),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          showCustomSnackbar(context, 'Por favor completa el campo: $label',
              isError: true);
          return ''; // evita el texto rojo
        }
        return null;
      },
    );
  }
}

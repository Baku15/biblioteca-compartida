import 'package:flutter/material.dart';
import 'package:flutter_libros/presentation/widgets/custom_snackbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/auth_provider.dart';
import 'login_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final auth = ref.read(authServiceProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Imagen de fondo
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/fondo_libro.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Capa oscura
          Container(
            color: Colors.black.withOpacity(0.5),
          ),

          // Contenido
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
                        'Crear Cuenta',
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
                      const SizedBox(height: 16),
                      _buildTextField("Repetir contraseña",
                          _confirmPasswordController, TextInputType.text,
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
                                      const EdgeInsets.symmetric(vertical: 18),
                                  textStyle: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() => _loading = true);
                                    try {
                                      await auth.register(
                                        _emailController.text.trim(),
                                        _passwordController.text.trim(),
                                      );

// Mostrar mensaje elegante
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          backgroundColor:
                                              Colors.white.withOpacity(0.95),
                                          elevation: 6,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          content: Row(
                                            children: const [
                                              Icon(Icons.check_circle,
                                                  color: Colors.green,
                                                  size: 22),
                                              SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  'Registro exitoso. Por favor inicia sesión.',
                                                  style: TextStyle(
                                                    color: Colors.black87,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                          duration: Duration(seconds: 3),
                                        ),
                                      );

// Pequeña espera para que el usuario lo vea antes del cambio de pantalla
                                      await Future.delayed(
                                          const Duration(milliseconds: 500));

// Redirigir al login
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const LoginScreen()),
                                      );
                                    } catch (e) {
                                      showCustomSnackbar(
                                          context, 'Error: ${e.toString()}',
                                          isError: true);
                                    } finally {
                                      setState(() => _loading = false);
                                    }
                                  }
                                },
                                child: const Text('REGISTRARSE'),
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
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
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
          borderSide: const BorderSide(color: Colors.red),
        ),
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

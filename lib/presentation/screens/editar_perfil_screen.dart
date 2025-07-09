import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _bioController = TextEditingController();
  File? _imagenSeleccionada;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc =
        await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
    final data = doc.data();

    if (data != null) {
      _nicknameController.text = data['nickname'] ?? '';
      _bioController.text = data['bio'] ?? '';
    }
  }

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imagenSeleccionada = File(picked.path);
      });
    }
  }

  Future<void> _guardarPerfil() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final nickname = _nicknameController.text.trim();

    // Validar nickname único
    final query = await FirebaseFirestore.instance
        .collection('usuarios')
        .where('nickname', isEqualTo: nickname)
        .get();

    final yaExisteOtro = query.docs.any((doc) => doc.id != uid);
    if (yaExisteOtro) {
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ese nickname ya está en uso')),
      );
      return;
    }

    String? fotoUrl;
    if (_imagenSeleccionada != null) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('fotos_perfil')
          .child('$uid.jpg');
      await ref.putFile(_imagenSeleccionada!);
      fotoUrl = await ref.getDownloadURL();
    }

    final Map<String, dynamic> nuevosDatos = {
      'nickname': nickname,
      'bio': _bioController.text.trim(),
    };
    if (fotoUrl != null) nuevosDatos['fotoUrl'] = fotoUrl;

    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .set(nuevosDatos, SetOptions(merge: true));

    setState(() => _guardando = false);
    Navigator.pop(context); // ✅ Regresa a Perfil con datos actualizados
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_imagenSeleccionada != null)
                CircleAvatar(
                  radius: 50,
                  backgroundImage: FileImage(_imagenSeleccionada!),
                )
              else
                const CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person, size: 50),
                ),
              TextButton.icon(
                onPressed: _seleccionarImagen,
                icon: const Icon(Icons.photo),
                label: const Text('Seleccionar imagen'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  labelText: 'Nickname',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Escribe tu nickname';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Bio (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              _guardando
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _guardarPerfil,
                      icon: const Icon(Icons.save),
                      label: const Text('Guardar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

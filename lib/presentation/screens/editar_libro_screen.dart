import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_libros/models/remotos/libro_compartido.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/local/libro_local_datasource.dart';
import '../../../models/locales/libro_local.dart';

class EditarLibroScreen extends StatefulWidget {
  final LibroLocal libro;

  const EditarLibroScreen({super.key, required this.libro});

  @override
  State<EditarLibroScreen> createState() => _EditarLibroScreenState();
}

class _EditarLibroScreenState extends State<EditarLibroScreen> {
  String? _estadoSeleccionado;
  TextEditingController _resenaController = TextEditingController();
  int _calificacion = 0;
  final _formKey = GlobalKey<FormState>();
  final _dataSource = LibroLocalDataSource();

  late TextEditingController _tituloController;
  late TextEditingController _autorController;
  late TextEditingController _categoriaController;
  late TextEditingController _resumenController;

  XFile? _imagenSeleccionada;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.libro.titulo);
    _autorController = TextEditingController(text: widget.libro.autor);
    _categoriaController = TextEditingController(text: widget.libro.categoria);
    _resumenController = TextEditingController(text: widget.libro.resumen);
    _estadoSeleccionado = widget.libro.estadoLectura ?? 'Quiero leer';
    _resenaController = TextEditingController(text: widget.libro.resena ?? '');
    _calificacion = widget.libro.calificacion ?? 0;
  }

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imagenSeleccionada = pickedFile);
    }
  }

  Future<void> _guardarCambios() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _guardando = true);

      final libroActualizado = widget.libro.copyWith(
        titulo: _tituloController.text.trim(),
        autor: _autorController.text.trim(),
        categoria: _categoriaController.text.trim(),
        resumen: _resumenController.text.trim(),
        imagenPath: _imagenSeleccionada?.path ?? widget.libro.imagenPath,
        estadoLectura: _estadoSeleccionado,
        resena: _resenaController.text.trim(),
        calificacion: _calificacion,
      );

      // Actualización local
      await _dataSource.updateLibro(libroActualizado);

      // 🔁 Si el libro ya fue compartido, también actualizar en Firestore
      if (libroActualizado.remoteId != null) {
        final docId = libroActualizado.remoteId!;
        await FirebaseFirestore.instance
            .collection('libros_compartidos')
            .doc(docId)
            .update({
          'titulo': libroActualizado.titulo,
          'autor': libroActualizado.autor,
          'categoria': libroActualizado.categoria,
          'resumen': libroActualizado.resumen,
          'imagenUrl': libroActualizado
              .imagenPath, // O la URL real si la subes a Firebase Storage
          'estadoLectura': libroActualizado.estadoLectura,
          'resena': libroActualizado.resena,
          'calificacion': libroActualizado.calificacion,
          'fechaActualizacion': DateTime.now().toIso8601String(),
        });
      } else {
        // Muestra un aviso opcional si el libro aún no fue compartido
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.orange,
            content: const Text('Este libro aún no fue compartido en la nube.'),
          ),
        );
      }

      setState(() => _guardando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green.withOpacity(0.95),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          content: const Text(
            '📘 Libro actualizado con éxito',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Libro"),
        backgroundColor: const Color(0xFF1976D2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_imagenSeleccionada != null ||
                  widget.libro.imagenPath != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(_imagenSeleccionada?.path ?? widget.libro.imagenPath!),
                    width: 120,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 10),
              ],
              ElevatedButton.icon(
                onPressed: _seleccionarImagen,
                icon: const Icon(Icons.photo),
                label: const Text("Cambiar Imagen"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 20),
              _campoTexto("Título", _tituloController),
              const SizedBox(height: 16),
              _campoTexto("Autor", _autorController),
              const SizedBox(height: 16),
              _campoTexto("Categoría", _categoriaController),
              const SizedBox(height: 16),
              _campoTexto("Resumen", _resumenController, maxLines: 4),
              const SizedBox(height: 30),
              const SizedBox(height: 16),
// Dropdown de Estado de lectura
              DropdownButtonFormField<String>(
                value: _estadoSeleccionado,
                decoration: InputDecoration(
                  labelText: "Estado de lectura",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: ['Quiero leer', 'Leyendo', 'Leído'].map((estado) {
                  return DropdownMenuItem<String>(
                    value: estado,
                    child: Text(estado),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _estadoSeleccionado = value),
              ),
              const SizedBox(height: 16),

// Campo de reseña
              TextFormField(
                controller: _resenaController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: "Reseña personal",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 16),
// Calificación con estrellas
              Row(
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      Icons.star,
                      color: index < _calificacion
                          ? Colors.amber
                          : Colors.grey[400],
                    ),
                    onPressed: () {
                      setState(() {
                        _calificacion = index + 1;
                      });
                    },
                  );
                }),
              ),
              _guardando
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _guardarCambios,
                      icon: const Icon(Icons.save),
                      label: const Text("Guardar Cambios"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 14),
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

  Widget _campoTexto(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Este campo es obligatorio';
        }
        return null;
      },
    );
  }

  void _mostrarDetallesLibroCompartido(
      BuildContext context, LibroCompartido libro) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (libro.imagenUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        libro.imagenUrl!,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    libro.titulo,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text('Autor: ${libro.autor}',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 12),
                  Text(
                    libro.categoria,
                    style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ⭐ Calificación
                  if (libro.calificacion != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return Icon(
                          index < libro.calificacion!
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                        );
                      }),
                    ),

                  // 📝 Reseña
                  if (libro.resena != null && libro.resena!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text("Reseña:",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      libro.resena!,
                      textAlign: TextAlign.justify,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],

                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cerrar'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

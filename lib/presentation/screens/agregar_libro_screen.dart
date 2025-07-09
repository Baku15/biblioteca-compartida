import 'dart:io';
import 'package:flutter/material.dart';
import '../../../data/local/libro_local_datasource.dart';
import '../../../models/locales/libro_local.dart';
import 'package:image_picker/image_picker.dart'; //

class AgregarLibroScreen extends StatefulWidget {
  const AgregarLibroScreen({super.key});

  @override
  State<AgregarLibroScreen> createState() => _AgregarLibroScreenState();
}

class _AgregarLibroScreenState extends State<AgregarLibroScreen> {
  final _resenaController = TextEditingController();
  int _calificacionSeleccionada = 0;
  String _estadoSeleccionado = 'Quiero leer';
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _autorController = TextEditingController();
  String? _categoriaSeleccionada;
  bool _mostrarCampoOtraCategoria = false;
  final _otraCategoriaController = TextEditingController();
  final _resumenController = TextEditingController();

  final _dataSource = LibroLocalDataSource();

  bool _guardando = false;
  XFile? _imagenSeleccionada;

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imagenSeleccionada = pickedFile);
    }
  }

  final List<String> _categoriasPredefinidas = [
    'Fantasía',
    'Ciencia ficción',
    'Romance',
    'Historia',
    'Educación',
    'Misterio',
    'Terror',
    'Thriller',
    'Drama',
    'Aventura',
    'Poesía',
    'Biografía',
    'Autobiografía',
    'Memorias',
    'Ensayo',
    'Cuento',
    'Crónica',
    'Literatura clásica',
    'Literatura contemporánea',
    'Novela gráfica',
    'Comic',
    'Juvenil',
    'Infantil',
    'Autoayuda',
    'Psicología',
    'Filosofía',
    'Sociología',
    'Política',
    'Economía',
    'Ciencias naturales',
    'Divulgación científica',
    'Tecnología',
    'Matemáticas',
    'Religión',
    'Espiritualidad',
    'Viajes',
    'Gastronomía',
    'Arte',
    'Música',
    'Teatro',
    'Cine',
    'Fotografía',
    'Erótica',
    'LGBTQ+',
    'Clásicos universales',
    'Cultura general',
    'Mitología',
    'Desarrollo personal',
    'Salud y bienestar',
    'Deportes',
    'Negocios',
    'Marketing',
    'Emprendimiento',
    'Educación financiera',
    'Lenguas y diccionarios',
    'Cómic manga',
    'Ciencia ficción distópica',
    'Narrativa histórica',
    'Realismo mágico',
    'Humor',
    'Relatos cortos',
    'Otro',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Libro'),
        backgroundColor: const Color(0xFF1976D2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _campoTexto("Título", _tituloController),
              const SizedBox(height: 16),
              _campoTexto("Autor", _autorController),
              const SizedBox(height: 16),

              /// Estado de Lectura
              DropdownButtonFormField<String>(
                value: _estadoSeleccionado,
                decoration: InputDecoration(
                  labelText: "Estado de lectura",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: [
                  'Quiero leer',
                  'Leyendo',
                  'Leído',
                ].map((estado) {
                  return DropdownMenuItem<String>(
                    value: estado,
                    child: Text(estado),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _estadoSeleccionado = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              /// Categoría
              DropdownButtonFormField<String>(
                value: _categoriaSeleccionada,
                items: _categoriasPredefinidas.map((categoria) {
                  return DropdownMenuItem<String>(
                    value: categoria,
                    child: Text(categoria),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _categoriaSeleccionada = value;
                    _mostrarCampoOtraCategoria = value == 'Otro';
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Categoría',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Selecciona una categoría';
                  }
                  return null;
                },
              ),

              if (_mostrarCampoOtraCategoria) const SizedBox(height: 16),

              /// Campo "Otra categoría"
              if (_mostrarCampoOtraCategoria)
                TextFormField(
                  controller: _otraCategoriaController,
                  decoration: InputDecoration(
                    labelText: 'Otra categoría',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    if (_mostrarCampoOtraCategoria &&
                        (value == null || value.trim().isEmpty)) {
                      return 'Escribe una categoría';
                    }
                    return null;
                  },
                ),

              const SizedBox(height: 16),
              _campoTexto("Resumen", _resumenController, maxLines: 4),

              const SizedBox(height: 16),
              Row(
                children: [
                  const Text("Calificación:"),
                  const SizedBox(width: 12),
                  for (int i = 1; i <= 5; i++)
                    IconButton(
                      icon: Icon(
                        i <= _calificacionSeleccionada
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                      ),
                      onPressed: () {
                        setState(() => _calificacionSeleccionada = i);
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _resenaController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Reseña personal',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 24),

              /// Imagen seleccionada
              _imagenSeleccionada != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(_imagenSeleccionada!.path),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Text("No se ha seleccionado imagen"),

              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _seleccionarImagen,
                icon: const Icon(Icons.image),
                label: const Text("Seleccionar Imagen"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),

              const SizedBox(height: 30),
              _guardando
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      label: const Text("Guardar"),
                      onPressed: _guardarLibro,
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

  Future<void> _guardarLibro() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _guardando = true);

      // Obtener la categoría según la selección
      final categoriaElegida = _mostrarCampoOtraCategoria
          ? _otraCategoriaController.text.trim()
          : _categoriaSeleccionada ?? '';

      final libro = LibroLocal(
        id: 0, // SQLite lo autogenera
        titulo: _tituloController.text.trim(),
        autor: _autorController.text.trim(),
        categoria: categoriaElegida,
        resumen: _resumenController.text.trim(),
        fechaCreacion: DateTime.now(),
        imagenPath: _imagenSeleccionada?.path,
        estadoLectura: _estadoSeleccionado,
        calificacion: _calificacionSeleccionada,
        resena: _resenaController.text.trim(),
      );

      await _dataSource.insertLibro(libro);
      final todos = await _dataSource.getLibros();
      print("🔍 Libros en la base de datos: ${todos.length}");

      setState(() => _guardando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green.withOpacity(0.95),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          content: const Text(
            '📚 Libro guardado exitosamente',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );

      Navigator.pop(context, true);
    }
  }
}

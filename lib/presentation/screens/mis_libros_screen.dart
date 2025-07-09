import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_libros/data/sincronizacion/sincronizar_libros.dart';
import 'package:intl/intl.dart';
import '../../../data/local/libro_local_datasource.dart';
import '../../../models/locales/libro_local.dart';
import 'package:intl/date_symbol_data_local.dart';

class MisLibrosScreen extends StatefulWidget {
  const MisLibrosScreen({super.key});

  @override
  State<MisLibrosScreen> createState() => _MisLibrosScreenState();
}

class _MisLibrosScreenState extends State<MisLibrosScreen> {
  List<LibroLocal> _libros = [];
  final LibroLocalDataSource _dataSource = LibroLocalDataSource();

  @override
  void initState() {
    super.initState();
    _cargarLibros();
  }

  Future<void> _cargarLibros() async {
    final libros = await _dataSource.getLibros();
    if (mounted) {
      setState(() {
        _libros = libros;
      });
    }
  }

  Future<void> _mostrarDetallesLibro(
      BuildContext context, LibroLocal libro) async {
    await initializeDateFormatting('es', null);
    final formatoFecha = DateFormat('d MMMM yyyy', 'es');
    final fechaTexto = formatoFecha.format(libro.fechaCreacion);

    // Íconos según categoría (puedes ampliarlo según categorías reales)
    final iconoCategoria = {
      'novela': Icons.menu_book,
      'ciencia': Icons.science,
      'historia': Icons.history_edu,
      'fantasía': Icons.auto_stories,
      'otros': Icons.bookmark_outline,
    };

    String categoria = libro.categoria.toLowerCase();
    IconData icono = iconoCategoria[categoria] ?? Icons.book;

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
                  if (libro.imagenPath != null &&
                      File(libro.imagenPath!).existsSync())
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(libro.imagenPath!),
                        height: 180,
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
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icono, color: Colors.blueGrey),
                      const SizedBox(width: 6),
                      Text(libro.categoria,
                          style: const TextStyle(
                              fontSize: 15, fontStyle: FontStyle.italic)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('📅 Agregado el $fechaTexto',
                      style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 12),
                  if (libro.resumen.isNotEmpty)
                    Text(
                      libro.resumen,
                      style: const TextStyle(fontSize: 15),
                      textAlign: TextAlign.justify,
                    ),

                  //parte que agrega calificacion
                  if (libro.calificacion != null) ...[
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
                    const SizedBox(height: 8),
                  ],
                  if (libro.resena != null && libro.resena!.isNotEmpty) ...[
                    Text(
                      libro.resena!,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 12),
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

  void _eliminarLibroConfirmado(BuildContext context, LibroLocal libro) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.white,
        title: const Text('¿Eliminar libro?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              final messenger =
                  ScaffoldMessenger.of(context); // ✅ Lo guardas primero
              Navigator.pop(context); // Luego cierras el diálogo

              // 🔥 Borrar de Firestore si tiene remoteId
              if (libro.remoteId != null && libro.remoteId!.isNotEmpty) {
                try {
                  await FirebaseFirestore.instance
                      .collection('libros_compartidos')
                      .doc(libro.remoteId)
                      .delete();
                } catch (e) {
                  print('❌ Error al borrar de Firebase: $e');
                }
              }

              // 🧹 Borrar localmente
              await _dataSource.deleteLibro(libro.id);
              _cargarLibros();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red.withOpacity(0.9),
                  content: const Text('📕 Libro eliminado'),
                ),
              );
            },
            label: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Libros'),
        backgroundColor: const Color(0xFF1976D2),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sincronizar con la nube',
            onPressed: _sincronizarConNube,
          ),
        ],
      ),
      body: _libros.isEmpty
          ? const Center(child: Text('No tienes libros aún.'))
          : ListView.builder(
              itemCount: _libros.length,
              itemBuilder: (context, index) {
                final libro = _libros[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: libro.imagenPath != null &&
                            File(libro.imagenPath!).existsSync()
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(libro.imagenPath!),
                              width: 60,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(
                            width: 60,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.book,
                                size: 40, color: Colors.black54),
                          ),
                    title: Text(
                      libro.titulo,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(libro.autor),
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit,
                              color: Colors.orangeAccent),
                          onPressed: () async {
                            final resultado = await Navigator.pushNamed(
                              context,
                              '/editar_libro',
                              arguments: libro,
                            );
                            if (resultado == true) _cargarLibros();
                          },
                        ),
                        IconButton(
                          icon:
                              const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () =>
                              _eliminarLibroConfirmado(context, libro),
                        ),
                        IconButton(
                          icon: const Icon(Icons.cloud_upload,
                              color: Colors.blueAccent),
                          onPressed: () async {
                            final sincronizador = SincronizadorLibros();
                            await sincronizador.compartirLibro(libro);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                    '📤 Libro compartido en la nube'),
                                backgroundColor: Colors.blue.withOpacity(0.9),
                                behavior: SnackBarBehavior.floating,
                                margin: const EdgeInsets.all(16),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    onTap: () => _mostrarDetallesLibro(context, libro),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final resultado =
              await Navigator.pushNamed(context, '/agregar_libro');
          if (resultado == true) _cargarLibros();
        },
        backgroundColor: const Color(0xFF1976D2),
        icon: const Icon(Icons.add),
        label: const Text("Agregar"),
      ),
    );
  }

  Future<void> _sincronizarConNube() async {
    final librosLocales = await _dataSource.getLibros();

    for (final libro in librosLocales) {
      final libroData = {
        'titulo': libro.titulo,
        'autor': libro.autor,
        'resumen': libro.resumen,
        'categoria': libro.categoria,
        'usuarioId': FirebaseAuth.instance.currentUser!.uid,
        'estadoLectura': libro.estadoLectura,
        'imagenUrl': null,
        'calificacion': libro.calificacion,
        'resena': libro.resena,
        'fechaCreacion': libro.fechaCreacion.toIso8601String(),
      };

      if (libro.remoteId != null && libro.remoteId!.isNotEmpty) {
        // Ya está sincronizado → actualiza
        await FirebaseFirestore.instance
            .collection('libros_compartidos')
            .doc(libro.remoteId)
            .set(libroData);
      } else {
        // Primera sincronización → agrega y guarda ID
        final docRef = await FirebaseFirestore.instance
            .collection('libros_compartidos')
            .add(libroData);

        await _dataSource.actualizarRemoteId(libro.id, docRef.id);
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('✅ Libros sincronizados sin duplicados'),
        backgroundColor: Colors.green.withOpacity(0.95),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

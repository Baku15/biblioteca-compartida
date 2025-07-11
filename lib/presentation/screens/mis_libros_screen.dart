import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_libros/data/local/historial_lectura_datasource.dart';
import 'package:flutter_libros/data/local/nota_lectura_datasource.dart';
import 'package:flutter_libros/data/sincronizacion/sincronizar_libros.dart';
import 'package:flutter_libros/models/locales/historial_lectura.dart';
import 'package:flutter_libros/models/locales/nota_lectura.dart';
import 'package:intl/intl.dart';
import '../../../data/local/libro_local_datasource.dart';
import '../../../models/locales/libro_local.dart';
import 'package:intl/date_symbol_data_local.dart';

class MisLibrosScreen extends StatefulWidget {
  final String usuarioId;
  const MisLibrosScreen({super.key, required this.usuarioId});

  @override
  State<MisLibrosScreen> createState() => _MisLibrosScreenState();
}

class _MisLibrosScreenState extends State<MisLibrosScreen> {
  List<LibroLocal> _libros = [];
  final LibroLocalDataSource _dataSource = LibroLocalDataSource();

  @override
  void initState() {
    super.initState();

    _descargarLibrosDelUsuario().then((_) async {
      await _sincronizarConNube(); // 🔄 Auto sincroniza al iniciar
      _cargarLibros();
    });
  }

  Future<void> _descargarLibrosDelUsuario() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final uid = currentUser.uid;
    final firestore = FirebaseFirestore.instance;
    final db = LibroLocalDataSource();

    final snapshot = await firestore
        .collection('libros_compartidos')
        .where('usuarioId', isEqualTo: uid)
        .get();

    for (final doc in snapshot.docs) {
      final data = doc.data();

      // Evita duplicados
      final librosLocales = await db.getLibros();
      final yaExiste = librosLocales.any((libro) => libro.remoteId == doc.id);
      if (yaExiste) continue;

      final libro = LibroLocal(
        id: 0,
        titulo: data['titulo'],
        autor: data['autor'],
        categoria: data['categoria'],
        resumen: data['resumen'],
        fechaCreacion:
            DateTime.tryParse(data['fechaCreacion']) ?? DateTime.now(),
        imagenPath: null,
        estadoLectura: data['estadoLectura'],
        calificacion: data['calificacion'],
        resena: data['resena'],
        remoteId: doc.id,
        usuarioId: uid,
      );

      await db.insertLibro(libro);
    }
  }

  Future<void> _cargarLibros() async {
    final libros = await _dataSource.getLibrosPorUsuario(widget.usuarioId);
    if (mounted) {
      setState(() {
        _libros = libros;
      });
    }
  }

  Future<void> _mostrarDetallesLibro(
      BuildContext contextGlobal, LibroLocal libro) async {
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

    Future<List<NotaLectura>> _obtenerNotas(int libroId) async {
      final notaDataSource = NotaLecturaDataSource();
      return await notaDataSource.obtenerNotasPorLibro(libroId);
    }

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
// boton de Notas
                  const SizedBox(height: 16),
                  FutureBuilder<List<NotaLectura>>(
                    future: _obtenerNotas(libro.id),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text("📌 No hay notas aún");
                      }

                      final notas = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("📝 Notas de lectura:",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          for (final nota in notas) ...[
                            Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Página
                                  Text(
                                    "Página ${nota.pagina}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.indigo,
                                    ),
                                  ),
                                  const SizedBox(height: 6),

                                  // Contenido
                                  Text(
                                    nota.contenido,
                                    style: const TextStyle(fontSize: 14),
                                  ),

                                  const SizedBox(height: 10),

                                  // Fecha
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        DateFormat('dd/MM/yyyy')
                                            .format(nota.fecha),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),

                                      // Botones editar / eliminar
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                color: Colors.orangeAccent),
                                            onPressed: () async {
                                              Navigator.pop(
                                                  context); // cerrar diálogo actual
                                              final resultado =
                                                  await Navigator.pushNamed(
                                                context,
                                                '/editar_nota',
                                                arguments: nota,
                                              );

                                              if (resultado == true) {
                                                _mostrarDetallesLibro(
                                                    context, libro); // recargar
                                              }
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.redAccent),
                                            onPressed: () {
                                              _eliminarNotaConfirmada(
                                                  context, nota, libro);
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),

                  // Boton para AGREGAR UNA NUEVA NOTA
                  ElevatedButton.icon(
                    icon: const Icon(Icons.note_add),
                    label: const Text("Agregar nota"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(context); // cerrar el diálogo actual

                      // Esperamos un pequeño microtask antes de usar context del padre
                      await Future.delayed(Duration.zero);

                      final resultado = await Navigator.pushNamed(
                        contextGlobal, // Usamos el contexto padre
                        '/agregar_nota',
                        arguments: libro.id,
                      );

                      if (resultado == true) {
                        _mostrarDetallesLibro(contextGlobal,
                            libro); // volvemos a mostrar el diálogo
                      }
                    },
                  ),

                  // Codigo de cerrar boton
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

  void _eliminarNotaConfirmada(
      BuildContext context, NotaLectura nota, LibroLocal libro) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.white,
        title: const Text('¿Eliminar nota?'),
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
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context); // cerrar diálogo

              // 🔥 Si la nota fue sincronizada con Firestore
              if (nota.remoteId != null &&
                  nota.remoteId!.isNotEmpty &&
                  libro.remoteId != null &&
                  libro.remoteId!.isNotEmpty) {
                try {
                  await FirebaseFirestore.instance
                      .collection('libros_compartidos')
                      .doc(libro.remoteId)
                      .collection('notas')
                      .doc(nota.remoteId)
                      .delete();
                } catch (e) {
                  print('❌ Error al borrar nota de Firebase: $e');
                }
              }

              // 🧹 Borrar local
              await NotaLecturaDataSource().deleteNota(nota.id!);

              // ✅ Recargar detalle del libro
              _mostrarDetallesLibro(context, libro);

              messenger.showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red.withOpacity(0.9),
                  content: const Text('🗒 Nota eliminada'),
                ),
              );
            },
            label: const Text('Eliminar'),
          ),
        ],
      ),
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
          final resultado = await Navigator.pushNamed(
            context,
            '/agregar_libro',
            arguments: FirebaseAuth.instance.currentUser!.uid, // ✅
          );
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
    final notasDataSource = NotaLecturaDataSource();
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Usuario no autenticado')),
      );
      return;
    }

    final uid = currentUser.uid;

    for (final libro in librosLocales) {
      final libroData = {
        'titulo': libro.titulo,
        'autor': libro.autor,
        'resumen': libro.resumen,
        'categoria': libro.categoria,
        'usuarioId': uid,
        'estadoLectura': libro.estadoLectura,
        'imagenUrl': null,
        'calificacion': libro.calificacion,
        'resena': libro.resena,
        'fechaCreacion': libro.fechaCreacion.toIso8601String(),
      };

      String remoteLibroId;

      if (libro.remoteId != null && libro.remoteId!.isNotEmpty) {
        // Ya sincronizado → actualizar
        remoteLibroId = libro.remoteId!;
        await FirebaseFirestore.instance
            .collection('libros_compartidos')
            .doc(remoteLibroId)
            .set(libroData);
      } else {
        // Primera sincronización → agregar y guardar ID
        final docRef = await FirebaseFirestore.instance
            .collection('libros_compartidos')
            .add(libroData);

        remoteLibroId = docRef.id;
        await _dataSource.actualizarRemoteId(libro.id, remoteLibroId);
      }

      // 🔁 Sincronizar notas
      final notas = await notasDataSource.obtenerNotasPorLibro(libro.id);
      for (final nota in notas) {
        final notaData = {
          'pagina': nota.pagina,
          'contenido': nota.contenido,
          'fecha': nota.fecha.toIso8601String(),
          'usuarioId': uid,
        };

        if (nota.remoteId != null && nota.remoteId!.isNotEmpty) {
          // Ya sincronizada → actualizar
          await FirebaseFirestore.instance
              .collection('libros_compartidos')
              .doc(remoteLibroId)
              .collection('notas')
              .doc(nota.remoteId)
              .set(notaData);
        } else {
          // Nueva nota → agregar
          final notaDocRef = await FirebaseFirestore.instance
              .collection('libros_compartidos')
              .doc(remoteLibroId)
              .collection('notas')
              .add(notaData);

          if (nota.id != null) {
            await notasDataSource.actualizarRemoteId(nota.id!, notaDocRef.id);
          }
        }
      }
    }

    // ✅ Mostrar una única notificación al final
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('✅ Todos los libros y notas fueron sincronizados'),
        backgroundColor: Colors.green.withOpacity(0.95),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

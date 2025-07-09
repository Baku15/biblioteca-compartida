import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_libros/data/local/nota_lectura_datasource.dart';
import 'package:flutter_libros/models/locales/nota_lectura.dart';
import 'package:intl/intl.dart';

class EditarNotaScreen extends StatefulWidget {
  final NotaLectura nota;

  const EditarNotaScreen({super.key, required this.nota});

  @override
  State<EditarNotaScreen> createState() => _EditarNotaScreenState();
}

class _EditarNotaScreenState extends State<EditarNotaScreen> {
  late TextEditingController _contenidoController;
  late TextEditingController _paginaController;
  DateTime _fecha = DateTime.now();
  final _formKey = GlobalKey<FormState>();
  final _notaDataSource = NotaLecturaDataSource();
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _contenidoController = TextEditingController(text: widget.nota.contenido);
    _paginaController =
        TextEditingController(text: widget.nota.pagina.toString());
    _fecha = widget.nota.fecha;
  }

  Future<void> _guardarCambios() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _guardando = true);

      final notaActualizada = widget.nota.copyWith(
        pagina: int.parse(_paginaController.text.trim()),
        contenido: _contenidoController.text.trim(),
        fecha: _fecha,
      );

      // Actualiza en SQLite
      await _notaDataSource.actualizarNota(notaActualizada);

      // Si tiene remoteId → actualiza también en Firestore
      if (notaActualizada.remoteId != null) {
        final docRef = FirebaseFirestore.instance
            .collection('notas_lectura_compartidas')
            .doc(notaActualizada.remoteId);

        final docSnapshot = await docRef.get();

        if (docSnapshot.exists) {
          await docRef.update({
            'pagina': notaActualizada.pagina,
            'contenido': notaActualizada.contenido,
            'fecha': notaActualizada.fecha.toIso8601String(),
          });
        } else {
          print('⚠️ Documento no encontrado en Firestore.');
          // Puedes decidir aquí si vuelves a crearlo:
          // await docRef.set({ ... });
        }
      }

      setState(() => _guardando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("✅ Nota actualizada"),
          backgroundColor: Colors.green.withOpacity(0.95),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );

      Navigator.pop(context, true);
    }
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? nuevaFecha = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (nuevaFecha != null) {
      setState(() {
        _fecha = nuevaFecha;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Nota"),
        backgroundColor: const Color(0xFF1976D2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _paginaController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration("Número de página"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Debe ser un número';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contenidoController,
                maxLines: 5,
                decoration: _inputDecoration("Contenido de la nota"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text("Fecha: "),
                  const SizedBox(width: 8),
                  Text(DateFormat('dd/MM/yyyy').format(_fecha)),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _seleccionarFecha,
                    icon: const Icon(Icons.calendar_today),
                    label: const Text("Cambiar"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
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

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

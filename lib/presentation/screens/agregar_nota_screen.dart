import 'package:flutter/material.dart';
import '../../../models/locales/nota_lectura.dart';
import '../../../data/local/nota_lectura_datasource.dart';

class AgregarNotaScreen extends StatefulWidget {
  final int libroId;
  final String modo; // 'crear' o 'editar'
  final NotaLectura? nota;
  const AgregarNotaScreen({
    super.key,
    required this.libroId,
    this.modo = 'crear',
    this.nota,
  });
  @override
  State<AgregarNotaScreen> createState() => _AgregarNotaScreenState();
}

class _AgregarNotaScreenState extends State<AgregarNotaScreen> {
  final _paginaController = TextEditingController();
  final _contenidoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _guardando = false;

  Future<void> _guardarNota() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    final nota = NotaLectura(
      libroId: widget.libroId,
      pagina: int.parse(_paginaController.text),
      contenido: _contenidoController.text.trim(),
      fecha: DateTime.now(),
    );

    await NotaLecturaDataSource().insertarNota(nota);
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Agregar Nota")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _paginaController,
                decoration: const InputDecoration(labelText: 'Página'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty
                    ? 'Escribe un número de página'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contenidoController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Contenido'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Escribe algo' : null,
              ),
              const SizedBox(height: 30),
              _guardando
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text("Guardar Nota"),
                      onPressed: _guardarNota,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

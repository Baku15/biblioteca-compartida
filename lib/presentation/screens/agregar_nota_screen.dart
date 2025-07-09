import 'package:flutter/material.dart';
import 'package:flutter_libros/application/nota_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/locales/nota_lectura.dart';

class AgregarNotaScreen extends ConsumerStatefulWidget {
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
  ConsumerState<AgregarNotaScreen> createState() => _AgregarNotaScreenState();
}

class _AgregarNotaScreenState extends ConsumerState<AgregarNotaScreen> {
  final _paginaController = TextEditingController();
  final _contenidoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    if (widget.modo == 'editar' && widget.nota != null) {
      _paginaController.text = widget.nota!.pagina.toString();
      _contenidoController.text = widget.nota!.contenido;
    }
  }

  Future<void> _guardarNota() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    final nota = NotaLectura(
      id: widget.modo == 'editar' ? widget.nota!.id : 0,
      libroId: widget.libroId,
      pagina: int.parse(_paginaController.text),
      contenido: _contenidoController.text.trim(),
      fecha: DateTime.now(),
    );

    if (widget.modo == 'editar') {
      await ref.read(notaProvider.notifier).editarNota(nota);
    } else {
      await ref.read(notaProvider.notifier).agregarNota(nota);
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:
              Text(widget.modo == 'editar' ? "Editar Nota" : "Agregar Nota")),
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
                      label: Text(widget.modo == 'editar'
                          ? "Guardar Cambios"
                          : "Guardar Nota"),
                      onPressed: _guardarNota,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

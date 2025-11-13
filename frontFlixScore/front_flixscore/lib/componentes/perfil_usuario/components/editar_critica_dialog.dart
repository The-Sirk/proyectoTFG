import 'package:flutter/material.dart';
import 'package:flixscore/modelos/critica_modelo.dart';
import 'package:flixscore/service/api_service.dart';
import 'package:flixscore/componentes/common/snack_bar.dart';

const Color _cardBackgroundColor = Color(0xFF1A1C25);
const Color _dividerColor = Color(0xFF333333);

class EditarCriticaDialog extends StatefulWidget {
  final ModeloCritica critica;
  final VoidCallback onGuardar;

  const EditarCriticaDialog({
    super.key,
    required this.critica,
    required this.onGuardar,
  });

  @override
  State<EditarCriticaDialog> createState() => _EditarCriticaDialogState();
}

class _EditarCriticaDialogState extends State<EditarCriticaDialog> {
  late int nuevaPuntuacion;
  late String nuevoComentario;
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    nuevaPuntuacion = widget.critica.puntuacion;
    nuevoComentario = widget.critica.comentario;
  }

  Future<void> _guardarCambios(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await _apiService.editarCritica(
          widget.critica.documentID!,
          comentario: nuevoComentario,
          puntuacion: nuevaPuntuacion,
        );
        if (mounted) {
          mostrarSnackBarExito(context, "Se han guardado los cambios");
          widget.onGuardar(); // Refresca la lista
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          print("Error: $e");
          mostrarSnackBarError(context, "Error al guardar los cambios. Inténtalo de nuevo más tarde");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: _cardBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: screenWidth > 600 ? 600 : screenWidth * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: StatefulBuilder(
            builder: (context, setStateDialog) {
              int? hoverStar;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Editar crítica',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Puntuación',
                              style: TextStyle(color: Colors.white70, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 0.0,
                              runSpacing: 2.0,
                              children: List.generate(10, (index) {
                                final value = index + 1;
                                return GestureDetector(
                                  onTapDown: (_) =>
                                      setStateDialog(() => nuevaPuntuacion = value),
                                  child: Container(
                                    width: 26,
                                    height: 26,
                                    alignment: Alignment.center,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Icon(
                                          value <= (hoverStar ?? nuevaPuntuacion)
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: Colors.orange,
                                          size: 26,
                                        ),
                                        if (value == (hoverStar ?? nuevaPuntuacion))
                                          Text(
                                            '${hoverStar ?? nuevaPuntuacion}',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Inter',
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              initialValue: nuevoComentario,
                              maxLines: 7,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Escribe tu crítica...',
                                hintStyle: const TextStyle(color: Colors.white38),
                                filled: true,
                                fillColor: const Color(0xFF1F2937),
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: _dividerColor),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: _dividerColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Colors.cyanAccent, width: 1.5),
                                ),
                              ),
                              onSaved: (val) => nuevoComentario = val!,
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: Navigator.of(context).pop,
                        child: const Text('Cancelar',
                            style: TextStyle(color: Colors.white70)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyanAccent,
                          foregroundColor: Colors.black,
                        ),
                        icon: const Icon(Icons.save),
                        label: const Text('Guardar'),
                        onPressed: () => _guardarCambios(context),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
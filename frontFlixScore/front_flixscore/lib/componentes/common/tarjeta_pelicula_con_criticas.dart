import 'package:flixscore/modelos/critica_modelo.dart';
import 'package:flutter/material.dart';
import 'package:flixscore/modelos/pelicula_modelo.dart';
import 'package:provider/provider.dart';
import 'package:flixscore/controllers/criticas_provider.dart';
import 'package:flixscore/componentes/home/components/resumen_pelicula.dart';

class TarjetaPeliculaConCriticas extends StatefulWidget {
  final ModeloPelicula pelicula;
  final List<ModeloCritica> criticasAmigos;

  const TarjetaPeliculaConCriticas({
    super.key,
    required this.pelicula,
    this.criticasAmigos = const [],
  });

  @override
  State<TarjetaPeliculaConCriticas> createState() =>
      _TarjetaPeliculaConCriticasState();
}

class _TarjetaPeliculaConCriticasState
    extends State<TarjetaPeliculaConCriticas> {
  TextEditingController comentarioController = TextEditingController();
  String nuevaCritica = "";
  bool mostrarCritica = false;
  int puntuacion = 0;
  int hoverStar = 0;

  @override
  Widget build(BuildContext context) {
    final criticasProvider = Provider.of<CriticasProvider>(context);
    final criticasUsuarioList = criticasProvider.criticasUsuario
        .where((c) => c.peliculaID == widget.pelicula.id)
        .toList();
    final criticaUsuario = criticasUsuarioList.isNotEmpty
        ? criticasUsuarioList.first
        : null;

    // Usar las críticas de amigos recibidas por parámetro
    final criticasAmigos = widget.criticasAmigos;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 800),
      child: Card(
        color: const Color(0xFF1F2937),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: _tarjetaLayout(
                criticasAmigos,
                criticaUsuario,
                criticasProvider,
              ),
            ),
            // Botón de cierre en esquina superior derecha
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Cerrar',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaLayout(
    List<ModeloCritica> criticasAmigos,
    ModeloCritica? criticaUsuario,
    CriticasProvider criticasProvider,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final esMovil = constraints.maxWidth < 600;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Layout responsive
            if (esMovil)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 140,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey,
                    ),
                    child: Image.network(
                      widget.pelicula.rutaPoster ?? '',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ResumenPelicula(
                    titulo: widget.pelicula.titulo,
                    resumen: widget.pelicula.resumen,
                    fechaEstreno: widget.pelicula.fechaEstreno,
                  ),
                ],
              )
            else
              Row(
                children: [
                  Container(
                    width: 140,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey,
                    ),
                    child: Image.network(
                      widget.pelicula.rutaPoster ?? '',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ResumenPelicula(
                      titulo: widget.pelicula.titulo,
                      resumen: widget.pelicula.resumen,
                      fechaEstreno: widget.pelicula.fechaEstreno,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.orange, size: 14),
                const SizedBox(width: 4),
                Text(
                  "${_calcularMedia(criticasAmigos)}/10",
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (criticaUsuario == null)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: mostrarCritica
                              ? Colors.white
                              : Colors.black,
                          backgroundColor: mostrarCritica
                              ? Colors.redAccent
                              : Colors.blueAccent,
                        ),
                        onPressed: () {
                          setState(() {
                            mostrarCritica = !mostrarCritica;
                          });
                        },
                        child: mostrarCritica
                            ? const Text("Cancelar")
                            : const Text("Escribir Critica"),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (mostrarCritica && criticaUsuario == null)
              widgetCrearCritica(criticasProvider),
            const SizedBox(height: 8),
            ...criticasAmigos.map((critica) {
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF374151),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(
                        criticasProvider
                                .getUsuarioAmigo(critica.usuarioUID)
                                ?.imagenPerfil ??
                            "",
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${(critica.usuarioUID == criticasProvider.usuarioLogueado?.documentID) ? (criticasProvider.usuarioLogueado?.nick ?? "Tú") : (criticasProvider.getUsuarioAmigo(critica.usuarioUID)?.nick ?? "Usuario desconocido (${critica.usuarioUID})")}  •  ${critica.fechaCreacion != null ? "${DateTime.fromMillisecondsSinceEpoch(critica.fechaCreacion!).day}/${DateTime.fromMillisecondsSinceEpoch(critica.fechaCreacion!).month}/${DateTime.fromMillisecondsSinceEpoch(critica.fechaCreacion!).year}" : ""}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            critica.comentario,
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }

  double _calcularMedia(List<ModeloCritica> criticas) {
    if (criticas.isEmpty) return 0;
    final total = criticas.fold<double>(
      0,
      (sum, critica) => sum + (critica.puntuacion),
    );
    return double.parse((total / criticas.length).toStringAsFixed(1));
  }

  Widget widgetCrearCritica(CriticasProvider criticasProvider) {
    final usuarioUID = criticasProvider.usuarioLogueado?.documentID ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Tu crítica:",
          style: TextStyle(
            color: Colors.cyan,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF374151),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 0.0,
                runSpacing: 2.0,
                children: List.generate(10, (index) {
                  final value = index + 1;
                  return GestureDetector(
                    onTapDown: (_) => setState(() {
                      puntuacion = value;
                    }),
                    child: Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            value <= puntuacion
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.orange,
                            size: 26,
                          ),
                          if (value == puntuacion)
                            Text(
                              puntuacion.toString(),
                              style: const TextStyle(
                                color: Colors.white,
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
              const SizedBox(height: 15),
              TextField(
                controller: comentarioController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Escribe tu crítica aquí...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF1F2937),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await criticasProvider.crearCritica(
                      ModeloCritica(
                        usuarioUID: usuarioUID,
                        peliculaID: widget.pelicula.id,
                        puntuacion: puntuacion,
                        comentario: comentarioController.text,
                        fechaCreacion: DateTime.now().millisecondsSinceEpoch,
                      ),
                    );
                  } catch (e) {
                    // Manejar error
                  }
                  if (mounted) {
                    setState(() {
                      mostrarCritica = false;
                      comentarioController.clear();
                      puntuacion = 0;
                      Navigator.pop(context);
                    });
                  }
                },
                child: const Text("Enviar critica"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

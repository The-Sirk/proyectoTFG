import 'package:flixscore/modelos/critica_modelo.dart';
import 'package:flutter/material.dart';
import 'package:flixscore/modelos/pelicula_modelo.dart';
import 'package:provider/provider.dart';
import 'package:flixscore/controllers/criticas_provider.dart';

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
  bool _guardando = false;

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
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _tarjetaLayout(
                  criticasAmigos,
                  criticaUsuario,
                  criticasProvider,
                ),
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
    // Usar MediaQuery para detectar el ancho de la pantalla
    final screenWidth = MediaQuery.of(context).size.width;
    final esMovil = screenWidth < 800;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Layout responsive: Column para móvil, Row para web
        if (esMovil)
          // Layout móvil: póster arriba, contenido abajo
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Póster de la película
              Container(
                width: 200,
                height: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.pelicula.rutaPoster ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.movie,
                          size: 48,
                          color: Colors.white54,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _informacionPrincipal(),
            ],
          )
        else
          // Layout web: póster a la izquierda, info a la derecha
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Póster de la película
              Container(
                width: 200,
                height: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.pelicula.rutaPoster ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.movie,
                          size: 48,
                          color: Colors.white54,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(child: _informacionPrincipal()),
            ],
          ),

        // Puntuación y críticas
        const SizedBox(height: 20),
        _seccionPuntuacionYCriticas(
          criticasAmigos,
          criticaUsuario,
          criticasProvider,
        ),
      ],
    );
  }

  // Widget con título, fecha y resumen
  Widget _informacionPrincipal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título
        Text(
          widget.pelicula.titulo,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // Fecha de estreno
        Text(
          widget.pelicula.fechaEstreno,
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
        const SizedBox(height: 12),

        // Resumen
        Text(
          widget.pelicula.resumen,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }

  // Widget con puntuación, botón de crítica y lista de críticas
  Widget _seccionPuntuacionYCriticas(
    List<ModeloCritica> criticasAmigos,
    ModeloCritica? criticaUsuario,
    CriticasProvider criticasProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Puntuación media
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
          ],
        ),
        const SizedBox(height: 20),

        // Botón para escribir crítica (solo si no tiene crítica)
        if (criticaUsuario == null)
          ElevatedButton(
            key: Key('botonEscribirCritica'),
            style: ElevatedButton.styleFrom(
              foregroundColor: mostrarCritica ? Colors.white : Colors.black,
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
                : const Text("Escribir Crítica"),
          ),
        const SizedBox(height: 12),

        // Formulario para crear crítica
        if (mostrarCritica && criticaUsuario == null)
          widgetCrearCritica(criticasProvider),
        const SizedBox(height: 16),

        // Título de sección de críticas
        if (criticasAmigos.isNotEmpty)
          const Text(
            "Críticas",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        const SizedBox(height: 12),

        // Lista de críticas
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
                GestureDetector(
                  onTap: () {
                    // Cerrar el diálogo actual
                    Navigator.of(context).pop();

                    // Navegar al perfil del usuario
                    if (critica.usuarioUID ==
                        criticasProvider.usuarioLogueado?.documentID) {
                      // Es el usuario logueado, ir a su perfil
                      Navigator.pushNamed(context, '/perfil-usuario');
                    } else {
                      // Es otro usuario, ir al perfil de amigo
                      final usuario = criticasProvider.getUsuarioAmigo(
                        critica.usuarioUID,
                      );
                      if (usuario != null) {
                        Navigator.pushNamed(
                          context,
                          '/perfil-amigo',
                          arguments: {
                            'usuarioId': critica.usuarioUID,
                            'nickUsuario': usuario.nick,
                          },
                        );
                      }
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: () {
                      final usuario = criticasProvider.getUsuarioAmigo(critica.usuarioUID);
                      final imagenUrl = usuario?.imagenPerfil;
                      final nick = usuario?.nick ?? "U";
                      final tieneImagen = imagenUrl != null && imagenUrl.isNotEmpty;
                      
                      return CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey[800],
                        backgroundImage: tieneImagen ? NetworkImage(imagenUrl) : null,
                        child: !tieneImagen
                            ? Text(
                                nick.isNotEmpty ? nick[0].toUpperCase() : "U",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      );
                    }(),
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
                    key: ValueKey('estrella_$index'),
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
                key: Key('TextField_Critica'),
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
                key: const Key('buttonGuardarCritica'),
                onPressed: _guardando ? null : () => _guardarCritica(criticasProvider), 
                child: Text(_guardando ? "Enviando..." : "Enviar crítica"),
              )
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _guardarCritica(CriticasProvider criticasProvider) async {
    if (_guardando) {
        return; 
    }
    final usuarioUID = criticasProvider.usuarioLogueado?.documentID ?? '';
    setState(() {
        _guardando = true;
    });
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
        if (mounted) {
            setState(() {
                mostrarCritica = false;
                comentarioController.clear();
                puntuacion = 0;
            });
            Navigator.pop(context);
        }
    } catch (e) {
        print('Error al guardar crítica: $e');
    } finally {
        if (mounted && _guardando) {
             setState(() {
                _guardando = false;
            });
        }
    }
  }
}
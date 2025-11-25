import 'package:flixscore/controllers/login_provider.dart';
import 'package:flutter/material.dart';
import 'package:flixscore/modelos/critica_modelo.dart';
import 'package:flixscore/modelos/pelicula_modelo.dart';
import 'package:flixscore/service/api_service.dart';
import 'package:flixscore/componentes/perfil_usuario/components/editar_critica_dialog.dart';
import 'package:flixscore/componentes/perfil_usuario/components/tarjeta_critica_item.dart';
import 'package:provider/provider.dart';

class MisCriticasCard extends StatefulWidget {
  final String usuarioId;
  final bool editable;

  const MisCriticasCard({
    super.key,
    required this.usuarioId,
    required this.editable,
  });

  @override
  State<MisCriticasCard> createState() => _MisCriticasCardState();
}

class _MisCriticasCardState extends State<MisCriticasCard> {
  late Future<List<_CriticaConPelicula>> _criticasConPeliculasFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _criticasConPeliculasFuture = _cargarCriticasConPeliculas();
  }

  Future<List<_CriticaConPelicula>> _cargarCriticasConPeliculas() async {
    final criticas = await _apiService.getCriticasByUserId(widget.usuarioId);
    final List<_CriticaConPelicula> lista = [];

    for (final critica in criticas) {
      try {
        final pelicula = await _apiService.getMovieByID(critica.peliculaID.toString());
        lista.add(_CriticaConPelicula(critica: critica, pelicula: pelicula));
      } catch (e) {
        // Si falla, añadimos la crítica pero sin película
        lista.add(_CriticaConPelicula(critica: critica, pelicula: null));
      }
    }

    return lista;
  }

  void _mostrarPopupEdicion(BuildContext context, ModeloCritica critica) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => EditarCriticaDialog(
        critica: critica,
        onGuardar: () async {
          await Provider.of<LoginProvider>(context, listen: false)
              .recargarPuntuaciones();
          setState(() {
            _criticasConPeliculasFuture = _cargarCriticasConPeliculas();
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<_CriticaConPelicula>>(
      future: _criticasConPeliculasFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.cyanAccent));
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              widget.editable
                  ? "Todavía no has escrito ninguna crítica."
                  : "Todavía no ha escrito ninguna crítica.",
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          );
        }

        final items = snapshot.data!;
        final bool isMobile = MediaQuery.of(context).size.width < 700;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              isMobile
              ? Column(
                  children: [
                    const SizedBox(height: 10),
                    ...items.map((item) {
                      final c = item.critica;
                      final p = item.pelicula;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: TarjetaCritica(
                          critica: c,
                          pelicula: p,
                          onEditar: () => _mostrarPopupEdicion(context, c),
                          editable: widget.editable,
                        ),
                      );
                    }).toList(),
                  ],
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final maxHeight = constraints.maxHeight - 60;
                    double sombraSuperior = 0.0;
                    double sombraInferior = 0.85;
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: maxHeight.clamp(200, 725),
                          ),
                          child: NotificationListener<ScrollNotification>(
                            onNotification: (scrollInfo) {
                              final atStart = scrollInfo.metrics.pixels <= 2;
                              final atEnd = scrollInfo.metrics.pixels >=
                                  scrollInfo.metrics.maxScrollExtent - 2;
                              final sombreadoSuperior = atStart ? 0.0 : 1.0;
                              final sombreadoInferior = atEnd ? 0.0 : 1.0;
                              if (sombreadoSuperior != sombraSuperior ||
                                  sombreadoInferior != sombraInferior) {
                                setState(() {
                                  sombraSuperior = sombreadoSuperior;
                                  sombraInferior = sombreadoInferior;
                                });
                              }
                              return false;
                            },
                            child: ShaderMask(
                              shaderCallback: (Rect rect) {
                                return LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(sombraSuperior),
                                    Colors.transparent,
                                    Colors.transparent,
                                    Colors.black.withOpacity(sombraInferior),
                                  ],
                                  stops: const [0.0, 0.05, 0.95, 1.0],
                                ).createShader(rect);
                              },
                              blendMode: BlendMode.dstOut,
                              child: ClipRRect(
                                borderRadius:
                                    const BorderRadius.vertical(bottom: Radius.circular(12)),
                                child: ScrollConfiguration(
                                  behavior: ScrollConfiguration.of(context).copyWith(
                                    physics: const BouncingScrollPhysics(),
                                  ),
                                  child: ListView.separated(
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.only(bottom: 5.0),
                                    itemCount: items.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 5),
                                    itemBuilder: (context, index) {
                                      final c = items[index].critica;
                                      final p = items[index].pelicula;
                                      return TarjetaCritica(
                                        critica: c,
                                        pelicula: p,
                                        onEditar: () => _mostrarPopupEdicion(context, c),
                                        editable: widget.editable,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class _CriticaConPelicula {
  final ModeloCritica critica;
  final ModeloPelicula? pelicula;

  _CriticaConPelicula({required this.critica, this.pelicula});
}
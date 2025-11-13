import 'package:flutter/material.dart';
import 'package:flixscore/modelos/critica_modelo.dart';
import 'package:flixscore/modelos/pelicula_modelo.dart';
import 'package:flixscore/service/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flixscore/componentes/perfil_usuario/components/editar_critica_dialog.dart';
import 'package:flixscore/componentes/perfil_usuario/components/tarjeta_critica_item.dart';

class MisCriticasCard extends StatefulWidget {
  final String usuarioId;

  const MisCriticasCard({super.key, required this.usuarioId});

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
        final uri = Uri.parse(
                'https://backend-proyectotfg-600260085391.europe-southwest1.run.app/tmdb/v1/peliculasPorId')
            .replace(queryParameters: {'id': critica.peliculaID.toString()});

        final response = await http.get(uri);

        if (response.statusCode == 200) {
          final List<dynamic> jsonList = json.decode(response.body);
          if (jsonList.isNotEmpty) {
            final pelicula = ModeloPelicula.fromJson(jsonList.first);
            lista.add(_CriticaConPelicula(critica: critica, pelicula: pelicula));
          } else {
            lista.add(_CriticaConPelicula(critica: critica, pelicula: null));
          }
        } else {
          lista.add(_CriticaConPelicula(critica: critica, pelicula: null));
        }
      } catch (e) {
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
        onGuardar: () {
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
          return const Center(
            child: Text(
              "No has escrito ninguna crítica todavía.",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          );
        }

        final items = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Tus críticas",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              // Listado con altura fija y sombras degradadas
              LayoutBuilder(
                builder: (context, constraints) {
                  final maxHeight = constraints.maxHeight - 60;
                  double sombraSuperior = 0.0;
                  double sombraInferior = 0.85; 
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: maxHeight.clamp(200, 694),
                        ),
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (scrollInfo) {
                            final atStart = scrollInfo.metrics.pixels <= 2;
                            final atEnd = scrollInfo.metrics.pixels >=
                                scrollInfo.metrics.maxScrollExtent - 2;
                            final sombreadoSuperior = atStart ? 0.0 : 1.0;
                            final sombreadoInferior = atEnd ? 0.0 : 1.0;
                            if (sombreadoSuperior != sombraSuperior || sombreadoInferior != sombraInferior) {
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
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                              child: ScrollConfiguration(
                                behavior: ScrollConfiguration.of(context).copyWith(
                                  physics: const BouncingScrollPhysics(),
                                ),
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  itemCount: items.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 5),
                                  itemBuilder: (context, index) {
                                    final c = items[index].critica;
                                    final p = items[index].pelicula;
                                    return TarjetaCritica(
                                      critica: c,
                                      pelicula: p,
                                      onEditar: () => _mostrarPopupEdicion(context, c),
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
              )
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
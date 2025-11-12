import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flixscore/modelos/critica_modelo.dart';
import 'package:flixscore/modelos/pelicula_modelo.dart';
import 'package:flixscore/service/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MisCriticasCard extends StatefulWidget {
  final String usuarioId;

  const MisCriticasCard({super.key, required this.usuarioId});

  @override
  State<MisCriticasCard> createState() => _MisCriticasCardState();
}

const Color cardBackgroundColor = Color(0xFF1A1C25);
const Color dividerColor = Color(0xFF333333);

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

  String _formatearFecha(int? timestamp) {
    if (timestamp == null) return 'Fecha no disponible';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<_CriticaConPelicula>>(
      future: _criticasConPeliculasFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
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
              // Listado con altura dinámica y scroll propio
              LayoutBuilder(
                builder: (context, constraints) {
                  final maxHeight = constraints.maxHeight - 60;
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: maxHeight.clamp(200, 694),
                    ),
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(
                        physics: const BouncingScrollPhysics(),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final c = items[index].critica;
                          final p = items[index].pelicula;

                          final posterUrl = (p?.rutaPoster ?? '').trim();

                          return Container(
                            decoration: BoxDecoration(
                              color: cardBackgroundColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: posterUrl.isNotEmpty
                                        ? posterUrl
                                        : 'https://dummyimage.com/100x150/333333/ffffff.png&text=Sin+Cartel',
                                    width: 138,
                                    height: 207,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(
                                      color: Colors.grey.shade800,
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2, color: Colors.cyanAccent),
                                      ),
                                    ),
                                    errorWidget: (_, __, ___) => Container(
                                      color: Colors.grey.shade800,
                                      child: const Center(
                                        child: Icon(Icons.broken_image,
                                            color: Colors.white54),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p?.titulo ?? 'Película desconocida',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        p?.fechaEstreno ?? 'Fecha no disponible',
                                        style: const TextStyle(color: Colors.white70),
                                      ),
                                      const SizedBox(height: 8),
                                      // Recuadro fijo
                                      SizedBox(
                                        height: 130,
                                        width: double.infinity,
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1F2937),
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                                color: dividerColor, width: 1),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(Icons.star,
                                                      color: Colors.cyanAccent,
                                                      size: 14),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    "${c.puntuacion}/10",
                                                    style: const TextStyle(
                                                      color: Colors.cyanAccent,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    _formatearFecha(c.fechaCreacion),
                                                    style: const TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const Divider(
                                                  height: 10, color: Colors.white24),
                                              Expanded(
                                                child: SingleChildScrollView(
                                                  physics:
                                                      const BouncingScrollPhysics(),
                                                  child: Text(
                                                    c.comentario,
                                                    style: const TextStyle(
                                                        color: Colors.white70),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
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
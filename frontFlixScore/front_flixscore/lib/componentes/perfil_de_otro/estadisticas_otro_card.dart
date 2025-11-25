import 'package:flutter/material.dart';
import 'package:flixscore/service/api_service.dart';

class EstadisticasAmigoCard extends StatefulWidget {
  final String idAmigo;

  const EstadisticasAmigoCard({super.key, required this.idAmigo});

  @override
  State<EstadisticasAmigoCard> createState() => _EstadisticasAmigoCardState();
}

class _EstadisticasAmigoCardState extends State<EstadisticasAmigoCard> {
  late Future<_Stats> _statsFuture;
  final ApiService _api = ApiService();

  @override
  void initState() {
    super.initState();
    _statsFuture = _cargarStats();
  }

  Future<_Stats> _cargarStats() async {
    final criticas = await _api.getCriticasByUserId(widget.idAmigo);
    final puntuaciones = criticas.map((c) => c.puntuacion).toList();
    final media = puntuaciones.isEmpty
        ? 0.0
        : puntuaciones.reduce((a, b) => a + b) / puntuaciones.length;
    return _Stats(
      peliculasValoradas: puntuaciones.length,
      puntuacionMedia: media,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_Stats>(
      future: _statsFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return _esqueletoCard(child: const CircularProgressIndicator(color: Colors.cyanAccent));
        }
        if (snap.hasError) {
          return _esqueletoCard(child: Text('Error al cargar stats', style: _textStyle(14, color: Colors.red)));
        }

        final s = snap.data!;
        return _esqueletoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Estadísticas', style: _textStyle(16, weight: FontWeight.bold)),
              const SizedBox(height: 20),
              _fila(Icons.movie_outlined, Colors.cyanAccent, 'Películas valoradas', s.peliculasValoradas.toString()),
              const Divider(height: 20, color: Color(0xFF333333)),
              _fila(Icons.star_border, Colors.orange.shade400, 'Puntuación media', '${s.puntuacionMedia.toStringAsFixed(1)} /10'),
            ],
          ),
        );
      },
    );
  }

  Widget _esqueletoCard({required Widget child}) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1C25),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(.2), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: child,
      );

  Widget _fila(IconData icono, Color colorIcono, String etiqueta, String valor) => Row(
        children: [
          Icon(icono, color: colorIcono, size: 24),
          const SizedBox(width: 16),
          Expanded(child: Text(etiqueta, style: _textStyle(16))),
          Text(valor, style: _textStyle(16)),
        ],
      );

  TextStyle _textStyle(double size, {FontWeight? weight, Color? color}) =>
      TextStyle(color: color ?? Colors.white, fontSize: size, fontWeight: weight);
}

class _Stats {
  final int peliculasValoradas;
  final double puntuacionMedia;

  _Stats({required this.peliculasValoradas, required this.puntuacionMedia});
}
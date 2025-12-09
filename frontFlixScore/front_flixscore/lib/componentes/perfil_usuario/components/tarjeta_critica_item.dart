import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:flixscore/controllers/criticas_provider.dart';
import 'package:flixscore/componentes/common/tarjeta_pelicula_con_criticas.dart';
import 'package:flixscore/modelos/critica_modelo.dart';
import 'package:flixscore/modelos/pelicula_modelo.dart';

const Color _cardBackgroundColor = Color(0xFF1A1C25);
const Color _dividerColor = Color(0xFF333333);
const Color _subtitleColor = Color(0xFF9CA3AF);

class TarjetaCritica extends StatelessWidget {
  final ModeloCritica critica;
  final ModeloPelicula? pelicula;
  final VoidCallback onEditar;
  final bool editable;

  const TarjetaCritica({
    super.key,
    required this.critica,
    required this.pelicula,
    required this.onEditar,
    required this.editable,
  });

  String _formatearFecha(int? timestamp) {
    if (timestamp == null) return 'Fecha no disponible';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  Widget _buildPoster(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double mobileBreakpoint = 600.0; 
    final double posterWidth;
    final double posterHeight;
    if (screenWidth < mobileBreakpoint) {
        posterWidth = screenWidth * 0.3; 
        posterHeight = posterWidth * (260 / 160); 
    } else {
        posterWidth = 160.0;
        posterHeight = 260.0;
    }

    final posterUrl = (pelicula?.rutaPoster ?? '').trim();
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: posterUrl.isNotEmpty
            ? posterUrl
            : 'https://dummyimage.com/100x150/333333/ffffff.png&text=Sin+Cartel',
        width: posterWidth,
        height: posterHeight,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          color: Colors.grey.shade800,
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.cyanAccent,
            ),
          ),
        ),
        errorWidget: (_, __, ___) => Container(
          color: Colors.grey.shade800,
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.white54),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoHeader(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          pelicula?.titulo ?? 'Película desconocida',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          pelicula?.fechaEstreno ?? 'Fecha no disponible',
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 4),
        _buildResumenPelicula(context, pelicula!.resumen),
      ],
    );
  }

  Widget _buildCriticaBox() {
    return SizedBox(
      height: 170,
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.only(bottom: 8, left: 10, right: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _dividerColor, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star, color: Colors.orange, size: 14),
                const SizedBox(width: 4),
                Text(
                  "${critica.puntuacion}/10",
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _formatearFecha(critica.fechaCreacion),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const Spacer(),
                editable
                    ? IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: _subtitleColor,
                          size: 18,
                        ),
                        onPressed: onEditar,
                        key: const Key('botonEditarCritica'),
                      )
                    : const SizedBox(height: 40),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Text(
                  critica.comentario,
                  style: const TextStyle(color: Colors.white70, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: editable
          ? null
          : () {
              final pelicula = this.pelicula;
              if (pelicula == null) return;

              final criticasProvider =
                  Provider.of<CriticasProvider>(context, listen: false);
              final criticasAmigos =
                  criticasProvider.getCriticasAmigosPorPelicula(pelicula.id);
              final miCritica = criticasProvider.criticasUsuario
                  .where((c) => c.peliculaID == pelicula.id)
                  .firstOrNull;

              showDialog(
                context: context,
                builder: (_) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TarjetaPeliculaConCriticas(
                    pelicula: pelicula,
                    criticasAmigos: criticasAmigos,
                  ),
                ),
              );
            },
      child: Container(
        decoration: BoxDecoration(
          color: _cardBackgroundColor,
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 600;
            return isSmall
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPoster(context),
                          const SizedBox(width: 12),
                          Expanded(child: _buildInfoHeader(context)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildCriticaBox(),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPoster(context),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoHeader(context),
                            const SizedBox(height: 8),
                            _buildCriticaBox(),
                          ],
                        ),
                      ),
                    ],
                  );
          },
        ),
      ),
    );
  }

  Widget _buildResumenPelicula(BuildContext context, String resumen) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double mobileBreakpoint = 600.0;
    final int maxLinesLimit = screenWidth < mobileBreakpoint ? 6 : 12;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: Text(
        resumen,
        maxLines: maxLinesLimit,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
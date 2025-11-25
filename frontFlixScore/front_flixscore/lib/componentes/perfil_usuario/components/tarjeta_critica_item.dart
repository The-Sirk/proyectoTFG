import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

  Widget _buildPoster() {
    final posterUrl = (pelicula?.rutaPoster ?? '').trim();
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: posterUrl.isNotEmpty
            ? posterUrl
            : 'https://dummyimage.com/100x150/333333/ffffff.png&text=Sin+Cartel',
        width: 123,
        height: 185,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          color: Colors.grey.shade800,
          child: const Center(
            child:
                CircularProgressIndicator(strokeWidth: 2, color: Colors.cyanAccent),
          ),
        ),
        errorWidget: (_, __, ___) => Container(
          color: Colors.grey.shade800,
          child: const Center(child: Icon(Icons.broken_image, color: Colors.white54)),
        ),
      ),
    );
  }

  Widget _buildInfoHeader() {
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
      ],
    );
  }

  Widget _buildCriticaBox() {
    return SizedBox(
      height: 130,
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
                        icon: const Icon(Icons.edit,
                            color: _subtitleColor, size: 18),
                        onPressed: onEditar,
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
    return Container(
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
              // ---------- MÓVIL ----------
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPoster(),
                        const SizedBox(width: 12),
                        Expanded(child: _buildInfoHeader()),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildCriticaBox(),
                  ],
                )
              // ---------- PC ----------
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPoster(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoHeader(),
                          const SizedBox(height: 8),
                          _buildCriticaBox(),
                        ],
                      ),
                    ),
                  ],
                );
        },
      )
    );
  }
}
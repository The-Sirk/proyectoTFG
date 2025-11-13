import 'package:flutter/material.dart';

class EstadisticasCard extends StatelessWidget {
  final int? peliculasValoradas;
  final int? numeroAmigos;
  final double? puntuacionMedia;

  const EstadisticasCard({
    super.key,
    this.peliculasValoradas,
    this.numeroAmigos,
    this.puntuacionMedia,
  });

  // Colores
  static const Color cardBackgroundColor = Color(0xFF1A1C25); 
  static const Color primaryTextColor = Colors.white;
  static const Color secondaryTextColor = Color(0xFFAAAAAA); 
  static const Color dividerColor = Color(0xFF333333);
  static const Color borderColor = Colors.cyan;
  static const Color highlightColor = Colors.cyanAccent;


  @override
  Widget build(BuildContext context) {
    final int safePeliculasValoradas = peliculasValoradas ?? 0;
    final int safeNumeroAmigos = numeroAmigos ?? 0;
    final double safePuntuacionMedia = puntuacionMedia ?? 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          const Text(
            "Estadísticas",
            style: TextStyle(
              color: primaryTextColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          _buildMetricRow(
            icon: Icons.people_alt_outlined,
            iconColor: Colors.blue.shade400,
            label: "Amigos",
            value: safeNumeroAmigos.toString(),
          ),

          const SizedBox(height: 10),

          const Divider(height: 20, color: dividerColor),

          const SizedBox(height: 10),

          // Renderiza la lista de métricas
          _buildMetricRow(
            icon: Icons.movie_outlined,
            iconColor: highlightColor,
            label: "Películas valoradas",
            value: safePeliculasValoradas.toString(),
          ),

          const SizedBox(height: 10),

          const Divider(height: 20, color: dividerColor),

          const SizedBox(height: 10),

          _buildMetricRow(
            icon: Icons.star_border,
            iconColor: Colors.orange.shade400,
            label: "Puntuación media",
            // Formatea la puntuación para mostrar 1 decimal y añade el sufijo /10
            value: "${safePuntuacionMedia.toStringAsFixed(1)} /10",
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // Widget auxiliar para construir cada fila de estadística
  Widget _buildMetricRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        // Icono de la fila
        Icon(
          icon,
          color: iconColor,
          size: 24,
        ),
        const SizedBox(width: 16),
        
        // Etiqueta de la fila
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: primaryTextColor,
              fontSize: 16,
            ),
          ),
        ),
        
        // Valor de la fila
        Text(
          value,
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 16,
            fontWeight: (label == "Puntuación media") ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
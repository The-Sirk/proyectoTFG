
import 'package:flixscore/componentes/home/components/resumen_pelicula.dart';
import 'package:flutter/material.dart';

class PeliculaCard extends StatelessWidget {
  const PeliculaCard({super.key});


  @override
  Widget build(BuildContext context) {
    
    return LayoutBuilder(
      builder: (context, constraints) {
        
        return IntrinsicHeight(
          child: Card(
            color: const Color(0xFF1F2937),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _gridLayout()
            ),
          ),
        );
      },
    );
  }

  // Layout para grid (desktop/tablet)
  Widget _gridLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Imagen y puntuación
        AspectRatio(
          aspectRatio: 2.0,
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFEC4899), Color(0xFFEF4444)],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.movie,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        ResumenPelicula(),
        const SizedBox(height: 12),
        const SizedBox(height: 16),
        
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF374151),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Carlos Ruiz:",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '"Una obra maestra del cine moderno. La narrativa compleja y los efectos visuales..."',
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
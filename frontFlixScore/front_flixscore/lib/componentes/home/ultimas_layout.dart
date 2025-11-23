
import 'package:flixscore/controllers/criticas_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UltimasLayout extends StatelessWidget {
  const UltimasLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CriticasProvider>(context);
    final peliculas = provider.peliculasCardUltimas;
    final error = provider.errorMessage;
    final cargando = provider.cargando;

    if (cargando) {
      return const Center(child: CircularProgressIndicator(color: Colors.cyan));
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Error al cargar las ultimas peliculas criticadas',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (peliculas.isEmpty) {
      return const Center(
        child: Text(
          "No hay películas populares disponibles",
          style: TextStyle(color: Colors.white54, fontSize: 16),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        bool esMovil = constraints.maxWidth < 600;
        if (esMovil) {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            itemCount: peliculas.length,
            itemBuilder: (context, index) {
              final pelicula = peliculas[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: pelicula,
              );
            },
          );
        } else {
          int columnas = constraints.maxWidth > 1000 ? 3 : 2;
          double anchoCard =
              (constraints.maxWidth - 60 - (20 * (columnas - 1))) / columnas;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              children: peliculas.map((pelicula) {
                return SizedBox(
                  width: anchoCard,
                  child: pelicula,
                );
              }).toList(),
            ),
          );
        }
      },
    );
  }
}
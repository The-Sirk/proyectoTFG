import 'package:flixscore/componentes/common/tarjeta_pelicula_con_criticas.dart';
import 'package:flixscore/componentes/home/components/resumen_pelicula.dart';
import 'package:flixscore/modelos/critica_modelo.dart';
import 'package:flixscore/modelos/pelicula_modelo.dart';
import 'package:flixscore/modelos/usuario_modelo.dart';
import 'package:flutter/material.dart';

class PeliculaCard extends StatelessWidget {
  final ModeloPelicula pelicula;
  final ModeloCritica? critica;
  final ModeloUsuario? usuario;
  final List<ModeloCritica>? criticasAmigos;
  final bool mostrarEtiquetaAmigo;

  const PeliculaCard({
    super.key,
    required this.pelicula,
    this.critica,
    this.usuario,
    this.criticasAmigos,
    this.mostrarEtiquetaAmigo = true,
  });

  @override
  Widget build(BuildContext context) {
    // Combina critica de usuario logueado y las de amigos
    final List<ModeloCritica> todasCriticas = [
      if (critica != null) critica!,
      ...(criticasAmigos ?? []),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return InkWell(
          key: Key('card_pelicula'),
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SingleChildScrollView(
                  child: TarjetaPeliculaConCriticas(
                    pelicula: pelicula,
                    criticasAmigos: todasCriticas, // pasa la lista combinada
                  ),
                ),
              ),
            );
          },
          child: Card(
            color: const Color(0xFF1F2937),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _tarjetaLayout(todasCriticas),
            ),
          ),
        );
      },
    );
  }

  Widget _tarjetaLayout(List<ModeloCritica> todasCriticas) {
    double? mediaTotal;
    if (todasCriticas.isNotEmpty) {
      final total = todasCriticas.fold<double>(
        0,
        (sum, c) => sum + c.puntuacion,
      );
      mediaTotal = double.parse(
        (total / todasCriticas.length).toStringAsFixed(1),
      );
    }

    return Builder(
      builder: (context) {
        // Usar MediaQuery para obtener el ancho de la pantalla, no el ancho de la tarjeta
        final screenWidth = MediaQuery.of(context).size.width;
        final esMovil = screenWidth < 800;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Layout responsive: Column para móvil, Row para web
            if (esMovil)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 140,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey,
                    ),
                    child: Image.network(
                      pelicula.rutaPoster ?? '',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ResumenPelicula(
                    titulo: pelicula.titulo,
                    resumen: pelicula.resumen.length > 150
                        ? '${pelicula.resumen.substring(0, 150)}...'
                        : pelicula.resumen,
                    fechaEstreno: pelicula.fechaEstreno,
                  ),
                ],
              )
            else
              Row(
                children: [
                  Container(
                    width: 140,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey,
                    ),
                    child: Image.network(
                      pelicula.rutaPoster ?? '',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ResumenPelicula(
                      titulo: pelicula.titulo,
                      resumen: pelicula.resumen.length > 150
                          ? '${pelicula.resumen.substring(0, 150)}...'
                          : pelicula.resumen,
                      fechaEstreno: pelicula.fechaEstreno,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.orange, size: 14),
                const SizedBox(width: 4),
                Text(
                  mediaTotal != null ? "$mediaTotal/10" : "Sin puntuación",
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (mostrarEtiquetaAmigo)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  "Criticada por amigos",
                  style: const TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

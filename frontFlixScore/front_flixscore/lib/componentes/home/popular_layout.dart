import 'package:flixscore/componentes/home/card_pelicula.dart';
import 'package:flixscore/modelos/pelicula_model.dart';
import 'package:flixscore/servicios/tmdb_service.dart';
import 'package:flutter/material.dart';

class PopularLayout extends StatefulWidget {
  const PopularLayout({super.key});

  @override
  State<PopularLayout> createState() => _PopularLayoutState();
}

class _PopularLayoutState extends State<PopularLayout> {
  // Instanciamos PeliculasService
  final PeliculaService _service = PeliculaService();

  // Variables de uso local
  List<Pelicula> _peliculas = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarPeliculasPopulares();
  }

  Future<void> _cargarPeliculasPopulares() async {
    try {
      setState(() {
        _cargando = true;
        _error = null;
      });

      final peliculas = await _service.buscarPeliculas("malditos");

      setState(() {
        _peliculas = peliculas;
        _cargando = false;
      });
    } catch (e) {
      print("Error al cargar películas populares: ${e.toString()}");
      setState(() {
        _error = e.toString();
        print(e.toString());
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildContent();
  }

  Widget _buildContent() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator(color: Colors.cyan));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Error al cargar películas populares',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cargarPeliculasPopulares,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_peliculas.isEmpty) {
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
          return _mostrarListView();
        } else {
          return _mostrarGridView(constraints);
        }
      },
    );
  }

  Widget _mostrarListView() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      itemCount: _peliculas.length,
      itemBuilder: (context, index) {
        final pelicula = _peliculas[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: PeliculaCard(pelicula: pelicula),
        );
      },
    );
  }

  Widget _mostrarGridView(BoxConstraints constraints) {
    int columnas = constraints.maxWidth > 1000 ? 3 : 2;
    double anchoCard =
        (constraints.maxWidth - 60 - (20 * (columnas - 1))) / columnas;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        children: _peliculas.map((pelicula) {
          return SizedBox(
            width: anchoCard,
            child: PeliculaCard(pelicula: pelicula),
          );
        }).toList(),
      ),
    );
  }
}

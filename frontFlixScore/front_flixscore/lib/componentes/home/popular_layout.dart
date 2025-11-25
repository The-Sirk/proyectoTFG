
import 'package:flixscore/componentes/home/card_pelicula.dart';
import 'package:flixscore/controllers/criticas_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PopularLayout extends StatefulWidget {
  const PopularLayout({super.key});

  @override
  State<PopularLayout> createState() => _PopularLayoutState();
}

class _PopularLayoutState extends State<PopularLayout> {
  // Variables de uso local
  
  bool _cargando = true;
  String? _error;
  List<PeliculaCard> _peliculas = [];

  @override
  void initState() {
    super.initState();
    _cargarPeliculas();
  }

  Future<void> _cargarPeliculas() async {
    try {
      setState(() {
        _cargando = true;
        _error = null;
      });
      _peliculas = [];
      final provider = Provider.of<CriticasProvider>(context, listen: false);

      _peliculas = provider.peliculasCardAmigos;
      setState(() {
        _peliculas = _peliculas;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
              'Error al cargar películas de tus amigos',
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
              onPressed: () {},
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_peliculas.isEmpty) {
      return const Center(
        child: Text(
          "No hay peliculas de vistas por tus amigos, o no tienes amigos. Vete al bar a buscarlos",
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
          child: pelicula,
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
          return SizedBox(width: anchoCard, child: pelicula);
        }).toList(),
      ),
    );
  }
}

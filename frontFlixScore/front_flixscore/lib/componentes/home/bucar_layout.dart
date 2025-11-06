import 'package:flixscore/componentes/home/card_pelicula.dart'; // ✅ Agregar import
import 'package:flixscore/modelos/pelicula_model.dart';
import 'package:flixscore/servicios/tmdb_service.dart';
import 'package:flutter/material.dart';

class BuscarLayout extends StatefulWidget {
  const BuscarLayout({super.key});

  @override
  State<BuscarLayout> createState() => _BuscarLayoutState();
}

class _BuscarLayoutState extends State<BuscarLayout> {
  // Instanciamos PeliculasService y el TextEditingController
  final PeliculaService _service = PeliculaService();
  final TextEditingController _buscarController = TextEditingController();

  // Variables de uso local
  List<Pelicula> _peliculas = [];
  bool _cargando = false;
  String? _error;
  bool _hasBuscado = false;

  // Metodo para limpiar recursos
  @override
  void dispose() {
    _buscarController.dispose();
    super.dispose();
  }

  Future<void> _buscarPeliculas(String query) async {
    if (query.trim().isEmpty) return;

    try {
      setState(() {
        _cargando = true;
        _error = null;
        _hasBuscado = true;
      });
      
      final peliculas = await _service.buscarPeliculas(query);
      
      setState(() {
        _peliculas = peliculas;
        _cargando = false;
      });
    } catch (e) {
      print("Error al buscar películas: ${e.toString()}");
      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Barra de búsqueda
          TextField(
            controller: _buscarController,
            decoration: InputDecoration(
              hintText: "Buscar películas...",
              hintStyle: const TextStyle(color: Colors.white54),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              suffixIcon: _buscarController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white54),
                      onPressed: () {
                        _buscarController.clear();
                        setState(() {
                          _peliculas.clear();
                          _hasBuscado = false;
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFF1F2937),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(color: Colors.white),
            onSubmitted: _buscarPeliculas,
            onChanged: (value) => setState(() {}),
          ),
          const SizedBox(height: 20),
          
          Expanded(
            child: mostrarContenido(),
          ),
        ],
      ),
    );
  }

  Widget mostrarContenido() {
    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.cyan),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Error al buscar películas',
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
              onPressed: () => _buscarPeliculas(_buscarController.text),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (!_hasBuscado) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, color: Colors.white54, size: 64),
            SizedBox(height: 16),
            Text(
              "Escribe para buscar películas",
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_peliculas.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.movie_outlined, color: Colors.white54, size: 64),
            SizedBox(height: 16),
            Text(
              "No se encontraron películas",
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
          ],
        ),
      );
    }

    // Verificamos si la pantalla es grande o movil
    return LayoutBuilder(
      builder: (context, constraints) {
        bool esMovil = constraints.maxWidth < 600;

        if (esMovil) {
          return _mostrarMovil();
        } else {
          return _mostrarPantallaGrande(constraints);
        }
      },
    );
  }

  // 
  Widget _mostrarMovil() {
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

  Widget _mostrarPantallaGrande(BoxConstraints constraints) {
    // Ajustamos la cantidad y ancho de las columnas.
    int columnas = constraints.maxWidth > 1000 ? 3 : 2;
    double anchoCard = (constraints.maxWidth - 60 - (20 * (columnas - 1))) / columnas;

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
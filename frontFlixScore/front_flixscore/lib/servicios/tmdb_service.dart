import 'dart:convert';

import 'package:flixscore/modelos/pelicula_model.dart';
import 'package:http/http.dart' as http;

class PeliculaService {

  static const String _baseUrl = "https://backend-proyectotfg-600260085391.europe-southwest1.run.app/tmdb/v1/peliculasPorNombre";

    Future<List<Pelicula>> buscarPeliculas(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?nombre=${Uri.encodeComponent(query)}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Pelicula.fromJson(json)).toList();
      } else {
        throw Exception('Error al buscar películas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

}
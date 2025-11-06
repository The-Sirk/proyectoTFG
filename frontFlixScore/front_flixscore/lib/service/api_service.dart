import 'dart:convert';
import 'package:http/http.dart' as http;
import '../modelos/pelicula_modelo.dart'; 
import '../modelos/usuario_modelo.dart'; 
import '../modelos/critica_modelo.dart';
import '../modelos/pelicula_media_modelo.dart'; 

class ApiService {
  
  // URL de nuestro Backend
  static const String _baseUrl = 
      'https://backend-proyectotfg-600260085391.europe-southwest1.run.app';

  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

// -----------------------------------------------------------------------
// Endpoints de Búsqueda de Películas (BuscaPeliculaController)
// -----------------------------------------------------------------------

  // GET /tmdb/v1/peliculasPorNombre?nombre={nombre}
  // Devuelve Mono<List<MovieSalida>>.
  Future<List<ModeloPelicula>> getMoviesByName(String nombre) async {
    final uri = Uri.parse('$_baseUrl/tmdb/v1/peliculasPorNombre').replace(
      queryParameters: {'nombre': nombre},
    );
    
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      // Esperamos una lista, incluso si la búsqueda es por ID
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => ModeloPelicula.fromJson(json)).toList();
    } else {
      throw Exception('Fallo al buscar películas por nombre (${response.statusCode}): ${response.body}');
    }
  }

  // GET /tmdb/v1/peliculasPorId?id={id}
  Future<ModeloPelicula> getMovieByID(String id) async {
    final uri = Uri.parse('$_baseUrl/tmdb/v1/peliculasPorId').replace(
      queryParameters: {'id': id},
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      // El Controller devuelve List, tomamos el primer elemento si existe
      final List<dynamic> jsonList = json.decode(response.body);
      if (jsonList.isEmpty) {
        throw Exception('Película con ID $id no encontrada.');
      }
      return ModeloPelicula.fromJson(jsonList.first);
    } else {
      throw Exception('Fallo al buscar película por ID (${response.statusCode}): ${response.body}');
    }
  }

// -----------------------------------------------------------------------
// Endpoints de Críticas (CriticaController)
// -----------------------------------------------------------------------

  // GET /api/v1/criticas (Todas)
  Future<List<ModeloCritica>> getAllCriticas() async {
    final response = await http.get(Uri.parse('$_baseUrl/api/v1/criticas'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => ModeloCritica.fromJson(json)).toList();
    } else {
      throw Exception('Fallo al obtener todas las críticas (${response.statusCode}): ${response.body}');
    }
  }
  
  // POST /api/v1/criticas (Añadir)
  Future<ModeloCritica> addCritica(ModeloCritica critica) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/v1/criticas'),
      headers: _headers,
      body: json.encode(critica.toMap()), 
    );

    // El Controller devuelve 200/201
    if (response.statusCode == 200 || response.statusCode == 201) {
      return ModeloCritica.fromJson(json.decode(response.body));
    } else {
      throw Exception('Fallo al añadir crítica (${response.statusCode}): ${response.body}');
    }
  }

  // GET /api/v1/criticas?id={id} (Buscar por ID de Crítica)
  Future<ModeloCritica> getCriticaById(String id) async {
    final uri = Uri.parse('$_baseUrl/api/v1/criticas/').replace(
      queryParameters: {'id': id},
    );

    final response = await http.get(uri); 

    if (response.statusCode == 200) {
      return ModeloCritica.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Crítica con ID $id no encontrada.');
    } else {
      throw Exception('Fallo al obtener crítica por ID (${response.statusCode}): ${response.body}');
    }
  }

  // GET /api/v1/criticas?userId={userId} (Buscar por ID de Usuario)
  Future<List<ModeloCritica>> getCriticasByUserId(String userId) async {
    final uri = Uri.parse('$_baseUrl/api/v1/criticas/').replace(
      queryParameters: {'userId': userId},
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => ModeloCritica.fromJson(json)).toList();
    } else {
      throw Exception('Fallo al obtener críticas del usuario (${response.statusCode}): ${response.body}');
    }
  }

  // GET /api/v1/criticas?peliculaId={peliculaId} (Buscar por ID de Película)
  Future<List<ModeloCritica>> getCriticasByPeliculaId(int peliculaId) async {
    final uri = Uri.parse('$_baseUrl/api/v1/criticas/').replace(
      queryParameters: {'peliculaId': peliculaId.toString()},
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => ModeloCritica.fromJson(json)).toList();
    } else if (response.statusCode == 400) {
       throw Exception('ID de película inválido o formato incorrecto.');
    } else {
      throw Exception('Fallo al obtener críticas de la película (${response.statusCode}): ${response.body}');
    }
  }
  
  // GET /api/v1/criticas/recientes?cantidad={cantidad}
  Future<List<ModeloCritica>> getCriticasRecientes(int cantidad) async {
    final uri = Uri.parse('$_baseUrl/api/v1/criticas/recientes').replace(
      queryParameters: {'cantidad': cantidad.toString()},
    );
    
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => ModeloCritica.fromJson(json)).toList();
    } else {
      throw Exception('Fallo al obtener críticas recientes (${response.statusCode}): ${response.body}');
    }
  }
  
  // GET /api/v1/criticas/ranking?cantidad={cantidad}
  Future<List<ModeloPeliculaMedia>> getRankingPeliculas(int cantidad) async {
    final uri = Uri.parse('$_baseUrl/api/v1/criticas/ranking').replace(
      queryParameters: {'cantidad': cantidad.toString()},
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => ModeloPeliculaMedia.fromJson(json)).toList(); 
    } else {
      throw Exception('Fallo al obtener ranking (${response.statusCode}): ${response.body}');
    }
  }
  
// -----------------------------------------------------------------------
// Endpoints de Usuario (UsuarioController)
// -----------------------------------------------------------------------

  // GET /api/v1/usuarios
  Future<List<ModeloUsuario>> getAllUsuarios() async {
    final response = await http.get(Uri.parse('$_baseUrl/api/v1/usuarios'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => ModeloUsuario.fromJson(json)).toList();
    } else {
      throw Exception('Fallo al obtener todos los usuarios (${response.statusCode}): ${response.body}');
    }
  }
  
  // GET /api/v1/usuarios/{documentId}
  Future<ModeloUsuario> getUsuarioByID(String id) async {
    final response = await http.get(Uri.parse('$_baseUrl/api/v1/usuarios/$id'));

    if (response.statusCode == 200) {
      return ModeloUsuario.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      // El Controller devuelve 404 NOT FOUND si no lo encuentra
      throw Exception('Usuario con ID $id no encontrado.');
    } else {
      throw Exception('Fallo al obtener usuario por ID (${response.statusCode}): ${response.body}');
    }
  }

  // GET /api/v1/usuarios/nick/{nick}
  Future<List<ModeloUsuario>> getByNick(String nick) async {
    final response = await http.get(Uri.parse('$_baseUrl/api/v1/usuarios/nick/$nick'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => ModeloUsuario.fromJson(json)).toList();
    } else {
      throw Exception('Fallo al obtener usuario por nick (${response.statusCode}): ${response.body}');
    }
  }

  // POST /api/v1/usuarios/crearUsuario
  Future<ModeloUsuario> addUsuario(ModeloUsuario usuario) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/v1/usuarios/crearUsuario'),
      headers: _headers,
      body: json.encode(usuario.toMap()), 
    );

    if (response.statusCode == 201) { // El Controller devuelve 201 CREATED
      return ModeloUsuario.fromJson(json.decode(response.body));
    } else if (response.statusCode == 409) {
      throw Exception('Conflicto: El nick ya está en uso. (${response.body})');
    } else if (response.statusCode == 400) {
      throw Exception('Petición incorrecta: ${response.body}');
    } else {
      throw Exception('Fallo al añadir usuario (${response.statusCode}): ${response.body}');
    }
  }
  
  // PUT /api/v1/usuarios/editarUsuario/{documentId}
  Future<void> updateUsuario(String id, ModeloUsuario usuario) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/api/v1/usuarios/editarUsuario/$id'),
      headers: _headers,
      body: json.encode(usuario.toMap()),
    );

    // El Controller devuelve 204 NO CONTENT si es exitoso
    if (response.statusCode == 204) { 
        return;
    } else if (response.statusCode == 404) {
        throw Exception('Usuario con ID $id no encontrado para actualizar.');
    } else if (response.statusCode == 409) {
        throw Exception('Conflicto: El nuevo nick ya está en uso. (${response.body})');
    } else {
      throw Exception('Fallo al actualizar usuario (${response.statusCode}): ${response.body}');
    }
  }

  // DELETE /api/v1/usuarios/{documentId}
  Future<void> deleteUsuario(String id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/api/v1/usuarios/$id'));

    // El Controller devuelve 200 OK con un mensaje o 404
    if (response.statusCode == 200) {
        return; // Eliminado con éxito
    } else if (response.statusCode == 404) {
      throw Exception('Usuario con ID $id no encontrado para eliminar.');
    } else {
      throw Exception('Fallo al eliminar usuario (${response.statusCode}): ${response.body}');
    }
  }
}
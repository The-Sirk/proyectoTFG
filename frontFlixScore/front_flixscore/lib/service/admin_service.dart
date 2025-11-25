import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:logging/logging.dart';

final _logger = Logger('AdminService');

class AdminService {
  static const String _baseUrl =
      'https://tfg-backend-152779337859.europe-west1.run.app/admin/users';

  late final String _devKey = Platform.environment['DEV_KEY_ROLES'] ?? 
      _logMissingKey();

  String _logMissingKey() {
      _logger.info("No hay claves de desarrollador (DEV_KEY_ROLES). Las llamadas de administración fallarán con 401/403 si la API lo requiere.");
      return '';
  }

  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  // ----------------------------------------------------------
  // ASIGNAR ROL
  // ----------------------------------------------------------
  Future<Map<String, dynamic>> asignarRol({
    required String uid,
    required String role,
  }) async {
    final uri = Uri.parse('$_baseUrl/$uid/role')
        .replace(queryParameters: {'role': role});
    final response = await http.post(
      uri,
      headers: _headers..['devKeyHeader'] = _devKey,
    );

    return _handleResponse(response);
  }

  // ----------------------------------------------------------
  // LISTADO PAGINADO
  // ----------------------------------------------------------
  Future<List<dynamic>> listarUsuarios({
    int maxResults = 50,
    String? nextPageToken,
  }) async {
    final uri = Uri.parse(_baseUrl.trim()).replace(queryParameters: {
      'maxResults': maxResults.toString(),
      if (nextPageToken != null) 'nextPageToken': nextPageToken,
    });

    final response = await http.get(
      uri,
      headers: _headers..['devKeyHeader'] = _devKey,
    );

    final body = json.decode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body is Map<String, dynamic> && body.containsKey('usuarios')) {
        // _nextToken = body['siguienteTokenPagina'] as String?;
        return body['usuarios'] as List<dynamic>;
      }
      if (body is List) return body;

      throw Exception('Formato inesperado: ${body.runtimeType}, keys: ${(body as Map).keys}');
    } else {
      final msg = body is Map ? body['message'] : 'Error ${response.statusCode}';
      throw Exception('${response.statusCode} - $msg');
    }
  }

  // ----------------------------------------------------------
  // BANEAR / DESBANEAR
  // ----------------------------------------------------------
  Future<Map<String, dynamic>> toggleDisable({
    required String uid,
    required bool disabled,
  }) async {
    final uri = Uri.parse('$_baseUrl/$uid/disable')
        .replace(queryParameters: {'disabled': disabled.toString()});
    final response = await http.put(
      uri,
      headers: _headers..['devKeyHeader'] = _devKey,
    );

    return _handleResponse(response);
  }

  // ----------------------------------------------------------
  // FORZAR RESET DE CONTRASEÑA
  // ----------------------------------------------------------
  Future<Map<String, dynamic>> forzarResetPassword({
    required String uid,
  }) async {
    final uri = Uri.parse('$_baseUrl/$uid/reset-password');
    final response = await http.post(
      uri, 
      headers: _headers..['devKeyHeader'] = _devKey,
    );

    return _handleResponse(response);
  }

  // ----------------------------------------------------------
  // ELIMINAR USUARIO
  // ----------------------------------------------------------
  Future<Map<String, dynamic>> eliminarUsuario({
    required String uid,
  }) async {
    final uri = Uri.parse('$_baseUrl/$uid');
    final response = await http.delete(
      uri,
      headers: _headers..['devKeyHeader'] = _devKey,
    );

    return _handleResponse(response);
  }

  // ----------------------------------------------------------
  // MANEJO COMÚN DE RESPUESTAS
  // ----------------------------------------------------------
  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = json.decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body as Map<String, dynamic>;
    } else {
      final msg = body['message'] ?? 'Error desconocido del servidor';
      throw Exception('${response.statusCode} - $msg');
    }
  }
}
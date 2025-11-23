import 'package:flixscore/componentes/home/card_pelicula.dart';
import 'package:flixscore/modelos/critica_modelo.dart';
import 'package:flixscore/modelos/usuario_modelo.dart';
import 'package:flixscore/service/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flixscore/utils/app_logger.dart';

class CriticasProvider extends ChangeNotifier {
  ModeloUsuario? _usuarioLogueado;
  ModeloUsuario? get usuarioLogueado => _usuarioLogueado;

  ApiService apiService = ApiService();

  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  bool _cargando = false;
  bool get cargando => _cargando;
  List<ModeloCritica> _criticasUsuario = [];
  List<ModeloCritica> get criticasUsuario => _criticasUsuario;
  List<ModeloCritica> _criticasAmigos = [];
  List<ModeloCritica> get criticasAmigos => _criticasAmigos;
  List<PeliculaCard> _peliculasCardAmigos = [];
  List<PeliculaCard> get peliculasCardAmigos => _peliculasCardAmigos;
  List<PeliculaCard> _peliculasCardUltimas = [];
  List<PeliculaCard> get peliculasCardUltimas => _peliculasCardUltimas;

  // Cache de amigos para no pedir sus datos repetidamente
  final Map<String, ModeloUsuario> _amigosCache = {};
  Map<String, ModeloUsuario> get amigosCache => _amigosCache;

  CriticasProvider();

  //Metodo para actualizar el usuario logueado
  void actualizarUsuarioLogueado(ModeloUsuario? usuario) {
    AppLogger.logMethod(
      'actualizarUsuarioLogueado',
      message: 'usuario: $usuario',
    );
    _usuarioLogueado = usuario;
    recargarUsuario();
  }

  Future<void> recargarUsuario() async {
    AppLogger.logMethod(
      '_recargarUsuario',
      message: 'usuarioLogueado: $_usuarioLogueado',
    );
    await cargarCriticasDelUsuario();
    await cargarCriticasDeAmigos();
    await servirPeliculasCard();
    notifyListeners();
  }

  Future<void> cargarCriticasDelUsuario() async {
    AppLogger.logMethod(
      '_cargarCriticasDelUsuario',
      message: 'usuarioLogueado: $_usuarioLogueado',
    );
    if (_usuarioLogueado == null) {
      _errorMessage = "Usuario no logueado";
      AppLogger.logError(_errorMessage!);
      notifyListeners();
      return;
    }

    try {
      _criticasUsuario = await apiService.getCriticasByUserId(
        _usuarioLogueado!.documentID!,
      );
      AppLogger.logVar('criticasUsuario', _criticasUsuario);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Error al cargar críticas del usuario desde Provider $e";
      AppLogger.logError(_errorMessage!);
    }
    notifyListeners();
  }

  Future<void> cargarCriticasDeAmigos() async {
    AppLogger.logMethod(
      '_cargarCriticasDeAmigos',
      message: 'usuarioLogueado: $_usuarioLogueado',
    );
    if (_usuarioLogueado == null) {
      _errorMessage = "Usuario no logueado";
      AppLogger.logError(_errorMessage!);
      notifyListeners();
      return;
    }

    List<ModeloCritica> criticasAmigosTemp = [];

    try {
      for (var amigoId in _usuarioLogueado!.amigosId) {
        AppLogger.logVar('amigoId', amigoId);
        List<ModeloCritica> criticasAmigo = await apiService
            .getCriticasByUserId(amigoId);
        AppLogger.logVar('criticasAmigo', criticasAmigo);
        criticasAmigosTemp.addAll(criticasAmigo);

        // Cargar datos del amigo si no están en caché
        if (!_amigosCache.containsKey(amigoId)) {
          try {
            final amigoUsuario = await apiService.getUsuarioByID(amigoId);
            _amigosCache[amigoId] = amigoUsuario;
          } catch (e) {
            AppLogger.logError("Error cargando datos de amigo $amigoId: $e");
          }
        }
      }
      _criticasAmigos = criticasAmigosTemp;
      AppLogger.logVar('criticasAmigos', _criticasAmigos);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Error al cargar críticas de amigos desde Provider: $e";
      AppLogger.logError(_errorMessage!);
    }
    notifyListeners();
  }

  Future<void> cargarUltimasCriticas() async {
    AppLogger.logMethod('cargarUltimasCriticas');
    _cargando = true;
    notifyListeners();
    try {
      List<ModeloCritica> ultimasCriticas = await apiService
          .getCriticasRecientes(10);
      AppLogger.logVar('ultimasCriticas', ultimasCriticas);

      // Cargar perfiles de usuarios desconocidos
      for (var critica in ultimasCriticas) {
        if (!_amigosCache.containsKey(critica.usuarioUID)) {
          try {
            final usuario = await apiService.getUsuarioByID(critica.usuarioUID);
            _amigosCache[critica.usuarioUID] = usuario;
          } catch (e) {
            AppLogger.logError(
              "Error cargando usuario ${critica.usuarioUID} en ultimas: $e",
            );
          }
        }
      }

      _peliculasCardUltimas.clear();

      // Agrupa críticas por película para evitar duplicados
      final Map<String, List<ModeloCritica>> criticasPorPelicula = {};
      for (var critica in ultimasCriticas) {
        final key = critica.peliculaID.toString();
        criticasPorPelicula.putIfAbsent(key, () => []);
        criticasPorPelicula[key]!.add(critica);
      }

      for (var entry in criticasPorPelicula.entries) {
        final peliculaID = entry.key;
        final pelicula = await apiService.getMovieByID(peliculaID);

        // Cargar TODAS las críticas de esa película (no solo las recientes)
        List<ModeloCritica> todasLasCriticas = [];
        try {
          todasLasCriticas = await apiService.getCriticasByPeliculaId(
            pelicula.id,
          );
        } catch (e) {
          AppLogger.logError(
            "Error cargando todas las criticas para pelicula $peliculaID: $e",
          );
          // Si falla, usamos al menos las que ya teniamos
          todasLasCriticas = entry.value;
        }

        // Cargar perfiles de usuarios de TODAS las críticas
        for (var critica in todasLasCriticas) {
          if (!_amigosCache.containsKey(critica.usuarioUID) &&
              critica.usuarioUID != _usuarioLogueado?.documentID) {
            try {
              final usuario = await apiService.getUsuarioByID(
                critica.usuarioUID,
              );
              _amigosCache[critica.usuarioUID] = usuario;
            } catch (e) {
              AppLogger.logError(
                "Error cargando usuario ${critica.usuarioUID} en ultimas (full): $e",
              );
            }
          }
        }

        // Buscar si hay críticas de amigos para esta película (ya deberían estar en todasLasCriticas si el backend funciona bien,
        // Asumimos que getCriticasByPeliculaId trae todo.

        _peliculasCardUltimas.add(
          PeliculaCard(pelicula: pelicula, criticasAmigos: todasLasCriticas),
        );
      }

      AppLogger.logVar('peliculasCardUltimas', _peliculasCardUltimas);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Error al cargar últimas críticas desde Provider: $e";
      AppLogger.logError(_errorMessage!);
    }
    _cargando = false;
    notifyListeners();
  }

  Future<void> servirPeliculasCard() async {
    AppLogger.logMethod(
      '_servirPeliculasCard',
      message: 'criticasAmigos: $_criticasAmigos',
    );
    // Usamos una lista local para evitar duplicados
    List<PeliculaCard> nuevasPeliculasCard = [];

    try {
      final criticasPorPelicula = _agruparCriticasPorPelicula(_criticasAmigos);
      for (var entry in criticasPorPelicula.entries) {
        final peliculaID = entry.key;
        final criticas = entry.value;
        var pelicula = await apiService.getMovieByID(peliculaID);

        // Busca tu crítica para esta película
        final miCriticaList = _criticasUsuario
            .where((c) => c.peliculaID.toString() == peliculaID)
            .toList();

        // Crea una lista combinada: primero tu crítica (si existe), luego las de amigos
        final todasCriticas = [...miCriticaList, ...criticas];

        nuevasPeliculasCard.add(
          PeliculaCard(
            pelicula: pelicula,
            criticasAmigos: todasCriticas,
            mostrarEtiquetaAmigo: false, // Ocultar etiqueta en Popular
          ),
        );
      }

      // Asignamos la lista completa al final
      _peliculasCardAmigos = nuevasPeliculasCard;

      AppLogger.logVar('peliculasCardAmigos', _peliculasCardAmigos);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Error al servir películas de amigos desde Provider: $e";
      AppLogger.logError(_errorMessage!);
    }
    notifyListeners();
  }

  Future<void> crearCritica(ModeloCritica nuevaCritica) async {
    AppLogger.logMethod('crearCritica', message: 'nuevaCritica: $nuevaCritica');
    AppLogger.logVar('nuevaCritica id Usuario', nuevaCritica.usuarioUID);
    AppLogger.logVar('nuevaCritica id Pelicula', nuevaCritica.peliculaID);
    AppLogger.logVar('nuevaCritica puntuacion', nuevaCritica.puntuacion);
    AppLogger.logVar('nuevaCritica comentario', nuevaCritica.comentario);
    AppLogger.logVar(
      'nuevaCritica fecha',
      nuevaCritica.fechaCreacion.toString(),
    );
    try {
      final criticaCreada = await apiService.addCritica(nuevaCritica);
      AppLogger.logVar('criticaCreada', criticaCreada);
      _criticasUsuario.add(criticaCreada);
      AppLogger.logVar('criticasUsuario', _criticasUsuario);

      // Actualizar las tarjetas para que se vea la nueva crítica
      await servirPeliculasCard();
      await cargarUltimasCriticas();

      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = "Error al crear crítica desde Provider: $e";
      AppLogger.logError(_errorMessage!);
      notifyListeners();
    }
  }

  Map<String, List<ModeloCritica>> _agruparCriticasPorPelicula(
    List<ModeloCritica> criticas,
  ) {
    final Map<String, List<ModeloCritica>> criticasPorPelicula = {};
    for (var critica in criticas) {
      final key = critica.peliculaID.toString();
      if (!criticasPorPelicula.containsKey(key)) {
        criticasPorPelicula[key] = [];
      }
      criticasPorPelicula[key]!.add(critica);
    }
    return criticasPorPelicula;
  }

  ModeloUsuario? getUsuarioAmigo(String id) {
    return _amigosCache[id];
  }

  List<ModeloCritica> getCriticasAmigosPorPelicula(int peliculaId) {
    return _criticasAmigos.where((c) => c.peliculaID == peliculaId).toList();
  }
}

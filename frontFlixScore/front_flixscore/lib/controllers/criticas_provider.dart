import 'package:flixscore/componentes/home/card_pelicula.dart';
import 'package:flixscore/modelos/critica_modelo.dart';
import 'package:flixscore/modelos/pelicula_modelo.dart';
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
    
    // Indicar que estamos cargando
    _cargando = true;
    notifyListeners();
    
    try {
      // PARALELIZACIÓN: Cargar críticas del usuario y de amigos simultáneamente
      await Future.wait([
        cargarCriticasDelUsuario(),
        cargarCriticasDeAmigos(),
      ]);
      
      // Después de tener las críticas, cargar las tarjetas y últimas críticas en paralelo
      await Future.wait([
        servirPeliculasCard(),
        cargarUltimasCriticas(),
      ]);
    } catch (e) {
      AppLogger.logError('Error en recargarUsuario: $e');
      _errorMessage = 'Error al cargar datos: $e';
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> cargarCriticasDelUsuario() async {
    AppLogger.logMethod(
      '_cargarCriticasDelUsuario',
      message: 'usuarioLogueado: $_usuarioLogueado',
    );
    if (_usuarioLogueado == null) {
      _errorMessage = "Usuario no logueado";
      AppLogger.logError(_errorMessage!);
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
  }

  Future<void> cargarCriticasDeAmigos() async {
    AppLogger.logMethod(
      '_cargarCriticasDeAmigos',
      message: 'usuarioLogueado: $_usuarioLogueado',
    );
    if (_usuarioLogueado == null) {
      _errorMessage = "Usuario no logueado";
      AppLogger.logError(_errorMessage!);
      return;
    }

    try {
      // PARALELIZACIÓN: Cargar críticas de TODOS los amigos simultáneamente
      final futures = _usuarioLogueado!.amigosId.map((amigoId) async {
        AppLogger.logVar('amigoId (paralelo)', amigoId);
        
        // Cargar críticas y datos del amigo en paralelo
        final results = await Future.wait([
          apiService.getCriticasByUserId(amigoId),
          // Solo cargar usuario si no está en caché
          if (!_amigosCache.containsKey(amigoId))
            apiService.getUsuarioByID(amigoId)
          else
            Future.value(_amigosCache[amigoId]),
        ]);
        
        final criticasAmigo = results[0] as List<ModeloCritica>;
        final amigoUsuario = results[1] as ModeloUsuario;
        
        AppLogger.logVar('criticasAmigo (paralelo)', criticasAmigo);
        
        // Actualizar caché
        _amigosCache[amigoId] = amigoUsuario;
        
        return criticasAmigo;
      }).toList();
      
      // Esperar a que todas las peticiones terminen
      final todasLasCriticas = await Future.wait(futures);
      
      // Aplanar la lista de listas
      _criticasAmigos = todasLasCriticas.expand((lista) => lista).toList();
      
      AppLogger.logVar('criticasAmigos (total)', _criticasAmigos);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Error al cargar críticas de amigos desde Provider: $e";
      AppLogger.logError(_errorMessage!);
    }
  }

  Future<void> cargarUltimasCriticas() async {
    AppLogger.logMethod('cargarUltimasCriticas');
    try {
      List<ModeloCritica> ultimasCriticas = await apiService
          .getCriticasRecientes(10);
      AppLogger.logVar('ultimasCriticas', ultimasCriticas);

      // PARALELIZACIÓN: Cargar usuarios desconocidos en paralelo
      final usuariosDesconocidos = ultimasCriticas
          .where((c) => !_amigosCache.containsKey(c.usuarioUID))
          .map((c) => c.usuarioUID)
          .toSet(); // Usar Set para evitar duplicados
      
      if (usuariosDesconocidos.isNotEmpty) {
        final usuariosFutures = usuariosDesconocidos.map((uid) async {
          try {
            final usuario = await apiService.getUsuarioByID(uid);
            return MapEntry(uid, usuario);
          } catch (e) {
            AppLogger.logError("Error cargando usuario $uid en ultimas: $e");
            return null;
          }
        }).toList();
        
        final usuariosResultados = await Future.wait(usuariosFutures);
        for (var entry in usuariosResultados) {
          if (entry != null) {
            _amigosCache[entry.key] = entry.value;
          }
        }
      }

      // Agrupa críticas por película para evitar duplicados
      final Map<String, List<ModeloCritica>> criticasPorPelicula = {};
      for (var critica in ultimasCriticas) {
        final key = critica.peliculaID.toString();
        criticasPorPelicula.putIfAbsent(key, () => []);
        criticasPorPelicula[key]!.add(critica);
      }

      // PARALELIZACIÓN: Cargar todas las películas y sus críticas en paralelo
      final peliculasFutures = criticasPorPelicula.entries.map((entry) async {
        final peliculaID = entry.key;
        
        try {
          // Cargar película y todas sus críticas en paralelo
          final results = await Future.wait([
            apiService.getMovieByID(peliculaID),
            apiService.getCriticasByPeliculaId(int.parse(peliculaID)),
          ]);
          
          final pelicula = results[0] as ModeloPelicula;
          var todasLasCriticas = results[1] as List<ModeloCritica>;
          
          // Si falló la carga de críticas, usar las que ya teníamos
          if (todasLasCriticas.isEmpty) {
            todasLasCriticas = entry.value;
          }
          
          // PARALELIZACIÓN: Cargar usuarios de críticas en paralelo
          final usuariosNuevos = todasLasCriticas
              .where((c) => 
                  !_amigosCache.containsKey(c.usuarioUID) &&
                  c.usuarioUID != _usuarioLogueado?.documentID)
              .map((c) => c.usuarioUID)
              .toSet();
          
          if (usuariosNuevos.isNotEmpty) {
            final usuariosFutures = usuariosNuevos.map((uid) async {
              try {
                final usuario = await apiService.getUsuarioByID(uid);
                return MapEntry(uid, usuario);
              } catch (e) {
                AppLogger.logError(
                  "Error cargando usuario $uid en ultimas (full): $e",
                );
                return null;
              }
            }).toList();
            
            final usuariosResultados = await Future.wait(usuariosFutures);
            for (var entry in usuariosResultados) {
              if (entry != null) {
                _amigosCache[entry.key] = entry.value;
              }
            }
          }

          // Filtrar solo las críticas de amigos
          final criticasDeAmigos = todasLasCriticas.where((critica) {
            final esAmigo =
                _usuarioLogueado?.amigosId.contains(critica.usuarioUID) ?? false;
            return esAmigo;
          }).toList();

          return PeliculaCard(
            pelicula: pelicula,
            criticasAmigos: todasLasCriticas,
            mostrarEtiquetaAmigo: criticasDeAmigos.isNotEmpty,
          );
        } catch (e) {
          AppLogger.logError(
            "Error cargando datos para película $peliculaID: $e",
          );
          return null;
        }
      }).toList();
      
      // Esperar todas las películas
      final peliculasResultados = await Future.wait(peliculasFutures);
      
      // Filtrar nulls
      _peliculasCardUltimas = peliculasResultados
          .where((p) => p != null)
          .cast<PeliculaCard>()
          .toList();
      AppLogger.logVar('peliculasCardUltimas', _peliculasCardUltimas);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Error al cargar últimas críticas desde Provider: $e";
      AppLogger.logError(_errorMessage!);
    }
  }

  Future<void> servirPeliculasCard() async {
    AppLogger.logMethod(
      '_servirPeliculasCard',
      message: 'criticasAmigos: $_criticasAmigos',
    );

    try {
      final criticasPorPelicula = _agruparCriticasPorPelicula(_criticasAmigos);
      
      // PARALELIZACIÓN: Cargar TODAS las películas simultáneamente
      final peliculasFutures = criticasPorPelicula.entries.map((entry) async {
        final peliculaID = entry.key;
        final criticas = entry.value;
        
        try {
          final pelicula = await apiService.getMovieByID(peliculaID);

          // Busca tu crítica para esta película
          final miCriticaList = _criticasUsuario
              .where((c) => c.peliculaID.toString() == peliculaID)
              .toList();

          // Crea una lista combinada: primero tu crítica (si existe), luego las de amigos
          final todasCriticas = [...miCriticaList, ...criticas];

          return PeliculaCard(
            pelicula: pelicula,
            criticasAmigos: todasCriticas,
            mostrarEtiquetaAmigo: false, // Ocultar etiqueta en Popular
          );
        } catch (e) {
          AppLogger.logError('Error cargando película $peliculaID: $e');
          return null;
        }
      }).toList();
      
      // Esperar a que todas las películas se carguen
      final peliculasResultados = await Future.wait(peliculasFutures);
      
      // Filtrar nulls (películas que fallaron)
      _peliculasCardAmigos = peliculasResultados
          .where((p) => p != null)
          .cast<PeliculaCard>()
          .toList();

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

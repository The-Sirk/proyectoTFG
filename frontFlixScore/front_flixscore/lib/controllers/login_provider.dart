import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flixscore/componentes/common/snack_bar.dart';
import 'package:flixscore/modelos/usuario_modelo.dart';
import 'package:flixscore/service/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum AuthStatus { noAutenticado, autenticado, autenticando }

class LoginProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ModeloUsuario? _usuarioLogueado;
  ModeloUsuario? get usuarioLogueado => _usuarioLogueado;

  AuthStatus _status = AuthStatus.noAutenticado;
  AuthStatus get status => _status;

  ApiService apiService = ApiService();

  String? _errorMessage;

  List<ModeloUsuario> _amigosObj = [];
  List<ModeloUsuario> get amigosObj => _amigosObj;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated =>
      _status == AuthStatus.autenticado && _usuarioLogueado != null;

  // Constructor que esta pendiente de cambios en el estado de autenticación
  LoginProvider() {
    _auth.authStateChanges().listen((User? user) async {
      if (user == null) {
        print(
          '[DEBUG LoginProvider] authStateChanges: user is null, setting noAutenticado',
        );
        _status = AuthStatus.noAutenticado;
        _usuarioLogueado = null;
        notifyListeners();
      } else {
        print(
          '[DEBUG LoginProvider] authStateChanges: user detected (${user.uid}), calling _cargarDatosUsuario',
        );
        // Siempre recargar datos cuando se detecta un usuario autenticado
        await _cargarDatosUsuario(user.uid);
      }
    });
  }

  // Recargamos datos del usuario
  Future<void> _cargarDatosUsuario(String uid) async {
    try {
      print(
        '[DEBUG LoginProvider] _cargarDatosUsuario: starting, setting autenticando',
      );
      _status = AuthStatus.autenticando;
      notifyListeners();

      final user = _auth.currentUser;
      final fechaRegistro = user?.metadata.creationTime;
      final puntuaciones = await _obtenerPuntuacionesDesdeCriticas(uid);

      final isAdmin = await _obtenerClaimAdmin();

      final DocumentSnapshot userDoc = await _firestore
          .collection("usuarios")
          .doc(uid)
          .get();

      if (userDoc.exists) {
        _usuarioLogueado = ModeloUsuario(
          documentID: uid,
          correo: userDoc.get("correo"),
          imagenPerfil: userDoc.get("imagen_perfil") ?? "",
          nick: userDoc.get("nick"),
          amigosId: List<String>.from(userDoc.get("amigos_id") ?? []),
          peliculasCriticadas: List<int>.from(
            userDoc.get("peliculas_criticadas") ?? [],
          ),
          peliculasFavoritas: List<int>.from(
            userDoc.get("peliculas_favoritas") ?? [],
          ),
          peliculasVistas: List<int>.from(
            userDoc.get("peliculas_vistas") ?? [],
          ),
          fechaRegistro: fechaRegistro,
          puntuaciones: puntuaciones,
          esAdmin: isAdmin,
        );
        print(
          '[DEBUG LoginProvider] _cargarDatosUsuario: user data loaded, setting autenticado',
        );
        _status = AuthStatus.autenticado;
      }
    } catch (e) {
      print('[DEBUG LoginProvider] _cargarDatosUsuario: ERROR - $e');
      _status = AuthStatus.noAutenticado;
      _errorMessage = 'Error al cargar datos: $e';
    }
    print(
      '[DEBUG LoginProvider] _cargarDatosUsuario: calling notifyListeners, status = $_status',
    );
    notifyListeners();
  }

  // Login
  Future<void> loginUsuario({
    required String email,
    required String password,
  }) async {
    try {
      _status = AuthStatus.autenticando;
      _errorMessage = null;
      notifyListeners();

      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user == null) {
        throw Exception('Error al autenticar usuario');
      }

      final user = userCredential.user!;
      final fechaRegistro = user.metadata.creationTime;
      final puntuaciones = await _obtenerPuntuacionesDesdeCriticas(user.uid);

      final DocumentSnapshot userDoc = await _firestore
          .collection("usuarios")
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('Usuario no encontrado en la base de datos');
      }

      _usuarioLogueado = ModeloUsuario(
        documentID: user.uid,
        correo: userDoc.get("correo"),
        imagenPerfil: userDoc.get("imagen_perfil") ?? "",
        nick: userDoc.get("nick"),
        amigosId: List<String>.from(userDoc.get("amigos_id") ?? []),
        peliculasCriticadas: List<int>.from(
          userDoc.get("peliculas_criticadas") ?? [],
        ),
        peliculasFavoritas: List<int>.from(
          userDoc.get("peliculas_favoritas") ?? [],
        ),
        peliculasVistas: List<int>.from(userDoc.get("peliculas_vistas") ?? []),
        fechaRegistro: fechaRegistro,
        puntuaciones: puntuaciones,
      );

      _status = AuthStatus.autenticado;
      _errorMessage = null;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.noAutenticado;
      _usuarioLogueado = null;

      if (e.code == 'user-not-found') {
        _errorMessage = 'No existe un usuario con ese correo';
      } else if (e.code == 'wrong-password') {
        _errorMessage = 'Contraseña incorrecta';
      } else if (e.code == 'invalid-email') {
        _errorMessage = 'El correo no es válido';
      } else if (e.code == 'user-disabled') {
        _errorMessage = 'Esta cuenta ha sido deshabilitada';
      } else {
        _errorMessage = 'Error de autenticación: ${e.message}';
      }

      notifyListeners();
      throw Exception(_errorMessage);
    } catch (e) {
      _status = AuthStatus.noAutenticado;
      _usuarioLogueado = null;
      _errorMessage = 'Error inesperado: $e';
      notifyListeners();
      throw Exception(_errorMessage);
    }
  }

  // Recuperaciónd de contraseña
  Future<void> solicitarRecuperacionContrasena({required String email}) async {
    try {
      _status = AuthStatus.autenticando; 
      _errorMessage = null;
      notifyListeners();
      await _auth.sendPasswordResetEmail(email: email);
      _status = AuthStatus.noAutenticado;
      notifyListeners();
      
    } on FirebaseAuthException catch (e) {
      // Revertimos el estado de autenticación ya que falló
      _status = AuthStatus.noAutenticado;
      _usuarioLogueado = null; 

      String errorMessage;
      if (e.code == 'invalid-email') {
        errorMessage = "El correo proporcionado no es válido.";
      } else if (e.code == 'user-not-found') {
        errorMessage = "Hemos enviado un correo para restablecer la contraseña. Revisa tu bandeja de entrada y spam.";
      } else {
        errorMessage = "Ocurrió un error inesperado al solicitar la recuperación: ${e.message}";
      }

      _errorMessage = errorMessage;
      notifyListeners();
      // Lanzamos la excepción para que el widget (card_login) pueda mostrar el SnackBar de error
      throw Exception(errorMessage); 
      
    } catch (e) {
      _status = AuthStatus.noAutenticado;
      _usuarioLogueado = null;
      _errorMessage = "Error desconocido al solicitar recuperación: $e";
      notifyListeners();
      throw Exception(_errorMessage);
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    // Cerrar sesión de Firebase Auth
    await _auth.signOut();

    // Cerrar sesión de Google Sign In para evitar problemas al volver a iniciar sesión
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;
      await googleSignIn.signOut();
    } catch (e) {
      // Si falla el signOut de Google, lo registramos pero continuamos
      if (kDebugMode) {
        print('Error al cerrar sesión de Google: $e');
      }
    }

    _usuarioLogueado = null;
    _status = AuthStatus.noAutenticado;
    _errorMessage = null;
    notifyListeners();
  }

  // Actualizar usuario
  Future<void> actualizarUsuario() async {
    if (_usuarioLogueado == null || _auth.currentUser == null) return;

    try {
      final user = _auth.currentUser!;
      final fechaRegistro = user.metadata.creationTime;
      final puntuaciones = await _obtenerPuntuacionesDesdeCriticas(user.uid);

      final DocumentSnapshot userDoc = await _firestore
          .collection("usuarios")
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        _usuarioLogueado = ModeloUsuario(
          documentID: user.uid,
          correo: userDoc.get("correo"),
          imagenPerfil: userDoc.get("imagen_perfil") ?? "",
          nick: userDoc.get("nick"),
          amigosId: List<String>.from(userDoc.get("amigos_id") ?? []),
          peliculasCriticadas: List<int>.from(
            userDoc.get("peliculas_criticadas") ?? [],
          ),
          peliculasFavoritas: List<int>.from(
            userDoc.get("peliculas_favoritas") ?? [],
          ),
          peliculasVistas: List<int>.from(
            userDoc.get("peliculas_vistas") ?? [],
          ),
          fechaRegistro: fechaRegistro,
          puntuaciones: puntuaciones,
        );
        notifyListeners();
      }
    } catch (e) {
      // TODO: Manejar error adecuadamente
      print('Error al actualizar usuario: $e');
    }
  }

  // Verificar sesión
  Future<void> verificarSesion() async {
    final user = _auth.currentUser;
    if (user != null) {
      _status = AuthStatus.autenticando;
      notifyListeners();

      try {
        final puntuaciones = await _obtenerPuntuacionesDesdeCriticas(user.uid);
        final DocumentSnapshot userDoc = await _firestore
            .collection("usuarios")
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          _usuarioLogueado = ModeloUsuario(
            documentID: user.uid,
            correo: userDoc.get("correo"),
            imagenPerfil: userDoc.get("imagen_perfil") ?? "",
            nick: userDoc.get("nick"),
            amigosId: List<String>.from(userDoc.get("amigos_id") ?? []),
            peliculasCriticadas: List<int>.from(
              userDoc.get("peliculas_criticadas") ?? [],
            ),
            peliculasFavoritas: List<int>.from(
              userDoc.get("peliculas_favoritas") ?? [],
            ),
            peliculasVistas: List<int>.from(
              userDoc.get("peliculas_vistas") ?? [],
            ),
            fechaRegistro: user.metadata.creationTime,
            puntuaciones: puntuaciones,
          );
          _status = AuthStatus.autenticado;
        } else {
          await logout();
        }
      } catch (e) {
        await logout();
      }
      notifyListeners();
    }
  }

  Future<void> loginGoogleWeb() async {
    try {
      // Seteamos el estado a autenticando
      _status = AuthStatus.autenticando;
      _errorMessage = null;
      notifyListeners();

      // Lanzamos el popup de autenticación de Google
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope(
        "https://www.googleapis.com/auth/contacts.readonly",
      );

      final UserCredential userCredential = await _auth.signInWithPopup(
        googleProvider,
      );
      
      if (userCredential.user == null) {
        // En caso de un fallo que no lance excepción
        _status = AuthStatus.noAutenticado;
        _usuarioLogueado = null;
        _errorMessage = 'Error de autenticación con Google:';
        notifyListeners();
        throw Exception('Error al autenticar usuario con Google');
      }

      // Si el usuario no existe en la base de datos, lo creamos
      final DocumentSnapshot userDoc = await _firestore
          .collection("usuarios")
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        await apiService.addUsuario(
          ModeloUsuario(
            documentID: userCredential.user!.uid,
            correo: userCredential.user!.email ?? "",
            imagenPerfil: userCredential.user!.photoURL ?? "",
            nick: userCredential.user!.displayName ?? "Usuario",
            amigosId: [],
            peliculasCriticadas: [],
            peliculasFavoritas: [],
            peliculasVistas: [],
          ),
        );
      }

      // El authStateChanges listener se encargará de cargar los datos del usuario
      if (userCredential.user != null && userCredential.user!.uid.isNotEmpty) {
        await _cargarDatosUsuario(userCredential.user!.uid);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'popup-closed-by-user' || e.code == 'auth/cancelled-popup-request') {
        print('[DEBUG LoginProvider] Login Google Web cancelado por el usuario.');
        _status = AuthStatus.noAutenticado;
        _usuarioLogueado = null;
        notifyListeners();
        return;
      }
      
      _status = AuthStatus.noAutenticado;
      _usuarioLogueado = null;
      _errorMessage = 'Error de autenticación con Google: ${e.message}';
      notifyListeners();
      throw Exception(_errorMessage);
    } catch (e) {
      _status = AuthStatus.noAutenticado;
      _usuarioLogueado = null;
      _errorMessage = 'Error de autenticación con Google: $e';
      notifyListeners();
      throw Exception(_errorMessage);
    }
  }

  Future<void> loginGoogle() async {
    try {
      _status = AuthStatus.autenticando;
      _errorMessage = null;
      notifyListeners();
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize();
      GoogleSignInAccount? googleUser; 
      try {
        googleUser = await googleSignIn.attemptLightweightAuthentication();
        googleUser ??= await googleSignIn.authenticate(); 
      } catch (e) {
      }
      if (googleUser == null) {
        _usuarioLogueado = null;
        _status = AuthStatus.noAutenticado;
        notifyListeners();
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credenciales = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential = await _auth.signInWithCredential(
        credenciales,
      );
      if (userCredential.user == null) {
        _status = AuthStatus.noAutenticado;
        _usuarioLogueado = null;
        _errorMessage = 'Error de autenticación con Google:';
        notifyListeners();
        throw Exception('Error al autenticar usuario con Google');
      }
      
      // Si el usuario no existe en la base de datos, lo creamos
      final DocumentSnapshot userDoc = await _firestore
          .collection("usuarios")
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        await apiService.addUsuario(
          ModeloUsuario(
            documentID: userCredential.user!.uid,
            correo: userCredential.user!.email ?? "",
            imagenPerfil: userCredential.user!.photoURL ?? "",
            nick: userCredential.user!.displayName ?? "Usuario",
            amigosId: [],
            peliculasCriticadas: [],
            peliculasFavoritas: [],
            peliculasVistas: [],
          ),
        );
      }
      
      if (userCredential.user != null && userCredential.user!.uid.isNotEmpty) {
        await _cargarDatosUsuario(userCredential.user!.uid);
      }
    } catch (e) {
      if (e.toString().contains('cancelled') || e.toString().contains('sign_in_failed')) {
          print('[DEBUG LoginProvider] Login Google (mobile) cancelación en el bloque catch.');
          _status = AuthStatus.noAutenticado;
          _usuarioLogueado = null;
          notifyListeners();
          return;
      }
      _status = AuthStatus.noAutenticado;
      _usuarioLogueado = null;
      _errorMessage = 'Error de autenticación con Google: $e';
      notifyListeners();
      throw Exception(_errorMessage);
    }
  }
  Future<void> actualizarNick(String nuevoNick) async {
    if (_usuarioLogueado == null || _auth.currentUser == null) return;
    try {
      await ApiService().cambiarNick(_auth.currentUser!.uid, nuevoNick);
      _usuarioLogueado = _usuarioLogueado!.copyWith(nick: nuevoNick);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Actualiza la URL de la imagen de perfil en Firestore y en el modelo local
  Future<void> actualizarImagenPerfil(String nuevaUrl) async {
    if (_usuarioLogueado == null || _auth.currentUser == null) return;

    try {
      // Guarda la nueva URL en Firestore
      await _firestore
          .collection('usuarios')
          .doc(_auth.currentUser!.uid)
          .update({'imagen_perfil': nuevaUrl});

      // Actualiza el modelo en memoria
      _usuarioLogueado = _usuarioLogueado!.copyWith(
        imagenPerfil: '$nuevaUrl?v=${DateTime.now().millisecondsSinceEpoch}',
      );
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Obtenemos las criticas del usuario
  Future<List<int>> _obtenerPuntuacionesDesdeCriticas(String usuarioId) async {
    try {
      final criticas = await ApiService().getCriticasByUserId(usuarioId);
      return criticas.map((c) => c.puntuacion).toList();
    } catch (_) {
      return [];
    }
  }

  // Se obtiene la lista de amigos del usuario
  Future<List<ModeloUsuario>> obtenerAmigos() async {
    if (_usuarioLogueado == null) return [];

    final ids = _usuarioLogueado!.amigosId;
    if (ids.isEmpty) return [];

    // Obtén los usuarios completos (una sola vez)
    final amigos = await Future.wait(
      ids.map((id) => ApiService().getUsuarioByID(id)),
    );

    return amigos;
  }

  // Carga de amigos al inicio
  Future<void> cargarAmigos({bool notificar = true}) async {
    if (_usuarioLogueado == null) return;

    final ids = _usuarioLogueado!.amigosId;
    if (ids.isEmpty) {
      _amigosObj = [];
      if (notificar) notifyListeners();
      return;
    }

    // Usamos Future.wait para obtener los objetos, manejando posibles errores de la API.
    final List<ModeloUsuario?> resultados = await Future.wait(
      ids.map((id) async {
        try {
          // Intentar obtener el usuario
          return await ApiService().getUsuarioByID(id);
        } catch (e) {
          // Imprimir el error para depuración
          if (kDebugMode) {
            print('Error al cargar amigo con ID $id: $e');
          }
          // Devolver null si el usuario no pudo ser cargado (ej. fue borrado)
          return null;
        }
      }),
    );

    // Filtrar los resultados para mantener solo los usuarios válidos (que no son null)
    _amigosObj = resultados.whereType<ModeloUsuario>().toList();

    // Si la lista de IDs estaba vacía, el código anterior ya lo manejó,
    // pero si falla la API de forma silenciosa, también actualizamos la UI.
    if (notificar) notifyListeners();
  }

  // Actualiza el listado de amigos tras algún cambio
  void actualizarAmigosId(List<String> nuevaLista) {
    if (_usuarioLogueado == null) return;

    _usuarioLogueado = _usuarioLogueado!.copyWith(amigosId: nuevaLista);
    notifyListeners();
    cargarAmigos(notificar: true);
  }

  // Nuevo método que contiene toda la lógica de búsqueda, verificación y adición
  Future<bool> buscarYAgregarAmigo(BuildContext context, String nick) async {
    final currentUserId = _usuarioLogueado?.documentID;

    // No se debería poder llegar a este punto, pero por si acaso...
    if (currentUserId == null) {
      mostrarSnackBarError(
        context,
        "Error: El usuario actual no está logueado.",
      );
      return false;
    }

    try {
      final api = ApiService();
      final usuariosEncontrados = await api.getByNick(nick);

      if (usuariosEncontrados.isEmpty) {
        mostrarSnackBarError(
          context,
          "No se encontró ningún usuario con el nick ''$nick''.",
        );
        return false;
      }

      final usuarioEncontrado = usuariosEncontrados.first;

      if (usuarioEncontrado.documentID == null) {
        mostrarSnackBarError(
          context,
          "El usuario encontrado no tiene ID válido.",
        );
        return false;
      }

      if (usuarioEncontrado.documentID! == currentUserId) {
        mostrarSnackBarError(
          context,
          "En FlixScore valoramos fuertemente tu amor propio, pero no puedes agregarte como amigo.",
        );
        return false;
      }

      // Verificar si ya es amigo usando el estado actual del provider
      if (_usuarioLogueado!.amigosId.contains(usuarioEncontrado.documentID!)) {
        mostrarSnackBarError(
          context,
          "${usuarioEncontrado.nick} ya es tu amigo",
        );
        return false;
      }

      // Mostrar diálogo de confirmación
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1A1C25),
          title: const Text(
            '¿Agregar amigo?',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            '¿Deseas agregar a ${usuarioEncontrado.nick} como amigo?',
            style: const TextStyle(color: Color(0xFFAAAAAA)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Color(0xFFAAAAAA)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Agregar',
                style: TextStyle(color: Colors.cyanAccent),
              ),
            ),
          ],
        ),
      );

      if (confirmar != true) return false;

      // Llamada a la API y actualización del Provider
      await api.agregarAmigo(currentUserId, usuarioEncontrado.documentID!);

      // Actualizar la lista de IDs de amigos en el provider
      List<String> nuevaListaIds = List.from(_usuarioLogueado!.amigosId)
        ..add(usuarioEncontrado.documentID!);
      actualizarAmigosId(nuevaListaIds);

      mostrarSnackBarExito(
        context,
        "${usuarioEncontrado.nick} agregado a tu lista de amigos",
      );
      return true;
    } catch (e) {
      mostrarSnackBarError(
        context,
        "Error al agregar amigo: ${e.toString().split(':').last.trim()}",
      );
      return false;
    }
  }

  // Método final, con este se acaba todo ELIMINA LA CUENTA DE USUARIO
  Future<bool> eliminarCuentaDefinitivamente(BuildContext context) async {
    final currentUserId = _usuarioLogueado?.documentID;

    if (currentUserId == null) {
      mostrarSnackBarError(context, "Error: Usuario no logueado.");
      return false;
    }

    // Mostrar diálogo de confirmación final
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1C25),
        title: const Text(
          'CONFIRMAR ELIMINACIÓN',
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Esta acción es irreversible. ¿Estás absolutamente seguro de que deseas eliminar tu cuenta y todos tus datos?',
          style: TextStyle(color: Color(0xFFAAAAAA)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFFAAAAAA)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'SÍ, ELIMINAR',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return false;

    try {
      final api = ApiService();
      final user = _auth.currentUser;

      // Eliminar documento del usuario en la base de datos (Firebase)
      await api.deleteUsuario(currentUserId);

      // Borra la cuenta de Firebase Authentication
      if (user != null) {
        await user.delete();
      }

      mostrarSnackBarExito(
        context,
        "Tu cuenta ha sido eliminada exitosamente.",
      );

      return true;
    } catch (e) {
      mostrarSnackBarError(
        context,
        "Error al eliminar la cuenta: ${e.toString().split(':').last.trim()}",
      );
      return false;
    }
  }

  // Recarga las puntuaciones medias del usuario
  Future<void> recargarPuntuaciones() async {
    if (_usuarioLogueado == null) return;
    final nuevas = await _obtenerPuntuacionesDesdeCriticas(
      _usuarioLogueado!.documentID!,
    );
    _usuarioLogueado = _usuarioLogueado!.copyWith(puntuaciones: nuevas);
    notifyListeners();
  }

  // Función auxiliar para obtener los custom claims
  Future<bool> _obtenerClaimAdmin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Forzar la recarga del token para obtener los claims más recientes
      final idTokenResult = await user.getIdTokenResult(true);

      // Obtener el Custom Claim llamado 'role' como String
      final role = idTokenResult.claims?['role'] as String?;

      // Verificar si el valor del rol es exactamente 'admin' (ignorando mayúsculas/minúsculas por seguridad)
      final isAdmin = role?.toLowerCase() == 'admin';

      // Imprimir el valor real para depuración
      print(
        '[DEBUG LoginProvider] _obtenerClaimAdmin: rol recuperado = $role, es admin = $isAdmin',
      );

      return isAdmin;
    } catch (e) {
      print('[DEBUG LoginProvider] Error al obtener custom claims: $e');
      return false;
    }
  }
}

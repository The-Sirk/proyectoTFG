import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flixscore/modelos/usuario_modelo.dart';
import 'package:flutter/foundation.dart';

enum AuthStatus { noAutenticado, autenticado, autenticando }

class LoginProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ModeloUsuario? _usuarioLogueado;
  ModeloUsuario? get usuarioLogueado => _usuarioLogueado;

  AuthStatus _status = AuthStatus.noAutenticado;
  AuthStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _status == AuthStatus.autenticado && _usuarioLogueado != null;

  LoginProvider() {
    _auth.authStateChanges().listen((User? user) async {
      if (user == null) {
        _status = AuthStatus.noAutenticado;
        _usuarioLogueado = null;
        notifyListeners();
      } else if (_usuarioLogueado == null) {
        await _cargarDatosUsuario(user.uid);
      }
    });
  }

  // Metodo para cargar los datos del usuario cuando se acaba de registrar
  Future<void> _cargarDatosUsuario(String uid) async {
    try {
      _status = AuthStatus.autenticando;
      notifyListeners();

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
          amigosId: List<String>.from(userDoc.get("amigos_ids") ?? []),
          peliculasCriticadas: List<int>.from(userDoc.get("peliculas_criticadas") ?? []),
          peliculasFavoritas: List<int>.from(userDoc.get("peliculas_favoritas") ?? []),
          peliculasVistas: List<int>.from(userDoc.get("peliculas_vistas") ?? []),
        );
        _status = AuthStatus.autenticado;
      }
    } catch (e) {
      _status = AuthStatus.noAutenticado;
      _errorMessage = 'Error al cargar datos: $e';
    }
    notifyListeners();
  }
  
  // Metodo para iniciar sesión
  Future<void> loginUsuario({
    required String email,
    required String password,
  }) async {
    try {
      _status = AuthStatus.autenticando;
      _errorMessage = null;
      notifyListeners();

      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Error al autenticar usuario');
      }

      final DocumentSnapshot userDoc = await _firestore
          .collection("usuarios")
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('Usuario no encontrado en la base de datos');
      }

      _usuarioLogueado = ModeloUsuario(
        documentID: userCredential.user!.uid,
        correo: userDoc.get("correo"),
        imagenPerfil: userDoc.get("imagen_perfil") ?? "",  //Imagen terminada en .webp
        nick: userDoc.get("nick"),
        amigosId: List<String>.from(userDoc.get("amigos_ids") ?? []),
        peliculasCriticadas: List<int>.from(userDoc.get("peliculas_criticadas") ?? []),
        peliculasFavoritas: List<int>.from(userDoc.get("peliculas_favoritas") ?? []),
        peliculasVistas: List<int>.from(userDoc.get("peliculas_vistas") ?? []),
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


  // Metodo para cerrar sesión
  Future<void> logout() async {
    await _auth.signOut();
    _usuarioLogueado = null;
    _status = AuthStatus.noAutenticado;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> actualizarUsuario() async {
    if (_usuarioLogueado == null || _auth.currentUser == null) return;

    try {
      final DocumentSnapshot userDoc = await _firestore
          .collection("usuarios")
          .doc(_auth.currentUser!.uid)
          .get();

      if (userDoc.exists) {
        _usuarioLogueado = ModeloUsuario(
          documentID: _auth.currentUser!.uid,
          correo: userDoc.get("correo"),
          imagenPerfil: userDoc.get("imagen_perfil") ?? "",
          nick: userDoc.get("nick"),
          amigosId: List<String>.from(userDoc.get("amigos_ids") ?? []),
          peliculasCriticadas: List<int>.from(userDoc.get("peliculas_criticadas") ?? []),
          peliculasFavoritas: List<int>.from(userDoc.get("peliculas_favoritas") ?? []),
          peliculasVistas: List<int>.from(userDoc.get("peliculas_vistas") ?? []),
         
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error al actualizar usuario: $e');
    }
  }

  Future<void> verificarSesion() async {
    final user = _auth.currentUser;
    if (user != null) {
      _status = AuthStatus.autenticando;
      notifyListeners();

      try {
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
            amigosId: List<String>.from(userDoc.get("amigos_ids") ?? []),
            peliculasCriticadas: List<int>.from(userDoc.get("peliculas_criticadas") ?? []),
            peliculasFavoritas: List<int>.from(userDoc.get("peliculas_favoritas") ?? []),
            peliculasVistas: List<int>.from(userDoc.get("peliculas_vistas") ?? []),
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

}
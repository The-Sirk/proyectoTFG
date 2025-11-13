import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flixscore/modelos/usuario_modelo.dart";
import "package:flutter/material.dart";

enum RolesUsuario {
  usuario,
  administrador,
}

enum RegisterStatus { noRegistrado, registrado, registrando }

class RegisterProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ModeloUsuario? _usuarioRegistrado;
  ModeloUsuario? get usuarioRegistrado => _usuarioRegistrado;

  RegisterStatus _status = RegisterStatus.noRegistrado;
  RegisterStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isRegistered => _status == RegisterStatus.registrado && _usuarioRegistrado != null;

  Future<void> registroUsuario({
    required String email,
    required String password,
    required String username,
    required String repeatPassword,
    RolesUsuario rol = RolesUsuario.usuario,
  }) async {
    try {
      _status = RegisterStatus.registrando;
      _errorMessage = null;
      notifyListeners();

      // Validaciones
      if (username.isEmpty || email.isEmpty || password.isEmpty || repeatPassword.isEmpty) {
        throw Exception("Por favor, completa todos los campos");
      }

      if (password != repeatPassword) {
        throw Exception("Las contraseñas no coinciden");
      }

      if (password.length < 6) {
        throw Exception("La contraseña debe tener al menos 6 caracteres");
      }

      // Verificar si el email ya existe en Firestore
      final QuerySnapshot emailQuery = await _firestore
          .collection("usuarios")
          .where("correo", isEqualTo: email)
          .limit(1)
          .get();

      if (emailQuery.docs.isNotEmpty) {
        throw Exception("El correo ya está registrado");
      }

      // Verificar si el nick ya existe en Firestore
      final QuerySnapshot nickQuery = await _firestore
          .collection("usuarios")
          .where("nick", isEqualTo: username)
          .limit(1)
          .get();

      if (nickQuery.docs.isNotEmpty) {
        throw Exception("El nombre de usuario ya está en uso");
      }

      // Crear el usuario en FirebaseAuth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception("Error al crear el usuario");
      }

      final String userId = userCredential.user!.uid;

      // Crear el documento en Firestore
      await _firestore.collection("usuarios").doc(userId).set({
        "correo": email,
        "nick": username,
        "imagen_perfil": "",
        "amigos_ids": [],
        "peliculas_criticadas": [],
        "peliculas_favoritas": [],
        "peliculas_vistas": [],
      });

      // Crear el modelo de usuario
      _usuarioRegistrado = ModeloUsuario(
        documentID: userId,
        correo: email,
        imagenPerfil: "",
        nick: username,
        amigosId: [],
        peliculasCriticadas: [],
        peliculasFavoritas: [],
        peliculasVistas: [],
      );

      _status = RegisterStatus.registrado;
      _errorMessage = null;
      notifyListeners();

    } on FirebaseAuthException catch (e) {
      _status = RegisterStatus.noRegistrado;
      _usuarioRegistrado = null;

      if (e.code == 'email-already-in-use') {
        _errorMessage = "El correo ya está en uso";
      } else if (e.code == 'weak-password') {
        _errorMessage = "La contraseña es demasiado débil";
      } else if (e.code == 'invalid-email') {
        _errorMessage = "El correo no es válido";
      } else {
        _errorMessage = "Error de registro: ${e.message}";
      }

      notifyListeners();
      throw Exception(_errorMessage);

    } catch (e) {
      _status = RegisterStatus.noRegistrado;
      _usuarioRegistrado = null;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      throw Exception(_errorMessage);
    }
  }

  // Limpiar el estado después del registro
  void reset() {
    _usuarioRegistrado = null;
    _status = RegisterStatus.noRegistrado;
    _errorMessage = null;
    notifyListeners();
  }
}
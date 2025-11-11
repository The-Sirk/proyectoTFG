class ModeloUsuario {
  final String? documentID;
  final String correo;
  final String? imagenPerfil;
  final String nick;
  final List<String> amigosId;
  final List<int> peliculasCriticadas;
  final List<int> peliculasFavoritas;
  final List<int> peliculasVistas;

  ModeloUsuario({
    this.documentID,
    required this.correo,
    this.imagenPerfil,
    required this.nick,
    required this.amigosId,
    required this.peliculasCriticadas,
    required this.peliculasFavoritas,
    required this.peliculasVistas,
  });

  factory ModeloUsuario.fromJson(Map<String, dynamic> json) {
    return ModeloUsuario(
      documentID: json['documentID'] as String?,
      correo: json['correo'] as String,
      imagenPerfil: json['imagen_perfil'] as String?,
      nick: json['nick'] as String,
      // Conversión segura de List<dynamic> a los tipos esperados
      amigosId: List<String>.from(json['amigos_id'] as List),
      peliculasCriticadas: List<int>.from(json['peliculas_criticadas'] as List),
      peliculasFavoritas: List<int>.from(json['peliculas_favoritas'] as List),
      peliculasVistas: List<int>.from(json['peliculas_vistas'] as List),
    );
  }

  // Método para enviar datos a la API (POST/PUT)
  Map<String, dynamic> toMap() {
    return {
      'documentID': documentID,
      'correo': correo,
      'imagen_perfil': imagenPerfil,
      'nick': nick,
      'amigos_id': amigosId,
      'peliculas_criticadas': peliculasCriticadas,
      'peliculas_favoritas': peliculasFavoritas,
      'peliculas_vistas': peliculasVistas,
    };
  }

  ModeloUsuario copyWith({
    String? documentID,
    String? correo,
    String? imagenPerfil,
    String? nick,
    List<String>? amigosId,
    List<int>? peliculasCriticadas,
    List<int>? peliculasFavoritas,
    List<int>? peliculasVistas,
  }) {
    return ModeloUsuario(
      documentID: documentID ?? this.documentID,
      correo: correo ?? this.correo,
      imagenPerfil: imagenPerfil ?? this.imagenPerfil,
      nick: nick ?? this.nick,
      amigosId: amigosId ?? this.amigosId,
      peliculasCriticadas: peliculasCriticadas ?? this.peliculasCriticadas,
      peliculasFavoritas: peliculasFavoritas ?? this.peliculasFavoritas,
      peliculasVistas: peliculasVistas ?? this.peliculasVistas,
    );
  }
}
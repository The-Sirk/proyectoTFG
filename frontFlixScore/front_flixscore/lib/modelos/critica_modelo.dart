class ModeloCritica {
  final String usuarioUID;
  final int peliculaID;
  final int puntuacion;
  final String comentario;
  final String? documentID;
  final int? fechaCreacion;

  ModeloCritica({
    required this.usuarioUID,
    required this.peliculaID,
    required this.puntuacion,
    required this.comentario,
    this.documentID,
    this.fechaCreacion,
  });

  factory ModeloCritica.fromJson(Map<String, dynamic> json) {
    return ModeloCritica(
      usuarioUID: json['usuarioUID'] as String,
      peliculaID: json['peliculaID'] as int,
      puntuacion: json['puntuacion'] as int,
      comentario: json['comentario'] as String,
      documentID: json['documentID'] as String?,
      fechaCreacion: json['fechaCreacion'] as int?,
    );
  }

  // Método para enviar datos a la API (POST)
  Map<String, dynamic> toMap() {
    return {
      'usuarioUID': usuarioUID,
      'peliculaID': peliculaID,
      'puntuacion': puntuacion,
      'comentario': comentario,
      'fechaCreacion': fechaCreacion,
    };
  }
}
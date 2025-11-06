import 'dart:convert';

class ModeloPeliculaMedia {
  final int peliculaID;
  final double puntuacionMedia;

  ModeloPeliculaMedia({
    required this.peliculaID,
    required this.puntuacionMedia,
  });

  factory ModeloPeliculaMedia.fromJson(Map<String, dynamic> json) {
    return ModeloPeliculaMedia(
      peliculaID: json['peliculaID'] as int,
      puntuacionMedia: (json['puntuacionMedia'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'peliculaID': peliculaID,
      'puntuacionMedia': puntuacionMedia,
    };
  }

  factory ModeloPeliculaMedia.fromJsonString(String source) =>
      ModeloPeliculaMedia.fromJson(json.decode(source) as Map<String, dynamic>);
}
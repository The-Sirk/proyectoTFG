class ModeloPelicula {
  final int id;
  final String titulo;
  final String tituloOriginal;
  final String resumen;
  final String fechaEstreno;
  final double popularidad;
  final double puntucionMedia;
  final int recuentoVotos;
  final String? rutaPoster; 
  final String? rutaFondo; 
  final String idiomaOriginal;
  final List<int> generosIds;

  ModeloPelicula({
    required this.id,
    required this.titulo,
    required this.tituloOriginal,
    required this.resumen,
    required this.fechaEstreno,
    required this.popularidad,
    required this.puntucionMedia,
    required this.recuentoVotos,
    this.rutaPoster,
    this.rutaFondo,
    required this.idiomaOriginal,
    required this.generosIds,
  });

  factory ModeloPelicula.fromJson(Map<String, dynamic> json) {
    return ModeloPelicula(
      id: json['id'] as int,
      titulo: json['titulo'] as String,
      tituloOriginal: json['tituloOriginal'] as String,
      resumen: json['resumen'] as String,
      fechaEstreno: json['fechaEstreno'] as String,
      popularidad: (json['popularidad'] as num).toDouble(),
      puntucionMedia: (json['puntucionMedia'] as num).toDouble(),
      recuentoVotos: json['recuentoVotos'] as int,
      rutaPoster: json['rutaPoster'] as String?, 
      rutaFondo: json['rutaFondo'] as String?,
      idiomaOriginal: json['idiomaOriginal'] as String,
      generosIds: json['generosIds'] != null
        ? List<int>.from(json['generosIds'] as List)
        : <int>[],
    );
  }
}
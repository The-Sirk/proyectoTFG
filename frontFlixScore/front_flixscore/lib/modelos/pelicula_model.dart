class Pelicula {

  final int id;
  final String titulo;
  final String resumen;
  final String fechaEstreno;
  final String rutaPoster;

  const Pelicula({
    required this.id,
    required this.titulo,
    required this.resumen,
    required this.fechaEstreno,
    required this.rutaPoster,
  });

  factory Pelicula.fromJson(Map<String, dynamic> json) {
    return Pelicula(
      id: json['id'] ?? 0,
      titulo: json['titulo'] ?? '',
      resumen: json['resumen'] ?? '',
      fechaEstreno: json['fechaEstreno'] ?? '',
      rutaPoster: json['rutaPoster'] ?? '',
    );
  }

}

class Amigo {
  final String nombre;
  final String? imagenPerfil;
  final String? documentID;
  final int amigosEnComun;
  final bool yaEsMiAmigo;

  Amigo({
    required this.nombre,
    this.imagenPerfil,
    this.documentID,
    this.amigosEnComun = 0,
    this.yaEsMiAmigo = false,
  });
}
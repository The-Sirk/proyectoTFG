import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flixscore/service/api_service.dart';
import 'package:flixscore/modelos/usuario_modelo.dart';

class FotoPerfilCualquierUsuario extends StatelessWidget {
  final String usuarioId;
  
  const FotoPerfilCualquierUsuario({required this.usuarioId});
  
  static const double _tamanioFoto = 108.0;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ModeloUsuario>(
      future: ApiService().getUsuarioByID(usuarioId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text("Error al cargar perfil.", style: TextStyle(color: Colors.red)));
        } else if (snapshot.hasData) {
          final usuario = snapshot.data!;
          final nick = usuario.nick;
          final urlImagen = usuario.imagenPerfil ?? "";
          final inicial = nick.isNotEmpty ? nick[0].toUpperCase() : '?';
          final urlFallback = "https://dummyimage.com/100x100/333333/aaaaaa.png&text=$inicial";
          final urlActual = urlImagen.isNotEmpty ? urlImagen : urlFallback;
          
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1C25),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Imagen de Perfil",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                const Divider(height: 20, color: Color(0xFF333333)),
                const SizedBox(height: 5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: _tamanioFoto,
                      height: _tamanioFoto,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF333333), width: 2),
                        ),
                        child: CircleAvatar(
                          radius: _tamanioFoto / 2,
                          backgroundColor: Colors.grey.shade700,
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: urlActual,
                              width: _tamanioFoto - 4,
                              height: _tamanioFoto - 4,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => const Center(
                                child: SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.cyan),
                                ),
                              ),
                              errorWidget: (_, __, ___) => Center(
                                child: Text(
                                  inicial,
                                  style: const TextStyle(
                                      fontSize: 55,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nick,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          );
        } else {
          return const Center(child: Text("Usuario no encontrado."));
        }
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Widget que representa un único amigo en la lista
class AmigoListItem extends StatelessWidget {
  final String nombre;
  final int amigosEnComun;
  final String? imagenPerfil;
  final VoidCallback onQuitarAmigo; // Callback para la acción de "Quitar amigo"

  const AmigoListItem({
    super.key,
    required this.nombre,
    required this.amigosEnComun,
    this.imagenPerfil,
    required this.onQuitarAmigo,
  });

  static const Color primaryTextColor = Colors.white;
  static const Color secondaryTextColor = Color(0xFFAAAAAA);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // Espacio para la foto de perfil del amigo (usaremos un icono de persona por ahora)
          CircleAvatar(
            backgroundColor: Colors.grey.shade700,
            backgroundImage: imagenPerfil != null
                ? CachedNetworkImageProvider(imagenPerfil!)
                : null,
            child: imagenPerfil == null
                ? Text(
                    nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),

          // Nombre y Amigos en Común
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    color: primaryTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  amigosEnComun == 1
                      ? '$amigosEnComun amigo en común'
                      : '$amigosEnComun amigos en común',
                  style: const TextStyle(
                    color: secondaryTextColor,
                    fontSize: 12,
                  ),
                )
              ],
            ),
          ),

          // Botón/Icono de Quitar Amigo
          InkWell(
            onTap: onQuitarAmigo,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.transparent, // Transparente para que solo se vea el icono
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.person_remove_outlined, // Icono para 'quitar amigo'
                color: secondaryTextColor,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 10.0),
        ],
      ),
    );
  }
}
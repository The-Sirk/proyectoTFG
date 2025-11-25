import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AmigoListItem extends StatelessWidget {
  final String nombre;
  final int amigosEnComun;
  final String? imagenPerfil;
  final VoidCallback onQuitarAmigo;
  final VoidCallback onTapPerfil;

  const AmigoListItem({
    super.key,
    required this.nombre,
    required this.amigosEnComun,
    this.imagenPerfil,
    required this.onQuitarAmigo,
    required this.onTapPerfil,
  });

  static const Color primaryTextColor = Colors.white;
  static const Color secondaryTextColor = Color(0xFFAAAAAA);

  @override
  Widget build(BuildContext context) {
    return Material( 
      color: Colors.transparent,
      child: InkWell(
        onTap: onTapPerfil,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Colors.grey.shade700,
                backgroundImage: (imagenPerfil?.isNotEmpty ?? false)
                    ? CachedNetworkImageProvider(imagenPerfil!)
                    : null,
                child: (imagenPerfil?.isEmpty ?? true)
                    ? Text(
                        nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w100,
                          fontSize: 20,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
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
              // Botón separado: NO abre el perfil
              IconButton(
                onPressed: onQuitarAmigo,
                icon: const Icon(
                  Icons.person_remove_outlined,
                  color: secondaryTextColor,
                  size: 24,
                ),
                tooltip: 'Eliminar amigo',
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}
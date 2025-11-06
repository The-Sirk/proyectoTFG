import 'package:flixscore/componentes/common/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PerfilUsuarioCard extends StatelessWidget {
  final String nickUsuario;
  final String emailUsuario;
  final String? urlImagen;
  final VoidCallback? onImageTap;

  const PerfilUsuarioCard({
    Key? key,
    required this.nickUsuario,
    required this.emailUsuario,
    required this.urlImagen,
    this.onImageTap,
  }) : super(key: key);

  static const Color cardBackgroundColor = Color(0xFF1A1C25); 
  static const Color primaryTextColor = Colors.white;
  static const Color secondaryTextColor = Color(0xFFAAAAAA); 
  static const Color dividerColor = Color(0xFF333333);
  static const Color borderColor = Colors.cyan;
  static const double avatarRadius = 52.0; 

  @override
  Widget build(BuildContext context) {
    final String safeUrl = urlImagen ?? "https://placeholder.com/100x100?text=Avatar";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
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
        mainAxisSize: MainAxisSize.min, 
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sección superior: Título y Subtítulo
          const Text(
            "Foto de Perfil",
            style: TextStyle(
              color: primaryTextColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Tu avatar se genera automáticamente basado en tu nick",
            style: TextStyle(
              color: secondaryTextColor,
              fontSize: 14,
            ),
          ),
          
          const SizedBox(height: 19),
          const Divider(height: 20, color: dividerColor), 
          const SizedBox(height: 19),
          
          // Sección inferior: Avatar y Datos de Usuario
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector( 
                onTap: () { 
                  mostrarSnackBarError(context, "Aquí se abriría el menú de selección"); 
                },
                child: SizedBox(
                  // Tamaño fijo para el área sensible al tacto
                  width: avatarRadius * 2 + 4, 
                  height: avatarRadius * 2 + 4,
                  child: Stack( 
                    children: [
                      // Avatar
                      Container(
                        padding: const EdgeInsets.all(2.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: dividerColor,
                            width: 2.0,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: avatarRadius,
                          backgroundColor: Colors.grey.shade700, 
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: safeUrl, 
                              width: avatarRadius * 2, 
                              height: avatarRadius * 2,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: SizedBox(
                                  width: 50, height: 50, child: CircularProgressIndicator(strokeWidth: 2, color: borderColor)
                                )
                              ),
                              errorWidget: (context, url, error) => Center(
                                child: Text(
                                    nickUsuario.isNotEmpty ? nickUsuario[0].toUpperCase() : '?',
                                    style: const TextStyle(fontSize: 55, fontWeight: FontWeight.bold, color: primaryTextColor)
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Icono del Lápiz
                      Positioned(
                        bottom: 5,
                        right: 5,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: dividerColor, 
                            shape: BoxShape.circle,
                            border: Border.all(color: secondaryTextColor, width: 1),
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 12,
                            color: primaryTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Espacio de separación y Nick/Email
              const SizedBox(width: 20),
              
              // Datos de Usuario
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nickUsuario,
                    style: const TextStyle(
                      color: primaryTextColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    emailUsuario,
                    style: const TextStyle(
                      color: secondaryTextColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
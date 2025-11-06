import 'package:flutter/material.dart';

// Widget que representa un único amigo en la lista
class AmigoListItem extends StatelessWidget {
  final String nombre;
  final int amigosEnComun;
  final VoidCallback onQuitarAmigo; // Callback para la acción de "Quitar amigo"

  const AmigoListItem({
    super.key,
    required this.nombre,
    required this.amigosEnComun,
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
          const Icon(
            Icons.person_pin,
            color: Color(0xFF1F2937),
            size: 40,
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
                  '$amigosEnComun amigos en común',
                  style: const TextStyle(
                    color: secondaryTextColor,
                    fontSize: 14,
                  ),
                ),
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
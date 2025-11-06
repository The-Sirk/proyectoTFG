import 'package:flutter/material.dart';
import 'comunes/amigo_item.dart';
import 'package:flixscore/componentes/common/snack_bar.dart';

// Modelo de datos simple para un amigo
class Amigo {
  final String nombre;
  final int amigosEnComun;
  Amigo({required this.nombre, required this.amigosEnComun});
}

// Tarjeta que contiene el listado de amigos
class ListaAmigosCard extends StatelessWidget {
  final List<Amigo> amigos;
  final double maxHeight; 

  const ListaAmigosCard({
    super.key,
    required this.amigos,
    this.maxHeight = 350,
  });

  static const Color cardBackgroundColor = Color(0xFF1A1C25); 
  static const Color primaryTextColor = Colors.white;
  static const Color secondaryTextColor = Color(0xFFAAAAAA);
  static const Color dividerColor = Color(0xFF333333);
  static const Color countBadgeColor = Color(0xFF1F2937);
  static const Color accentColor = Color(0xFFEF4444);


  // Función para mostrar el diálogo de confirmación
  Future<bool?> _mostrarDialogoConfirmacion(BuildContext context, String nombreAmigo) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: cardBackgroundColor,
          title: const Text(
            'Confirmar Eliminación',
            style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold),
          ),
          content: Text(
            '¿Estás seguro de que quieres dejar de seguir a $nombreAmigo?',
            style: const TextStyle(color: secondaryTextColor),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancelar',
                style: TextStyle(color: secondaryTextColor),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text(
                'Confirmar',
                style: TextStyle(color: accentColor, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
          // Encabezado de la tarjeta
          Row(
            children: [
              const Text(
                "Mis Amigos",
                style: TextStyle(
                  color: primaryTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              // Badge con el número de amigos
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: countBadgeColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  amigos.length.toString(),
                  style: const TextStyle(
                    color: primaryTextColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Subtítulo
          const Text(
            "Personas que sigues",
            style: TextStyle(
              color: secondaryTextColor,
              fontSize: 14,
            ),
          ),
          
          const Divider(height: 20, color: dividerColor),
          
          // Listado de Amigos usando ListView.builder
          SizedBox(
            height: 275, // Espacio en vertical máximo que va a ocupar el listview
            child: ListView.builder(
              shrinkWrap: true, // Ajusta su altura al contenido (hasta maxHeight)
              itemCount: amigos.length,
              itemBuilder: (context, index) {
                final amigo = amigos[index];
                return AmigoListItem(
                  nombre: amigo.nombre,
                  amigosEnComun: amigo.amigosEnComun,
                  // Se envuelve la lógica en un Future para manejar el diálogo asíncrono
                  onQuitarAmigo: () async {
                    // Muestra el diálogo y espera la respuesta (true/false)
                    final confirmado = await _mostrarDialogoConfirmacion(context, amigo.nombre);

                    // Si la respuesta es true, procede con la "eliminación"
                    if (confirmado == true) {
                      // TODO: Implementar la lógica real para quitar amigo

                      mostrarSnackBarExito(context, "${amigo.nombre} eliminado/a con éxito");
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
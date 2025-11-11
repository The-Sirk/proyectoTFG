import 'package:flutter/material.dart';
import 'comunes/amigo_item.dart';
import 'package:flixscore/componentes/common/snack_bar.dart';
import 'package:flixscore/modelos/amigo_modelo.dart';
import 'package:flixscore/service/api_service.dart';

class ListaAmigosCard extends StatefulWidget {
  final List<Amigo> amigos;
  final double maxHeight;
  final String usuarioId;
  final Function(String) onAmigoEliminado;

  const ListaAmigosCard({
    super.key,
    required this.amigos,
    this.maxHeight = 350,
    required this.usuarioId,
    required this.onAmigoEliminado,
  });

  static const Color cardBackgroundColor = Color(0xFF1A1C25);
  static const Color primaryTextColor = Colors.white;
  static const Color secondaryTextColor = Color(0xFFAAAAAA);
  static const Color dividerColor = Color(0xFF333333);
  static const Color countBadgeColor = Color(0xFF1F2937);
  static const Color accentColor = Color(0xFFEF4444);

  @override
  State<ListaAmigosCard> createState() => _ListaAmigosCardState();
}

class _ListaAmigosCardState extends State<ListaAmigosCard> {
  final ApiService _apiService = ApiService();

  Future<bool?> _mostrarDialogoConfirmacion(BuildContext context, String nombreAmigo) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ListaAmigosCard.cardBackgroundColor,
          title: const Text(
            'Confirmar Eliminación',
            style: TextStyle(color: ListaAmigosCard.primaryTextColor, fontWeight: FontWeight.bold),
          ),
          content: Text(
            '¿Estás seguro de que quieres dejar de seguir a $nombreAmigo?',
            style: const TextStyle(color: ListaAmigosCard.secondaryTextColor),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancelar',
                style: TextStyle(color: ListaAmigosCard.secondaryTextColor),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text(
                'Confirmar',
                style: TextStyle(color: ListaAmigosCard.accentColor, fontWeight: FontWeight.bold),
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
        color: ListaAmigosCard.cardBackgroundColor,
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
          Row(
            children: [
              const Text(
                "Mis Amigos",
                style: TextStyle(
                  color: ListaAmigosCard.primaryTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ListaAmigosCard.countBadgeColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  widget.amigos.length.toString(),
                  style: const TextStyle(
                    color: ListaAmigosCard.primaryTextColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            "Personas que sigues",
            style: TextStyle(
              color: ListaAmigosCard.secondaryTextColor,
              fontSize: 14,
            ),
          ),
          const Divider(height: 20, color: ListaAmigosCard.dividerColor),
          SizedBox(
            height: 275,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.amigos.length,
              itemBuilder: (context, index) {
                final amigo = widget.amigos[index];
                return AmigoListItem(
                  nombre: amigo.nombre,
                  amigosEnComun: amigo.amigosEnComun,
                  imagenPerfil: amigo.imagenPerfil, // ✅ Nueva línea
                  onQuitarAmigo: () async {
                    final confirmado = await _mostrarDialogoConfirmacion(context, amigo.nombre);
                    if (confirmado != true) return;

                    try {
                      final amigosEncontrados = await _apiService.getByNick(amigo.nombre);
                      if (amigosEncontrados.isEmpty) {
                        mostrarSnackBarError(context, "No se encontró al usuario");
                        return;
                      }
                      final amigoUsuario = amigosEncontrados.first;
                      if (amigoUsuario.documentID == null) {
                        mostrarSnackBarError(context, "El amigo no tiene ID válido");
                        return;
                      }

                      await _apiService.eliminarAmigo(widget.usuarioId, amigoUsuario.documentID!);

                      setState(() {
                        widget.amigos.removeAt(index);
                      });

                      widget.onAmigoEliminado(amigo.nombre);

                      mostrarSnackBarExito(context, "${amigo.nombre} eliminado de tus amigos");
                    } catch (e) {
                      mostrarSnackBarError(context, "Error al eliminar amigo: ${e.toString().split(':').last.trim()}");
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
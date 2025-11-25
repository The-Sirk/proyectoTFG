import 'package:flixscore/paginas/perfil_amigo_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'components/amigo_item.dart';
import 'package:flixscore/modelos/amigo_modelo.dart';
import 'package:flixscore/service/api_service.dart';
import 'package:flixscore/controllers/login_provider.dart';
import 'package:flixscore/componentes/common/snack_bar.dart';

class ListaAmigosCard extends StatefulWidget {
  final String usuarioId;
  final List<Amigo> amigosConComunes;

  const ListaAmigosCard({
    super.key,
    required this.usuarioId,
    required this.amigosConComunes,
  });

  @override
  State<ListaAmigosCard> createState() => _ListaAmigosCardState();
}

class _ListaAmigosCardState extends State<ListaAmigosCard> {
  late List<Amigo> _amigos;

  @override
  void initState() {
    super.initState();
    _amigos = List.from(widget.amigosConComunes);
  }

  @override
  void didUpdateWidget(covariant ListaAmigosCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.amigosConComunes != oldWidget.amigosConComunes) {
      _amigos = List.from(widget.amigosConComunes);
    }
  }

  // Método de eliminacion de amigos
  Future<void> _confirmarYEliminarAmigo(Amigo amigo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1C25),
        title: const Text('¿Dejar de seguir?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('¿Deseas dejar de seguir a ${amigo.nombre}?',
            style: const TextStyle(color: Color(0xFFAAAAAA))),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFFAAAAAA))),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed != true || amigo.documentID == null) return;

    try {
      final api = ApiService();
      await api.eliminarAmigo(widget.usuarioId, amigo.documentID!);
      final provider = Provider.of<LoginProvider>(context, listen: false);
      provider.actualizarAmigosId(
        provider.usuarioLogueado!.amigosId.where((id) => id != amigo.documentID).toList(),
      );
      mostrarSnackBarExito(context, 'Ya no sigues a ${amigo.nombre}');
      setState(() {
        _amigos.remove(amigo);
      });
    } catch (_) {
      mostrarSnackBarError(context, 'No hemos podido eliminar a ${amigo.nombre}, inténtalo mas tarde.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Encabezado ---
          Row(
            children: [
              const Text(
                "Mis Amigos",
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2937),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _amigos.length.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text("Personas que sigues", style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 14)),
          const Divider(height: 20, color: Color(0xFF333333)),

          // --- Contenido con Altura Fija ---
          SizedBox(
            height: 275, // Altura fija que queremos mantener
            child: _amigos.isEmpty
                ? const Center(
                    child: Text(
                      "No tienes amigos agregados.",
                      style: TextStyle(color: Color(0xFFAAAAAA)),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _amigos.length,
                    itemBuilder: (_, i) {
                      final a = _amigos[i];
                      return GestureDetector(
                        key: ValueKey(a.documentID),
                        child: AmigoListItem(
                          key: ValueKey(a.documentID),
                          nombre: a.nombre,
                          amigosEnComun: a.amigosEnComun,
                          imagenPerfil: a.imagenPerfil,
                          onQuitarAmigo: () => _confirmarYEliminarAmigo(a),
                          onTapPerfil: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PerfilAmigoPage(
                                usuarioId: a.documentID!,
                                nickUsuario: a.nombre,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
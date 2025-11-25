import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flixscore/service/api_service.dart';
import 'package:flixscore/modelos/amigo_modelo.dart';
import 'package:flixscore/controllers/login_provider.dart';
import 'components/amigo_de_otro_item.dart';

const Color cardBackgroundColor = Color(0xFF1A1C25); 
const Color primaryTextColor = Colors.white;
const Color secondaryTextColor = Color(0xFFAAAAAA); 
const Color dividerColor = Color(0xFF333333);
const Color errorColor = Colors.redAccent;
const Color colorResaltado = Colors.cyanAccent;

// Amigos del perfil que estoy visitando con botón + si no es mi amigo todavía
class AmigosDeOtroCard extends StatefulWidget {
  final String userId;
  const AmigosDeOtroCard({super.key, required this.userId});

  @override
  State<AmigosDeOtroCard> createState() => _AmigosDeOtroCardState();
}

class _AmigosDeOtroCardState extends State<AmigosDeOtroCard> {
  late Future<_Datos> _datosFuture;
  final ApiService _api = ApiService();

  @override
  void initState() {
    super.initState();
    _datosFuture = _cargarDatos();
  }

  Future<_Datos> _cargarDatos() async {
    final usuario = await _api.getUsuarioByID(widget.userId);
    final ids = usuario.amigosId;
    final misIds = Provider.of<LoginProvider>(context, listen: false).usuarioLogueado?.amigosId.toSet() ?? {};

    final usuarios = await Future.wait(ids.map((id) => _api.getUsuarioByID(id)));
    final amigos = usuarios.map((u) {
      return Amigo(
        nombre: u.nick,
        imagenPerfil: u.imagenPerfil,
        documentID: u.documentID,
        amigosEnComun: 0,
        yaEsMiAmigo: misIds.contains(u.documentID),
      );
    }).toList();

    return _Datos(nick: usuario.nick, amigos: amigos);
  }

  @override
  Widget build(BuildContext context) {

    return Consumer<LoginProvider>(
      builder: (_, __, ___) => FutureBuilder<_Datos>(
        future: _datosFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: colorResaltado));
          }
          if (snap.hasError) {
            return Center(child: Text('Error al cargar amigos', style: TextStyle(color: errorColor)));
          }
          final datos = snap.data!;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: cardBackgroundColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(.2), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Amigos de ${datos.nick}', style: const TextStyle(color: primaryTextColor, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Pulsa + para agregarlos tu también', style: TextStyle(color: secondaryTextColor, fontSize: 14)),
                const Divider(height: 20, color: dividerColor),
                if (datos.amigos.isEmpty)
                  const Center(
                    child: Text(
                      'Sin amigos todavía',
                      style: TextStyle(
                        color: secondaryTextColor
                      )
                    )
                  )
                else
                  SizedBox(
                    height: 508,
                    child: ListView.separated(
                      itemCount: datos.amigos.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => AmigoDeOtroItem(amigo: datos.amigos[i]),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Datos {
  final String nick;
  final List<Amigo> amigos;
  _Datos({required this.nick, required this.amigos});
}
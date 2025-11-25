import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flixscore/controllers/login_provider.dart';
import 'package:flixscore/modelos/amigo_modelo.dart';
import 'package:flixscore/paginas/perfil_amigo_page.dart';

class AmigoDeOtroItem extends StatelessWidget {
  final Amigo amigo;
  const AmigoDeOtroItem({super.key, required this.amigo});

  static const Color secondaryTextColor = Color(0xFFAAAAAA);

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    final miId = loginProvider.usuarioLogueado?.documentID;
    final esMiPerfil = amigo.documentID == miId;
    final yaEsAmigo = loginProvider.usuarioLogueado?.amigosId.contains(amigo.documentID) ?? false;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: (esMiPerfil) ? null : () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PerfilAmigoPage(
              usuarioId: amigo.documentID!,
              nickUsuario: amigo.nombre,
            ),
          ),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Colors.grey.shade700,
                backgroundImage: (amigo.imagenPerfil?.isNotEmpty ?? false)
                    ? CachedNetworkImageProvider(amigo.imagenPerfil!)
                    : null,
                child: (amigo.imagenPerfil?.isEmpty ?? true)
                    ? Text(
                        amigo.nombre.isNotEmpty ? amigo.nombre[0].toUpperCase() : '?',
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
                      amigo.nombre,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      esMiPerfil
                          ? 'Tú'
                          : yaEsAmigo
                              ? 'Ya es tu amigo'
                              : 'Aún lo lo sigues',
                      style: const TextStyle(color: secondaryTextColor, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (!esMiPerfil && !yaEsAmigo) ...[
                IconButton(
                  icon: const Icon(Icons.person_add_outlined, color: secondaryTextColor),
                  tooltip: 'Agregar amigo',
                  onPressed: () => _agregar(context),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _agregar(BuildContext context) async {
    await Provider.of<LoginProvider>(context, listen: false)
        .buscarYAgregarAmigo(context, amigo.nombre);
  }
}
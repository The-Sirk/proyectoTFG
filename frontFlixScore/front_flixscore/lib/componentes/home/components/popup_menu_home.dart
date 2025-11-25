import 'package:flixscore/service/admin_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flixscore/controllers/login_provider.dart';
import 'package:flixscore/paginas/home_page.dart';
import 'package:flixscore/paginas/admin_page.dart';
import 'package:flixscore/paginas/login_page.dart';
import 'package:flixscore/paginas/perfil_usuario_page.dart';

enum AppBarMenuOption { verPerfil, administracion, cerrarSesion }

class AppBarPopupMenu extends StatelessWidget {
  const AppBarPopupMenu({super.key});

  void _onSelected(BuildContext context, AppBarMenuOption item) {
    switch (item) {
      case AppBarMenuOption.verPerfil:
        Navigator.push(context,
          MaterialPageRoute(builder: (_) => const PerfilUsuario()),
        );
        break;
      case AppBarMenuOption.administracion:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminUsuariosPage()),
        );
        break;
      case AppBarMenuOption.cerrarSesion:
        Provider.of<LoginProvider>(context, listen: false).logout();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AppBarMenuOption>(
      tooltip: 'Navegación',
      onSelected: (item) => _onSelected(context, item),
      icon: CircleAvatar(
        radius: 27,
        backgroundColor: const Color(0xFF0A0E1A),
        child: ClipOval(
          child: Image.network(
            Provider.of<LoginProvider>(context).usuarioLogueado?.imagenPerfil ?? '',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white),
          ),
        ),
      ),
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: AppBarMenuOption.verPerfil,
          child: Row(
            children: [
              Icon(Icons.person_2_outlined, color: Colors.blue),
              SizedBox(width: 8),
              Text('Ver mi perfil'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: AppBarMenuOption.administracion,
          child: Row(
            children: [
              Icon(Icons.shield_outlined, color: Colors.blue),
              SizedBox(width: 8),
              Text('Administración'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: AppBarMenuOption.cerrarSesion,
          child: Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 8),
              Text('Cerrar Sesión'),
            ],
          ),
        ),
      ],
    );
  }
}
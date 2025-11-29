import 'package:flixscore/paginas/admin_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flixscore/controllers/login_provider.dart';
import 'package:flixscore/paginas/perfil_usuario_page.dart';

enum AppBarMenuOption { verPerfil, administracion, cerrarSesion }

class AppBarPopupMenu extends StatelessWidget {
  const AppBarPopupMenu({super.key});

  void _onSelected(BuildContext context, AppBarMenuOption item) {
    switch (item) {
      case AppBarMenuOption.verPerfil:
        Navigator.push(
          context,
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
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lógica para determinar si el usuario es administrador
    final loginProvider = Provider.of<LoginProvider>(context);
    final bool esAdmin = loginProvider.usuarioLogueado?.esAdmin ?? false;

    // Construcción de la lista de elementos del menú condicionalmente
    final List<PopupMenuEntry<AppBarMenuOption>> menuItems = [
      const PopupMenuItem(
        key: Key('menuitem_verPerfil'),
        value: AppBarMenuOption.verPerfil,
        child: Row(
          children: [
            Icon(Icons.person_2_outlined, color: Colors.blue),
            SizedBox(width: 8),
            Text('Ver mi perfil'),
          ],
        ),
      ),
    ];

    // Se añade la opción de Administración solo si es administrador
    if (esAdmin) {
      menuItems.add(
        const PopupMenuItem(
          key: Key('menuitem_administracion'),
          value: AppBarMenuOption.administracion,
          child: Row(
            children: [
              Icon(Icons.shield_outlined, color: Colors.blue),
              SizedBox(width: 8),
              Text('Administración'),
            ],
          ),
        ),
      );
    }

    // Se añade la opción de Cerrar Sesión
    menuItems.add(
      const PopupMenuItem(
        key: Key('menuitem_cerrarSesion'),
        value: AppBarMenuOption.cerrarSesion,
        child: Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 8),
            Text('Cerrar Sesión'),
          ],
        ),
      ),
    );

    return PopupMenuButton<AppBarMenuOption>(
      key: const Key('menu_perfil'),
      tooltip: 'Navegación',
      onSelected: (item) => _onSelected(context, item),
      icon: Builder(
        builder: (context) {
          final String urlImagen = loginProvider.usuarioLogueado?.imagenPerfil ?? '';
          final String? nickUsuario = loginProvider.usuarioLogueado?.nick;
          final String inicial = nickUsuario != null && nickUsuario.isNotEmpty
              ? nickUsuario[0].toUpperCase()
              : '?'; 
          const double radioAvatar = 28;
          const double tamanoFuente = radioAvatar * 1.2;
          final Widget fallbackWidget = Center(
            child: Text(
              inicial,
              style: const TextStyle(
                fontSize: tamanoFuente, 
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          );
          Widget childWidget;
          if (urlImagen.isEmpty) {
            childWidget = fallbackWidget;
          } else {
            childWidget = ClipOval(
              child: Image.network(
                urlImagen,
                fit: BoxFit.cover,
                cacheWidth: 150,
                errorBuilder: (_, __, ___) => fallbackWidget,
              ),
            );
          }
          return CircleAvatar(
            radius: radioAvatar,
            backgroundColor: const Color(0xFF333333),
            child: childWidget,
          );
        }
      ),
      itemBuilder: (_) => menuItems,
    );
  }
}

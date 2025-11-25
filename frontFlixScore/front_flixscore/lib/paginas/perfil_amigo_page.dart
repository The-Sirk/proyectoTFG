import 'package:flixscore/componentes/perfil_de_otro/amigos_de_otro_card.dart';
import 'package:flixscore/componentes/perfil_de_otro/estadisticas_otro_card.dart';
import 'package:flixscore/componentes/perfil_de_otro/imagen_perfil_otro_card.dart';
import 'package:flixscore/paginas/admin_page.dart';
import 'package:flixscore/paginas/home_page.dart';
import 'package:flixscore/paginas/login_page.dart';
import 'package:flixscore/paginas/perfil_usuario_page.dart';
import 'package:flutter/material.dart';
import 'package:flixscore/modelos/usuario_modelo.dart';
import 'package:flixscore/service/api_service.dart';
import 'package:flixscore/componentes/perfil_usuario/mis_criticas_card.dart';
import 'package:flixscore/controllers/login_provider.dart';
import 'package:provider/provider.dart';

enum MenuOption { navegarAHome, verPerfilPropio, administracion, cerrarSesion}

class PerfilAmigoPage extends StatelessWidget {
  final String usuarioId;
  final String nickUsuario;

  const PerfilAmigoPage({
    super.key,
    required this.usuarioId,
    required this.nickUsuario,
  });

  Future<ModeloUsuario> _cargarUsuario() async {
    return await ApiService().getUsuarioByID(usuarioId);
  }

  @override
  Widget build(BuildContext context) {

    const Color appBarColor = Color(0xFF111827); 
    const Color backgroundPage = Color(0xFF0A0E1A);

    // Lógica para manejar la selección del menú
    void onMenuItemSelected(MenuOption item) {
      switch (item) {
        // Vamos al home
        case MenuOption.navegarAHome:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
          );
          break;

        // Vamos al perfil
        case MenuOption.verPerfilPropio:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PerfilUsuario(),
            ),
          );
          break;

        // Vamos a administración
        case MenuOption.administracion:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminUsuariosPage()),
          );
          break;

        // Cerramos sesión
        case MenuOption.cerrarSesion:
          Provider.of<LoginProvider>(context, listen: false).logout();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
          break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Perfil de $nickUsuario"),
        automaticallyImplyLeading: true,
        toolbarHeight: 80,
        backgroundColor: appBarColor,
        actions: [

          // Menú Desplegable
          PopupMenuButton<MenuOption>(
            tooltip: 'Menú',                
            onSelected: onMenuItemSelected,
            icon: const Icon(Icons.more_vert, color: Colors.white),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<MenuOption>>[

              // Navegar al Home
              PopupMenuItem<MenuOption>(
                value: MenuOption.navegarAHome,
                child: Row(
                  children: const [
                    Icon(Icons.house_outlined, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Ir a principal'),
                  ],
                ),
              ),

              // A administración
              PopupMenuItem<MenuOption>(
                value: MenuOption.administracion,
                child: Row(
                  children: [
                    Icon(Icons.shield_outlined, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Administración'),
                  ],
                ),
              ),

              // Ver Perfil Propio
              PopupMenuItem<MenuOption>(
                value: MenuOption.verPerfilPropio,
                child: Row(
                  children: const [
                    Icon(Icons.person_2_outlined, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Ver mi perfil'),
                  ],
                ),
              ),

              //Cerrar Sesión
              PopupMenuItem<MenuOption>(
                value: MenuOption.cerrarSesion,
                child: Row(
                  children: const [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Cerrar Sesión'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 15),
        ],
      ),
      backgroundColor: backgroundPage,
      body: FutureBuilder<ModeloUsuario>(
        future: _cargarUsuario(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final usuario = snapshot.data!;

          return LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 600;

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: isSmall
                      ? _buildOneColumnLayout(usuario)
                      : _buildTwoColumnLayout(usuario),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildOneColumnLayout(
    ModeloUsuario usuario,
  ) {
    return Column(
      children: [
        FotoPerfilCualquierUsuario(usuarioId: usuarioId),
        const SizedBox(height: 10),
        EstadisticasAmigoCard(idAmigo: usuarioId),
        MisCriticasCard(usuarioId: usuarioId, editable: false),
        AmigosDeOtroCard(userId: usuarioId),
      ]
    );
  }

  Widget _buildTwoColumnLayout(
    ModeloUsuario usuario,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 6,
          child: Column(
            children: [
              FotoPerfilCualquierUsuario(usuarioId: usuarioId),
              const SizedBox(height: 16),
              MisCriticasCard(usuarioId: usuarioId, editable: false),
            ],
          ),
        ),
        Expanded(
          flex: 4,
          child: Column(
            children: [
              EstadisticasAmigoCard(idAmigo: usuarioId),
              const SizedBox(height: 15,),
              AmigosDeOtroCard(userId: usuarioId),
            ],
          ),
        ),
      ],
    );
  }
}
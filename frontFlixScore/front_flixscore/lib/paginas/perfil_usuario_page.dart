import 'package:flutter/material.dart';
import 'package:flixscore/service/api_service.dart';
import 'package:flixscore/modelos/usuario_modelo.dart';
import 'package:flixscore/modelos/amigo_modelo.dart';
import 'package:flixscore/componentes/common/tab_button.dart';
import 'package:flixscore/componentes/perfil_usuario/estadisticas_card.dart';
import 'package:flixscore/componentes/perfil_usuario/lista_amigos_card.dart';
import 'package:flixscore/componentes/common/snack_bar.dart';
import 'package:flixscore/componentes/perfil_usuario/foto_perfil_card.dart';
import 'package:flixscore/componentes/perfil_usuario/informacion_basica_card.dart';
import 'package:flixscore/componentes/perfil_usuario/buscar_usuario_card.dart';

class PerfilUsuario extends StatefulWidget {
  const PerfilUsuario({super.key});

  @override
  State<PerfilUsuario> createState() => _PerfilUsuarioState();
}

class _PerfilUsuarioState extends State<PerfilUsuario> {
  final double _kTabletBreakpoint = 700.0;
  int tabSeleccionada = 0;
  
  final String userId = 
    'fyQdILnR3X6jd20OqDgr';
    //'Jq0Y3sToCUVG2BHPrQDH'; 

  late Future<Map<String, dynamic>> _datosCompletosFuture; 
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // 🆕 Iniciamos la función de carga en cascada
    _datosCompletosFuture = _cargarDatosCompletos();
  }

  Future<Map<String, dynamic>> _cargarDatosCompletos() async {
    // Obtener el usuario principal
    final ModeloUsuario usuario = await _apiService.getUsuarioByID(userId);
    
    // Crear una lista de Futures para obtener los objetos completos de los amigos
    final List<Future<ModeloUsuario>> futurosAmigos = usuario.amigosId.map((amigoId) {
      // Usamos el endpoint para obtener el objeto completo por ID
      return _apiService.getUsuarioByID(amigoId);
    }).toList();

    // Esperar a que TODAS las peticiones de amigos terminen en paralelo
    final List<ModeloUsuario> objetosAmigos = await Future.wait(futurosAmigos);

    // Devolver un mapa con el usuario principal y la lista de objetos amigos
    return {
      'usuarioPrincipal': usuario,
      'amigosObj': objetosAmigos, // Lista de ModeloUsuario de los amigos
    };
  }
  
  // Función _handleUserSearch para la búsqueda
  void _handleUserSearch(String nick) async {
    mostrarSnackBarExito(context, "Buscando a '$nick'...");
    try {
      final List<ModeloUsuario> usuariosEncontrados = 
          await _apiService.getByNick(nick);
      if (usuariosEncontrados.isEmpty) {
        mostrarSnackBarError(context, "No se encontró ningún usuario con el nick '$nick'.");
      } else {
        final ModeloUsuario usuarioEncontrado = usuariosEncontrados.first;
        mostrarSnackBarExito(
          context, 
          "Usuario '${usuarioEncontrado.nick}' encontrado. ¿Deseas agregarlo?"
        );
      }
    } catch (e) {
      mostrarSnackBarError(context, "Error en la búsqueda: ${e.toString().split(':')[1].trim()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        toolbarHeight: 80,
        backgroundColor: const Color(0xFF111827),
        title: const Text(
            "Mi Perfil",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.normal,
              fontFamily: "Inter",
            ),
          ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.cyan.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 17),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
              onPressed: () {
                mostrarSnackBarExito(context, "Cambios guardados con éxito.");
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.save, size: 18),
                  SizedBox(width: 8),
                  Text("Guardar Cambios"),
                ],
              ),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF0A0E1A),
      
      body: FutureBuilder<Map<String, dynamic>>(
        future: _datosCompletosFuture,
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar el usuario: ${snapshot.error}',
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            );
          }
          
          if (snapshot.hasData) {
            // Desempaquetamos los datos
            final ModeloUsuario usuario = snapshot.data!['usuarioPrincipal'];
            final List<ModeloUsuario> amigosObj = snapshot.data!['amigosObj'];
            
            final List<Amigo> listaDeAmigosReal = amigosObj.map((amigo) => 
              Amigo(
                nombre: amigo.nick, // Acceso correcto al nick
                amigosEnComun: 5 // MOCK, hay que trabajar en ello
              )
            ).toList();

            return LayoutBuilder(
              builder: (context, constraints) {
                final bool isLargeScreen = constraints.maxWidth > _kTabletBreakpoint;

                return SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isLargeScreen ? constraints.maxWidth * 0.05 : 0.0,
                      vertical: 10.0,
                    ),
                    child: isLargeScreen
                        ? _buildTwoColumnLayout(context, usuario, listaDeAmigosReal)
                        : _buildOneColumnLayout(context, usuario, listaDeAmigosReal),
                  ),
                );
              },
            );
          }
          
          return const Center(child: Text("Usuario no encontrado o no disponible.", style: TextStyle(color: Colors.white)));
        },
      ),
    );
  }

  // --- Métodos de Construcción ---

  Widget _buildOneColumnLayout(BuildContext context, ModeloUsuario usuario, List<Amigo> listaAmigos) {
    return Column(
      children: [
        _buildTabSelector(),
        PerfilUsuarioCard(
          nickUsuario: usuario.nick,
          emailUsuario: usuario.correo,
          urlImagen: usuario.imagenPerfil ?? "url_default.jpg", 
        ),
        const SizedBox(height: 10),
        InformacionBasicaCard(
          nombreRecibido: usuario.nick,
          emailRecibido: usuario.correo,
          fechaRegistro: "N/A",
        ),
        const SizedBox(height: 10),
        EstadisticasCard(
          peliculasValoradas: usuario.peliculasCriticadas.length,
          numeroAmigos: usuario.amigosId.length, // Usamos el tamaño de la lista de IDs como el número de amigos
          puntuacionMedia: 3.6,
        ),
        const SizedBox(height: 10),
        ListaAmigosCard(
          amigos: listaAmigos
        ),
        const SizedBox(height: 10),
        BuscarUsuarioCard(
          onSearch: _handleUserSearch, 
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildTwoColumnLayout(BuildContext context, ModeloUsuario usuario, List<Amigo> listaAmigos) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTabSelector(),
              PerfilUsuarioCard(
                nickUsuario: usuario.nick,
                emailUsuario: usuario.correo,
                urlImagen: usuario.imagenPerfil ?? "url_default.jpg",
              ),
              InformacionBasicaCard(
                nombreRecibido: usuario.nick,
                emailRecibido: usuario.correo,
                fechaRegistro: "N/A",
              ),
            ],
          ),
        ),
        Expanded(
          flex: 4,
          child: Column(
            children: [
              EstadisticasCard(
                peliculasValoradas: usuario.peliculasCriticadas.length,
                numeroAmigos: usuario.amigosId.length,
                puntuacionMedia: 3.6,
              ),
              ListaAmigosCard(
                amigos: listaAmigos
              ),
              BuscarUsuarioCard(
                onSearch: _handleUserSearch,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Container(
        width: double.infinity,
        height: 45,
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(36)
        ),
        child: Row(
          children: [
            Expanded(
              child: TabButton(
                icono: Icons.access_time, 
                etiqueta: "Información", 
                seleccionado: tabSeleccionada == 0,
                onTap: () => setState(() => tabSeleccionada = 0)
              ),
            ),
            Expanded(
              child: TabButton(
                icono: Icons.trending_up, 
                etiqueta: "Mis críticas", 
                seleccionado: tabSeleccionada == 1,
                onTap: () => setState(() => tabSeleccionada = 1)
              ),
            ),
          ],
        )
      ),
    );
  }
}
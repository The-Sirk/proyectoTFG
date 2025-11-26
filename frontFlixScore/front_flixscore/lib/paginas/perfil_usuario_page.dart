import 'package:flixscore/controllers/login_provider.dart';
import 'package:flixscore/modelos/amigo_modelo.dart';
import 'package:flixscore/paginas/admin_page.dart';
import 'package:flixscore/paginas/home_page.dart';
import 'package:flixscore/paginas/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flixscore/service/api_service.dart';
import 'package:flixscore/modelos/usuario_modelo.dart';
import 'package:flixscore/componentes/common/tab_button.dart';
import 'package:flixscore/componentes/perfil_usuario/estadisticas_card.dart';
import 'package:flixscore/componentes/perfil_usuario/lista_amigos_card.dart';
import 'package:flixscore/componentes/perfil_usuario/imagen_perfil_card.dart';
import 'package:flixscore/componentes/perfil_usuario/informacion_basica_card.dart';
import 'package:flixscore/componentes/perfil_usuario/buscar_usuario_card.dart';
import 'package:flixscore/componentes/perfil_usuario/mis_criticas_card.dart';
import 'package:provider/provider.dart';

enum MenuOption { navegarAHome, administracion, cerrarSesion }

class PerfilUsuario extends StatefulWidget {
  const PerfilUsuario({super.key});

  @override
  State<PerfilUsuario> createState() => _PerfilUsuarioState();
}

class _PerfilUsuarioState extends State<PerfilUsuario> {
  final double _kTabletBreakpoint = 700.0;
  int tabSeleccionada = 0;

  late Future<Map<String, dynamic>> _datosCompletosFuture;
  final ApiService _apiService = ApiService();

  String? _nickActual;

  List<Amigo> _amigosConComunes = [];

  final GlobalKey<BuscarUsuarioCardState> _buscarKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _datosCompletosFuture = _cargarDatosDesdeProvider();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<LoginProvider>(context, listen: true);
    final currentUserId = provider.usuarioLogueado?.documentID;

    if (currentUserId != null &&
        provider.usuarioLogueado?.amigosId.isNotEmpty == true) {
      _recargarAmigosConComunes(provider.amigosObj, currentUserId);
    }
  }

  Future<Map<String, dynamic>> _cargarDatosDesdeProvider() async {
    final provider = Provider.of<LoginProvider>(context, listen: false);
    final usuario = provider.usuarioLogueado!;
    final userId = usuario.documentID!;

    // Amigos desde provider
    await provider.cargarAmigos(notificar: false);
    final objetosAmigos = provider.amigosObj;
    final amigosConComunes = await _cargarAmigosConComunes(
      objetosAmigos,
      userId,
    );

    // Estadísticas desde provider
    final criticasCount = usuario.puntuaciones.length;
    final puntuacionMedia = usuario.puntuaciones.isEmpty
        ? 0.0
        : double.parse(
            (usuario.puntuaciones.reduce((a, b) => a + b) /
                    usuario.puntuaciones.length)
                .toStringAsFixed(1),
          );

    return {
      'usuarioPrincipal': usuario,
      'amigosConComunes': amigosConComunes,
      'criticasCount': criticasCount,
      'puntuacionMedia': puntuacionMedia,
    };
  }

  Future<List<Amigo>> _cargarAmigosConComunes(
    List<ModeloUsuario> amigosObj,
    String currentUserId,
  ) async {
    final List<Amigo> lista = [];

    for (final amigo in amigosObj) {
      try {
        if (amigo.documentID == null) {
          lista.add(
            Amigo(
              nombre: amigo.nick,
              amigosEnComun: 0,
              imagenPerfil: amigo.imagenPerfil,
              documentID: amigo.documentID,
            ),
          );
          continue;
        }
        final enComun = await _apiService.contarAmigosEnComun(
          currentUserId,
          amigo.documentID!,
        );
        lista.add(
          Amigo(
            nombre: amigo.nick,
            amigosEnComun: enComun,
            imagenPerfil: amigo.imagenPerfil,
            documentID: amigo.documentID,
          ),
        );
      } catch (e) {
        lista.add(
          Amigo(
            nombre: amigo.nick,
            amigosEnComun: 0,
            imagenPerfil: amigo.imagenPerfil,
            documentID: amigo.documentID,
          ),
        );
      }
    }

    return lista;
  }

  Future<void> _recargarAmigosConComunes(
    List<ModeloUsuario> amigosObj,
    String currentUserId,
  ) async {
    final nuevosConComunes = await _cargarAmigosConComunes(
      amigosObj,
      currentUserId,
    );
    if (mounted) {
      setState(() {
        _amigosConComunes = nuevosConComunes;
      });
    }
  }

  void _actualizarListaAmigosDespuesDeBusqueda() async {
    final provider = Provider.of<LoginProvider>(context, listen: false);
    final currentUserId = provider.usuarioLogueado!.documentID!;

    await provider.cargarAmigos();
    final nuevosConComunes = await _cargarAmigosConComunes(
      provider.amigosObj,
      currentUserId,
    );

    setState(() {
      _amigosConComunes = nuevosConComunes;
    });
  }

  void _manejarEliminacion() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LoginProvider>(context, listen: false).logout();
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lógica para manejar la selección del menú
    void onMenuItemSelected(MenuOption item) {
      switch (item) {
        // Vamos al home
        case MenuOption.navegarAHome:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
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

    // Lógica para determinar si el usuario es administrador
    final loginProvider = Provider.of<LoginProvider>(context);
    final bool esAdmin = loginProvider.usuarioLogueado?.esAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
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
        automaticallyImplyLeading: true,
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
              if (esAdmin)
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
            final ModeloUsuario usuario = snapshot.data!['usuarioPrincipal'];
            final currentUserId = usuario.documentID!;

            _nickActual ??= usuario.nick;

            final provider = Provider.of<LoginProvider>(context, listen: true);
            if (provider.amigosObj.isNotEmpty) {
              _recargarAmigosConComunes(provider.amigosObj, currentUserId);
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final bool isLargeScreen =
                    constraints.maxWidth > _kTabletBreakpoint;

                return SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isLargeScreen
                          ? constraints.maxWidth * 0.05
                          : 0.0,
                      vertical: 10.0,
                    ),
                    child: isLargeScreen
                        ? _buildTwoColumnLayout(
                            context,
                            usuario,
                            _amigosConComunes,
                            currentUserId,
                          )
                        : _buildOneColumnLayout(
                            context,
                            usuario,
                            _amigosConComunes,
                            currentUserId,
                          ),
                  ),
                );
              },
            );
          }

          return const Center(
            child: Text(
              "Usuario no encontrado o no disponible.",
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOneColumnLayout(
    BuildContext context,
    ModeloUsuario usuario,
    List<Amigo> amigosConComunes,
    String currentUserId,
  ) {
    return Column(
      children: [
        _buildTabSelector(),
        if (tabSeleccionada == 0) ...[
          ImagenPerfilUsuarioCard(
            nickUsuario: _nickActual ?? '',
            emailUsuario: usuario.correo,
            urlImagenInicial: usuario.imagenPerfil,
            usuarioId: currentUserId,
            onImagenActualizada: (nuevaUrl) {
              Provider.of<LoginProvider>(
                context,
                listen: false,
              ).actualizarImagenPerfil(nuevaUrl);
            },
          ),
          const SizedBox(height: 10),
          InformacionBasicaCard(
            nombreRecibido: _nickActual ?? '',
            emailRecibido: usuario.correo,
            fechaRegistro: usuario.fechaRegistro,
            usuarioId: currentUserId,
            onNickActualizado: (nuevoNick) {
              setState(() => _nickActual = nuevoNick);
            },
            onCuentaEliminada: _manejarEliminacion,
          ),
          const SizedBox(height: 10),
          const EstadisticasCard(),
          const SizedBox(height: 10),
          ListaAmigosCard(
            usuarioId: currentUserId,
            amigosConComunes: amigosConComunes,
          ),
          const SizedBox(height: 10),
          BuscarUsuarioCard(
            key: _buscarKey,
            onAmigoAgregado: _actualizarListaAmigosDespuesDeBusqueda,
          ),
          const SizedBox(height: 10),
        ] else
          MisCriticasCard(usuarioId: currentUserId, editable: true),
      ],
    );
  }

  Widget _buildTwoColumnLayout(
    BuildContext context,
    ModeloUsuario usuario,
    List<Amigo> amigosConComunes,
    String currentUserId,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 6,
          child: tabSeleccionada == 0
              ? Column(
                  children: [
                    _buildTabSelector(),
                    ImagenPerfilUsuarioCard(
                      nickUsuario: _nickActual ?? '',
                      emailUsuario: usuario.correo,
                      urlImagenInicial: usuario.imagenPerfil,
                      usuarioId: currentUserId,
                      onImagenActualizada: (nuevaUrl) {
                        Provider.of<LoginProvider>(
                          context,
                          listen: false,
                        ).actualizarImagenPerfil(nuevaUrl);
                      },
                    ),
                    InformacionBasicaCard(
                      nombreRecibido: _nickActual ?? '',
                      emailRecibido: usuario.correo,
                      fechaRegistro: usuario.fechaRegistro,
                      usuarioId: currentUserId,
                      onNickActualizado: (nuevoNick) {
                        setState(() => _nickActual = nuevoNick);
                      },
                      onCuentaEliminada: _manejarEliminacion,
                    ),
                  ],
                )
              : Column(
                  children: [
                    _buildTabSelector(),
                    MisCriticasCard(usuarioId: currentUserId, editable: true),
                  ],
                ),
        ),
        Expanded(
          flex: 4,
          child: Column(
            children: [
              const EstadisticasCard(),
              ListaAmigosCard(
                usuarioId: currentUserId,
                amigosConComunes: amigosConComunes,
              ),
              BuscarUsuarioCard(
                key: _buscarKey,
                onAmigoAgregado: _actualizarListaAmigosDespuesDeBusqueda,
              ),
              const SizedBox(height: 10),
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
          borderRadius: BorderRadius.circular(36),
        ),
        child: Row(
          children: [
            Expanded(
              child: TabButton(
                icono: Icons.access_time,
                etiqueta: "Información",
                seleccionado: tabSeleccionada == 0,
                onTap: () => setState(() => tabSeleccionada = 0),
              ),
            ),
            Expanded(
              child: TabButton(
                icono: Icons.trending_up,
                etiqueta: "Mis críticas",
                seleccionado: tabSeleccionada == 1,
                onTap: () => setState(() => tabSeleccionada = 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

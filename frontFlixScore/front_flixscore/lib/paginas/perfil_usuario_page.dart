import 'package:flutter/material.dart';
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
  // Definimos un punto de quiebre para el diseño de dos columnas
  final double _kTabletBreakpoint = 700.0;
  int tabSeleccionada = 0;

  // Aquí se introducirán los datos del usuario para no tener que cargarlos por cada widget
  // Deberán cargarse al inicio para no hacer cargas parciales por cada tarjeta
  String nombreUsuario = "Perico";
  String emailUsuario = "perico@eldelospalot.es";
  String fechaRegistroUsuario = "06/11/2025 08:50";
  String urlFotoPerfil = "https://img.freepik.com/free-photo/goth-student-attending-school_23-2150576778.jpg?size=338&ext=jpg";
  int peliculasValoradasUsuario = 14;
  int numeroAmigosUsuario = 4; 
  var puntuacionMediaUsuario = 6.8;
  List<Amigo> listaDeAmigos = [
    Amigo(nombre: "FilipinosPowah", amigosEnComun: 5),
    Amigo(nombre: "El rey del pollo frito", amigosEnComun: 8),
    Amigo(nombre: "SSSIIIIUUUUuuuu", amigosEnComun: 3),
    Amigo(nombre: "Pikmin69", amigosEnComun: 12),
    Amigo(nombre: "FilipinosPowah", amigosEnComun: 5),
    Amigo(nombre: "El rey del pollo frito", amigosEnComun: 8),
    Amigo(nombre: "SSSIIIIUUUUuuuu", amigosEnComun: 3),
    Amigo(nombre: "Pikmin69", amigosEnComun: 12),
    Amigo(nombre: "FilipinosPowah", amigosEnComun: 5),
    Amigo(nombre: "El rey del pollo frito", amigosEnComun: 8),
    Amigo(nombre: "SSSIIIIUUUUuuuu", amigosEnComun: 3),
    Amigo(nombre: "Pikmin69", amigosEnComun: 12),
    Amigo(nombre: "FilipinosPowah", amigosEnComun: 5),
    Amigo(nombre: "El rey del pollo frito", amigosEnComun: 8),
    Amigo(nombre: "SSSIIIIUUUUuuuu", amigosEnComun: 3),
    Amigo(nombre: "Pikmin69", amigosEnComun: 12),
    Amigo(nombre: "FilipinosPowah", amigosEnComun: 5),
    Amigo(nombre: "El rey del pollo frito", amigosEnComun: 8),
    Amigo(nombre: "SSSIIIIUUUUuuuu", amigosEnComun: 3),
    Amigo(nombre: "Pikmin69", amigosEnComun: 12),
    Amigo(nombre: "FilipinosPowah", amigosEnComun: 5),
    Amigo(nombre: "El rey del pollo frito", amigosEnComun: 8),
    Amigo(nombre: "SSSIIIIUUUUuuuu", amigosEnComun: 3),
    Amigo(nombre: "Pikmin69", amigosEnComun: 12),
    Amigo(nombre: "FilipinosPowah", amigosEnComun: 5),
    Amigo(nombre: "El rey del pollo frito", amigosEnComun: 8),
    Amigo(nombre: "SSSIIIIUUUUuuuu", amigosEnComun: 3),
    Amigo(nombre: "Pikmin69", amigosEnComun: 12),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        toolbarHeight: 80,
        backgroundColor: const Color(0xFF111827),
        title: const Row(
          children: [
            Text(
              "Mi Perfil",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.normal,
                fontFamily: "Inter",
              ),
            ),
          ],
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
      // Para que sea responsive
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Determina si el ancho es mayor que el punto de quiebre (Smartphone/Desktop)
          final bool isLargeScreen = constraints.maxWidth > _kTabletBreakpoint;

          // Contenido principal de la página, envuelto en SingleChildScrollView para el scroll
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                // Reduce el padding horizontal en pantallas grandes para usar mejor el espacio
                horizontal: isLargeScreen ? constraints.maxWidth * 0.05 : 0.0,
                vertical: 10.0,
              ),
              // Si es pantalla grande, usa Row (2 columnas); si es pequeña, usa Column (1 columna)
              child: isLargeScreen
                  ? _buildTwoColumnLayout(context)
                  : _buildOneColumnLayout(context),
            ),
          );
        },
      ),
    );
  }

  // --- Funciones para construir las estructuras de diseño ---

  Widget _buildOneColumnLayout(BuildContext context) {
    // Diseño para móvil (una sola columna)
    return Column(
      children: [
        // Selector de pestañas
         _buildTabSelector(),

        // Tarjeta de foto de perfil
        PerfilUsuarioCard(
          nickUsuario: nombreUsuario,
          emailUsuario: emailUsuario,
          urlImagen: urlFotoPerfil,
        ),

        const SizedBox(height: 10),

        //Tarjeta información básica
        InformacionBasicaCard(
          nombreRecibido: nombreUsuario,
          emailRecibido: emailUsuario,
          fechaRegistro: fechaRegistroUsuario,
          ),

        const SizedBox(height: 10),

        // Tarjeta de estadísticas
        EstadisticasCard(
          peliculasValoradas: peliculasValoradasUsuario,
          numeroAmigos: numeroAmigosUsuario, 
          puntuacionMedia: puntuacionMediaUsuario,
        ),

        const SizedBox(height: 10),
        
        //Tarjeta de lista de amigos
        ListaAmigosCard(
          amigos: listaDeAmigos
        ),

        const SizedBox(height: 10),

        // Tarjeta que permite la búsqueda de nuevos amigos y su agregación
        BuscarUsuarioCard(
          onSearch: (nick) {
          // TODO: Implementar la lógica para buscar el 'nick' en la base de datos
          print('Buscando usuario: $nick');
          },
        ),

        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildTwoColumnLayout(BuildContext context) {
    // Diseño para Desktop/Web (dos columnas usando Row y Expanded)
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, // Alinea las columnas desde arriba
      children: [

        //-----------------------------------------------------
        // Columna 1: Información Principal (60% del ancho)
        //-----------------------------------------------------
        Expanded(
          flex: 6, //Esto determina el porcentaje de ancho que ocupa esa columnna
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selector de Pestañas
              _buildTabSelector(),

              // Tarjeta de foto de perfil
              PerfilUsuarioCard(
                nickUsuario: nombreUsuario,
                emailUsuario: emailUsuario,
                urlImagen: urlFotoPerfil,
              ),

              // Tarjeta de información básica
              InformacionBasicaCard(nombreRecibido: nombreUsuario,
              emailRecibido: emailUsuario,
              fechaRegistro: fechaRegistroUsuario,
              )
            ],
          ),
        ),
        
        //--------------------------------------
        // Columna 2: Auxiliares (40% del ancho)
        //--------------------------------------
        Expanded(
          flex: 4,
          child: Column(
            children: [

              // Tarjeta de estadísticas
              EstadisticasCard(
                peliculasValoradas: peliculasValoradasUsuario,
                numeroAmigos: numeroAmigosUsuario, 
                puntuacionMedia: puntuacionMediaUsuario,
              ),

              // Tarjeta de lista de amigos
              ListaAmigosCard(
                amigos: listaDeAmigos
              ),

              // Tarjeta que permite la búsqueda de nuevos amigos y su agregación
              BuscarUsuarioCard(
                onSearch: (nick) {
                // TODO: Implementar la lógica para buscar el 'nick' en la base de datos
                print('Buscando usuario: $nick');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }


  // Widget solo para la clase, prepara el selector por pestañas
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
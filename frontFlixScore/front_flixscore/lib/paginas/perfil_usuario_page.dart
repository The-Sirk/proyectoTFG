import 'package:firebase_core/firebase_core.dart';
import 'package:flixscore/modelos/amigo_modelo.dart';
import 'package:flutter/material.dart';
import 'package:flixscore/service/api_service.dart';
import 'package:flixscore/modelos/usuario_modelo.dart';
import 'package:flixscore/componentes/common/tab_button.dart';
import 'package:flixscore/componentes/perfil_usuario/estadisticas_card.dart';
import 'package:flixscore/componentes/perfil_usuario/lista_amigos_card.dart';
import 'package:flixscore/componentes/common/snack_bar.dart';
import 'package:flixscore/componentes/perfil_usuario/foto_perfil_card.dart';
import 'package:flixscore/componentes/perfil_usuario/informacion_basica_card.dart';
import 'package:flixscore/componentes/perfil_usuario/buscar_usuario_card.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

class PerfilUsuario extends StatefulWidget {
  const PerfilUsuario({super.key});

  @override
  State<PerfilUsuario> createState() => _PerfilUsuarioState();
}

class _PerfilUsuarioState extends State<PerfilUsuario> {
  final double _kTabletBreakpoint = 700.0;
  int tabSeleccionada = 0;

  final String userId = '2yiZnZWkLjr8WY3DaINR';
                        //'U9iIJTLZPrA2zdvVVDiz'; //Señor del jabón de la carcel
                        //'Jq0Y3sToCUVG2BHPrQDH'; // OpaHostil
                        //'fyQdILnR3X6jd20OqDgr'; // Sirk

  late Future<Map<String, dynamic>> _datosCompletosFuture;
  final ApiService _apiService = ApiService();
  
  final ImagePicker _picker = ImagePicker();

  String? _nickActual;
  String? _imagenPerfilActual;
  ModeloUsuario? _usuarioActual;

  List<ModeloUsuario> _amigosObj = [];
  List<Amigo> _amigosConComunes = [];

  final GlobalKey<BuscarUsuarioCardState> _buscarKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _datosCompletosFuture = _cargarDatosCompletos();
  }

  Future<Map<String, dynamic>> _cargarDatosCompletos() async {
    final ModeloUsuario usuario = await _apiService.getUsuarioByID(userId);

    final List<Future<ModeloUsuario>> futurosAmigos = usuario.amigosId.map((amigoId) {
      return _apiService.getUsuarioByID(amigoId);
    }).toList();

    final List<ModeloUsuario> objetosAmigos = await Future.wait(futurosAmigos);
    final listaDeAmigosReal = await _cargarAmigosConComunes(objetosAmigos);
    final criticasCount = await _contarCriticasUsuario(usuario.documentID!);
    final puntuacionMedia = await _calcularPuntuacionMedia(usuario.documentID!);

    _amigosObj = objetosAmigos;
    _amigosConComunes = listaDeAmigosReal;

    return {
      'usuarioPrincipal': usuario,
      'amigosObj': objetosAmigos,
      'amigosConComunes': listaDeAmigosReal,
      'criticasCount': criticasCount,
      'puntuacionMedia': puntuacionMedia,
    };
  }

  Future<List<Amigo>> _cargarAmigosConComunes(List<ModeloUsuario> amigosObj) async {
    final List<Amigo> lista = [];

    for (final amigo in amigosObj) {
      try {
        if (amigo.documentID == null) {
          lista.add(Amigo(
            nombre: amigo.nick,
            amigosEnComun: 0,
            imagenPerfil: amigo.imagenPerfil,
          ));
          continue;
        }
        final enComun = await _apiService.contarAmigosEnComun(userId, amigo.documentID!);
        lista.add(Amigo(
          nombre: amigo.nick,
          amigosEnComun: enComun,
          imagenPerfil: amigo.imagenPerfil,
        ));
      } catch (e) {
        lista.add(Amigo(
          nombre: amigo.nick,
          amigosEnComun: 0,
          imagenPerfil: amigo.imagenPerfil,
        ));
      }
    }

    return lista;
  }

  Future<int> _contarCriticasUsuario(String usuarioId) async {
    try {
      final criticas = await _apiService.getCriticasByUserId(usuarioId);
      return criticas.length;
    } catch (e) {
      return 0;
    }
  }

  Future<double> _calcularPuntuacionMedia(String usuarioId) async {
    try {
      final criticas = await _apiService.getCriticasByUserId(usuarioId);
      if (criticas.isEmpty) return 0.0;

      final total = criticas.fold<int>(0, (sum, c) => sum + c.puntuacion);
      return double.parse((total / criticas.length).toStringAsFixed(1));
    } catch (e) {
      return 0.0;
    }
  }

  void _agregarAmigoLocal(ModeloUsuario nuevoAmigo) async {
    if (nuevoAmigo.documentID == null) return;

    _usuarioActual?.amigosId.add(nuevoAmigo.documentID!);

    final futuros = _usuarioActual!.amigosId.map((id) => _apiService.getUsuarioByID(id)).toList();
    final nuevosObjetos = await Future.wait(futuros);
    final nuevosConComunes = await _cargarAmigosConComunes(nuevosObjetos);

    setState(() {
      _amigosObj = nuevosObjetos;
      _amigosConComunes = nuevosConComunes;
    });
  }

  void _eliminarAmigoLocal(String amigoNombre) async {
    try {
      final amigosEncontrados = await _apiService.getByNick(amigoNombre);
      if (amigosEncontrados.isNotEmpty) {
        final amigoUsuario = amigosEncontrados.first;
        if (amigoUsuario.documentID != null) {
          _usuarioActual?.amigosId.remove(amigoUsuario.documentID);

          final futuros = _usuarioActual!.amigosId.map((id) => _apiService.getUsuarioByID(id)).toList();
          final nuevosObjetos = await Future.wait(futuros);
          final nuevosConComunes = await _cargarAmigosConComunes(nuevosObjetos);

          setState(() {
            _amigosObj = nuevosObjetos;
            _amigosConComunes = nuevosConComunes;
          });
        }
      }
    } catch (e) {
      // Silencioso
    }
  }

  void _handleUserSearch(String nick) async {
    if (nick.trim().isEmpty) {
      mostrarSnackBarError(context, "El nick no puede estar vacío");
      return;
    }

    try {
      final usuariosEncontrados = await _apiService.getByNick(nick);

      if (usuariosEncontrados.isEmpty) {
        mostrarSnackBarError(context, "No se encontró ningún usuario con el nick '$nick'.");
        return;
      }

      final usuarioEncontrado = usuariosEncontrados.first;

      final confirmar = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1A1C25),
          title: const Text(
            '¿Agregar amigo?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            '¿Deseas agregar a ${usuarioEncontrado.nick} como amigo?',
            style: const TextStyle(color: Color(0xFFAAAAAA)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar', style: TextStyle(color: Color(0xFFAAAAAA))),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Agregar', style: TextStyle(color: Colors.cyanAccent)),
            ),
          ],
        ),
      );

      if (confirmar != true) return;

      if (usuarioEncontrado.documentID == null) {
        mostrarSnackBarError(context, "El usuario encontrado no tiene ID válido.");
        return;
      }

      if (_usuarioActual?.amigosId.contains(usuarioEncontrado.documentID!) ?? false) {
        mostrarSnackBarError(context, "${usuarioEncontrado.nick} ya es tu amigo");
        return;
      }

      await _apiService.agregarAmigo(userId, usuarioEncontrado.documentID!);
      _agregarAmigoLocal(usuarioEncontrado);

      _buscarKey.currentState?.clearText();

      mostrarSnackBarExito(context, "${usuarioEncontrado.nick} agregado a tu lista de amigos");
    } catch (e) {
      mostrarSnackBarError(context, "Error al agregar amigo: ${e.toString().split(':').last.trim()}");
    }
  }

  // Lógica para la carga y edición de imágenes 
  Future<Map<String, dynamic>?> _selectImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) return null;

      Uint8List bytes;
      
      if (kIsWeb) {
        bytes = await pickedFile.readAsBytes();
      } else {
        bytes = await pickedFile.readAsBytes();
      }

      final size = bytes.lengthInBytes;
      
      String extension = 'jpg';
      if (pickedFile.name.contains('.')) {
        extension = pickedFile.name.split('.').last.toLowerCase();
      }

      const int maxSizeBytes = 1024 * 1024; // 1 MB
      const List<String> allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];

      if (size > maxSizeBytes) {
        if (mounted) {
          mostrarSnackBarError(context, "La imagen excede el tamaño máximo de 1MB.");
        }
        return null;
      }

      if (!allowedExtensions.contains(extension)) {
        if (mounted) {
          mostrarSnackBarError(context, "Extensión no permitida. Solo se admiten JPG, JPEG, PNG, GIF o WEBP.");
        }
        return null;
      }

      return {
        'bytes': bytes,
        'fileName': 'avatar_$userId.$extension',
        'extension': extension,
      };
    } catch (e) {
      debugPrint("Error al seleccionar imagen: $e");
      if (mounted) {
        mostrarSnackBarError(context, "Error al seleccionar la imagen. Inténtalo de nuevo.");
      }
      return null;
    }
  }
  
  Future<String> _uploadFile(Map<String, dynamic> fileData) async {
    try {
      final storage = FirebaseStorage.instanceFor(
        app: Firebase.app(),
        bucket: Firebase.app().options.storageBucket,
      );
      final storageRef = storage.ref();
      
      final path = 'profile_images/$userId/${fileData['fileName']}';
      
      debugPrint("Subiendo imagen a: $path");
      
      final uploadTask = storageRef.child(path).putData(
        fileData['bytes'] as Uint8List,
        SettableMetadata(
          contentType: 'image/${fileData['extension']}',
          cacheControl: 'public, max-age=3600',
        ),
      );
      
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        debugPrint('Progreso de subida: ${progress.toStringAsFixed(2)}%');
      });
      
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      debugPrint("Imagen subida exitosamente: $downloadUrl");
      return downloadUrl;
      
    } catch (e, st) {
      debugPrint('Error en _uploadFile: $e  ($st)');
      String code = '';
      String msg  = e.toString();

      if (e is FirebaseException) {
        code = e.code;
        msg  = e.message ?? code;
      }

      if (code == 'unauthorized') {
        throw 'No tienes permisos. Revisa las reglas de Storage.';
      } else if (code == 'canceled') {
        throw 'Subida cancelada.';
      } else if (code == 'unknown' || msg.contains('network')) {
        throw 'Error de red o CORS. Comprueba tu conexión.';
      } else {
        throw 'Error al subir imagen: $msg';
      }
    }
  }

  String _obtenerMensajeError(dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'unauthorized':
          return 'No tienes permisos. Verifica las reglas de Firebase.';
        case 'canceled':
          return 'La operación fue cancelada.';
        case 'unknown':
          return 'Error de conexión. Verifica tu red y la configuración CORS.';
        case 'object-not-found':
          return 'El archivo no existe.';
        case 'quota-exceeded':
          return 'Se excedió la cuota de almacenamiento.';
        default:
          return 'Error de Firebase: ${error.message ?? error.code}';
      }
    }
    
    final errorStr = error.toString();
    if (errorStr.contains('CORS')) {
      return 'Error de CORS. Configura el acceso en Firebase Storage.';
    }
    if (errorStr.contains('Network')) {
      return 'Error de red. Verifica tu conexión.';
    }
    
    return 'Error inesperado. Inténtalo de nuevo.';
  }

  void _handleImageSelection() async {
    if (_usuarioActual?.documentID == null) {
      mostrarSnackBarError(context, "Error: ID de usuario no disponible.");
      return;
    }
    
    final fileData = await _selectImage();
    if (fileData == null) {
      return;
    }
    
    OverlayEntry? loadingEntry;
    
    try {
      if (mounted) {
        loadingEntry = OverlayEntry(
          builder: (context) => Container(
            color: Colors.black54,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.cyanAccent),
                  SizedBox(height: 16),
                  Text(
                    'Subiendo imagen...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        );
        Overlay.of(context).insert(loadingEntry);
      }
      
      debugPrint("Iniciando subida de imagen...");
      final String newUrl = await _uploadFile(fileData);
      debugPrint("Imagen subida, actualizando base de datos...");
      
      await _apiService.cambiarImagenPerfil(_usuarioActual!.documentID!, newUrl);
      debugPrint("Base de datos actualizada");

      setState(() {
        _imagenPerfilActual = newUrl;
      });
      
      if (mounted) {
        mostrarSnackBarExito(context, "Foto de perfil actualizada con éxito.");
      }

    } catch (e) {
      debugPrint("Error completo al actualizar imagen: $e");
      
      if (mounted) {
        final mensaje = _obtenerMensajeError(e);
        mostrarSnackBarError(context, mensaje);
      }
    } finally {
      if (loadingEntry != null && loadingEntry.mounted) {
        loadingEntry.remove();
      }
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
            final int criticasCount = snapshot.data!['criticasCount'] as int;
            final double puntuacionMedia = snapshot.data!['puntuacionMedia'] as double;

            _nickActual ??= usuario.nick;
            _usuarioActual = usuario;
            _imagenPerfilActual ??= usuario.imagenPerfil;

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
                        ? _buildTwoColumnLayout(context, usuario, _amigosConComunes, criticasCount, puntuacionMedia)
                        : _buildOneColumnLayout(context, usuario, _amigosConComunes, criticasCount, puntuacionMedia),
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

  Widget _buildOneColumnLayout(BuildContext context, ModeloUsuario usuario, List<Amigo> listaAmigos, int criticasCount, double puntuacionMedia) {
    return Column(
      children: [
        _buildTabSelector(),
        PerfilUsuarioCard(
          key: ValueKey(_imagenPerfilActual),
          nickUsuario: _nickActual ?? '',
          emailUsuario: usuario.correo,
          urlImagen: _imagenPerfilActual,
          onImageTap: _handleImageSelection,
        ),
        const SizedBox(height: 10),
        InformacionBasicaCard(
          nombreRecibido: _nickActual ?? '',
          emailRecibido: usuario.correo,
          fechaRegistro: "N/A",
          usuarioId: userId,
          onNickActualizado: (nuevoNick) {
            setState(() {
              _nickActual = nuevoNick;
            });
          },
        ),
        const SizedBox(height: 10),
        EstadisticasCard(
          peliculasValoradas: criticasCount,
          numeroAmigos: _usuarioActual?.amigosId.length ?? 0,
          puntuacionMedia: puntuacionMedia,
        ),
        const SizedBox(height: 10),
        ListaAmigosCard(
          amigos: listaAmigos,
          usuarioId: userId,
          onAmigoEliminado: (amigoNombre) => _eliminarAmigoLocal(amigoNombre),
        ),
        const SizedBox(height: 10),
        BuscarUsuarioCard(
          key: _buscarKey,
          onSearch: _handleUserSearch,
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildTwoColumnLayout(BuildContext context, ModeloUsuario usuario, List<Amigo> listaAmigos, int criticasCount, double puntuacionMedia) {
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
                key: ValueKey(_imagenPerfilActual),
                nickUsuario: _nickActual ?? '',
                emailUsuario: usuario.correo,
                urlImagen: _imagenPerfilActual,
                onImageTap: _handleImageSelection,
              ),
              InformacionBasicaCard(
                nombreRecibido: _nickActual ?? '',
                emailRecibido: usuario.correo,
                fechaRegistro: "N/A",
                usuarioId: userId,
                onNickActualizado: (nuevoNick) {
                  setState(() {
                    _nickActual = nuevoNick;
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          flex: 4,
          child: Column(
            children: [
              EstadisticasCard(
                peliculasValoradas: criticasCount,
                numeroAmigos: _usuarioActual?.amigosId.length ?? 0,
                puntuacionMedia: puntuacionMedia,
              ),
              ListaAmigosCard(
                amigos: listaAmigos,
                usuarioId: userId,
                onAmigoEliminado: (amigoNombre) => _eliminarAmigoLocal(amigoNombre),
              ),
              BuscarUsuarioCard(
                key: _buscarKey,
                onSearch: _handleUserSearch,
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
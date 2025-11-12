import 'dart:typed_data';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flixscore/service/api_service.dart';
import 'package:flixscore/componentes/common/snack_bar.dart';

class FotoPerfilUsuarioCard extends StatefulWidget {
  final String nickUsuario;
  final String emailUsuario;
  final String? urlImagenInicial;
  final String usuarioId;
  final Function(String nuevaUrl) onImagenActualizada;

  const FotoPerfilUsuarioCard({
    Key? key,
    required this.nickUsuario,
    required this.emailUsuario,
    required this.urlImagenInicial,
    required this.usuarioId,
    required this.onImagenActualizada,
  }) : super(key: key);

  @override
  State<FotoPerfilUsuarioCard> createState() => _FotoPerfilUsuarioCardState();
}

class _FotoPerfilUsuarioCardState extends State<FotoPerfilUsuarioCard> {
  String? _urlImagen;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _urlImagen = widget.urlImagenInicial;
  }

  Future<void> _cambiarImagen() async {
    final fileData = await _seleccionImagen();
    if (fileData == null) return;

    OverlayEntry? subiendoImagen;
    try {
      subiendoImagen = OverlayEntry(
        builder: (_) => Container(
          color: Colors.black54,
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.cyanAccent),
                SizedBox(height: 16),
                Text('Subiendo imagen...', 
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      Overlay.of(context).insert(subiendoImagen);

      final nuevaUrl = await _subirImagen(fileData);
      await ApiService().cambiarImagenPerfil(widget.usuarioId, nuevaUrl);

      setState(() => _urlImagen = nuevaUrl);
      widget.onImagenActualizada(nuevaUrl);

      if (mounted) mostrarSnackBarExito(context, "Foto actualizada con éxito.");
    } catch (e) {
      if (mounted) mostrarSnackBarError(context, _obtenerMensajeError(e));
    } finally {
      subiendoImagen?.remove();
    }
  }

  Future<Map<String, dynamic>?> _seleccionImagen() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (pickedFile == null) return null;

      final bytes = await pickedFile.readAsBytes();
      final size = bytes.lengthInBytes;

      String extension = 'jpg';
      if (pickedFile.name.contains('.')) {
        extension = pickedFile.name.split('.').last.toLowerCase();
      }

      const maxSize = 1024 * 1024;
      const allowed = ['jpg', 'jpeg', 'png', 'gif', 'webp'];

      if (size > maxSize) {
        if (mounted) mostrarSnackBarError(context, "La imagen excede 1MB.");
        return null;
      }
      if (!allowed.contains(extension)) {
        if (mounted) mostrarSnackBarError(context, "Formato no permitido.");
        return null;
      }

      return {
        'bytes': bytes,
        'fileName': 'avatar_${widget.usuarioId}.$extension',
        'extension': extension,
      };
    } catch (e) {
      if (mounted) mostrarSnackBarError(context, "Error al seleccionar imagen.");
      return null;
    }
  }

  Future<String> _subirImagen(Map<String, dynamic> fileData) async {
    try {
      final storage = FirebaseStorage.instanceFor(
        app: Firebase.app(),
        bucket: Firebase.app().options.storageBucket,
      );
      final ref = storage.ref('profile_images/${widget.usuarioId}/${fileData['fileName']}');
      final uploadTask = ref.putData(
        fileData['bytes'] as Uint8List,
        SettableMetadata(
          contentType: 'image/${fileData['extension']}',
          cacheControl: 'public, max-age=3600',
        ),
      );

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw _obtenerMensajeError(e);
    }
  }

  String _obtenerMensajeError(dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'unauthorized':
          return 'No tienes permisos. Revisa Firebase Storage.';
        case 'canceled':
          return 'Subida cancelada.';
        case 'unknown':
          return 'Error de red o CORS.';
        default:
          return 'Error de Firebase: ${error.message ?? error.code}';
      }
    }
    final msg = error.toString();
    if (msg.contains('CORS')) return 'Error de CORS.';
    if (msg.contains('Network')) return 'Error de red.';
    return 'Error inesperado.';
  }

  @override
  Widget build(BuildContext context) {
    final safeUrl = _urlImagen ?? "https://dummyimage.com/100x100/333333/aaaaaa.png&text=F";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C25),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Foto de Perfil", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text("Cambia aquí como te ven tus amigos.", style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 14)),
          const SizedBox(height: 19),
          const Divider(height: 20, color: Color(0xFF333333)),
          const SizedBox(height: 19),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _cambiarImagen,
                child: SizedBox(
                  width: 108,
                  height: 108,
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF333333), width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 52,
                          backgroundColor: Colors.grey.shade700,
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: safeUrl,
                              width: 104,
                              height: 104,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => const Center(
                                child: SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.cyan),
                                ),
                              ),
                              errorWidget: (_, __, ___) => Center(
                                child: Text(
                                  widget.nickUsuario.isNotEmpty ? widget.nickUsuario[0].toUpperCase() : '?',
                                  style: const TextStyle(fontSize: 55, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 5,
                        right: 5,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF333333),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFAAAAAA), width: 1),
                          ),
                          child: const Icon(Icons.edit, size: 12, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.nickUsuario, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(widget.emailUsuario, style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 14)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
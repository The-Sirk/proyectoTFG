import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:flixscore/service/api_service.dart';
import 'package:flixscore/modelos/usuario_modelo.dart';
import 'package:flixscore/controllers/login_provider.dart';

class FotoPerfilCualquierUsuario extends StatefulWidget {
  final String usuarioId;
  const FotoPerfilCualquierUsuario({super.key, required this.usuarioId});

  @override
  State<FotoPerfilCualquierUsuario> createState() =>
      _FotoPerfilCualquierUsuarioState();
}

class _FotoPerfilCualquierUsuarioState
    extends State<FotoPerfilCualquierUsuario> {
  late Future<ModeloUsuario> _usuarioFuture;
  bool _yaEsAmigo = false;
  bool _isLoading = false;

  String _nick = '';

  @override
  void initState() {
    super.initState();
    _usuarioFuture = ApiService().getUsuarioByID(widget.usuarioId);
    _checkAmistad();
  }

  Future<void> _checkAmistad() async {
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    final misAmigos = loginProvider.usuarioLogueado?.amigosId ?? [];
    setState(() => _yaEsAmigo = misAmigos.contains(widget.usuarioId));
  }

  // Sin parámetros: usa _nick del estado
  Future<void> _agregarAmigo() async {
    if (_nick.isEmpty) return;
    setState(() => _isLoading = true);

    await Provider.of<LoginProvider>(
      context,
      listen: false,
    ).buscarYAgregarAmigo(context, _nick);

    setState(() => _isLoading = false);
    _checkAmistad();
  }

  static const double _tamanioFoto = 108.0;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ModeloUsuario>(
      future: _usuarioFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Error al cargar perfil.',
              style: TextStyle(color: Colors.red),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('Usuario no encontrado.'));
        }

        final usuario = snapshot.data!;
        _nick = usuario.nick;

        final urlImagen = usuario.imagenPerfil ?? '';
        final inicial = usuario.nick.isNotEmpty
            ? usuario.nick[0].toUpperCase()
            : '?';
        final urlFallback =
            'https://dummyimage.com/100x100/333333/aaaaaa.png&text=$inicial';
        final urlActual = urlImagen.isNotEmpty ? urlImagen : urlFallback;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1C25),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Imagen de Perfil',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              const Divider(height: 20, color: Color(0xFF333333)),
              const SizedBox(height: 5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: _tamanioFoto,
                    height: _tamanioFoto,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF333333),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: _tamanioFoto / 2,
                        backgroundColor: Colors.grey.shade700,
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: urlActual,
                            width: _tamanioFoto - 4,
                            height: _tamanioFoto - 4,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => const Center(
                              child: SizedBox(
                                width: 50,
                                height: 50,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.cyan,
                                ),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Center(
                              child: Text(
                                inicial,
                                style: const TextStyle(
                                  fontSize: 55,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              usuario.nick,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (_yaEsAmigo)
                              const Text(
                                'Es tu amigo',
                                style: TextStyle(
                                  color: Color(0xFFAAAAAA),
                                  fontSize: 14,
                                ),
                              )
                            else
                              _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : ElevatedButton.icon(
                                      onPressed: _agregarAmigo,
                                      key: const Key('botonAgregarAmigo'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.cyan,
                                        foregroundColor: Colors.white,
                                        elevation: 4,
                                        shadowColor: Colors.cyan.withOpacity(
                                          0.4,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.person_add,
                                        size: 20,
                                      ),
                                      label: const Text(
                                        'Hacer amigo',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

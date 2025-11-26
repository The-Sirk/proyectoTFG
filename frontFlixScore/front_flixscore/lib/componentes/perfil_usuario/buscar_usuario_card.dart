import 'dart:async';
import 'package:flixscore/modelos/usuario_modelo.dart';
import 'package:flixscore/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flixscore/controllers/login_provider.dart';

const Color _primaryTextColor = Colors.white;
const Color _subtitleColor = Color(0xFF9CA3AF);
const Color _textoEditable = Color.fromARGB(255, 174, 176, 179);
const Color _cardBackgroundColor = Color(0xFF1A1C25);
const Color _inputBackgroundColor = Color(0xFF1F2937);

class BuscarUsuarioCard extends StatefulWidget {
  final VoidCallback onAmigoAgregado;

  const BuscarUsuarioCard({super.key, required this.onAmigoAgregado});

  @override
  State<BuscarUsuarioCard> createState() => BuscarUsuarioCardState();
}

class BuscarUsuarioCardState extends State<BuscarUsuarioCard> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  List<ModeloUsuario> _usuariosEncontrados = [];
  bool _buscando = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  void clearText() {
    _searchController.clear();
    _cerrarOverlay();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _cerrarOverlay();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Cerrar overlay si el texto está vacío
    if (query.trim().isEmpty) {
      _cerrarOverlay();
      return;
    }

    _debounce = Timer(const Duration(seconds: 2), () {
      _buscarUsuarios(query);
    });
  }

  Future<void> _buscarUsuarios(String query) async {
    print("DEBUG: Iniciando búsqueda para query: '$query'");
    setState(() {
      _buscando = true;
    });

    try {
      print("DEBUG: Iniciando búsqueda local para: '$query'");
      // Obtenemos todos los usuarios y filtramos localmente para "contains" e "ignoreCase"
      final todosLosUsuarios = await ApiService().getAllUsuarios();
      print(
        "DEBUG: Total usuarios obtenidos de API: ${todosLosUsuarios.length}",
      );

      // Filtramos para no mostrar al propio usuario ni a los que ya son amigos
      final provider = Provider.of<LoginProvider>(context, listen: false);
      final usuarioLogueado = provider.usuarioLogueado;
      final queryLower = query.toLowerCase();

      final usuariosFiltrados = todosLosUsuarios.where((u) {
        final esElMismo = u.documentID == usuarioLogueado?.documentID;
        final esAmigo =
            usuarioLogueado?.amigosId.contains(u.documentID) ?? false;
        final coincideNick = u.nick.toLowerCase().contains(queryLower);

        return !esElMismo && !esAmigo && coincideNick;
      }).toList();

      if (mounted) {
        setState(() {
          _usuariosEncontrados = usuariosFiltrados;
          _buscando = false;
        });
        _mostrarOverlay();
      }
    } catch (e) {
      print("Error buscando usuarios: $e");
      if (mounted) {
        setState(() {
          _usuariosEncontrados = [];
          _buscando = false;
        });
        _cerrarOverlay();
      }
    }
  }

  void _mostrarOverlay() {
    _cerrarOverlay();

    if (_usuariosEncontrados.isEmpty) return;

    final int totalResultados = _usuariosEncontrados.length;
    final int maxResultados = 5;
    final int resultadosRestantes = totalResultados > maxResultados
        ? totalResultados - maxResultados
        : 0;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          width: 300, // Ajustar según el ancho del input o fijo
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            targetAnchor: Alignment.topLeft,
            followerAnchor: Alignment.bottomLeft,
            offset: const Offset(0.0, -8.0), // Pequeño margen arriba del input
            child: Material(
              elevation: 4.0,
              color: _inputBackgroundColor,
              borderRadius: BorderRadius.circular(8),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 250),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: totalResultados > maxResultados
                            ? maxResultados
                            : totalResultados,
                        itemBuilder: (context, index) {
                          final usuario = _usuariosEncontrados[index];
                          final tieneImagen =
                              usuario.imagenPerfil != null &&
                              usuario.imagenPerfil!.isNotEmpty;

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: tieneImagen
                                  ? NetworkImage(usuario.imagenPerfil!)
                                  : null,
                              radius: 16,
                              backgroundColor: tieneImagen ? null : Colors.grey,
                              child: !tieneImagen
                                  ? const Icon(
                                      Icons.person,
                                      size: 16,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            title: Text(
                              usuario.nick,
                              style: const TextStyle(color: Colors.white),
                            ),
                            onTap: () {
                              _agregarAmigo(usuario);
                              _cerrarOverlay();
                              _searchController.clear();
                            },
                          );
                        },
                      ),
                    ),
                    if (resultadosRestantes > 0)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 16.0,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: _subtitleColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Text(
                          '$resultadosRestantes más',
                          style: const TextStyle(
                            color: _subtitleColor,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _cerrarOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _agregarAmigo(ModeloUsuario usuario) async {
    final provider = Provider.of<LoginProvider>(context, listen: false);
    // Usamos el método existente en el provider pero pasando el nick exacto
    // O mejor, creamos una lógica directa aquí ya que tenemos el objeto usuario

    // Como el método del provider busca por nick de nuevo, podemos usarlo
    // o podemos llamar directamente a la API si queremos ser más eficientes.
    // Para mantener consistencia con la lógica del provider (snackbars, validaciones),
    // llamaremos al método del provider.

    final bool agregadoExitosamente = await provider.buscarYAgregarAmigo(
      context,
      usuario.nick,
    );

    if (agregadoExitosamente) {
      widget.onAmigoAgregado();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: _cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Buscar Amigos",
            style: TextStyle(
              color: _primaryTextColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Introduce el Nick de tu amigo para encontrarlo",
            style: TextStyle(color: _subtitleColor, fontSize: 14),
          ),
          const SizedBox(height: 20),
          CompositedTransformTarget(
            link: _layerLink,
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              onSubmitted: (value) {
                _debounce?.cancel();
                _buscarUsuarios(value);
              },
              style: const TextStyle(color: _primaryTextColor),
              decoration: InputDecoration(
                hintText: 'Ejemplo: NickAmigote123',
                hintStyle: const TextStyle(color: _textoEditable),
                prefixIcon: const Icon(
                  Icons.person_search_outlined,
                  color: _subtitleColor,
                ),
                suffixIcon: _buscando
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _subtitleColor,
                          ),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.search, color: _subtitleColor),
                        onPressed: () {
                          _debounce?.cancel();
                          _buscarUsuarios(_searchController.text);
                        },
                        tooltip: 'Buscar',
                      ),
                fillColor: _inputBackgroundColor,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 10,
                ),
              ),
              cursorColor: _primaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

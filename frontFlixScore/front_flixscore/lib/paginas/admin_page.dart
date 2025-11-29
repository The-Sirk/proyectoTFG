import 'package:flutter/material.dart';
import 'package:flixscore/service/admin_service.dart';
import 'package:intl/intl.dart';
import '../componentes/common/snack_bar.dart';

class AdminUsuariosPage extends StatefulWidget {
  const AdminUsuariosPage({super.key});

  @override
  State<AdminUsuariosPage> createState() => _AdminUsuariosPageState();
}

class _AdminUsuariosPageState extends State<AdminUsuariosPage> {
  final AdminService _adminService = AdminService();
  final ScrollController _scrollController = ScrollController();
  String? _nextPageToken;

  List<dynamic> _usuarios = [];
  String? _nextToken;
  bool _cargando = false;
  bool _cargandoMas = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _cargarUsuarios();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_cargandoMas &&
        _nextToken != null) {
      _cargarUsuarios(siguiente: true);
    }
  }

  Future<void> _cargarUsuarios({bool siguiente = false}) async {
    if (_cargando || _cargandoMas) return;
    setState(() => siguiente ? _cargandoMas = true : _cargando = true);

    try {
      final lista = await _adminService.listarUsuarios(
        maxResults: 50,
        nextPageToken: siguiente ? _nextToken : null,
      );
      setState(() {
        _usuarios.addAll(lista);
      });
    } catch (e) {
      mostrarSnackBarError(context, 'Error al cargar usuarios: $e');
    } finally {
      setState(() {
        _cargando = false;
        _cargandoMas = false;
      });
    }
  }

  Future<void> _asignarRol(String uid, String newRole) async {
    try {
      await _adminService.asignarRol(uid: uid, role: newRole);
      _actualizarUsuario(uid, (u) => u['role'] = newRole);
      mostrarSnackBarExito(context, 'Rol $newRole asignado');
    } catch (e) {
      mostrarSnackBarError(context, 'Error al asignar rol: $e');
    }
  }

  Future<void> _toggleDisable(String uid, bool disabled) async {
    try {
      await _adminService.toggleDisable(uid: uid, disabled: disabled);
      _actualizarUsuario(uid, (u) => u['disabled'] = disabled);
      mostrarSnackBarExito(
        context,
        disabled ? 'Usuario suspendido' : 'Usuario habilitado',
      );
    } catch (e) {
      mostrarSnackBarError(context, 'Error al cambiar estado: $e');
    }
  }

  Future<void> _resetPassword(String uid) async {
    try {
      await _adminService.forzarResetPassword(uid: uid);
      mostrarSnackBarExito(context, 'Email de reset enviado');
    } catch (e) {
      mostrarSnackBarError(context, 'Error al resetear: $e');
    }
  }

  Future<void> _eliminarUsuario(String uid) async {
    try {
      await _adminService.eliminarUsuario(uid: uid);
      setState(() => _usuarios.removeWhere((u) => u['uid'] == uid));
      mostrarSnackBarExito(context, 'Usuario eliminado');
    } catch (e) {
      mostrarSnackBarError(context, 'Error al eliminar: $e');
    }
  }

  void _actualizarUsuario(String uid, void Function(Map<String, dynamic>) mod) {
    final idx = _usuarios.indexWhere((u) => u['uid'] == uid);
    if (idx != -1) setState(() => mod(_usuarios[idx]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: const Color(0xFF111827),
        title: const Text(
          'Administración de usuarios',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.normal,
            fontFamily: "Inter",
          ),
        ),
      ),
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: _cargando && _usuarios.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () async {
                  _usuarios.clear();
                  _nextToken = null;
                  await _cargarUsuarios();
                },
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(top: 10),
                  itemCount: _usuarios.length + (_nextToken != null ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (i == _usuarios.length && _nextPageToken != null) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            key: const Key('botonCargarMasUsuarios'),
                            onPressed: _cargandoMas
                                ? null
                                : () => _cargarUsuarios(siguiente: true),
                            child: _cargandoMas
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Cargar más usuarios'),
                          ),
                        ),
                      );
                    }
                    final u = _usuarios[i];
                    final uid = u['uid'] as String;
                    final email = u['email'] as String? ?? 'Sin email';
                    final disabled = u['disabled'] as bool? ?? false;
                    final rol = u['role'] as String? ?? 'user';
                    final roleColor = rol == 'admin'
                        ? Colors.blue
                        : rol == 'sadmin'
                        ? Colors.purple
                        : Colors.grey;
                    return Center(
                      child: SizedBox(
                        key: const Key('usuarioItem'),
                        width: MediaQuery.of(context).size.width <= 600
                            ? double.infinity
                            : MediaQuery.of(context).size.width * 0.5,
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 8,
                          ),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: roleColor,
                              child: Text(
                                email[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              email,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'UID: ${uid}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      rol.toUpperCase(),
                                      style: TextStyle(
                                        color: roleColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      disabled ? 'SUSPENDIDO' : 'ACTIVO',
                                      style: TextStyle(
                                        color: disabled
                                            ? Colors.red
                                            : Colors.green,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Verificado: ${u['emailVerified'] == true ? 'Sí' : 'No'}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                    if (u['creationTime'] != null)
                                      Text(
                                        'Creado: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(u['creationTime']).toLocal())}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    if (u['lastSignInTime'] != null)
                                      Text(
                                        'Último acceso: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(u['lastSignInTime']).toLocal())}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Rol:',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    DropdownButton<String>(
                                      key: const Key('rolDropdown'),
                                      dropdownColor: Colors.grey[850],
                                      value: ['user', 'admin'].contains(rol)
                                          ? rol
                                          : 'user',
                                      items: ['user', 'admin']
                                          .map(
                                            (r) => DropdownMenuItem(
                                              value: r,
                                              child: Text(
                                                r.toUpperCase(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (val) {
                                        if (val != null) _asignarRol(uid, val);
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    Column(
                                      children: [
                                        SizedBox(
                                          width: 300,
                                          child: ElevatedButton.icon(
                                            key: const Key(
                                              'botonResetPassword',
                                            ),
                                            onPressed: disabled
                                                ? null
                                                : () => _resetPassword(uid),
                                            icon: const Icon(Icons.lock_reset),
                                            label: const Text('Reset password'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.blue.shade700,
                                              foregroundColor: Colors.white,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        SizedBox(
                                          width: 300,
                                          child: ElevatedButton.icon(
                                            key: const Key('botonDeshabilitar'),
                                            onPressed: () =>
                                                _toggleDisable(uid, !disabled),
                                            icon: Icon(
                                              disabled
                                                  ? Icons.check_circle
                                                  : Icons.block,
                                            ),
                                            label: Text(
                                              disabled
                                                  ? 'Habilitar'
                                                  : 'Deshabilitar',
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: disabled
                                                  ? Colors.green
                                                  : Colors.orange,
                                              foregroundColor: Colors.white,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        SizedBox(
                                          width: 300,
                                          child: ElevatedButton.icon(
                                            key: const Key(
                                              'botonEliminarUsuario',
                                            ),
                                            onPressed: disabled
                                                ? null
                                                : () => _eliminarUsuario(uid),
                                            icon: const Icon(
                                              Icons.delete_forever,
                                            ),
                                            label: const Text('Eliminar'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              foregroundColor: Colors.white,
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
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}

import 'package:flixscore/componentes/common/snack_bar.dart';
import 'package:flixscore/componentes/common/tab_button.dart';
import 'package:flixscore/controllers/login_provider.dart';
import 'package:flixscore/controllers/register_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class LoginCard extends StatefulWidget {
  const LoginCard({super.key});

  @override
  State<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
  int selectedTab = 0;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController repeatPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    repeatPasswordController.dispose();
    super.dispose();
  }

  // Registro del usuario
  void _registrarUsuario() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final username = usernameController.text.trim();
    final repeatPassword = repeatPasswordController.text.trim();

    final registerProvider = Provider.of<RegisterProvider>(
      context,
      listen: false,
    );

    try {
      await registerProvider.registroUsuario(
        email: email,
        password: password,
        username: username,
        repeatPassword: repeatPassword,
      );

      if (registerProvider.isRegistered && mounted) {
        mostrarSnackBarExito(
          context,
          "Usuario registrado correctamente, disfruta de las pelis!",
        );
        // Navegar al home después del registro exitoso
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      mostrarSnackBarError(context, "Error al registrarte: ${e.toString()}");
    }
  }

  // Login del usuario
  void _iniciarSesion() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      mostrarSnackBarError(context, "Por favor, completa todos los campos");
      return;
    }

    final LoginProvider loginProvider = Provider.of<LoginProvider>(
      context,
      listen: false,
    );

    try {
      await loginProvider.loginUsuario(email: email, password: password);
      if (loginProvider.isAuthenticated && mounted) {
        mostrarSnackBarExito(context, "Inicio de sesion correcto!");
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      mostrarSnackBarError(
        context,
        "Error en el inicio de sesion: ${e.toString()}",
      );
    }
  }

  // Método para la recuperación de contraseña del usuario
  void _recuperarContrasena() async {
    final recuperacionEmailController = TextEditingController();
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1C25),
        title: const Text(
          'Recuperar Contraseña',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ingresa el correo electrónico de tu cuenta para recibir el email de restablecimiento.',
              style: TextStyle(color: Color(0xFFAAAAAA)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: recuperacionEmailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => Navigator.of(context).pop(true),
              key: Key('correoARecuperar'),
              decoration: const InputDecoration(
                labelText: 'Tu correo electrónico',
                floatingLabelBehavior: FloatingLabelBehavior.never,
                prefixIcon: Icon(Icons.email_outlined, color: Colors.white54),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancelar',
              key: Key('cancelarRecuperacion'),
              style: TextStyle(color: Color(0xFFAAAAAA)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Enviar Enlace',
              key: Key('enviarRecuperacion'),
              style: TextStyle(color: Colors.blueAccent),
            ),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      final email = recuperacionEmailController.text.trim();
      //recuperacionEmailController.dispose();
      if (email.isEmpty) {
        if (mounted) {
          mostrarSnackBarError(context, "El correo no puede estar vacío.");
        }
        return;
      }
      try {
        final LoginProvider loginProvider = Provider.of<LoginProvider>(
          context,
          listen: false,
        );
        print('[LOGGER 4] Llamando a Firebase para enviar correo a: $email');
        await loginProvider.solicitarRecuperacionContrasena(email: email);
        print('[LOGGER 5] Correo enviado con éxito. Preparando SnackBar.');
        if (mounted) {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) { 
              print('[LOGGER 6a] Mostrando SnackBar de ÉXITO.');
              mostrarSnackBarExito(
                context,
                "Se ha enviado un correo... Revisa tu bandeja de entrada.",
              );
            } else {
              print('[LOGGER 6b] Falló el segundo chequeo mounted dentro del delay. No se muestra SnackBar.');
            }
          });
        } else {
          print('[LOGGER 6c] Falló el primer chequeo mounted. Correo enviado, pero no se muestra SnackBar.');
        }
      } catch (e) {
        print('[LOGGER 7] Excepción atrapada: $e');
        if (mounted) {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              print('[LOGGER 8a] Mostrando SnackBar de ERROR.');
              mostrarSnackBarError(
                context,
                "Error: ${e.toString().replaceAll('Exception: ', '')}",
              );
            } else {
              print('[LOGGER 8b] Falló el segundo chequeo mounted dentro del delay. No se muestra SnackBar.');
            }
          });
        } else {
          print('[LOGGER 8c] Falló el primer chequeo mounted. Error ocurrido, pero no se muestra SnackBar.');
        }
      }
    } else {
      print('[LOGGER 9] Usuario canceló el diálogo.');
    }
    recuperacionEmailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _loginProvider = Provider.of<LoginProvider>(context);
    final _registerProvider = Provider.of<RegisterProvider>(context);
    final _cargando = selectedTab == 0
        ? _loginProvider.status == AuthStatus.autenticando
        : _registerProvider.status == RegisterStatus.registrando;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(32),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Acceder a tu cuenta",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamily: "Inter",
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Inicia sesión o crea una cuenta nueva",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF232836),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                width: double.infinity,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2937),
                  borderRadius: BorderRadius.circular(36),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TabButton(
                        key: const Key('tab_iniciarSesion'),
                        icono: Icons.abc,
                        etiqueta: "Iniciar Sesion",
                        seleccionado: selectedTab == 0,
                        onTap: () => setState(() => selectedTab = 0),
                      ),
                    ),
                    Expanded(
                      child: TabButton(
                        key: const Key('tab_registrarse'),
                        icono: Icons.login,
                        etiqueta: "Registrarse",
                        seleccionado: selectedTab == 1,
                        onTap: () => setState(() => selectedTab = 1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _construirCuerpo(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                key: const Key('boton_enviar'),
                onPressed: () {
                  if (selectedTab == 0) {
                    _iniciarSesion();
                  } else {
                    _registrarUsuario();
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _cargando
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(selectedTab == 0 ? "Iniciar Sesión" : "Registrarse"),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Divider(color: Colors.white24)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    "O",
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
                Expanded(child: Divider(color: Colors.white24)),
              ],
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                key: const Key('boton_loginGoogle'),
                onPressed: () async {
                  print('[DEBUG CardLogin] Google login button pressed');
                  if (kIsWeb) {
                    print('[DEBUG CardLogin] Calling loginGoogleWeb');
                    await _loginProvider.loginGoogleWeb();
                  } else {
                    print('[DEBUG CardLogin] Calling loginGoogle');
                    await _loginProvider.loginGoogle();
                  }
                  print(
                    '[DEBUG CardLogin] Login finished. isAuthenticated: ${_loginProvider.isAuthenticated}, mounted: ${context.mounted}',
                  );
                  if (_loginProvider.isAuthenticated && context.mounted) {
                    print('[DEBUG CardLogin] Navigating to /home');
                    Navigator.pushReplacementNamed(context, '/home');
                  } else {
                    print('[DEBUG CardLogin] Navigation skipped');
                  }
                },
                icon: SvgPicture.asset(
                  "assets/images/google-icon.svg",
                  //"assets/images/google_icon.png",
                  width: 35,
                  height: 35,
                ),
                // icon: Icon(Icons.g_mobiledata, color: Colors.white, size: 28),
                label: const Text("Continuar con Google"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color.fromARGB(255, 0, 0, 0),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirCuerpo() {
    switch (selectedTab) {
      case 0:
        return Column(
          children: [
            const SizedBox(height: 24),
            const Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              key: const Key('textfield_email_login'),
              controller: emailController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.email_outlined, color: Colors.white54),
                labelText: "tu@email.com",
                floatingLabelBehavior: FloatingLabelBehavior.never, 
              ),
            ),
            const SizedBox(height: 16),
            const Text("Contraseña",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              key: const Key('textfield_password_login'),
              controller: passwordController,
              obscureText: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _iniciarSesion(),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.lock_outline, color: Colors.white54),
                labelText: "••••••••",
                floatingLabelBehavior: FloatingLabelBehavior.never, 
              ),
            ),
            const SizedBox(height: 8), 
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _recuperarContrasena,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  "¿Olvidaste tu contraseña?",
                  style: TextStyle(
                    color: Colors.blueAccent, 
                    fontWeight: FontWeight.bold,
                    fontSize: 12, 
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      case 1:
        return Column(
          children: [
            const SizedBox(height: 24),
            const Text(
              "Nombre de Usuario",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('textfield_username_registro'),
              controller: usernameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person, color: Colors.white54),
                labelText: "Nombre de Usuario",
                floatingLabelBehavior: FloatingLabelBehavior.never, 
              ),
            ),
            const SizedBox(height: 16),
            const Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              key: const Key('textfield_email_registro'),
              controller: emailController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.email_outlined, color: Colors.white54),
                labelText: "tu@email.com",
                floatingLabelBehavior: FloatingLabelBehavior.never, 
              ),
            ),
            const SizedBox(height: 16),
            const Text("Contraseña",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              key: const Key('textfield_password_registro'),
              obscureText: true,
              controller: passwordController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.lock_outline, color: Colors.white54),
                labelText: "••••••••",
                floatingLabelBehavior: FloatingLabelBehavior.never, 
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Repetir Contraseña",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('textfield_repeatPassword_registro'),
              controller: repeatPasswordController,
              textInputAction: TextInputAction.done,
              obscureText: true,
              onSubmitted: (_) => _registrarUsuario(),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.lock_reset, color: Colors.white54),
                labelText: "••••••••",
                floatingLabelBehavior: FloatingLabelBehavior.never, 
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      default:
        return Container();
    }
  }
}

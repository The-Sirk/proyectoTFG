import 'package:flixscore/componentes/common/snack_bar.dart';
import 'package:flixscore/componentes/common/tab_button.dart';
import 'package:flixscore/paginas/home_page.dart';
import 'package:flixscore/controllers/login_provider.dart';
import 'package:flixscore/controllers/register_provider.dart';
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
  final TextEditingController repeatPasswordController = TextEditingController();

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

    final registerProvider = Provider.of<RegisterProvider>(context, listen: false);

    try {
      await registerProvider.registroUsuario(
        email: email,
        password: password,
        username: username,
        repeatPassword: repeatPassword,
      );

      if (registerProvider.isRegistered && mounted) {
        mostrarSnackBarExito(context, "Usuario registrado correctamente, disfruta de las pelis!");
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
      }
    } catch (e) {
      mostrarSnackBarError(context, "Error en el inicio de sesion: ${e.toString()}");
    }
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
                        icono: Icons.abc,
                        etiqueta: "Iniciar Sesion",
                        seleccionado: selectedTab == 0,
                        onTap: () => setState(() => selectedTab = 0),
                      ),
                    ),
                    Expanded(
                      child: TabButton(
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
                    : Text(
                        selectedTab == 0 ? "Iniciar Sesión" : "Registrarse",
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Divider(color: Colors.white24)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    "O continúa con",
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
                onPressed: () {},
                icon: SvgPicture.asset(
                  "images/google-icon.svg",
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
            Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.email_outlined, color: Colors.white54),
                hintText: "tu@email.com",
              ),
            ),
            const SizedBox(height: 16),
            Text("Contraseña", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock_outline, color: Colors.white54),
                hintText: "••••••••",
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      case 1:
        return Column(
          children: [
            const SizedBox(height: 24),
            Text(
              "Nombre de Usuario",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person, color: Colors.white54),
                hintText: "Nombre de Usuario",
              ),
            ),
            const SizedBox(height: 16),
            Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.email_outlined, color: Colors.white54),
                hintText: "tu@email.com",
              ),
            ),
            const SizedBox(height: 16),
            Text("Contraseña", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              obscureText: true,
              controller: passwordController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock_outline, color: Colors.white54),
                hintText: "••••••••",
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Repetir Contraseña",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: repeatPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock_reset, color: Colors.white54),
                hintText: "••••••••",
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

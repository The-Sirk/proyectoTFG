import 'package:flixscore/componentes/common/tab_button.dart';
import 'package:flutter/material.dart';

class LoginCard extends StatefulWidget {
  const LoginCard({super.key});

  @override
  State<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
  bool isLogin = true;
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
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
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Iniciar Sesión"),
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
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: Image.asset(
                  "assets/images/google_icon.png",
                  width: 28,
                  height: 28,
                ),
                // icon: Icon(Icons.g_mobiledata, color: Colors.white, size: 28),
                label: const Text("Continuar con Google"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color.fromARGB(255, 0, 0, 0),
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
            Text("Nombre de Usuario", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person, color: Colors.white54),
                hintText: "nick",
              ),
            ),
            const SizedBox(height: 16),
            Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
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
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock_outline, color: Colors.white54),
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

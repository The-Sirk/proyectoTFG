import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:flixscore/controllers/criticas_provider.dart';
import 'package:flixscore/controllers/login_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _cargarDatos();
    });
  }

  Future<void> _cargarDatos() async {
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    
    // Esperar a que el usuario esté autenticado (máx 5 segundos)
    int intentos = 0;
    while (!loginProvider.isAuthenticated && intentos < 50) {
      await Future.delayed(const Duration(milliseconds: 100));
      intentos++;
    }

    // Esperar el splash mínimo
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      if (loginProvider.isAuthenticated) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: Lottie.asset('assets/images/animacion-splash.json')),
    );
  }
}

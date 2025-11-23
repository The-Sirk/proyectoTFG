import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:flixscore/controllers/criticas_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState()  {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _cargarDatos();
    });
  }

  Future<void> _cargarDatos() async {
    final provider = Provider.of<CriticasProvider>(context, listen: false);

    // Definir el tiempo mínimo de espera (ej. 4 segundos)
    final minSplashDuration = Future.delayed(const Duration(seconds: 4));

    // Definir la carga de datos
    final dataLoading = Future(() async {
      await provider.cargarCriticasDelUsuario();
      await provider.cargarCriticasDeAmigos();
      await provider.cargarUltimasCriticas();
      await provider.servirPeliculasCard();
    });

    // Esperar a que AMBOS terminen
    await Future.wait([minSplashDuration, dataLoading]);

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Lottie.asset('assets/images/animacion-splash.json'),
      ),
    );
  }
}
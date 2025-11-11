import 'package:firebase_core/firebase_core.dart';
import 'package:flixscore/paginas/home_page.dart';
import 'package:flixscore/firebase_options.dart';
import 'package:flixscore/paginas/perfil_usuario_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'paginas/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase inicializado correctamente');
  } catch (e, st) {
    debugPrint('ERROR al inicializar Firebase: $e');
    debugPrint('Stack: $st');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlixScore',
      locale: const Locale('es'),
      supportedLocales: const [Locale('es')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates, 
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomePage(),
        '/perfil': (context) => const PerfilUsuario(),
      },
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(
          primary: Colors.blueAccent,
          // Color de fonode de Widgets "contenedores"
          surface: Color(0xFF181C23),
        ),
        inputDecorationTheme: InputDecorationTheme(
          // Filled es para rellenar el fonde de todos los inputs y fillColor el color con el que lo hacemos.
          filled: true,
          fillColor: Color.fromARGB(255, 57, 65, 88),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: SafeArea(
          child: const Scaffold(
          backgroundColor: Color(0xFF000000),
          body: Center(child: LoginScreen()),
          //body: Center(child: HomePage()),
        ),
      ),
    );
  }
}

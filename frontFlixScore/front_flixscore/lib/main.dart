import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flixscore/controllers/login_provider.dart';
import 'package:flixscore/controllers/register_provider.dart';
import 'package:flixscore/paginas/home_page.dart';
import 'package:flixscore/paginas/perfil_usuario_page.dart';
import 'package:flixscore/paginas/login_page.dart';
import 'package:flixscore/firebase_options.dart';


void main() async {
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => RegisterProvider()),
      ],
      child: MaterialApp(
        title: 'FlixScore',
        locale: const Locale('es'),
        supportedLocales: const [Locale('es')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.blueAccent,
            surface: Color(0xFF181C23),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color.fromARGB(255, 57, 65, 88),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        
        home: Consumer2<LoginProvider, RegisterProvider>(
          builder: (context, loginProvider, registerProvider, _) {
            if (loginProvider.status == AuthStatus.autenticado || 
                registerProvider.status == RegisterStatus.registrado) {
              return const HomePage();
            } else {
              return const SafeArea(
                child: Scaffold(
                  backgroundColor: Color(0xFF000000),
                  body: Center(child: LoginScreen()),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
import 'package:flixscore/controllers/criticas_provider.dart';
import 'package:flixscore/paginas/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flixscore/controllers/login_provider.dart';
import 'package:flixscore/controllers/register_provider.dart';
import 'package:flixscore/paginas/home_page.dart';
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

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => RegisterProvider()),
        // Con proxy provider nos aseguramos que CriticasProvider
        // siempre tenga el usuario logueado actualizado
        // En consecuencia, las críticas se actualizaran y no se tendra que hacer tantas llamadas
        // desde las paginas que usen CriticasProvider
        ChangeNotifierProxyProvider<LoginProvider, CriticasProvider>(
          create: (_) => CriticasProvider(),
          update: (_, loginProvider, criticasProvider) {
            criticasProvider!.actualizarUsuarioLogueado(
              loginProvider.usuarioLogueado,
            );
            return criticasProvider;
          },
        ),
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
        navigatorObservers: [routeObserver],
        initialRoute: "/",
        routes: {
          '/': (context) => const SplashScreen(),
          "/home": (context) => Consumer2<LoginProvider, RegisterProvider>(
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
        },
      ),
    );
  }
}

import 'package:flixscore/controllers/login_provider.dart';
import 'package:flixscore/controllers/register_provider.dart';
import 'package:flixscore/paginas/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import "firebase_options.dart";
import 'package:firebase_core/firebase_core.dart';
import 'paginas/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
        home: Consumer2<LoginProvider, RegisterProvider>(
          builder: (context, loginProvider, registerProvider,  _) {
            if (loginProvider.status == AuthStatus.autenticado || 
                registerProvider.status == RegisterStatus.registrado) {
              return HomePage();
            } else {
              return SafeArea(
                child: const Scaffold(
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

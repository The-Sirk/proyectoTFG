
import 'package:flutter/material.dart';

import 'paginas/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    /**
     * Envolvemos toda la app en un Safe Area para no ocupar ningun espacio del dispositivo
     */
    return MaterialApp(
      title: 'Flutter Demo',
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
        ),
      ),
    );
  }
}

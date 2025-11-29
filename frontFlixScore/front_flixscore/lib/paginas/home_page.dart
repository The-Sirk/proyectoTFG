import 'package:flixscore/componentes/home/components/popup_menu_home.dart';
import 'package:flixscore/componentes/common/tab_button.dart';
import 'package:flixscore/componentes/home/bucar_layout.dart';
import 'package:flixscore/componentes/home/popular_layout.dart';
import 'package:flixscore/componentes/home/ultimas_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tabSeleccionada = 0;

  Future<bool> _mostrarDialogoSalir() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            key: const Key('dialog_salir_app'),
            backgroundColor: const Color(0xFF1F2937),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              '¿Salir de la aplicación?',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
            content: const Text(
              '¿Estás seguro de que quieres cerrar FlixScore?',
              style: TextStyle(color: Colors.white70, fontFamily: 'Inter'),
            ),
            actions: [
              TextButton(
                key: const Key('button_cancelar_salir'),
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.white70, fontFamily: 'Inter'),
                ),
              ),
              TextButton(
                key: const Key('button_confirmar_salir'),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Salir',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false; // Si se cierra el diálogo tocando fuera, no salir
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;

        final bool deberaSalir = await _mostrarDialogoSalir();
        if (deberaSalir && context.mounted) {
          // Cerrar la aplicación
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 80,
          backgroundColor: const Color(0xFF111827),
          title: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8), // <-- Aquí se define el radio
                child: Container(
                  width: 45,
                  height: 45,
                  child: Image.asset(
                    'assets/icon/icon.png',
                    fit: BoxFit.cover, 
                    cacheWidth: 150, 
                  ),
                ),
              ),
              const SizedBox(width: 15),
              const Text(
                "FlixScore",
                style: TextStyle(
                  color: Colors.cyan,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Inter",
                ),
              ),
            ],
          ),
          centerTitle: false,
          actions: const [AppBarPopupMenu(), SizedBox(width: 16)],
        ),
        backgroundColor: const Color(0xFF0A0E1A),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Descubre Películas",
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              fontFamily: "Inter",
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Explora las películas más comentadas y populares en la comunidad",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        height: 45,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F2937),
                          borderRadius: BorderRadius.circular(36),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TabButton(
                                key: const Key('tab_ultimas'),
                                icono: Icons.access_time,
                                etiqueta: "Últimas",
                                seleccionado: tabSeleccionada == 0,
                                onTap: () =>
                                    setState(() => tabSeleccionada = 0),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: TabButton(
                                key: const Key('tab_amigos'),
                                icono: Icons.trending_up,
                                etiqueta: "De tus amigos",
                                seleccionado: tabSeleccionada == 1,
                                onTap: () =>
                                    setState(() => tabSeleccionada = 1),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: TabButton(
                                key: const Key('tab_buscar'),
                                icono: Icons.search,
                                etiqueta: "Buscar",
                                seleccionado: tabSeleccionada == 2,
                                onTap: () =>
                                    setState(() => tabSeleccionada = 2),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                switch (tabSeleccionada) {
                  0 => UltimasLayout(),
                  1 => PopularLayout(),
                  2 => BuscarLayout(),
                  _ => UltimasLayout(),
                },
              ],
            ),
          ),
        ),
      ),
    );
  }
}

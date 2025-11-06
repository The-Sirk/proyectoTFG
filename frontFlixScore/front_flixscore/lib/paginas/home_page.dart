import 'package:flixscore/componentes/common/tab_button.dart';
import 'package:flixscore/componentes/home/bucar_layout.dart';
import 'package:flixscore/componentes/home/popular_layout.dart';
import 'package:flixscore/componentes/home/ultimas_layout.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> {

  int tabSeleccionada = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 80,
        backgroundColor: const Color(0xFF111827),
        title: Row(
          spacing: 15,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.local_movies_outlined,
                color: Colors.white,
                size: 28,
              ),
            ),
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFF0A0E1A),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color.fromARGB(255, 40, 241, 231),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF0A0E1A),
      body: Center(
        child: FractionallySizedBox(
          widthFactor: 1.0,
          child: Column(
            children: [
              // CONTENIDO FIJO - No scrollable
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Descubre Películas",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
                        borderRadius: BorderRadius.circular(36)
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TabButton(
                              icono: Icons.access_time, 
                              etiqueta: "Últimas", 
                              seleccionado: tabSeleccionada == 0,
                              onTap: () => setState(() => tabSeleccionada = 0)
                            ),
                          ),
                          Expanded(
                            child: TabButton(
                              icono: Icons.trending_up, 
                              etiqueta: "Popular", 
                              seleccionado: tabSeleccionada == 1,
                              onTap: () => setState(() => tabSeleccionada = 1)
                            ),
                          ),
                          Expanded(
                            child: TabButton(
                              icono: Icons.search, 
                              etiqueta: "Buscar", 
                              seleccionado: tabSeleccionada == 2,
                              onTap: () => setState(() => tabSeleccionada = 2)
                            ),
                          ),
                        ],
                      )
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              // CONTENIDO SCROLLABLE
               Expanded(
                  child: switch(tabSeleccionada) {
                    0 => UltimasLayout(),
                    1 => PopularLayout(),
                    2 => BuscarLayout(),
                    _ => UltimasLayout(),
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}


                

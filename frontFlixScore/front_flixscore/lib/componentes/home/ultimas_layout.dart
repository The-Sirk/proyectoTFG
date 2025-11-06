import 'package:flixscore/componentes/home/card_pelicula.dart';
import 'package:flutter/material.dart';
class UltimasLayout extends StatefulWidget {
  const UltimasLayout({super.key});

  @override
  State<UltimasLayout> createState() => _UltimasLayoutState();
}

class _UltimasLayoutState extends State<UltimasLayout> {

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool esMovil = constraints.maxWidth < 600;
        
        if (esMovil) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            children: const [
              
            ],
          );
        } else {
          return _desktopLayout(constraints);
        }
      },
    );
  }
}

Widget _desktopLayout(BoxConstraints constraints) {
    int columnas = constraints.maxWidth > 1000 ? 3 : 2;
    double anchoCard = (constraints.maxWidth - 60 - (20 * (columnas - 1))) / columnas;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        children: List.generate(6, (index) {
          return SizedBox(
            width: anchoCard,
            child: Text("")
          );
        }),
      ),
    );
  }
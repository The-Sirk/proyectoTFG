import 'package:flutter/material.dart';

class ResumenPelicula extends StatelessWidget {
  final String titulo;
  final String resumen;
  final String fechaEstreno;

  const ResumenPelicula({
    super.key,
    required this.titulo,
    required this.resumen,
    required this.fechaEstreno,});

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(fechaEstreno, style: TextStyle(color: Colors.grey[400], fontSize: 16)),
        SizedBox(height: 12),
        Text(resumen)
      ],
    );
  }
}

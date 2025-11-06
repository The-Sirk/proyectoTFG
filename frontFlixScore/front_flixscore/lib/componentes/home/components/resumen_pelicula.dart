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
    List<String> generosMock = ["Sci-Fi", "Thriller"];

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
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: generosMock
              .map(
                (genero) => Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF374151),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    genero,
                    style: TextStyle(color: Colors.grey[300], fontSize: 12),
                  ),
                ),
              )
              .toList(),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Icon(
              Icons.comment,
              color: const Color.fromARGB(255, 252, 252, 252),
              size: 16,
            ),
            SizedBox(width: 6),
            Flexible(
              child: Text(
                "1 crítica",
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Icon(
              Icons.calendar_month,
              color: const Color.fromARGB(255, 102, 102, 102),
              size: 16,
            ),
            SizedBox(width: 6),
            Flexible(
              child: Text(
                "25/10/2024",
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

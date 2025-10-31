import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.all(10),
          child: Icon(Icons.local_movies_outlined, color: Colors.white, size: 36),
        ),
        const SizedBox(height: 18),
        Text(
          "FlixScore",
          style: TextStyle(
            color: Colors.cyanAccent,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Tu comunidad de críticas de cine",
          style: TextStyle(
            color: Colors.white54,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}
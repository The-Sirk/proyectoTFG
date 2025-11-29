import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
                borderRadius: BorderRadius.circular(8),
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
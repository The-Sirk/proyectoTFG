import 'package:flutter/material.dart';

Widget TabButton({
  required IconData icono,
  required String etiqueta,
  required bool seleccionado,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: 50,
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: seleccionado ? const Color.fromARGB(255, 0, 0, 0) : Colors.transparent,
        borderRadius: BorderRadius.circular(25)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icono,
            color: Colors.white70,
            size: 20
          ),
          SizedBox(width: 8),
          Text(
            etiqueta,
            style: TextStyle(
              color: seleccionado ? Colors.white : Colors.white70,
              fontSize: 13,
              fontWeight: seleccionado ? FontWeight.w600 : FontWeight.normal
            ),
          ),
        ],
      )
    )
  );
}
import 'package:flutter/material.dart';

Widget ImagenPelicula() {

  return Container(
    width: double.infinity,
    height: double.infinity,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12 ),
      color: Colors.blueAccent,
    ),
    child: Stack(
      children: [
        // Aqui cambiaremos en su momento por la ruta de la imagen traida de TDBM
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12 ),
            color: Colors.amber
          ),
        ),
        Positioned(
          top: 8 ,
          left: 8 ,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 8 ,
              vertical: 4 ,
            ),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(8 ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, size: 16 ),
                SizedBox(width: 4 ),
                Text(
                  "9.0",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12 ,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

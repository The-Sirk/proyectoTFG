 import 'package:flutter/material.dart';


Widget CuadroCritica(String? nombreUsuario, String? textoCritica) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12), 
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8), 
        border: Border.all(
          color: const Color(0xFF374151),
          width: 1, 
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nombreUsuario ?? "",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14, 
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6), 
          Text(
            textoCritica ?? "",
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 14, 
              fontStyle: FontStyle.italic,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
 import 'package:flutter/material.dart';


Widget CuadroCritica() {
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
            "Carlos Ruiz:",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14, 
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6), 
          Text(
            '"Una obra maestra del cine moderno. La narrativa compleja y l..."',
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
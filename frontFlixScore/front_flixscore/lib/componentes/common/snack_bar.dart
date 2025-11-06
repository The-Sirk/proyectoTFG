import 'package:flutter/material.dart';

// ----------------------------------------------------
// Wrappers públicos de SnackBars
// ----------------------------------------------------

/// Muestra un SnackBar de éxito (fondo azul).
void mostrarSnackBarExito(BuildContext context, String mensaje) {
  _crearYMostrarSnackBar(context, valido: true, mensaje: mensaje);
}

/// Muestra un SnackBar de error (fondo rojo).
void mostrarSnackBarError(BuildContext context, String mensaje) {
  _crearYMostrarSnackBar(context, valido: false, mensaje: mensaje);
}

//----------------------------------------------------------------------
// Función de utilidad privada que contiene la lógica real del SnackBar.
void _crearYMostrarSnackBar(BuildContext context, {
  required bool valido, 
  required String mensaje
}) {
  // Configuración de estilo basada en el valor de 'valido'
  final icono = valido ? Icons.check_circle_outline : Icons.error_outline;
  final color = valido ? Colors.cyan.shade600 : Colors.red.shade600;
  // Se deja así por si más adelante se quiere modificar el estilo
  final textStyle = TextStyle(
    color: valido ? Colors.white : Colors.white
  );

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(icono, color: Colors.white), 
          const SizedBox(width: 8),
          Expanded(child: Text(mensaje, style: textStyle)), 
        ],
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
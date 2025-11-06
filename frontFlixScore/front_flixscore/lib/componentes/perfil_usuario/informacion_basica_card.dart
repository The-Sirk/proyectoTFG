import 'package:flutter/material.dart';
import 'package:flixscore/componentes/common/snack_bar.dart';

const Color _primaryTextColor = Colors.white;
const Color _subtitleColor = Color(0xFF9CA3AF);
const Color _textoEditable = Color.fromARGB(255, 174, 176, 179);
const Color _textoNoEditable = Color(0xFF5D5F63);
const Color _cardBackgroundColor = Color(0xFF1A1C25);
const Color _inputBackgroundColor = Color(0xFF1F2937);

const Color secondaryTextColor = Color(0xFFAAAAAA);
const Color dividerColor = Color(0xFF333333);
const Color countBadgeColor = Color(0xFF1F2937);
const Color accentColor = Color(0xFFEF4444);

class InformacionBasicaCard extends StatelessWidget {
  final String nombreRecibido;
  final String emailRecibido;
  final String fechaRegistro;

  const InformacionBasicaCard({
    super.key,
    required this.nombreRecibido,
    required this.emailRecibido,
    required this.fechaRegistro,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: _cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título y Subtítulo
          const Text(
            "Información Básica",
            style: TextStyle(
              color: _primaryTextColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Consulta tu información personal",
            style: TextStyle(
              color: _subtitleColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),

          // Campo Nombre
          _TextoNoEditable(
            titulo: "Nick",
            hintText: nombreRecibido, 
            icono: Icons.person_outline,
            textoAyuda: "Da este Nick a tus amigos para ser agregado",
          ),
          const SizedBox(height: 10),

          // Campo Email
          _TextoNoEditable(
            titulo: "Email",
            hintText: emailRecibido, 
            icono: Icons.email_outlined,
            textoAyuda: "El email no puede ser modificado",
          ),
          const SizedBox(height: 10),

          // Campo Fecha de registro
          _TextoNoEditable(
            titulo: "Fecha de registro",
            hintText: fechaRegistro, 
            icono: Icons.calendar_month_outlined,
            textoAyuda: "Fecha en la que te registraste",
          ),
          const SizedBox(height: 15),

          // Botón para eliminar la cuenta
          ElevatedButton.icon(
            onPressed: () {
              // Aquí va la lógica para borrar el registro del usuario
              mostrarSnackBarExito(context, "Su cuenta se ha eliminado, gracias por haber compartido sus opiniones con nosotros");
            },
            icon: const Icon(Icons.delete),
            label: const Text("Eliminar mi cuenta"),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==============================================================================
// _TitledInputField (Campo de entrada de una sola línea)
// ==============================================================================
class _TextoEditable extends StatelessWidget {
  final String titulo;
  final String hintText;
  final IconData icono;
  final bool esEditable;
  final String? textoAyuda;

  const _TextoEditable({
    required this.titulo,
    required this.hintText,
    required this.icono,
    this.esEditable = true,
    this.textoAyuda,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            color: _primaryTextColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          readOnly: !esEditable,
          style: const TextStyle(color: _primaryTextColor),
          decoration: InputDecoration(
            // El texto de sugerencia (hintText) es el valor inicial/placeholder
            hintText: hintText, 
            hintStyle: TextStyle(color: _textoEditable),
            prefixIcon: Icon(icono, color: _subtitleColor),
            fillColor: _inputBackgroundColor,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          ),
        ),
        if (textoAyuda != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 10),
            child: Text(
              textoAyuda!,
              style: const TextStyle(color: _subtitleColor, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

// ==============================================================================
// _TextoNoEditable
// ==============================================================================
class _TextoNoEditable extends StatelessWidget {
  final String titulo;
  final String hintText;
  final IconData icono;
  final bool esEditable;
  final String? textoAyuda;

  const _TextoNoEditable({
    required this.titulo,
    required this.hintText,
    required this.icono,
    this.esEditable = false,
    this.textoAyuda,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            color: _primaryTextColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          readOnly: !esEditable,
          style: const TextStyle(color: _primaryTextColor),
          decoration: InputDecoration(
            // El texto de sugerencia (hintText) es el valor inicial/placeholder
            hintText: hintText, 
            hintStyle: TextStyle(color: _textoNoEditable),
            prefixIcon: Icon(icono, color: _subtitleColor),
            fillColor: _inputBackgroundColor,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          ),
        ),
        if (textoAyuda != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 10),
            child: Text(
              textoAyuda!,
              style: const TextStyle(color: _subtitleColor, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
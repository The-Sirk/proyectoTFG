import 'package:flutter/material.dart';
import 'package:flixscore/componentes/common/snack_bar.dart';
import 'package:flixscore/service/api_service.dart';

const Color _primaryTextColor = Colors.white;
const Color _subtitleColor = Color(0xFF9CA3AF);
const Color _textoNoEditable = Color(0xFF5D5F63);
const Color _cardBackgroundColor = Color(0xFF1A1C25);
const Color _inputBackgroundColor = Color(0xFF1F2937);
const Color _accentColor = Color(0xFFEF4444);

class InformacionBasicaCard extends StatefulWidget {
  final String nombreRecibido;
  final String emailRecibido;
  final String fechaRegistro;
  final String usuarioId;
  final Function(String) onNickActualizado;

  const InformacionBasicaCard({
    super.key,
    required this.nombreRecibido,
    required this.emailRecibido,
    required this.fechaRegistro,
    required this.usuarioId,
    required this.onNickActualizado,
  });

  @override
  State<InformacionBasicaCard> createState() => _InformacionBasicaCardState();
}

class _InformacionBasicaCardState extends State<InformacionBasicaCard> {
  late TextEditingController _nickController;

  @override
  void initState() {
    super.initState();
    _nickController = TextEditingController(text: widget.nombreRecibido);
  }

  @override
  void dispose() {
    _nickController.dispose();
    super.dispose();
  }

  // Lógica del botón de guardar cambios (Nick)
  Future<void> _guardarCambios() async {
    final nuevoNick = _nickController.text.trim();
    if (nuevoNick.isEmpty) {
      mostrarSnackBarError(context, "El nick no puede estar vacío");
      return;
    }

    try {
      await ApiService().cambiarNick(widget.usuarioId, nuevoNick);
      mostrarSnackBarExito(context, "Nick actualizado con éxito");
      widget.onNickActualizado(nuevoNick);
    } catch (e) {
      mostrarSnackBarError(context, "Error al actualizar nick: $e");
    }
  }

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

          _TextoEditable(
            titulo: "Nick",
            controller: _nickController,
            icono: Icons.person_outline,
            textoAyuda: "Da este Nick a tus amigos para ser agregado",
          ),
          const SizedBox(height: 10),

          _TextoNoEditable(
            titulo: "Email",
            hintText: widget.emailRecibido,
            icono: Icons.email_outlined,
            textoAyuda: "El email no puede ser modificado",
          ),
          const SizedBox(height: 10),

          _TextoNoEditable(
            titulo: "Fecha de registro",
            hintText: widget.fechaRegistro,
            icono: Icons.calendar_month_outlined,
            textoAyuda: "Fecha en la que te registraste",
          ),
          const SizedBox(height: 15),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  mostrarSnackBarExito(
                    context,
                    "Su cuenta se ha eliminado, gracias por haber compartido sus opiniones con nosotros",
                  );
                },
                icon: const Icon(Icons.delete),
                label: const Text("Eliminar mi cuenta"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _guardarCambios,
                icon: const Icon(Icons.save),
                label: const Text("Guardar cambios"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==============================================================================
// _TextoEditable con controller
// ==============================================================================
class _TextoEditable extends StatelessWidget {
  final String titulo;
  final TextEditingController controller;
  final IconData icono;
  final String? textoAyuda;

  const _TextoEditable({
    required this.titulo,
    required this.controller,
    required this.icono,
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
          controller: controller,
          style: const TextStyle(color: _primaryTextColor),
          decoration: InputDecoration(
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
  final String? textoAyuda;

  const _TextoNoEditable({
    required this.titulo,
    required this.hintText,
    required this.icono,
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
          readOnly: true,
          style: const TextStyle(color: _primaryTextColor),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: _textoNoEditable),
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
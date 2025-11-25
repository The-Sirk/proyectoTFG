import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flixscore/controllers/login_provider.dart';

const Color _primaryTextColor = Colors.white;
const Color _subtitleColor = Color(0xFF9CA3AF);
const Color _textoEditable = Color.fromARGB(255, 174, 176, 179);
const Color _cardBackgroundColor = Color(0xFF1A1C25);
const Color _inputBackgroundColor = Color(0xFF1F2937);

class BuscarUsuarioCard extends StatefulWidget {
  final VoidCallback onAmigoAgregado;

  const BuscarUsuarioCard({
    super.key,
    required this.onAmigoAgregado,
  });

  @override
  State<BuscarUsuarioCard> createState() => BuscarUsuarioCardState();
}

class BuscarUsuarioCardState extends State<BuscarUsuarioCard> {
  final TextEditingController _searchController = TextEditingController();

  void clearText() {
    _searchController.clear();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _buscarYagregar(BuildContext context) async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    
    FocusScope.of(context).unfocus(); 

    final provider = Provider.of<LoginProvider>(context, listen: false);
    
    final bool agregadoExitosamente = await provider.buscarYAgregarAmigo(context, query);

    if (agregadoExitosamente) {
      clearText();
      widget.onAmigoAgregado(); 
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
            "Buscar Amigos",
            style: TextStyle(
              color: _primaryTextColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Introduce el Nick de tu amigo para encontrarlo",
            style: TextStyle(
              color: _subtitleColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _searchController,
            onSubmitted: (_) => _buscarYagregar(context), 
            style: const TextStyle(color: _primaryTextColor),
            decoration: InputDecoration(
              hintText: 'Ejemplo: NickAmigote123',
              hintStyle: const TextStyle(color: _textoEditable),
              prefixIcon: const Icon(Icons.person_search_outlined, color: _subtitleColor),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search, color: _subtitleColor),
                onPressed: () => _buscarYagregar(context), 
                tooltip: 'Buscar',
              ),
              fillColor: _inputBackgroundColor,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            ),
            cursorColor: _primaryTextColor,
          ),
        ],
      ),
    );
  }
}
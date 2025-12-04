import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// Widget para los enlaces de Términos y Política de Privacidad
class LegalLinksWidget extends StatelessWidget {
  const LegalLinksWidget({super.key});

  // Función para abrir la URL externa
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(
      url,
      mode: LaunchMode.platformDefault,
      webOnlyWindowName: '_blank',
    )) {
      throw Exception('No se pudo lanzar la URL: $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    const String termsUrl = 'https://flixscore.es/terminos-servicio.html';
    const String privacyUrl = 'https://flixscore.es/politica-privacidad.html';

    // Color de texto claro para el fondo oscuro
    const TextStyle linkStyle = TextStyle(
      color: Colors
          .grey, // Un color gris para que se vea como un enlace en el footer.
      fontSize: 12,
    );

    // Contenedor centrado para que los enlaces no ocupen todo el ancho
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // Solo ocupa el espacio necesario.
          children: [
            TextButton(
              onPressed: () => _launchUrl(termsUrl),
              child: const Text('Términos de Servicio', style: linkStyle),
            ),

            // Separador
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('|', style: linkStyle),
            ),

            TextButton(
              onPressed: () => _launchUrl(privacyUrl),
              child: const Text('Política de Privacidad', style: linkStyle),
            ),
          ],
        ),
      ),
    );
  }
}

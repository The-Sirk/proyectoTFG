import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flixscore/main.dart' as app;
import 'package:flutter/material.dart';




void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> safe(Future<void> Function() step) async {
    try {
      await step();
    } catch (e) {
      /* Deja de detectar el alertdialog al hacer clic y bloquea la ejecucion si no se controla con este Try/catch*/
      fail('Error: $e');
    }
  }

  testWidgets('Ver el perfil de un amigo', (WidgetTester tester) async {
    // Llamado de la aplicacion que queremos ejecutar
    await tester.runAsync(() async {
      app.main();
    });   
    // Esperar a que cargue toda la aplicacion
    await tester.pumpAndSettle();
    // Esperar 1 segundos para elementos visuales
    await tester.pump(const Duration(seconds: 1));

    // Iniciar sesion
    final usuariologin = find.byKey(Key('textfield_email_login'));
    await tester.enterText(usuariologin, 'Testing3@Testing3.es');
    final passlogin = find.byKey(Key('textfield_password_login'));
    await tester.enterText(passlogin, 'Testing3');
    final btninicio = find.byKey(Key('boton_enviar'));
    
    await tester.tap(btninicio);
    
    await tester.pumpAndSettle();

    await tester.pump(const Duration(seconds: 1));

    // Navegar al perfil
    await tester.tap(find.byKey(Key("menu_perfil")));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byKey(Key("menuitem_verPerfil")));
    
    await tester.pumpAndSettle();

    await tester.pump(const Duration(seconds: 2));


    // Ver el perfil del amigo agregado
    await safe(() async => tester.tap(find.byKey(Key('ListaAmigos'))));  
    await tester.pumpAndSettle();

    

    // Esperar la carga
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));



  });


}
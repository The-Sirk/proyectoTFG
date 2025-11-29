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

    Future<void> pumpUntilFoundandTap(WidgetTester tester, Finder finder,
      {Duration timeout = const Duration(seconds: 10)}) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 100));
      if (finder.evaluate().isNotEmpty){
        await safe(() async => tester.tap(finder));
        return;
      }
    }
    fail('No se encontró el widget: $finder');
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
    await tester.enterText(usuariologin, 'Testing@Testing.es');
    final passlogin = find.byKey(Key('textfield_password_login'));
    await tester.enterText(passlogin, 'Testing');
    final btninicio = find.byKey(Key('boton_enviar'));
    
    await tester.tap(btninicio);
    
    await tester.pumpAndSettle();

    await tester.pump(const Duration(seconds: 1));

    // Seleccionar pelicula
    await pumpUntilFoundandTap(tester, find.byKey(Key('card_pelicula')).first);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));

    // Escribir critica y valorar
    await tester.tap(find.byKey(Key('botonEscribirCritica')));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byKey(Key('botonEscribirCritica')));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byKey(Key('botonEscribirCritica')));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byKey(Key('estrella_6')));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));

///Pendiente añadir texto y guardar

    // Navegar al perfil
    await tester.tap(find.byKey(Key("menu_perfil")));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byKey(Key("menuitem_verPerfil")));
    
    await tester.pumpAndSettle();

    await tester.pump(const Duration(seconds: 2));

/*
    // Ver el perfil del amigo agregado
    await safe(() async => tester.tap(find.byKey(Key('ListaAmigos'))));  
    await tester.pumpAndSettle();
*/
    

    // Esperar la carga
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));



  });


}
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

  testWidgets('Login con credenciales válidas, agregar/eliminar amigo', (WidgetTester tester) async {
    // Llamado de la aplicacion que queremos ejecutar
    await tester.runAsync(() async {
      app.main();
    });   
    // Esperar a que cargue toda la aplicacion
    await tester.pumpAndSettle();
    // Esperar 1 segundos
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

    // Navegar al perfil
    await tester.tap(find.byKey(Key("menu_perfil")));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byKey(Key("menuitem_verPerfil")));
    
    await tester.pumpAndSettle();

    await tester.pump(const Duration(seconds: 2));

    // Buscar amigo y agregar
    final buscarAmigo = find.byKey(Key('Busqueda_Amigo'));
    await tester.enterText(buscarAmigo, 'Sirk');
    await tester.pump(const Duration(seconds: 5));
    await tester.tap(find.byKey(Key('Buscar')));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byKey(Key('CircleAvatar')));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    final cancelar = find.text('Cancelar');
    final Agregar = find.text('Agregar');

    await safe(() async => tester.tap(cancelar));
    await tester.pumpAndSettle();
    
    await tester.tap(buscarAmigo);
    await tester.enterText(buscarAmigo, 'Sirk');
    await tester.pump(const Duration(seconds: 5));
    await tester.tap(find.byKey(Key('Buscar')));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byKey(Key('CircleAvatar')));

    await tester.pumpAndSettle();
  
    await safe(() async => tester.tap(Agregar));
    await tester.pumpAndSettle();
    
    // Eliminar el amigo agregado
    await safe(() async => tester.tap(find.byKey(Key('botonEliminarAmigoUsuario'))));  
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));

    
    await safe(() async => tester.tap(cancelar));
    await tester.pumpAndSettle();
    
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byKey(Key('botonEliminarAmigoUsuario')));  
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    await safe(() async => tester.tap(find.text('Confirmar')));

    // Esperar la eliminacion
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));



  });


}
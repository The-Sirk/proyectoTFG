import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/services.dart';
import 'package:flixscore/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flixscore/componentes/common/tab_button.dart';
import 'package:flixscore/componentes/home/components/popup_menu_home.dart';



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

    Future<void> pumpUntilFound(WidgetTester tester, Finder finder,
      {Duration timeout = const Duration(seconds: 10)}) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 100));
      if (finder.evaluate().isNotEmpty)return;
    }
    fail('No se encontró el widget: $finder');
  }
  testWidgets('Registro con credenciales válidas y eliminacion de cuenta', (WidgetTester tester) async {
    // Llamado de la aplicacion que queremos ejecutar
    await tester.runAsync(() async {
      app.main();
    });   
    // Esperar a que cargue toda la aplicacion
    await tester.pumpAndSettle();
    // Esperar 1 segundos para elementos visuales
    await tester.pump(const Duration(seconds: 1));


    // Registro de usuario 
    await pumpUntilFoundandTap(tester, find.byKey(Key('tab_registrarse')));
    await tester.pumpAndSettle();

    // Esperar 1 segundos para elementos visuales
    await tester.pump(const Duration(seconds: 1));

    final usuario = find.byKey(Key('textfield_username_registro'));
    await tester.enterText(usuario, 'Testing2');
    await tester.pump(const Duration(seconds: 1));

    final usuariologin = find.byKey(Key('textfield_email_registro'));
    await tester.enterText(usuariologin, 'Testing2@Testing2.es');
    await tester.pump(const Duration(seconds: 1));

    final passlogin = find.byKey(Key('textfield_password_registro'));
    await tester.enterText(passlogin, 'Testing2');
    await tester.pump(const Duration(seconds: 1));

    final repetpasslogin = find.byKey(Key('textfield_repeatPassword_registro'));
    await tester.enterText(repetpasslogin, 'Testing2');
    await tester.pump(const Duration(seconds: 1));

  
    // Enviar los datos del registro
    final btninicio = find.byKey(Key('boton_enviar'));
    await tester.tap(btninicio);    
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));

    // Navegar al perfil
    await pumpUntilFoundandTap(tester, find.byKey(Key('menu_perfil')));
    await tester.pump(const Duration(seconds: 1));
    await pumpUntilFoundandTap(tester, find.byKey(Key("menuitem_verPerfil")));
    await tester.pumpAndSettle();

    await tester.pump(const Duration(seconds: 2));

    // Eliminacion del perfil

    await safe(() async => tester.tap(find.byKey(Key('botonEliminarCuenta')))); 
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));

    await safe(() async => tester.tap(find.text('Cancelar')));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));

    await safe(() async => tester.tap(find.byKey(Key('botonEliminarCuenta')))); 
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));

    await safe(() async =>tester.tap(find.text('SÍ, ELIMINAR')));
    await tester.pumpAndSettle();

    await tester.pump(const Duration(seconds: 2));


   
    
/*
    await tester.pumpAndSettle();
    final usuariologi = find.widgetWithText(TextField, 'tu@email.com');
    // Introducir Texto en el campo TextField
    await tester.enterText(usuariologi, 'Testing2@Testing.es');
    // Busqueda de campo tipo TextField sin ID por hintText
    final passlog = find.widgetWithText(TextField, '••••••••');
    await tester.enterText(passlog, 'Testing2');
    final btnini = find.text('Iniciar Sesión');
    
    // Hacer clic en el boton de inicio
    await tester.tap(btnini);
    
    await tester.pumpAndSettle();
*/
/*
    await tester.pump(const Duration(seconds: 2));
    await tester.showKeyboard(find.byKey(Key('Buscar')));
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    await tester.pump(const Duration(seconds: 2));
    await tester.tap(find.byKey(Key('BuscarAgregar')));
    await tester.pumpAndSettle();
*/

/*
    // Verifica que los campos estén presentes
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.text('Iniciar Sesión'), findsWidgets);

    // Ingresa email y contraseña
    await tester.enterText(find.byType(TextFormField).at(0), 'usuario@ejemplo.com');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');

    // Pulsa el botón de login
    await tester.tap(find.widgetWithText(ElevatedButton, 'Iniciar Sesión'));
    await tester.pumpAndSettle();

    // Verifica que se redirige al home o muestra mensaje de éxito
    expect(find.text('Bienvenido'), findsOneWidget);

*/
  });


}
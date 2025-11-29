import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/services.dart';
import 'package:flixscore/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flixscore/componentes/common/tab_button.dart';
import 'package:flixscore/componentes/home/components/popup_menu_home.dart';



void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();


  testWidgets('Login con credenciales válidas, agregar/eliminar amigo', (WidgetTester tester) async {
    // Llamado de la aplicacion que queremos ejecutar
    await tester.runAsync(() async {
      app.main();
    });   
    // Esperar a que cargue toda la aplicacion
    await tester.pumpAndSettle();
    // Esperar 1 segundos
    await tester.pump(const Duration(seconds: 1));
    // Busqueda de campo tipo TextField sin ID por hintText
    final usuariologin = find.byKey(Key('textfield_email_login'));
    // Introducir Texto en el campo TextField
    await tester.enterText(usuariologin, 'Testing@Testing.es');
    // Busqueda de campo tipo TextField sin ID por hintText
    final passlogin = find.byKey(Key('textfield_password_login'));
    await tester.enterText(passlogin, 'Testing');
    final btninicio = find.byKey(Key('boton_enviar'));
    
    // Hacer clic en el boton de inicio
    await tester.tap(btninicio);
    
    await tester.pumpAndSettle();

    await tester.pump(const Duration(seconds: 1));
    // Pulsar en icono de perfil
    
    await tester.tap(find.byKey(Key("menu_perfil")));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byKey(Key("menuitem_verPerfil")));
    
    await tester.pumpAndSettle();

    await tester.pump(const Duration(seconds: 2));

    // Buscar amigo
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

    try{
    await tester.tap(cancelar);
    await tester.pumpAndSettle();
    } catch (e){/* Deja de detectar el alertdialog y bloquea la ejecucion si no se controla con este Try/catch*/}
    await tester.tap(buscarAmigo);
    await tester.enterText(buscarAmigo, 'Sirk');
    await tester.pump(const Duration(seconds: 5));
    await tester.tap(find.byKey(Key('Buscar')));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byKey(Key('CircleAvatar')));

    await tester.pumpAndSettle();
    try{
    await tester.tap(Agregar);
    await tester.pumpAndSettle();
    } catch (e){/* Deja de detectar el alertdialog y bloquea la ejecucion si no se controla con este Try/catch*/}

    // Esta seccion es para eliminar el amigo agregado
    await tester.tap(find.byKey(Key('botonEliminarAmigoUsuario')));  
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));

    try{
    await tester.tap(cancelar);
    await tester.pumpAndSettle();
    } catch (e){/* Deja de detectar el alertdialog y bloquea la ejecucion si no se controla con este Try/catch*/}
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byKey(Key('botonEliminarAmigoUsuario')));  
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));

    try{
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();
    } catch (e){/* Deja de detectar el alertdialog y bloquea la ejecucion si no se controla con este Try/catch*/}

    
/*
    await tester.pump(const Duration(seconds: 2));
    await tester.showKeyboard(find.byKey(Key('Buscar')));
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    await tester.pump(const Duration(seconds: 2));
    await tester.tap(find.byKey(Key('BuscarAgregar')));
    await tester.pumpAndSettle();
*/
    await tester.pump(const Duration(seconds: 2));
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
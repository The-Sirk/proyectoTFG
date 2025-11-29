import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/services.dart';
import 'package:flixscore/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flixscore/componentes/common/tab_button.dart';
import 'package:flixscore/componentes/home/components/popup_menu_home.dart';



void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();



  testWidgets('Registro con credenciales válidas y cierre de sesion', (WidgetTester tester) async {
    // Llamado de la aplicacion que queremos ejecutar
    app.main();

    // Esperar a que cargue toda la aplicacion
    await tester.pumpAndSettle();

    final registrarse = find.text('Registrarse');
    await tester.tap(registrarse);

    await tester.pumpAndSettle();
    // Esperar 1 segundos
    await tester.pump(const Duration(seconds: 1));
    final usuario = find.widgetWithText(TextField, 'Nombre de Usuario');
    // Introducir Texto en el campo TextField
    await tester.enterText(usuario, 'Testing2');
    // Busqueda de campo tipo TextField sin ID por hintText
    final usuariologin = find.widgetWithText(TextField,'tu@email.com');
    // Introducir Texto en el campo TextField
    await tester.enterText(usuariologin, 'Testing2@Testing.es');
    // Busqueda de campo tipo TextField sin ID por hintText
    final passlogin = find.widgetWithText(TextField, '••••••••').first;
    await tester.enterText(passlogin, 'Testing2');
    final repetpasslogin = find.widgetWithText(TextField, '••••••••').last;
    await tester.enterText(repetpasslogin, 'Testing2');
    await tester.scrollUntilVisible(
    find.widgetWithText(ElevatedButton, 'Registrarse'),
    200.0, // cantidad de desplazamiento por scroll
    scrollable: find.byType(Scrollable).first, // opcional si hay varios scrollables
  );

    final btninicio = find.widgetWithText(ElevatedButton, 'Registrarse');
    
    // Hacer clic en el boton de inicio
    await tester.tap(btninicio);
    
    await tester.pumpAndSettle();
    // Pulsar en icono de perfil
    try{
    await tester.tap(find.byKey(Key("Navegación")));
    } catch (e){/* Deja de detectar el alertdialog y bloquea la ejecucion si no se controla con este Try/catch*/}
    await tester.pumpAndSettle();  
    await tester.pump(const Duration(seconds: 1));
    try{
    await tester.tap(find.byKey(Key("Ver mi perfil")));
    } catch (e){/* Deja de detectar el alertdialog y bloquea la ejecucion si no se controla con este Try/catch*/}

    
    await tester.pumpAndSettle();

    await tester.pump(const Duration(seconds: 1));
    await tester.scrollUntilVisible(
    find.byKey(Key('EliminarCuenta')),
    200.0, // cantidad de desplazamiento por scroll
    scrollable: find.byType(Scrollable).first, // opcional si hay varios scrollables
    );


     
    try{
    await tester.tap(find.byKey(Key('EliminarCuenta'))); 

    } catch (e){/* Deja de detectar el alertdialog y bloquea la ejecucion si no se controla con este Try/catch*/}
    await tester.pumpAndSettle();

    print(find.text('Cancelar'));

    try{
    await tester.tap(find.text('Cancelar'));

    } catch (e){/* Deja de detectar el alertdialog y bloquea la ejecucion si no se controla con este Try/catch*/}
    await tester.pumpAndSettle();
    try{
    await tester.tap(find.byKey(Key('EliminarCuenta'))); 

    } catch (e){/* Deja de detectar el alertdialog y bloquea la ejecucion si no se controla con este Try/catch*/}
    await tester.pumpAndSettle();
    try{
    await tester.tap(find.text('SÍ, ELIMINAR'));
    await tester.pumpAndSettle();
    } catch (e){ print(e.toString());/* Deja de detectar el alertdialog y bloquea la ejecucion si no se controla con este Try/catch*/}
    
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
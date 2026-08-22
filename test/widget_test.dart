import 'package:despensa/app/despensa_app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('muestra la pantalla de inicio de sesión', (tester) async {
    await tester.pumpWidget(const DespensaApp());

    expect(find.text('Hola de nuevo'), findsOneWidget);
    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}

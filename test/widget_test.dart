import 'package:despensa/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('muestra la presentación inicial de Despensa', (tester) async {
    await tester.pumpWidget(const DespensaApp());

    expect(find.text('Despensa'), findsOneWidget);
    expect(find.text('Tu hogar, mejor organizado'), findsOneWidget);
    expect(
      find.text('Proyecto base configurado correctamente.'),
      findsOneWidget,
    );
  });
}

import 'package:despensa/app/despensa_app.dart';
import 'package:despensa/core/services/local_storage.dart';
import 'package:despensa/core/services/household_data_service.dart';
import 'package:despensa/features/inventory/presentation/inventory_screen.dart';
import 'package:despensa/features/inventory/presentation/product_form_screen.dart';
import 'package:despensa/features/households/presentation/households_screen.dart';
import 'package:despensa/features/cart/presentation/cart_screen.dart';
import 'package:despensa/features/members/presentation/members_screen.dart';
import 'package:despensa/features/activity/data/activity_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('conserva datos en el almacenamiento local', () async {
    const data = [
      {'name': 'Casa persistente', 'members': 1},
    ];

    await LocalStorage.writeList('test.households', data);

    expect(await LocalStorage.readList('test.households'), data);
  });

  test('conserva el identificador remoto de un producto', () {
    final product = ProductFormData.fromJson({
      '_id': 'producto-123',
      'name': 'Arroz',
      'units': 2,
    });

    expect(product.id, 'producto-123');
    expect(product.toJson()['_id'], 'producto-123');
  });

  test('sincroniza inventario y cesta juntos en modo local', () async {
    await HouseholdDataService.saveMany(
      householdName: 'Casa sincronizada',
      householdId: null,
      sections: {
        'inventory': [
          {'name': 'Arroz', 'units': 2},
        ],
        'cart': [
          {'name': 'Leche', 'units': 1, 'completed': false},
        ],
      },
    );

    final inventory = await LocalStorage.readList(
      LocalStorage.householdKey('inventory', 'Casa sincronizada'),
    );
    final cart = await LocalStorage.readList(
      LocalStorage.householdKey('cart', 'Casa sincronizada'),
    );
    expect(inventory?.single['name'], 'Arroz');
    expect(cart?.single['name'], 'Leche');
  });

  test('actualiza y elimina un documento individual en modo local', () async {
    final created = await HouseholdDataService.upsert(
      section: 'inventory',
      householdName: 'Casa granular',
      householdId: null,
      data: {'name': 'Arroz', 'units': 1},
    );
    expect(created['_id'], isNotEmpty);

    final updated = await HouseholdDataService.upsert(
      section: 'inventory',
      householdName: 'Casa granular',
      householdId: null,
      data: {...created, 'units': 3},
    );
    var stored = await LocalStorage.readList(
      LocalStorage.householdKey('inventory', 'Casa granular'),
    );
    expect(stored, hasLength(1));
    expect(updated['units'], 3);

    await HouseholdDataService.deleteItem(
      section: 'inventory',
      householdName: 'Casa granular',
      householdId: null,
      data: updated,
    );
    stored = await LocalStorage.readList(
      LocalStorage.householdKey('inventory', 'Casa granular'),
    );
    expect(stored, isEmpty);
  });

  test('ordena la actividad local de más reciente a más antigua', () async {
    await ActivityService.record(
      householdName: 'Casa historial',
      householdId: null,
      description: 'añadió arroz',
    );
    await ActivityService.record(
      householdName: 'Casa historial',
      householdId: null,
      description: 'vació la cesta',
    );
    final activity = await ActivityService.load(
      householdName: 'Casa historial',
      householdId: null,
    );
    expect(activity.map((entry) => entry.description), [
      'vació la cesta',
      'añadió arroz',
    ]);
  });

  testWidgets('muestra la pantalla de inicio de sesión', (tester) async {
    await tester.pumpWidget(const DespensaApp());

    expect(find.text('Hola de nuevo'), findsOneWidget);
    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });

  testWidgets('muestra los hogares después de iniciar sesión', (tester) async {
    await tester.pumpWidget(const DespensaApp());

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'test@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();

    expect(find.text('Mis hogares'), findsOneWidget);
    expect(find.text('Casa García'), findsOneWidget);
    expect(find.text('Piso Córdoba'), findsOneWidget);
    expect(find.text('Crear hogar'), findsOneWidget);
  });

  testWidgets('abre el hogar seleccionado', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HouseholdsScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Piso Córdoba'));
    await tester.pumpAndSettle();

    expect(find.text('Piso Córdoba'), findsOneWidget);
    expect(find.text('Inicio'), findsOneWidget);

    await tester.tap(find.byTooltip('Volver a mis hogares'));
    await tester.pumpAndSettle();
    expect(find.text('Mis hogares'), findsOneWidget);
  });

  testWidgets('permite crear un hogar', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HouseholdsScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Casa de verano');
    await tester.tap(find.widgetWithText(FilledButton, 'Crear'));
    await tester.pumpAndSettle();

    expect(find.text('Casa de verano'), findsOneWidget);
    expect(find.text('1 miembro'), findsOneWidget);
  });

  testWidgets('abre el perfil desde la lista de hogares', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HouseholdsScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Ver perfil'));
    await tester.pumpAndSettle();
    expect(find.text('Mi perfil'), findsOneWidget);
    expect(find.text('Cambiar nombre'), findsOneWidget);
    expect(find.text('Cambiar contraseña'), findsOneWidget);
    expect(find.text('Eliminar cuenta'), findsOneWidget);
  });

  testWidgets('filtra los productos del inventario por nombre', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: InventoryScreen()));

    await tester.enterText(find.byType(TextField), 'leche');
    await tester.pump();

    expect(find.text('Leche semidesnatada'), findsOneWidget);
    expect(find.text('Manzanas Galas'), findsNothing);
  });

  testWidgets('permite reducir rápidamente la cantidad', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: InventoryScreen()));

    expect(find.text('6 uds.'), findsOneWidget);
    await tester.tap(find.byTooltip('Reducir cantidad').first);
    await tester.pump();

    expect(find.text('5 uds.'), findsOneWidget);
  });

  testWidgets('muestra cantidades con su unidad', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: InventoryScreen()));

    expect(find.text('6 uds.'), findsOneWidget);
    expect(find.text('1 uds. / 500 g'), findsOneWidget);
  });

  testWidgets('permite establecer rápidamente las unidades', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: InventoryScreen()));
    await tester.tap(find.text('6 uds.'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '9');
    await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
    await tester.pumpAndSettle();
    expect(find.text('9 uds.'), findsOneWidget);
  });

  testWidgets('filtra productos agotados', (tester) async {
    await LocalStorage.writeList(
      LocalStorage.householdKey('inventory', 'filtros'),
      [
        {
          'name': 'Vacío',
          'units': 0,
          'amount': null,
          'measurementUnit': 'g',
          'expirationDate': null,
        },
        {
          'name': 'Lleno',
          'units': 2,
          'amount': null,
          'measurementUnit': 'g',
          'expirationDate': null,
        },
      ],
    );
    await tester.pumpWidget(
      const MaterialApp(home: InventoryScreen(householdName: 'filtros')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Agotados'));
    await tester.pump();
    expect(find.text('Vacío'), findsOneWidget);
    expect(find.text('Lleno'), findsNothing);
  });

  testWidgets('abre añadir producto en un panel inferior', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: InventoryScreen()));

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text('Añadir producto'), findsWidgets);
    expect(find.text('Despensa'), findsOneWidget);
  });

  testWidgets('envía productos del inventario a la cesta', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: InventoryScreen()));
    await tester.pumpAndSettle();

    final productCard = find.ancestor(
      of: find.text('Manzanas Galas'),
      matching: find.byType(Card),
    );
    final menu = find.descendant(
      of: productCard,
      matching: find.byType(PopupMenuButton<String>),
    );
    await tester.tap(menu);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Añadir a la cesta'));
    await tester.pumpAndSettle();

    final stored = await LocalStorage.readList(
      LocalStorage.householdKey('cart', 'demo'),
    );
    expect(stored?.any((item) => item['name'] == 'Manzanas Galas'), isTrue);
    expect(find.text('Producto añadido a la cesta'), findsOneWidget);
  });

  testWidgets('propone uds. sin incluirlo en el valor escrito', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProductFormScreen()));

    final unitsField = tester.widget<TextFormField>(
      find.byType(TextFormField).at(1),
    );
    final unitsTextField = tester.widget<TextField>(
      find.byType(TextField).at(1),
    );
    expect(unitsField.controller?.text, '1');
    expect(unitsTextField.decoration?.suffixText, 'uds.');
    expect(find.text('Unidades'), findsOneWidget);
    expect(find.text('Cantidad (opcional)'), findsOneWidget);
  });

  testWidgets('añade elementos a la cesta', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CartScreen()));

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Arroz');
    await tester.enterText(find.byType(TextFormField).at(1), '2');
    await tester.enterText(find.byType(TextFormField).at(2), '500');
    await tester.tap(find.text('Añadir elemento'));
    await tester.pumpAndSettle();

    expect(find.text('Arroz'), findsOneWidget);
    expect(find.text('2 uds. / 500 g'), findsOneWidget);
  });

  testWidgets('elimina elementos de la cesta', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CartScreen()));

    await tester.tap(find.byTooltip('Opciones de Café en grano'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar').last);
    await tester.pump();

    expect(find.text('Café en grano'), findsNothing);
    expect(find.text('Deshacer'), findsOneWidget);
  });

  testWidgets('edita elementos de la cesta', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CartScreen()));

    await tester.tap(find.byTooltip('Opciones de Café en grano'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(1), '3');
    await tester.tap(find.text('Guardar cambios'));
    await tester.pumpAndSettle();

    expect(find.text('3 uds. / 1 kg'), findsOneWidget);
    expect(find.text('Elemento actualizado'), findsOneWidget);
  });

  testWidgets('incorpora los productos comprados al inventario', (
    tester,
  ) async {
    final inventoryKey = LocalStorage.householdKey('inventory', 'demo');
    await LocalStorage.writeList(inventoryKey, [
      {
        'name': 'Huevos camperos',
        'units': 2,
        'amount': null,
        'measurementUnit': 'g',
        'expirationDate': null,
      },
    ]);
    await tester.pumpWidget(const MaterialApp(home: CartScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Guardar comprados en despensa'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
    await tester.pumpAndSettle();

    final inventory = await LocalStorage.readList(inventoryKey);
    expect(inventory?.single['units'], 14);
    expect(find.text('Huevos camperos'), findsNothing);
    expect(find.text('Compra incorporada a la despensa'), findsOneWidget);
  });

  testWidgets('vacía por completo la cesta', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CartScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Vaciar cesta'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Vaciar'));
    await tester.pumpAndSettle();
    expect(find.text('La cesta está vacía'), findsOneWidget);
    expect(find.text('Cesta vaciada'), findsOneWidget);
  });

  testWidgets('invita y elimina miembros del hogar', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: MembersScreen(householdName: 'Casa prueba')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Usuario principal'), findsOneWidget);

    await tester.tap(find.text('Invitar miembro'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'ana@example.com');
    await tester.tap(find.widgetWithText(FilledButton, 'Enviar'));
    await tester.pumpAndSettle();
    expect(find.text('ana'), findsOneWidget);
    expect(find.text('Miembro · ana@example.com'), findsOneWidget);

    await tester.tap(find.byTooltip('Opciones de ana'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar miembro'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Eliminar'));
    await tester.pumpAndSettle();
    expect(find.text('ana'), findsNothing);
    expect(find.text('Usuario principal'), findsOneWidget);
  });
}

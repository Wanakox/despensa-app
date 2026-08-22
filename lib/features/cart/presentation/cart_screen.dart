import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final completed = <int>{0};
  final items = const [('Huevos camperos', '1 docena'), ('Café en grano', '2 bolsas'), ('Tomates cherry', '1 pack'), ('Pan de molde', '1 ud')];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cesta de la compra')),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final checked = completed.contains(index);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: CheckboxListTile(
                value: checked,
                onChanged: (value) => setState(() => value == true ? completed.add(index) : completed.remove(index)),
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(item.$1, style: TextStyle(fontWeight: FontWeight.w700, decoration: checked ? TextDecoration.lineThrough : null)),
                subtitle: Text('Cantidad: ${item.$2}'),
                secondary: IconButton(onPressed: () {}, icon: const Icon(Icons.delete_outline)),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => _showAddItem(context), child: const Icon(Icons.add)),
    );
  }

  Future<void> _showAddItem(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.viewInsetsOf(context).bottom + 24),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Añadir a la cesta', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),
            const AppTextField(label: 'Nombre', hintText: 'Ej. Arroz'),
            const SizedBox(height: 16),
            const AppTextField(label: 'Cantidad', hintText: 'Ej. 2', keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            const AppTextField(label: 'Unidad', hintText: 'Ej. paquetes'),
            const SizedBox(height: 24),
            AppPrimaryButton(label: 'Añadir elemento', onPressed: () => Navigator.pop(context)),
          ]),
        ),
      ),
    );
  }
}

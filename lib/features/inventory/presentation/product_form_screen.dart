import 'package:flutter/material.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';

class ProductFormScreen extends StatelessWidget {
  const ProductFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Añadir producto')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        children: [
          const AppTextField(label: 'Nombre del producto', hintText: 'Ej. Yogur griego'),
          const SizedBox(height: 20),
          const AppTextField(label: 'Cantidad', hintText: 'Ej. 3', keyboardType: TextInputType.number),
          const SizedBox(height: 20),
          const AppTextField(label: 'Unidad', hintText: 'Ej. uds, g o botellas'),
          const SizedBox(height: 20),
          const AppTextField(label: 'Fecha de caducidad (opcional)', hintText: 'dd/mm/aaaa', suffixIcon: Icon(Icons.calendar_today_outlined)),
          const SizedBox(height: 30),
          AppPrimaryButton(label: 'Añadir producto', onPressed: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }
}

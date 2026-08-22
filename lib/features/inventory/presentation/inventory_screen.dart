import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import 'product_form_screen.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  static const products = [
    ('Manzanas Galas', '6 uds', 'Caduca en 2 días', true),
    ('Leche semidesnatada', '3 brik', 'Caduca en 8 días', false),
    ('Filetes de ternera', '500 g', 'Consumir hoy', true),
    ('Detergente líquido', '1 botella', 'Larga duración', false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Despensa')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          const TextField(decoration: InputDecoration(hintText: 'Buscar producto...', prefixIcon: Icon(Icons.search))),
          const SizedBox(height: 18),
          ...products.map((product) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ProductCard(name: product.$1, quantity: product.$2, status: product.$3, urgent: product.$4),
              )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProductFormScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.name, required this.quantity, required this.status, required this.urgent});
  final String name;
  final String quantity;
  final String status;
  final bool urgent;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: const CircleAvatar(backgroundColor: AppColors.primarySoft, child: Icon(Icons.inventory_2_outlined, color: AppColors.primary)),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 4),
          Text('Cantidad: $quantity'),
          const SizedBox(height: 8),
          DecoratedBox(
            decoration: BoxDecoration(color: urgent ? AppColors.accentSoft : AppColors.primarySoft, borderRadius: BorderRadius.circular(8)),
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), child: Text(status, style: TextStyle(color: urgent ? AppColors.accent : AppColors.primaryDark, fontSize: 12, fontWeight: FontWeight.w600))),
          ),
        ]),
        trailing: PopupMenuButton<String>(
          itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Text('Editar')), PopupMenuItem(value: 'delete', child: Text('Eliminar'))],
        ),
      ),
    );
  }
}

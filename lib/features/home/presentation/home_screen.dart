import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/section_title.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.onNavigate, required this.onLogout, super.key});
  final ValueChanged<int> onNavigate;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hola, María', style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 4),
                    Text('Casa García', style: Theme.of(context).textTheme.headlineMedium),
                  ],
                ),
              ),
              IconButton.filledTonal(tooltip: 'Cerrar sesión', onPressed: () => _confirmLogout(context), icon: const Icon(Icons.logout)),
            ],
          ),
          const SizedBox(height: 28),
          const Row(
            children: [
              Expanded(child: _MetricCard(icon: Icons.inventory_2_outlined, value: '42', label: 'En despensa')),
              SizedBox(width: 14),
              Expanded(child: _MetricCard(icon: Icons.shopping_basket_outlined, value: '12', label: 'Para comprar', accent: true)),
            ],
          ),
          const SizedBox(height: 30),
          const SectionTitle('Accesos rápidos'),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _QuickAction(icon: Icons.add_circle_outline, label: 'Ver inventario', onTap: () => onNavigate(1))),
              const SizedBox(width: 14),
              Expanded(child: _QuickAction(icon: Icons.shopping_basket_outlined, label: 'Lista cesta', accent: true, onTap: () => onNavigate(2))),
            ],
          ),
          const SizedBox(height: 30),
          const SectionTitle('Miembros'),
          const SizedBox(height: 14),
          const _MemberTile(name: 'María', activity: 'Hace 10 min', initials: 'M'),
          const SizedBox(height: 12),
          const _MemberTile(name: 'Lucas', activity: 'Hace 1 hora', initials: 'L'),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Quieres salir de tu cuenta?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Cerrar sesión')),
        ],
      ),
    );
    if (shouldLogout == true) onLogout();
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.icon, required this.value, required this.label, this.accent = false});
  final IconData icon;
  final String value;
  final String label;
  final bool accent;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: accent ? AppColors.accent : AppColors.primary),
          const SizedBox(height: 16),
          Text(value, style: Theme.of(context).textTheme.headlineMedium),
          Text(label),
        ]),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.onTap, this.accent = false});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool accent;
  @override
  Widget build(BuildContext context) {
    final color = accent ? AppColors.accent : AppColors.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
        decoration: BoxDecoration(color: accent ? AppColors.accentSoft : AppColors.primarySoft, borderRadius: BorderRadius.circular(18)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: color), const SizedBox(width: 8), Flexible(child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700)))]),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.name, required this.activity, required this.initials});
  final String name;
  final String activity;
  final String initials;
  @override
  Widget build(BuildContext context) {
    return Card(child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), leading: CircleAvatar(backgroundColor: AppColors.primarySoft, child: Text(initials)), title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text(activity)));
  }
}

import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';

class MembersScreen extends StatelessWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Miembros del hogar')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(20)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Invitar nuevo miembro', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primaryDark)),
              const SizedBox(height: 8),
              const Text('Comparte un enlace de invitación o envíalo por correo.'),
              const SizedBox(height: 18),
              AppPrimaryButton(label: 'Invitar miembro', icon: Icons.add_circle_outline, onPressed: () {}),
            ]),
          ),
          const SizedBox(height: 22),
          const _MemberCard(name: 'María García', role: 'Propietario', initials: 'MG'),
          const SizedBox(height: 12),
          const _MemberCard(name: 'Lucas García', role: 'Miembro', initials: 'LG', removable: true),
          const SizedBox(height: 12),
          const _MemberCard(name: 'Abuela Elena', role: 'Miembro', initials: 'AE', removable: true),
        ],
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.name, required this.role, required this.initials, this.removable = false});
  final String name;
  final String role;
  final String initials;
  final bool removable;
  @override
  Widget build(BuildContext context) {
    return Card(child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), leading: CircleAvatar(backgroundColor: AppColors.primarySoft, child: Text(initials)), title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text(role), trailing: removable ? IconButton(onPressed: () {}, icon: const Icon(Icons.remove_circle_outline, color: AppColors.accent)) : null));
  }
}

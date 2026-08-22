import 'package:flutter/material.dart';

import '../../../core/widgets/app_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({required this.onLogout, super.key});
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('María García', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text('maria@ejemplo.com', style: Theme.of(context).textTheme.bodyLarge),
          const Spacer(),
          AppPrimaryButton(label: 'Cerrar sesión', icon: Icons.logout, onPressed: onLogout),
        ]),
      ),
    );
  }
}

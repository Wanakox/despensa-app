import 'package:flutter/material.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 8, 28, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Crear cuenta', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 8),
              Text('Organiza tu hogar colaborativamente', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 32),
              const AppTextField(label: 'Nombre completo', hintText: 'Ej. María García'),
              const SizedBox(height: 18),
              const AppTextField(label: 'Correo electrónico', hintText: 'correo@ejemplo.com', keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 18),
              const AppTextField(label: 'Contraseña', hintText: 'Elige tu contraseña', obscureText: true),
              const SizedBox(height: 18),
              const AppTextField(label: 'Confirmar contraseña', hintText: 'Repite tu contraseña', obscureText: true),
              const SizedBox(height: 28),
              AppPrimaryButton(label: 'Registrarse', onPressed: () => Navigator.of(context).pop()),
            ],
          ),
        ),
      ),
    );
  }
}

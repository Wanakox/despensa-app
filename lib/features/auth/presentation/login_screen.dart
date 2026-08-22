import 'package:flutter/material.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../home/presentation/main_shell.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                children: [
                  Image.asset('docs/branding/despensa-app-icon.png', width: 112),
                  const SizedBox(height: 28),
                  Text('Hola de nuevo', style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 8),
                  Text('Inicia sesión para acceder a tu despensa', style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
                  const SizedBox(height: 36),
                  const AppTextField(label: 'Correo electrónico', hintText: 'correo@ejemplo.com', keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 20),
                  const AppTextField(label: 'Contraseña', hintText: 'Introduce tu contraseña', obscureText: true, suffixIcon: Icon(Icons.visibility_outlined)),
                  const SizedBox(height: 28),
                  AppPrimaryButton(
                    label: 'Iniciar sesión',
                    onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainShell())),
                  ),
                  const SizedBox(height: 18),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen())),
                    child: const Text('¿No tienes cuenta? Regístrate'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

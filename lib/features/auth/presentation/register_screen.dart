import 'package:flutter/material.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../households/presentation/households_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HouseholdsScreen()),
        (_) => false,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AuthService.errorMessage(error))));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 8, 28, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Crear cuenta',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Organiza tu hogar colaborativamente',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 32),
                AppTextField(
                  label: 'Nombre completo',
                  hintText: 'Ej. María García',
                  controller: _nameController,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Introduce tu nombre'
                      : null,
                ),
                const SizedBox(height: 18),
                AppTextField(
                  label: 'Correo electrónico',
                  hintText: 'correo@ejemplo.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value == null || !value.contains('@')
                      ? 'Introduce un correo válido'
                      : null,
                ),
                const SizedBox(height: 18),
                AppTextField(
                  label: 'Contraseña',
                  hintText: 'Elige tu contraseña',
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) => value == null || value.length < 6
                      ? 'Usa al menos 6 caracteres'
                      : null,
                ),
                const SizedBox(height: 18),
                AppTextField(
                  label: 'Confirmar contraseña',
                  hintText: 'Repite tu contraseña',
                  controller: _confirmationController,
                  obscureText: true,
                  validator: (value) => value != _passwordController.text
                      ? 'Las contraseñas no coinciden'
                      : null,
                ),
                const SizedBox(height: 28),
                AppPrimaryButton(
                  label: 'Registrarse',
                  loading: _loading,
                  onPressed: _register,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

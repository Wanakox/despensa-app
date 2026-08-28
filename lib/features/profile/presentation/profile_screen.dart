import 'package:flutter/material.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/widgets/app_button.dart';

class ProfileSheet extends StatefulWidget {
  const ProfileSheet({super.key});
  @override
  State<ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends State<ProfileSheet> {
  var _busy = false;

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final name = user?.displayName?.trim();
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          18,
          24,
          MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Mi perfil',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Cerrar',
                    onPressed: _busy ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              CircleAvatar(radius: 34, child: Text(_initials(name))),
              const SizedBox(height: 14),
              Text(
                name == null || name.isEmpty ? 'Usuario local' : name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(user?.email ?? 'Modo local sin cuenta conectada'),
              const SizedBox(height: 26),
              AppPrimaryButton(
                label: 'Cambiar nombre',
                icon: Icons.edit_outlined,
                onPressed: _busy ? null : _changeName,
              ),
              const SizedBox(height: 12),
              AppPrimaryButton(
                label: 'Cambiar contraseña',
                icon: Icons.password_outlined,
                onPressed: _busy || user == null ? null : _changePassword,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _busy || user == null ? null : _deleteAccount,
                icon: const Icon(Icons.delete_forever_outlined),
                label: const Text('Eliminar cuenta'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
              ),
              if (_busy) ...[
                const SizedBox(height: 20),
                const LinearProgressIndicator(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _changeName() async {
    var enteredName = AuthService.currentUser?.displayName ?? '';
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar nombre'),
        content: TextFormField(
          initialValue: enteredName,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Nombre'),
          onChanged: (value) => enteredName = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final value = enteredName.trim();
              if (value.isNotEmpty) Navigator.pop(context, value);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (name == null || !mounted) return;
    await _run(() => AuthService.updateName(name), 'Nombre actualizado');
  }

  Future<void> _changePassword() async {
    final values = await showDialog<(String, String)?>(
      context: context,
      builder: (_) => const _PasswordDialog(),
    );
    if (values == null || !mounted) return;
    await _run(
      () => AuthService.changePassword(
        currentPassword: values.$1,
        newPassword: values.$2,
      ),
      'Contraseña actualizada',
    );
  }

  Future<void> _deleteAccount() async {
    final password = await showDialog<String>(
      context: context,
      builder: (_) => const _DeleteAccountDialog(),
    );
    if (password == null || !mounted) return;
    await _run(
      () => AuthService.deleteAccount(password),
      'Cuenta eliminada',
      closeWithDelete: true,
    );
  }

  Future<void> _run(
    Future<void> Function() action,
    String success, {
    bool closeWithDelete = false,
  }) async {
    setState(() => _busy = true);
    try {
      await action();
      if (!mounted) return;
      if (closeWithDelete) {
        Navigator.pop(context, true);
      } else {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(success)));
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _busy = false);
      final message = error is StateError
          ? error.message
          : AuthService.errorMessage(error);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  String _initials(String? name) {
    final words = name?.trim().split(RegExp(r'\s+')) ?? const [];
    if (words.isEmpty || words.first.isEmpty) return 'U';
    return (words.length == 1
            ? words.first[0]
            : '${words.first[0]}${words.last[0]}')
        .toUpperCase();
  }
}

class _PasswordDialog extends StatefulWidget {
  const _PasswordDialog();
  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Cambiar contraseña'),
    content: Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _current,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Contraseña actual'),
            validator: (value) => value == null || value.isEmpty
                ? 'Introduce tu contraseña actual'
                : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _next,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Nueva contraseña'),
            validator: (value) => value == null || value.length < 6
                ? 'Debe tener al menos 6 caracteres'
                : null,
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(onPressed: _submit, child: const Text('Cambiar')),
    ],
  );
  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, (_current.text, _next.text));
    }
  }
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();
  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _controller = TextEditingController();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Eliminar cuenta'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Esta acción eliminará tu cuenta. Si eres propietario de algún hogar, antes deberás transferirlo o eliminarlo.',
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _controller,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Contraseña actual'),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: () {
          if (_controller.text.isNotEmpty) {
            Navigator.pop(context, _controller.text);
          }
        },
        child: const Text('Eliminar cuenta'),
      ),
    ],
  );
}

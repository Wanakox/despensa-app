import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/local_storage.dart';
import '../../auth/presentation/login_screen.dart';
import '../../home/presentation/main_shell.dart';
import '../../profile/presentation/profile_screen.dart';
import '../data/household_service.dart';
import '../domain/household.dart';
import '../domain/household_invitation.dart';
import '../../activity/data/activity_service.dart';

class HouseholdsScreen extends StatefulWidget {
  const HouseholdsScreen({super.key});

  @override
  State<HouseholdsScreen> createState() => _HouseholdsScreenState();
}

class _HouseholdsScreenState extends State<HouseholdsScreen> {
  var _households = <Household>[];
  var _invitations = <HouseholdInvitation>[];
  var _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHouseholds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis hogares'),
        actions: [
          IconButton(
            tooltip: 'Ver perfil',
            onPressed: _showProfile,
            icon: const Icon(Icons.account_circle_outlined),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: _confirmLogout,
            icon: const Icon(Icons.logout),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadHouseholds,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                children: [
                  if (_invitations.isNotEmpty) ...[
                    Text(
                      'Invitaciones',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    ..._invitations.map(
                      (invitation) => _InvitationCard(
                        invitation: invitation,
                        onAccept: () => _respond(invitation, true),
                        onReject: () => _respond(invitation, false),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  Text(
                    _households.isEmpty
                        ? 'Aún no tienes hogares. Crea uno o acepta una invitación.'
                        : 'Selecciona el hogar que quieres gestionar',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 20),
                  ..._households.map(
                    (household) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _HouseholdCard(
                        household: household,
                        onTap: () => _openHousehold(household),
                        onAction: (action) =>
                            _handleHouseholdAction(household, action),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'create-household',
        onPressed: _showCreateHousehold,
        icon: const Icon(Icons.add_home_outlined),
        label: const Text('Crear hogar'),
      ),
    );
  }

  void _openHousehold(Household household) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            MainShell(householdId: household.id, householdName: household.name),
      ),
    );
  }

  Future<void> _showProfile() async {
    final deleted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const ProfileSheet(),
    );
    if (deleted != true || !mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Future<void> _showCreateHousehold() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const _CreateHouseholdDialog(),
    );
    if (name == null || !mounted) return;
    try {
      final household = await HouseholdService.create(name);
      await Future.wait([
        LocalStorage.writeList(
          LocalStorage.householdKey('inventory', name),
          const [],
        ),
        LocalStorage.writeList(
          LocalStorage.householdKey('cart', name),
          const [],
        ),
      ]);
      if (!mounted) return;
      setState(() => _households.add(household));
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Hogar “$name” creado')));
    } catch (error) {
      debugPrint('Error al crear el hogar: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se ha podido crear el hogar.')),
      );
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Quieres salir de tu cuenta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await AuthService.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Future<void> _loadHouseholds() async {
    try {
      final results = await Future.wait([
        HouseholdService.load(),
        HouseholdService.loadInvitations(),
      ]);
      if (!mounted) return;
      setState(() {
        _households = results[0] as List<Household>;
        _invitations = results[1] as List<HouseholdInvitation>;
        _loading = false;
      });
    } catch (error) {
      debugPrint('Error al cargar los hogares: $error');
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se han podido cargar tus hogares.')),
      );
    }
  }

  Future<void> _respond(HouseholdInvitation invitation, bool accept) async {
    try {
      await HouseholdService.respondToInvitation(invitation, accept: accept);
      if (accept) {
        await ActivityService.record(
          householdName: invitation.householdName,
          householdId: invitation.householdId,
          description: 'se unió al hogar',
        );
      }
      await _loadHouseholds();
      if (!mounted) return;
      _showMessage(
        accept
            ? 'Ya formas parte de ${invitation.householdName}'
            : 'Invitación rechazada',
      );
    } catch (error) {
      debugPrint('Error al responder invitación: $error');
      if (mounted) _showMessage('No se ha podido responder a la invitación.');
    }
  }

  Future<void> _handleHouseholdAction(
    Household household,
    String action,
  ) async {
    if (action == 'rename') {
      final name = await showDialog<String>(
        context: context,
        builder: (_) => _HouseholdNameDialog(
          title: 'Renombrar hogar',
          initialValue: household.name,
        ),
      );
      if (name == null || !mounted) return;
      await _runHouseholdAction(
        () => HouseholdService.rename(household, name),
        'Hogar renombrado',
      );
      return;
    }
    final deleting = action == 'delete';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(deleting ? 'Eliminar hogar' : 'Abandonar hogar'),
        content: Text(
          deleting
              ? 'Se eliminará “${household.name}” para todos sus miembros. Esta acción no se puede deshacer.'
              : '¿Quieres abandonar “${household.name}”?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(deleting ? 'Eliminar' : 'Abandonar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _runHouseholdAction(
      () => deleting
          ? HouseholdService.delete(household)
          : HouseholdService.leave(household),
      deleting ? 'Hogar eliminado' : 'Has abandonado el hogar',
    );
  }

  Future<void> _runHouseholdAction(
    Future<void> Function() action,
    String success,
  ) async {
    try {
      await action();
      await _loadHouseholds();
      if (mounted) _showMessage(success);
    } catch (error) {
      debugPrint('Error al gestionar hogar: $error');
      if (mounted) _showMessage('No se ha podido completar la operación.');
    }
  }

  void _showMessage(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
}

class _CreateHouseholdDialog extends StatefulWidget {
  const _CreateHouseholdDialog();

  @override
  State<_CreateHouseholdDialog> createState() => _CreateHouseholdDialogState();
}

class _CreateHouseholdDialogState extends State<_CreateHouseholdDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Crear hogar'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Nombre del hogar',
            hintText: 'Ej. Casa García',
          ),
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Introduce un nombre'
              : null,
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Crear')),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, _controller.text.trim());
  }
}

class _HouseholdCard extends StatelessWidget {
  const _HouseholdCard({
    required this.household,
    required this.onTap,
    required this.onAction,
  });

  final Household household;
  final VoidCallback onTap;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    final memberLabel = household.members == 1
        ? '1 miembro'
        : '${household.members} miembros';
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.primarySoft,
                child: Icon(Icons.home_outlined, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      household.name,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(memberLabel),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Opciones de ${household.name}',
                onSelected: onAction,
                itemBuilder: (_) => [
                  if (household.isOwner)
                    const PopupMenuItem(
                      value: 'rename',
                      child: Text('Renombrar'),
                    ),
                  PopupMenuItem(
                    value: household.isOwner ? 'delete' : 'leave',
                    child: Text(
                      household.isOwner ? 'Eliminar hogar' : 'Abandonar hogar',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InvitationCard extends StatelessWidget {
  const _InvitationCard({
    required this.invitation,
    required this.onAccept,
    required this.onReject,
  });
  final HouseholdInvitation invitation;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            invitation.householdName,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text('Te han invitado a compartir este hogar.'),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: onReject, child: const Text('Rechazar')),
              const SizedBox(width: 8),
              FilledButton(onPressed: onAccept, child: const Text('Aceptar')),
            ],
          ),
        ],
      ),
    ),
  );
}

class _HouseholdNameDialog extends StatefulWidget {
  const _HouseholdNameDialog({required this.title, required this.initialValue});
  final String title;
  final String initialValue;
  @override
  State<_HouseholdNameDialog> createState() => _HouseholdNameDialogState();
}

class _HouseholdNameDialogState extends State<_HouseholdNameDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: Form(
      key: _formKey,
      child: TextFormField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Nombre del hogar'),
        validator: (value) => value == null || value.trim().isEmpty
            ? 'Introduce un nombre'
            : null,
        onFieldSubmitted: (_) => _submit(),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(onPressed: _submit, child: const Text('Guardar')),
    ],
  );
  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, _controller.text.trim());
    }
  }
}

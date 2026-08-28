import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/expiration_preferences.dart';
import '../data/member_service.dart';
import '../domain/household_member.dart';
import '../../activity/data/activity_service.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({
    required this.householdName,
    this.householdId,
    this.expirationWarningDays = ExpirationPreferences.defaultWarningDays,
    this.onExpirationWarningDaysChanged,
    super.key,
  });

  final String householdName;
  final String? householdId;
  final int expirationWarningDays;
  final ValueChanged<int>? onExpirationWarningDaysChanged;

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  var _members = <HouseholdMember>[];
  var _loading = true;

  bool get _isOwner => AuthService.currentUser == null
      ? _members.any((member) => member.isOwner)
      : _members.any(
          (member) =>
              member.isOwner && member.id == AuthService.currentUser!.uid,
        );

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Miembros del hogar')),
    body: RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          if (_isOwner || _loading)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Invitar nuevo miembro',
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(color: AppColors.primaryDark),
                  ),
                  const SizedBox(height: 8),
                  const Text('Envía una invitación a su correo electrónico.'),
                  const SizedBox(height: 18),
                  AppPrimaryButton(
                    label: 'Invitar miembro',
                    icon: Icons.add_circle_outline,
                    onPressed: _showInviteDialog,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications_active_outlined),
              title: const Text('Aviso de caducidad'),
              subtitle: Text(
                widget.expirationWarningDays == 0
                    ? 'Avisar el mismo día'
                    : 'Avisar con ${widget.expirationWarningDays} días de antelación',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _configureExpirationWarning,
            ),
          ),
          const SizedBox(height: 22),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_members.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('Todavía no hay miembros.')),
            )
          else
            ..._members.map(
              (member) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _MemberCard(
                  member: member,
                  onRemove: !_isOwner || member.isOwner
                      ? null
                      : () => _remove(member),
                  onTransfer: !_isOwner || member.isOwner
                      ? null
                      : () => _transfer(member),
                ),
              ),
            ),
        ],
      ),
    ),
  );

  Future<void> _load() async {
    try {
      final members = await MemberService.load(
        householdName: widget.householdName,
        householdId: widget.householdId,
      );
      if (!mounted) return;
      setState(() {
        _members = members;
        _loading = false;
      });
    } catch (error) {
      debugPrint('Error al cargar miembros: $error');
      if (!mounted) return;
      setState(() => _loading = false);
      _showMessage('No se han podido cargar los miembros.');
    }
  }

  Future<void> _showInviteDialog() async {
    final request = await showDialog<_InvitationRequest>(
      context: context,
      builder: (_) => const _InviteMemberDialog(),
    );
    if (request == null || !mounted) return;
    try {
      await MemberService.invite(
        householdName: widget.householdName,
        householdId: widget.householdId,
        email: request.email,
      );
      await _load();
      await _record('invitó a ${request.email} al hogar');
      if (request.share && mounted) {
        await SharePlus.instance.share(
          ShareParams(
            subject: 'Invitación a ${widget.householdName}',
            text:
                'Te invito a compartir “${widget.householdName}” en Despensa. '
                'Instala o abre la aplicación y regístrate con ${request.email}. '
                'La invitación aparecerá en la pantalla Mis hogares.',
          ),
        );
      }
      if (mounted) _showMessage('Invitación creada para ${request.email}');
    } catch (error) {
      debugPrint('Error al invitar miembro: $error');
      if (mounted) _showMessage('No se ha podido enviar la invitación.');
    }
  }

  Future<void> _configureExpirationWarning() async {
    final selected = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Avisar antes de caducar'),
        children: [0, 1, 3, 7, 14]
            .map(
              (days) => ListTile(
                leading: Icon(
                  days == widget.expirationWarningDays
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                ),
                title: Text(days == 0 ? 'El mismo día' : '$days días antes'),
                onTap: () => Navigator.pop(context, days),
              ),
            )
            .toList(),
      ),
    );
    if (selected == null || !mounted) return;
    try {
      await ExpirationPreferences.save(
        householdName: widget.householdName,
        householdId: widget.householdId,
        days: selected,
      );
      widget.onExpirationWarningDaysChanged?.call(selected);
      if (mounted) _showMessage('Margen de caducidad actualizado');
    } catch (error) {
      debugPrint('Error al guardar el margen de caducidad: $error');
      if (mounted) _showMessage('No se ha podido guardar el margen.');
    }
  }

  Future<void> _remove(HouseholdMember member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar miembro'),
        content: Text('¿Quieres eliminar a ${member.name} del hogar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await MemberService.remove(
        householdName: widget.householdName,
        householdId: widget.householdId,
        member: member,
      );
      await _load();
      await _record('eliminó a ${member.name} del hogar');
      if (mounted) _showMessage('${member.name} ha sido eliminado');
    } catch (error) {
      debugPrint('Error al eliminar miembro: $error');
      if (mounted) _showMessage('No se ha podido eliminar al miembro.');
    }
  }

  Future<void> _transfer(HouseholdMember member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transferir propiedad'),
        content: Text(
          '${member.name} pasará a ser propietario y tú serás miembro.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Transferir'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await MemberService.transferOwnership(
        householdId: widget.householdId,
        newOwner: member,
      );
      await _load();
      await _record('transfirió la propiedad a ${member.name}');
      if (mounted) _showMessage('Propiedad transferida a ${member.name}');
    } catch (error) {
      debugPrint('Error al transferir propiedad: $error');
      if (mounted) _showMessage('No se ha podido transferir la propiedad.');
    }
  }

  void _showMessage(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

  Future<void> _record(String description) async {
    try {
      await ActivityService.record(
        householdName: widget.householdName,
        householdId: widget.householdId,
        description: description,
      );
    } catch (error) {
      debugPrint('Error al registrar actividad: $error');
    }
  }
}

class _InviteMemberDialog extends StatefulWidget {
  const _InviteMemberDialog();
  @override
  State<_InviteMemberDialog> createState() => _InviteMemberDialogState();
}

class _InviteMemberDialogState extends State<_InviteMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Invitar miembro'),
    content: Form(
      key: _formKey,
      child: TextFormField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(labelText: 'Correo electrónico'),
        validator: (value) {
          final email = value?.trim() ?? '';
          if (email.isEmpty) return 'Introduce un correo';
          if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
            return 'Introduce un correo válido';
          }
          return null;
        },
        onFieldSubmitted: (_) => _submit(false),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      TextButton.icon(
        onPressed: () => _submit(true),
        icon: const Icon(Icons.share_outlined),
        label: const Text('Compartir'),
      ),
      FilledButton(
        onPressed: () => _submit(false),
        child: const Text('Enviar'),
      ),
    ],
  );

  void _submit(bool share) {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      _InvitationRequest(
        email: _controller.text.trim().toLowerCase(),
        share: share,
      ),
    );
  }
}

class _InvitationRequest {
  const _InvitationRequest({required this.email, required this.share});
  final String email;
  final bool share;
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.member, this.onRemove, this.onTransfer});
  final HouseholdMember member;
  final VoidCallback? onRemove;
  final VoidCallback? onTransfer;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: AppColors.primarySoft,
        child: Text(member.initials),
      ),
      title: Text(
        member.name,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        member.email.isEmpty
            ? (member.isOwner ? 'Propietario' : 'Miembro')
            : '${member.isOwner ? 'Propietario' : 'Miembro'} · ${member.email}',
      ),
      trailing: onRemove == null && onTransfer == null
          ? null
          : PopupMenuButton<String>(
              tooltip: 'Opciones de ${member.name}',
              onSelected: (value) =>
                  value == 'transfer' ? onTransfer?.call() : onRemove?.call(),
              itemBuilder: (_) => [
                if (onTransfer != null)
                  const PopupMenuItem(
                    value: 'transfer',
                    child: Text('Hacer propietario'),
                  ),
                if (onRemove != null)
                  const PopupMenuItem(
                    value: 'remove',
                    child: Text('Eliminar miembro'),
                  ),
              ],
            ),
    ),
  );
}

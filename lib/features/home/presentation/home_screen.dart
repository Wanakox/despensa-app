import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/household_data_service.dart';
import '../../../core/widgets/section_title.dart';
import '../../members/data/member_service.dart';
import '../../members/domain/household_member.dart';
import '../../activity/data/activity_service.dart';
import '../../activity/domain/activity_entry.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.householdName,
    required this.onNavigate,
    required this.onLogout,
    this.householdId,
    super.key,
  });
  final String householdName;
  final String? householdId;
  final ValueChanged<int> onNavigate;
  final VoidCallback onLogout;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _inventory = <Map<String, dynamic>>[];
  var _cart = <Map<String, dynamic>>[];
  var _members = <HouseholdMember>[];
  var _activity = <ActivityEntry>[];
  final _subscriptions = <StreamSubscription<dynamic>>[];

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  int get _expiringProducts {
    final today = DateUtils.dateOnly(DateTime.now());
    return _inventory.where((product) {
      if ((product['units'] as num? ?? 0) <= 0) return true;
      final value = product['expirationDate'] as String?;
      if (value == null) return false;
      final date = DateTime.tryParse(value);
      return date != null &&
          DateUtils.dateOnly(date).difference(today).inDays <= 3;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final displayName = AuthService.currentUser?.displayName?.trim();
    final greetingName = displayName == null || displayName.isEmpty
        ? 'de nuevo'
        : displayName.split(' ').first;
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
                    Text(
                      'Hola, $greetingName',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.householdName,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                tooltip: 'Volver a mis hogares',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.home_outlined),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: 'Cerrar sesión',
                onPressed: () => _confirmLogout(context),
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  icon: Icons.inventory_2_outlined,
                  value: '${_inventory.length}',
                  label: 'En despensa',
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _MetricCard(
                  icon: Icons.shopping_basket_outlined,
                  value:
                      '${_cart.where((item) => item['completed'] != true).length}',
                  label: 'Para comprar',
                  accent: true,
                ),
              ),
            ],
          ),
          if (_expiringProducts > 0) ...[
            const SizedBox(height: 14),
            Card(
              color: AppColors.accentSoft,
              child: ListTile(
                leading: const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.accent,
                ),
                title: Text('$_expiringProducts productos requieren atención'),
                subtitle: const Text(
                  'Agotados, caducados o próximos a caducar',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => widget.onNavigate(1),
              ),
            ),
          ],
          const SizedBox(height: 30),
          const SectionTitle('Accesos rápidos'),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _QuickAction(
                  icon: Icons.add_circle_outline,
                  label: 'Ver inventario',
                  onTap: () => widget.onNavigate(1),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _QuickAction(
                  icon: Icons.shopping_basket_outlined,
                  label: 'Lista cesta',
                  accent: true,
                  onTap: () => widget.onNavigate(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          const SectionTitle('Actividad reciente'),
          const SizedBox(height: 10),
          if (_activity.isEmpty)
            const Text('Todavía no hay actividad en este hogar.')
          else
            ..._activity
                .take(6)
                .map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ActivityTile(entry: entry),
                  ),
                ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(child: SectionTitle('Miembros')),
              TextButton(
                onPressed: () => widget.onNavigate(3),
                child: const Text('Ver todos'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_members.isEmpty)
            const Text('No hay miembros disponibles.')
          else
            ..._members
                .take(3)
                .map(
                  (member) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _MemberTile(member: member),
                  ),
                ),
        ],
      ),
    );
  }

  Future<void> _startLoading() async {
    final inventoryStream = HouseholdDataService.watch(
      section: 'inventory',
      householdId: widget.householdId,
    );
    final cartStream = HouseholdDataService.watch(
      section: 'cart',
      householdId: widget.householdId,
    );
    final membersStream = MemberService.watch(householdId: widget.householdId);
    final activityStream = ActivityService.watch(
      householdId: widget.householdId,
    );
    if (inventoryStream == null ||
        cartStream == null ||
        membersStream == null ||
        activityStream == null) {
      final results = await Future.wait([
        HouseholdDataService.load(
          section: 'inventory',
          householdName: widget.householdName,
          householdId: widget.householdId,
          localDefaults: const [],
        ),
        HouseholdDataService.load(
          section: 'cart',
          householdName: widget.householdName,
          householdId: widget.householdId,
          localDefaults: const [],
        ),
        MemberService.load(
          householdName: widget.householdName,
          householdId: widget.householdId,
        ),
        ActivityService.load(
          householdName: widget.householdName,
          householdId: widget.householdId,
        ),
      ]);
      if (!mounted) return;
      setState(() {
        _inventory = results[0] as List<Map<String, dynamic>>;
        _cart = results[1] as List<Map<String, dynamic>>;
        _members = results[2] as List<HouseholdMember>;
        _activity = results[3] as List<ActivityEntry>;
      });
      return;
    }
    _subscriptions.add(
      inventoryStream.listen((data) {
        if (mounted) setState(() => _inventory = data);
      }),
    );
    _subscriptions.add(
      cartStream.listen((data) {
        if (mounted) setState(() => _cart = data);
      }),
    );
    _subscriptions.add(
      membersStream.listen((data) {
        if (mounted) setState(() => _members = data);
      }),
    );
    _subscriptions.add(
      activityStream.listen((data) {
        if (mounted) setState(() => _activity = data);
      }),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
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
    if (shouldLogout == true) widget.onLogout();
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.entry});
  final ActivityEntry entry;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      dense: true,
      leading: const CircleAvatar(child: Icon(Icons.history, size: 20)),
      title: Text('${entry.actorName} ${entry.description}'),
      subtitle: Text(_relativeTime(entry.createdAt)),
    ),
  );

  String _relativeTime(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inMinutes < 1) return 'Ahora';
    if (difference.inHours < 1) return 'Hace ${difference.inMinutes} min';
    if (difference.inDays < 1) return 'Hace ${difference.inHours} h';
    return 'Hace ${difference.inDays} d';
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.value,
    required this.label,
    this.accent = false,
  });
  final IconData icon;
  final String value;
  final String label;
  final bool accent;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent ? AppColors.accent : AppColors.primary),
          const SizedBox(height: 16),
          Text(value, style: Theme.of(context).textTheme.headlineMedium),
          Text(label),
        ],
      ),
    ),
  );
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.accent = false,
  });
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
        decoration: BoxDecoration(
          color: accent ? AppColors.accentSoft : AppColors.primarySoft,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(color: color, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.member});
  final HouseholdMember member;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        backgroundColor: AppColors.primarySoft,
        child: Text(member.initials),
      ),
      title: Text(
        member.name,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(member.isOwner ? 'Propietario' : 'Miembro'),
    ),
  );
}

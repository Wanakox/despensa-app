import 'package:flutter/material.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/expiration_preferences.dart';
import '../../auth/presentation/login_screen.dart';
import '../../cart/presentation/cart_screen.dart';
import '../../inventory/presentation/inventory_screen.dart';
import '../../members/presentation/members_screen.dart';
import 'home_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({required this.householdName, this.householdId, super.key});

  final String householdName;
  final String? householdId;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  int _cartRevision = 0;
  int _inventoryRevision = 0;
  int _expirationWarningDays = ExpirationPreferences.defaultWarningDays;

  @override
  void initState() {
    super.initState();
    _loadExpirationPreferences();
  }

  Future<void> _loadExpirationPreferences() async {
    final days = await ExpirationPreferences.load(
      householdName: widget.householdName,
      householdId: widget.householdId,
    );
    if (mounted) setState(() => _expirationWarningDays = days);
  }

  Future<void> _logout() async {
    await AuthService.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        householdId: widget.householdId,
        householdName: widget.householdName,
        onNavigate: (index) => setState(() => _selectedIndex = index),
        onLogout: _logout,
        expirationWarningDays: _expirationWarningDays,
      ),
      InventoryScreen(
        key: ValueKey(_inventoryRevision),
        householdId: widget.householdId,
        householdName: widget.householdName,
        onCartChanged: () => setState(() => _cartRevision++),
        expirationWarningDays: _expirationWarningDays,
      ),
      CartScreen(
        key: ValueKey(_cartRevision),
        householdId: widget.householdId,
        householdName: widget.householdName,
        onInventoryChanged: () => setState(() => _inventoryRevision++),
      ),
      MembersScreen(
        householdId: widget.householdId,
        householdName: widget.householdName,
        expirationWarningDays: _expirationWarningDays,
        onExpirationWarningDaysChanged: (days) =>
            setState(() => _expirationWarningDays = days),
      ),
    ];
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Despensa',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_basket_outlined),
            selectedIcon: Icon(Icons.shopping_basket),
            label: 'Cesta',
          ),
          NavigationDestination(
            icon: Icon(Icons.group_outlined),
            selectedIcon: Icon(Icons.group),
            label: 'Miembros',
          ),
        ],
      ),
    );
  }
}

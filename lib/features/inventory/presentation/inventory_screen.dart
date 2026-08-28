import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/services/household_data_service.dart';
import '../../../core/services/auth_service.dart';
import '../../cart/presentation/cart_screen.dart';
import '../../activity/data/activity_service.dart';
import 'product_form_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({
    this.householdName = 'demo',
    this.householdId,
    this.onCartChanged,
    this.expirationWarningDays = 3,
    super.key,
  });
  final String householdName;
  final String? householdId;
  final VoidCallback? onCartChanged;
  final int expirationWarningDays;

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _searchController = TextEditingController();
  StreamSubscription<List<Map<String, dynamic>>>? _productsSubscription;
  final _products = <ProductFormData>[
    ProductFormData(
      name: 'Manzanas Galas',
      units: 6,
      expirationDate: DateTime.now().add(const Duration(days: 2)),
    ),
    ProductFormData(
      name: 'Leche semidesnatada',
      units: 3,
      amount: 1,
      measurementUnit: 'l',
      expirationDate: DateTime.now().add(const Duration(days: 8)),
    ),
    ProductFormData(
      name: 'Filetes de ternera',
      units: 1,
      amount: 500,
      measurementUnit: 'g',
      expirationDate: DateTime.now(),
    ),
    const ProductFormData(name: 'Detergente líquido', units: 1),
  ];
  String _query = '';
  _InventoryFilter _filter = _InventoryFilter.all;

  @override
  void initState() {
    super.initState();
    _startLoadingProducts();
  }

  List<ProductFormData> get _visibleProducts {
    final query = _query.trim().toLowerCase();
    var products = query.isEmpty
        ? _products
        : _products
              .where((product) => product.name.toLowerCase().contains(query))
              .toList();
    if (_filter == _InventoryFilter.exhausted) {
      products = products.where((product) => product.units == 0).toList();
    } else if (_filter == _InventoryFilter.expired) {
      final today = DateUtils.dateOnly(DateTime.now());
      products = products.where((product) {
        final date = product.expirationDate;
        return date != null && DateUtils.dateOnly(date).isBefore(today);
      }).toList();
    } else if (_filter == _InventoryFilter.alphabetical) {
      products = [...products]
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }
    return products;
  }

  @override
  void dispose() {
    _productsSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = _visibleProducts;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Despensa'),
        actions: [
          IconButton(
            onPressed: null,
            tooltip: AuthService.currentUser == null
                ? 'Modo local'
                : 'Sincronización activa',
            icon: Icon(
              AuthService.currentUser == null
                  ? Icons.cloud_off_outlined
                  : Icons.cloud_done_outlined,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: 'Buscar producto...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Limpiar búsqueda',
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                      icon: const Icon(Icons.close),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'Todos',
                  selected: _filter == _InventoryFilter.all,
                  onTap: () => setState(() => _filter = _InventoryFilter.all),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'A–Z',
                  selected: _filter == _InventoryFilter.alphabetical,
                  onTap: () =>
                      setState(() => _filter = _InventoryFilter.alphabetical),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Agotados',
                  selected: _filter == _InventoryFilter.exhausted,
                  onTap: () =>
                      setState(() => _filter = _InventoryFilter.exhausted),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Caducados',
                  selected: _filter == _InventoryFilter.expired,
                  onTap: () =>
                      setState(() => _filter = _InventoryFilter.expired),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (products.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Column(
                children: [
                  Icon(Icons.search_off, size: 48),
                  SizedBox(height: 12),
                  Text('No hay productos que coincidan con la búsqueda'),
                ],
              ),
            )
          else
            ...products.map((product) {
              final index = _products.indexOf(product);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ProductCard(
                  product: product,
                  expirationWarningDays: widget.expirationWarningDays,
                  onIncrease: () => _changeUnits(index, 1),
                  onDecrease: () => _changeUnits(index, -1),
                  onSetUnits: () => _setUnits(index),
                  onEdit: () => _editProduct(index),
                  onDelete: () => _confirmDelete(index),
                  onAddToCart: () => _addToCart(index),
                ),
              );
            }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add-inventory-product',
        onPressed: _addProduct,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _addProduct() async {
    final product = await showModalBottomSheet<ProductFormData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      builder: (_) => const ProductFormScreen(),
    );
    if (product == null || !mounted) return;
    try {
      final stored = await HouseholdDataService.upsert(
        section: 'inventory',
        householdName: widget.householdName,
        householdId: widget.householdId,
        data: product.toJson(),
      );
      if (!mounted) return;
      setState(() => _products.add(ProductFormData.fromJson(stored)));
      await _record('añadió “${product.name}” al inventario');
      _showMessage('Producto añadido');
    } catch (error) {
      _handleSyncError(error);
    }
  }

  Future<void> _editProduct(int index) async {
    final product = await showModalBottomSheet<ProductFormData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      builder: (_) => ProductFormScreen(initialData: _products[index]),
    );
    if (product == null || !mounted) return;
    try {
      final stored = await HouseholdDataService.upsert(
        section: 'inventory',
        householdName: widget.householdName,
        householdId: widget.householdId,
        data: product.toJson(),
      );
      if (!mounted) return;
      setState(() => _products[index] = ProductFormData.fromJson(stored));
      await _record('editó “${product.name}” en el inventario');
      _showMessage('Producto actualizado');
    } catch (error) {
      _handleSyncError(error);
    }
  }

  Future<void> _confirmDelete(int index) async {
    final product = _products[index];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text('¿Quieres eliminar “${product.name}” de la despensa?'),
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
      await HouseholdDataService.deleteItem(
        section: 'inventory',
        householdName: widget.householdName,
        householdId: widget.householdId,
        data: product.toJson(),
      );
      if (!mounted) return;
      setState(() => _products.remove(product));
      await _record('eliminó “${product.name}” del inventario');
      _showMessage('Producto eliminado');
    } catch (error) {
      _handleSyncError(error);
    }
  }

  Future<void> _addToCart(int index) async {
    final product = _products[index];
    final added = await CartScreen.addInventoryProduct(
      householdId: widget.householdId,
      householdName: widget.householdName,
      product: product,
    );
    if (!mounted) return;
    if (!added) {
      _showMessage('Ese producto ya está en la cesta');
      return;
    }
    widget.onCartChanged?.call();
    await _record('añadió “${product.name}” a la cesta');
    _showMessage('Producto añadido a la cesta');
  }

  Future<void> _changeUnits(int index, int change) async {
    final product = _products[index];
    final units = (product.units + change).clamp(0, 999999);
    final updated = ProductFormData(
      id: product.id,
      name: product.name,
      units: units,
      amount: product.amount,
      measurementUnit: product.measurementUnit,
      expirationDate: product.expirationDate,
    );
    setState(() => _products[index] = updated);
    try {
      final stored = await HouseholdDataService.upsert(
        section: 'inventory',
        householdName: widget.householdName,
        householdId: widget.householdId,
        data: updated.toJson(),
      );
      if (mounted) {
        setState(() => _products[index] = ProductFormData.fromJson(stored));
      }
      await _record('cambió “${product.name}” a $units unidades');
    } catch (error) {
      if (mounted) setState(() => _products[index] = product);
      _handleSyncError(error);
    }
  }

  Future<void> _setUnits(int index) async {
    final product = _products[index];
    var enteredUnits = product.units;
    final units = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cantidad de ${product.name}'),
        content: TextFormField(
          initialValue: product.units.toString(),
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Unidades',
            suffixText: 'uds.',
          ),
          onChanged: (value) => enteredUnits = int.tryParse(value.trim()) ?? -1,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (enteredUnits >= 0) Navigator.pop(context, enteredUnits);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (units == null || units == product.units || !mounted) return;
    await _changeUnits(index, units - product.units);
  }

  Future<void> _loadProducts() async {
    final stored = await HouseholdDataService.load(
      section: 'inventory',
      householdName: widget.householdName,
      householdId: widget.householdId,
      localDefaults: _products.map((product) => product.toJson()).toList(),
    );
    if (!mounted) return;
    setState(() {
      _products
        ..clear()
        ..addAll(stored.map(ProductFormData.fromJson));
    });
  }

  void _startLoadingProducts() {
    final stream = HouseholdDataService.watch(
      section: 'inventory',
      householdId: widget.householdId,
    );
    if (stream == null) {
      _loadProducts();
      return;
    }
    _productsSubscription = stream.listen(
      (stored) {
        if (!mounted) return;
        setState(() {
          _products
            ..clear()
            ..addAll(stored.map(ProductFormData.fromJson));
        });
      },
      onError: (Object error) {
        debugPrint('Error al sincronizar el inventario: $error');
        if (mounted) {
          _showMessage('No se ha podido sincronizar la despensa.');
        }
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleSyncError(Object error) {
    debugPrint('Error al sincronizar inventario: $error');
    if (mounted) _showMessage('No se ha podido sincronizar el cambio.');
  }

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

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.onIncrease,
    required this.onDecrease,
    required this.onSetUnits,
    required this.onEdit,
    required this.onDelete,
    required this.onAddToCart,
    required this.expirationWarningDays,
  });
  final ProductFormData product;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onSetUnits;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddToCart;
  final int expirationWarningDays;

  @override
  Widget build(BuildContext context) {
    final expiration = _expirationStatus(product.expirationDate);
    final urgent = product.units == 0 || expiration.$2;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              backgroundColor: AppColors.primarySoft,
              child: Icon(Icons.inventory_2_outlined, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      IconButton.outlined(
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Reducir cantidad',
                        onPressed: product.units == 0 ? null : onDecrease,
                        icon: const Icon(Icons.remove, size: 18),
                      ),
                      InkWell(
                        onTap: onSetUnits,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          child: Text(_formatProductAmount(product)),
                        ),
                      ),
                      IconButton.outlined(
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Aumentar cantidad',
                        onPressed: onIncrease,
                        icon: const Icon(Icons.add, size: 18),
                      ),
                    ],
                  ),
                  if (product.units == 0 || expiration.$1 != null) ...[
                    const SizedBox(height: 8),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: urgent
                            ? AppColors.accentSoft
                            : AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Text(
                          product.units == 0 ? 'Agotado' : expiration.$1!,
                          style: TextStyle(
                            color: urgent
                                ? AppColors.accent
                                : AppColors.primaryDark,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'cart') onAddToCart();
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'cart', child: Text('Añadir a la cesta')),
                PopupMenuItem(value: 'edit', child: Text('Editar')),
                PopupMenuItem(value: 'delete', child: Text('Eliminar')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  (String?, bool) _expirationStatus(DateTime? date) {
    if (date == null) return (null, false);
    final days = DateUtils.dateOnly(date)
        .difference(DateUtils.dateOnly(DateTime.now()))
        .inDays;
    if (days < 0) return ('Caducado', true);
    if (days == 0) return ('Consumir hoy', true);
    return ('Caduca en $days días', days <= expirationWarningDays);
  }

  String _formatProductAmount(ProductFormData product) {
    final units = '${product.units} uds.';
    final amount = product.amount;
    if (amount == null) return units;
    final value = amount == amount.roundToDouble()
        ? amount.toInt().toString()
        : amount.toString().replaceAll('.', ',');
    return '$units / $value ${product.measurementUnit}';
  }
}

enum _InventoryFilter { all, alphabetical, exhausted, expired }

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ChoiceChip(
    label: Text(label),
    selected: selected,
    onSelected: (_) => onTap(),
  );
}

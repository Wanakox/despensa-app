import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/services/household_data_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../inventory/presentation/product_form_screen.dart';
import '../../activity/data/activity_service.dart';

class _CartItem {
  _CartItem({
    this.id,
    required this.name,
    required this.units,
    this.amount,
    this.measurementUnit = 'g',
    this.completed = false,
  });
  final String? id;
  final String name;
  final int units;
  final double? amount;
  final String measurementUnit;
  bool completed;

  factory _CartItem.fromJson(Map<String, dynamic> json) => _CartItem(
    id: json['_id'] as String?,
    name: json['name'] as String,
    units: json['units'] as int,
    amount: (json['amount'] as num?)?.toDouble(),
    measurementUnit: json['measurementUnit'] as String? ?? 'g',
    completed: json['completed'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    if (id != null) '_id': id,
    'name': name,
    'units': units,
    'amount': amount,
    'measurementUnit': measurementUnit,
    'completed': completed,
  };
}

class CartScreen extends StatefulWidget {
  const CartScreen({
    this.householdName = 'demo',
    this.householdId,
    this.onInventoryChanged,
    super.key,
  });
  final String householdName;
  final String? householdId;
  final VoidCallback? onInventoryChanged;

  static Future<bool> addInventoryProduct({
    required String householdName,
    required String? householdId,
    required ProductFormData product,
  }) async {
    final stored = await HouseholdDataService.load(
      section: 'cart',
      householdName: householdName,
      householdId: householdId,
      localDefaults: _defaultItemMaps(),
    );
    final duplicate = stored.any(
      (item) =>
          (item['name'] as String).trim().toLowerCase() ==
          product.name.trim().toLowerCase(),
    );
    if (duplicate) return false;
    await HouseholdDataService.upsert(
      section: 'cart',
      householdName: householdName,
      householdId: householdId,
      data: {
        'name': product.name,
        'units': 1,
        'amount': product.amount,
        'measurementUnit': product.measurementUnit,
        'completed': false,
      },
    );
    return true;
  }

  static List<Map<String, dynamic>> _defaultItemMaps() => [
    {'name': 'Huevos camperos', 'units': 12, 'completed': true},
    {
      'name': 'Café en grano',
      'units': 2,
      'amount': 1,
      'measurementUnit': 'kg',
      'completed': false,
    },
    {
      'name': 'Tomates cherry',
      'units': 1,
      'amount': 250,
      'measurementUnit': 'g',
      'completed': false,
    },
    {'name': 'Pan de molde', 'units': 1, 'completed': false},
  ];

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  StreamSubscription<List<Map<String, dynamic>>>? _itemsSubscription;
  final _items = <_CartItem>[
    _CartItem(name: 'Huevos camperos', units: 12, completed: true),
    _CartItem(
      name: 'Café en grano',
      units: 2,
      amount: 1,
      measurementUnit: 'kg',
    ),
    _CartItem(name: 'Tomates cherry', units: 1, amount: 250),
    _CartItem(name: 'Pan de molde', units: 1),
  ];

  @override
  void initState() {
    super.initState();
    _startLoadingItems();
  }

  @override
  void dispose() {
    _itemsSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cesta de la compra'),
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
          IconButton(
            tooltip: 'Guardar comprados en despensa',
            onPressed: _movePurchasedToInventory,
            icon: const Icon(Icons.inventory_2_outlined),
          ),
          IconButton(
            tooltip: 'Vaciar cesta',
            onPressed: _items.isEmpty ? null : _clearCart,
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _items.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_basket_outlined, size: 52),
                  SizedBox(height: 12),
                  Text('La cesta está vacía'),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: CheckboxListTile(
                      value: item.completed,
                      onChanged: (value) => _toggleItem(index, value ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(
                        item.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          decoration: item.completed
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      subtitle: Text(_formatItemAmount(item)),
                      secondary: PopupMenuButton<String>(
                        tooltip: 'Opciones de ${item.name}',
                        onSelected: (value) => value == 'edit'
                            ? _editItem(index)
                            : _removeItem(index),
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'edit', child: Text('Editar')),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text('Eliminar'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add-cart-item',
        onPressed: _showAddItem,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddItem() async {
    final item = await showModalBottomSheet<_CartItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      builder: (_) => const _CartItemForm(),
    );
    if (item == null || !mounted) return;
    if (_hasDuplicate(item.name)) {
      _showDuplicateMessage();
      return;
    }
    try {
      final stored = await HouseholdDataService.upsert(
        section: 'cart',
        householdName: widget.householdName,
        householdId: widget.householdId,
        data: item.toJson(),
      );
      if (!mounted) return;
      setState(() => _items.add(_CartItem.fromJson(stored)));
      await _record('añadió “${item.name}” a la cesta');
      _showMessage('Elemento añadido a la cesta');
    } catch (error) {
      _handleSyncError(error);
    }
  }

  Future<void> _editItem(int index) async {
    final item = await showModalBottomSheet<_CartItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      builder: (_) => _CartItemForm(initialItem: _items[index]),
    );
    if (item == null || !mounted) return;
    if (_hasDuplicate(item.name, exceptIndex: index)) {
      _showDuplicateMessage();
      return;
    }
    try {
      final stored = await HouseholdDataService.upsert(
        section: 'cart',
        householdName: widget.householdName,
        householdId: widget.householdId,
        data: item.toJson(),
      );
      if (!mounted) return;
      setState(() => _items[index] = _CartItem.fromJson(stored));
      await _record('editó “${item.name}” en la cesta');
      _showMessage('Elemento actualizado');
    } catch (error) {
      _handleSyncError(error);
    }
  }

  bool _hasDuplicate(String name, {int? exceptIndex}) {
    final normalizedName = name.trim().toLowerCase();
    return _items.asMap().entries.any(
      (entry) =>
          entry.key != exceptIndex &&
          entry.value.name.trim().toLowerCase() == normalizedName,
    );
  }

  void _showDuplicateMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ese producto ya está en la cesta')),
    );
  }

  Future<void> _removeItem(int index) async {
    final removed = _items[index];
    try {
      await HouseholdDataService.deleteItem(
        section: 'cart',
        householdName: widget.householdName,
        householdId: widget.householdId,
        data: removed.toJson(),
      );
    } catch (error) {
      _handleSyncError(error);
      return;
    }
    if (!mounted) return;
    setState(() => _items.remove(removed));
    await _record('eliminó “${removed.name}” de la cesta');
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('“${removed.name}” eliminado'),
          action: SnackBarAction(
            label: 'Deshacer',
            onPressed: () => _restoreItem(index, removed),
          ),
        ),
      );
  }

  String _formatItemAmount(_CartItem item) {
    final units = '${item.units} uds.';
    final amount = item.amount;
    if (amount == null) return units;
    final value = amount == amount.roundToDouble()
        ? amount.toInt().toString()
        : amount.toString().replaceAll('.', ',');
    return '$units / $value ${item.measurementUnit}';
  }

  Future<void> _loadItems() async {
    final stored = await HouseholdDataService.load(
      section: 'cart',
      householdName: widget.householdName,
      householdId: widget.householdId,
      localDefaults: CartScreen._defaultItemMaps(),
    );
    if (!mounted) return;
    setState(() {
      _items
        ..clear()
        ..addAll(stored.map(_CartItem.fromJson));
    });
  }

  void _startLoadingItems() {
    final stream = HouseholdDataService.watch(
      section: 'cart',
      householdId: widget.householdId,
    );
    if (stream == null) {
      _loadItems();
      return;
    }
    _itemsSubscription = stream.listen(
      (stored) {
        if (!mounted) return;
        setState(() {
          _items
            ..clear()
            ..addAll(stored.map(_CartItem.fromJson));
        });
      },
      onError: (Object error) {
        debugPrint('Error al sincronizar la cesta: $error');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se ha podido sincronizar la cesta.'),
            ),
          );
        }
      },
    );
  }

  Future<void> _toggleItem(int index, bool completed) async {
    final item = _items[index];
    final previous = item.completed;
    setState(() => item.completed = completed);
    try {
      await HouseholdDataService.upsert(
        section: 'cart',
        householdName: widget.householdName,
        householdId: widget.householdId,
        data: item.toJson(),
      );
      await _record(
        '${completed ? 'marcó' : 'desmarcó'} “${item.name}” como comprado',
      );
    } catch (error) {
      if (mounted) setState(() => item.completed = previous);
      _handleSyncError(error);
    }
  }

  Future<void> _restoreItem(int index, _CartItem removed) async {
    try {
      final stored = await HouseholdDataService.upsert(
        section: 'cart',
        householdName: widget.householdName,
        householdId: widget.householdId,
        data: removed.toJson(),
      );
      if (!mounted) return;
      setState(
        () => _items.insert(
          index.clamp(0, _items.length),
          _CartItem.fromJson(stored),
        ),
      );
      await _record('restauró “${removed.name}” en la cesta');
    } catch (error) {
      _handleSyncError(error);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleSyncError(Object error) {
    debugPrint('Error al sincronizar la cesta: $error');
    if (mounted) _showMessage('No se ha podido sincronizar el cambio.');
  }

  Future<void> _movePurchasedToInventory() async {
    final purchased = _items.where((item) => item.completed).toList();
    if (purchased.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay productos marcados como comprados'),
        ),
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Guardar en despensa'),
        content: Text(
          'Se incorporarán ${purchased.length} productos al inventario y se retirarán de la cesta.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final inventory = await HouseholdDataService.load(
      section: 'inventory',
      householdName: widget.householdName,
      householdId: widget.householdId,
      localDefaults: const [],
    );
    for (final item in purchased) {
      final index = inventory.indexWhere(
        (product) =>
            (product['name'] as String).trim().toLowerCase() ==
            item.name.trim().toLowerCase(),
      );
      if (index == -1) {
        inventory.add({
          'name': item.name,
          'units': item.units,
          'amount': item.amount,
          'measurementUnit': item.measurementUnit,
          'expirationDate': null,
        });
      } else {
        final product = inventory[index];
        product['units'] = (product['units'] as int) + item.units;
        product['amount'] ??= item.amount;
        product['measurementUnit'] ??= item.measurementUnit;
      }
    }
    setState(() => _items.removeWhere((item) => item.completed));
    await HouseholdDataService.saveMany(
      householdName: widget.householdName,
      householdId: widget.householdId,
      sections: {
        'inventory': inventory,
        'cart': _items.map((item) => item.toJson()).toList(),
      },
    );
    if (!mounted) return;
    widget.onInventoryChanged?.call();
    await _record('incorporó ${purchased.length} productos a la despensa');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Compra incorporada a la despensa')),
    );
  }

  Future<void> _clearCart() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vaciar cesta'),
        content: Text(
          'Se eliminarán los ${_items.length} productos de la cesta.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Vaciar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await HouseholdDataService.save(
        section: 'cart',
        householdName: widget.householdName,
        householdId: widget.householdId,
        data: const [],
      );
      if (!mounted) return;
      setState(() => _items.clear());
      await _record('vació la cesta');
      _showMessage('Cesta vaciada');
    } catch (error) {
      _handleSyncError(error);
    }
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

class _CartItemForm extends StatefulWidget {
  const _CartItemForm({this.initialItem});
  final _CartItem? initialItem;

  @override
  State<_CartItemForm> createState() => _CartItemFormState();
}

class _CartItemFormState extends State<_CartItemForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _unitsController;
  late final TextEditingController _amountController;
  late String _measurementUnit;

  @override
  void initState() {
    super.initState();
    final item = widget.initialItem;
    _nameController = TextEditingController(text: item?.name ?? '');
    _unitsController = TextEditingController(
      text: item?.units.toString() ?? '1',
    );
    _amountController = TextEditingController(
      text: _formatAmount(item?.amount),
    );
    _measurementUnit = item?.measurementUnit ?? 'g';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _unitsController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.initialItem == null
                    ? 'Añadir a la cesta'
                    : 'Editar elemento',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              AppTextField(
                controller: _nameController,
                label: 'Nombre',
                hintText: 'Ej. Arroz',
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Introduce un nombre'
                    : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _unitsController,
                label: 'Unidades',
                hintText: 'Ej. 3',
                suffixText: 'uds.',
                keyboardType: TextInputType.number,
                validator: (value) {
                  final units = int.tryParse(value?.trim() ?? '');
                  return units == null || units <= 0
                      ? 'Introduce un número de unidades válido'
                      : null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _amountController,
                label: 'Cantidad (opcional)',
                hintText: 'Ej. 500',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return null;
                  final amount = double.tryParse(text.replaceAll(',', '.'));
                  return amount == null || amount < 0
                      ? 'Introduce una cantidad válida'
                      : null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _measurementUnit,
                decoration: const InputDecoration(
                  labelText: 'Unidad de medida',
                ),
                items: const [
                  DropdownMenuItem(value: 'g', child: Text('Gramos (g)')),
                  DropdownMenuItem(value: 'kg', child: Text('Kilogramos (kg)')),
                  DropdownMenuItem(value: 'ml', child: Text('Mililitros (ml)')),
                  DropdownMenuItem(value: 'l', child: Text('Litros (l)')),
                ],
                onChanged: (value) {
                  if (value != null) _measurementUnit = value;
                },
              ),
              const SizedBox(height: 24),
              AppPrimaryButton(
                label: widget.initialItem == null
                    ? 'Añadir elemento'
                    : 'Guardar cambios',
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final amountText = _amountController.text.trim().replaceAll(',', '.');
    Navigator.pop(
      context,
      _CartItem(
        id: widget.initialItem?.id,
        name: _nameController.text.trim(),
        units: int.parse(_unitsController.text.trim()),
        amount: amountText.isEmpty ? null : double.parse(amountText),
        measurementUnit: _measurementUnit,
        completed: widget.initialItem?.completed ?? false,
      ),
    );
  }

  String _formatAmount(double? amount) {
    if (amount == null) return '';
    return amount == amount.roundToDouble()
        ? amount.toInt().toString()
        : amount.toString();
  }
}

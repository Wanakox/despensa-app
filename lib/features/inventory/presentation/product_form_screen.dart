import 'package:flutter/material.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';

class ProductFormData {
  const ProductFormData({
    this.id,
    required this.name,
    required this.units,
    this.amount,
    this.measurementUnit = 'g',
    this.expirationDate,
  });
  final String? id;
  final String name;
  final int units;
  final double? amount;
  final String measurementUnit;
  final DateTime? expirationDate;

  factory ProductFormData.fromJson(Map<String, dynamic> json) {
    return ProductFormData(
      id: json['_id'] as String?,
      name: json['name'] as String,
      units: json['units'] as int,
      amount: (json['amount'] as num?)?.toDouble(),
      measurementUnit: json['measurementUnit'] as String? ?? 'g',
      expirationDate: json['expirationDate'] == null
          ? null
          : DateTime.parse(json['expirationDate'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) '_id': id,
    'name': name,
    'units': units,
    'amount': amount,
    'measurementUnit': measurementUnit,
    'expirationDate': expirationDate?.toIso8601String(),
  };
}

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({this.initialData, super.key});
  final ProductFormData? initialData;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _unitsController;
  late final TextEditingController _amountController;
  late String _measurementUnit;
  DateTime? _expirationDate;

  @override
  void initState() {
    super.initState();
    final product = widget.initialData;
    _nameController = TextEditingController(text: product?.name ?? '');
    _unitsController = TextEditingController(
      text: product?.units.toString() ?? '1',
    );
    _amountController = TextEditingController(
      text: _formatAmount(product?.amount),
    );
    _measurementUnit = product?.measurementUnit ?? 'g';
    _expirationDate = product?.expirationDate;
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
    final isEditing = widget.initialData != null;
    return Material(
      color: Colors.transparent,
      child: Padding(
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isEditing ? 'Editar producto' : 'Añadir producto',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Cerrar',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                AppTextField(
                  controller: _nameController,
                  label: 'Nombre del producto',
                  hintText: 'Ej. Yogur griego',
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Introduce un nombre'
                      : null,
                ),
                const SizedBox(height: 20),
                AppTextField(
                  controller: _unitsController,
                  label: 'Unidades',
                  hintText: 'Ej. 3',
                  suffixText: 'uds.',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final units = int.tryParse(value?.trim() ?? '');
                    return units == null || units < 0
                        ? 'Introduce un número de unidades válido'
                        : null;
                  },
                ),
                const SizedBox(height: 20),
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
                    final quantity = double.tryParse(text.replaceAll(',', '.'));
                    return quantity == null || quantity < 0
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
                    DropdownMenuItem(
                      value: 'kg',
                      child: Text('Kilogramos (kg)'),
                    ),
                    DropdownMenuItem(
                      value: 'ml',
                      child: Text('Mililitros (ml)'),
                    ),
                    DropdownMenuItem(value: 'l', child: Text('Litros (l)')),
                  ],
                  onChanged: (value) {
                    if (value != null) _measurementUnit = value;
                  },
                ),
                const SizedBox(height: 20),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Fecha de caducidad (opcional)'),
                  subtitle: Text(
                    _expirationDate == null
                        ? 'Sin fecha seleccionada'
                        : _formatDate(_expirationDate!),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_expirationDate != null)
                        IconButton(
                          tooltip: 'Quitar fecha',
                          onPressed: () =>
                              setState(() => _expirationDate = null),
                          icon: const Icon(Icons.close),
                        ),
                      IconButton(
                        tooltip: 'Seleccionar fecha',
                        onPressed: _selectDate,
                        icon: const Icon(Icons.calendar_today_outlined),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                AppPrimaryButton(
                  label: isEditing ? 'Guardar cambios' : 'Añadir producto',
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _expirationDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );
    if (date != null) setState(() => _expirationDate = date);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final amountText = _amountController.text.trim().replaceAll(',', '.');
    Navigator.of(context).pop(
      ProductFormData(
        id: widget.initialData?.id,
        name: _nameController.text.trim(),
        units: int.parse(_unitsController.text.trim()),
        amount: amountText.isEmpty ? null : double.parse(amountText),
        measurementUnit: _measurementUnit,
        expirationDate: _expirationDate,
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  String _formatAmount(double? amount) {
    if (amount == null) return '';
    return amount == amount.roundToDouble()
        ? amount.toInt().toString()
        : amount.toString();
  }
}

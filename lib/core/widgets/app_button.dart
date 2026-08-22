import 'package:flutter/material.dart';

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({required this.label, required this.onPressed, this.icon, this.loading = false, super.key});

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final labelWidget = loading
        ? const SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
        : Text(label);
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: icon == null
          ? FilledButton(onPressed: loading ? null : onPressed, child: labelWidget)
          : FilledButton.icon(onPressed: loading ? null : onPressed, icon: Icon(icon), label: labelWidget),
    );
  }
}

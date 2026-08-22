import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({required this.label, this.hintText, this.controller, this.keyboardType, this.obscureText = false, this.prefixIcon, this.suffixIcon, super.key});

  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(hintText: hintText, prefixIcon: prefixIcon == null ? null : Icon(prefixIcon), suffixIcon: suffixIcon),
        ),
      ],
    );
  }
}

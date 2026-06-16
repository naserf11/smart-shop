import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextEditingController? controller;

  // 1. New parameters added for the refactored login screen
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool enabled;

  const CustomTextField({
    super.key,
    required this.hint,
    this.prefixIcon,
    this.obscureText = false,
    this.controller,
    // 2. Initialize the new parameters (enabled defaults to true)
    this.keyboardType,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    // 3. Swapped TextField for TextFormField to enable validation features
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      ),
    );
  }
}

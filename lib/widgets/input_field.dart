import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool isMultiline;
  final int? maxLines;

  const InputField({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.validator,
    this.isMultiline = false,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        validator: validator,
        maxLines: isMultiline ? (maxLines ?? 3) : 1,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          alignLabelWithHint: isMultiline,
        ),
      ),
    );
  }
} 
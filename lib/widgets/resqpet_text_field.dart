import 'package:flutter/material.dart';

class ResQPetTextField extends StatelessWidget {

  final String label;
  final TextInputType textInputType;
  final TextEditingController? controller;
  final Icon? prefixIcon;
  final String? Function(String? value)? validator;
  final int maxLines;
  final int? maxLength;

  const ResQPetTextField({
    super.key,
    required this.label,
    this.textInputType = TextInputType.text,
    this.controller,
    this.validator,
    this.prefixIcon,
    this.maxLength,
    this.maxLines = 1
  });

  @override
  Widget build(BuildContext context) {

    return TextFormField(
      controller: controller,
      keyboardType: textInputType,
      maxLines: 1,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefixIcon,
        border: OutlineInputBorder(),
        filled: true,
      ),
      validator: validator,
    );
  }
}
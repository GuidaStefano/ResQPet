import 'package:flutter/material.dart';

class ResQPetTextField extends StatelessWidget {

  final String label;
  final TextInputType textInputType;
  final TextEditingController? controller;
  final Icon? prefixIcon;
  final String? Function(String? value)? validator;

  const ResQPetTextField({
    super.key,
    required this.label,
    this.textInputType = TextInputType.text,
    this.controller,
    this.validator,
    this.prefixIcon
  });

  @override
  Widget build(BuildContext context) {

    return TextFormField(
      controller: controller,
      keyboardType: textInputType,
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
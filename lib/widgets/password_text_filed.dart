import 'package:flutter/material.dart';

class PasswordTextField extends StatefulWidget {

  final String label;
  final TextEditingController? controller;
  final String? Function(String? value)? validator;

  const PasswordTextField({
    super.key,
    this.label = 'Password',
    this.controller,
    this.validator
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {

  bool isObscured = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: isObscured,
      decoration: InputDecoration(
        labelText: widget.label,
        suffixIcon: IconButton(
          icon: Icon(
            isObscured 
              ? Icons.visibility_off
              : Icons.visibility
          ),
          onPressed: () {
            setState(() => isObscured = !isObscured);
          }
        ),
        prefixIcon: Icon(Icons.lock_outline),
        border: OutlineInputBorder(),
        filled: true,
      ),
      validator: widget.validator,
    );
  }
}
import 'package:flutter/material.dart';

class PhoneNumberInput extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final InputDecoration? decoration;

  const PhoneNumberInput({
    Key? key,
    required this.controller,
    this.validator,
    this.decoration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: decoration,
      keyboardType: TextInputType.phone,
      validator: validator ??
          (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Ce champ est requis';
            }
            return null;
          },
    );
  }
}

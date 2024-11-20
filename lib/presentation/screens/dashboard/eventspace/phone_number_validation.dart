import 'package:flutter/material.dart';

class PhoneNumberInput extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const PhoneNumberInput({
    Key? key,
    required this.controller,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Numéro de téléphone',
      ),
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

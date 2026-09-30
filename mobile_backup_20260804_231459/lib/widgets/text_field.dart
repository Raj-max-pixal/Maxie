import 'package:flutter/material.dart';
import '../theme/app_constants.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    this.controller,
    this.hintText,
    this.obscureText = false,
  });

  final TextEditingController? controller;
  final String? hintText;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius_12),
        ),
      ),
    );
  }
}

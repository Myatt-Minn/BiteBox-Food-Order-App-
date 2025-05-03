import 'package:flutter/material.dart';
import 'package:foodorderapplication/utils/consts.dart';

class TextFieldInput extends StatelessWidget {
  final TextEditingController textEditingController;
  final String hint;
  final bool isPass;
  final TextInputType keyboardtype;

  const TextFieldInput({
    super.key,
    required this.textEditingController,
    required this.hint,
    this.isPass = false,
    required this.keyboardtype,
  });

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderSide: Divider.createBorderSide(context),
    );
    return TextField(
      controller: textEditingController,
      decoration: InputDecoration(
        hintText: hint,
        border: inputBorder,
        focusedBorder: inputBorder,
        focusColor: primaryColor,
        enabledBorder: inputBorder,
        filled: true,
        contentPadding: const EdgeInsets.all(8),
      ),
      keyboardType: keyboardtype,
      obscureText: isPass,
    );
  }
}

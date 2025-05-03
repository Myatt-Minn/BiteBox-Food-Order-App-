import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

pickAnImage(ImageSource source) async {
  final ImagePicker picker = ImagePicker();

  XFile? file = await picker.pickImage(source: source);

  if (file != null) {
    return await file.readAsBytes();
  }
  return "No image found";
}

showSnakBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(content),
  ));
}

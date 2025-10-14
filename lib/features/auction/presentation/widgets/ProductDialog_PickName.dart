import 'package:flutter/material.dart';

class ProductDialogPickName extends StatelessWidget {
  const ProductDialogPickName({super.key, required this.setName});
  final Function(String) setName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: "Product Name",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onChanged: (String str) {
          setName(str);
        },
      ),
    );
  }
}

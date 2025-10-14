import 'package:flutter/material.dart';

class ProductDialogPickDescr extends StatelessWidget {
  const ProductDialogPickDescr({super.key, required this.setDescr});
  final Function(String) setDescr;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: "Product Description",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onChanged: (String str) {
          setDescr(str);
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProductDialogPickPrice extends StatelessWidget {
  const ProductDialogPickPrice({super.key, required this.setPrice});
  final Function(double) setPrice;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ],
          decoration: InputDecoration(
            labelText: "Start Price",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onChanged: (String str) {
            setPrice(double.parse(str));
          }),
    );
  }
}

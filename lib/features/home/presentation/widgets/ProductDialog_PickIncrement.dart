import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProductDialogPickIncrement extends StatelessWidget {
  const ProductDialogPickIncrement({super.key, required this.setIncrease});
  final Function(double) setIncrease;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
          keyboardType: TextInputType.numberWithOptions(),
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp("[0-9]+.?[0-9]?"))
          ],
          decoration: InputDecoration(
            labelText: "Price Increment",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onChanged: (String str) {
            setIncrease(double.parse(str));
          }),
    );
  }
}

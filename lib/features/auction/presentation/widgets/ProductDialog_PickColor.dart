import 'package:flutter/material.dart';
import 'package:streaming/shared/data/models/enums.dart';

class ProductDialogPickColor extends StatefulWidget {
  const ProductDialogPickColor({
    super.key,
    required this.setColor,
  });
  final Function(SimpleColor) setColor;

  @override
  State<ProductDialogPickColor> createState() => _PickColorState();
}

class _PickColorState extends State<ProductDialogPickColor> {
  SimpleColor? selectedColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownMenu<SimpleColor>(
        initialSelection: SimpleColor.other,
        requestFocusOnTap: true,
        label: const Text('Color'),
        onSelected: (SimpleColor? color) {
          setState(() {
            selectedColor = color;
          });
          widget.setColor(color!);
        },
        dropdownMenuEntries: SimpleColor.values
            .map<DropdownMenuEntry<SimpleColor>>((SimpleColor color) {
          return DropdownMenuEntry<SimpleColor>(
            value: color,
            label: color.name,
            enabled: color.name != 'Grey',
          );
        }).toList(),
      ),
    );
  }
}

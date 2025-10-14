import 'package:flutter/material.dart';
import 'package:streaming/features/home/data/models/enums.dart';

class ProductDialogPickSize extends StatefulWidget {
  const ProductDialogPickSize({
    super.key,
    required this.setSize,
  });
  final Function(ClothingSize) setSize;

  @override
  State<ProductDialogPickSize> createState() => _PickSizeState();
}

class _PickSizeState extends State<ProductDialogPickSize> {
  ClothingSize? selectedColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownMenu<ClothingSize>(
        initialSelection: ClothingSize.M,
        requestFocusOnTap: true,
        label: const Text('Product size'),
        onSelected: (ClothingSize? size) {
          setState(() {
            selectedColor = size;
          });
          widget.setSize(size!);
        },
        dropdownMenuEntries: ClothingSize.values
            .map<DropdownMenuEntry<ClothingSize>>((ClothingSize size) {
          return DropdownMenuEntry<ClothingSize>(
            value: size,
            label: size.name,
          );
        }).toList(),
      ),
    );
  }
}
